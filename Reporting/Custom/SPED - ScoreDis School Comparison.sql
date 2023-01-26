USE pocatello
GO

DECLARE @eYear INT;
SET @eYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END;

SELECT p.personID,
	i.lastName + ', ' + i.firstName AS 'studentName',
	sch.comments AS 'attendingSchool',
	sch1.comments AS 'homeSchool'
FROM Enrollment AS e
	INNER JOIN [Identity] AS i ON i.personID = e.personID
	INNER JOIN Person AS p ON p.currentIdentityID = i.identityID AND i.personID = p.personID
	INNER JOIN CustomStudent AS cs ON cs.enrollmentID = e.enrollmentID AND cs.attributeID = 903
	INNER JOIN Calendar AS cal ON cal.calendarID = e.calendarID AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID AND hm.[secondary] = 0 AND (hm.endDate IS NULL OR GETDATE() <= hm.endDate)
	INNER JOIN Household AS h ON hm.householdID = h.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID AND hl.[secondary] = 0 AND (hl.endDate IS NULL OR GETDATE() <= hl.endDate)
	INNER JOIN [Address] AS a ON a.addressID = hl.addressID
	INNER JOIN SchoolBoundary AS sb ON sb.addressID = a.addressID AND sb.schoolID != cal.schoolID AND
		CASE 
			WHEN sb.schoolID BETWEEN 1 AND 14 THEN 'EL' 
			WHEN sb.schoolID IN (15,16,17,21,28) THEN 'MS'
			WHEN sb.schoolID IN (18,19,20,22) THEN 'HS' END
		= 
		CASE
			WHEN cal.schoolID BETWEEN 1 AND 14 THEN 'EL' 
			WHEN cal.schoolID IN (15,16,17,21,28) THEN 'MS'
			WHEN cal.schoolID IN (18,19,20,22) THEN 'HS' END
	INNER JOIN School AS sch1 ON sch1.schoolID = sb.schoolID

WHERE e.endYear = @eYear
	--AND e.active = 1 
	--AND (e.endDate IS NULL OR GETDATE() <= e.endDate)
ORDER BY attendingSchool