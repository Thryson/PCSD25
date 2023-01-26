USE pocatello

DECLARE @eYear INT;
SET @eYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END;

SELECT DISTINCT p.personID AS 'Child Local ID', 
	p.stateID AS 'Child EDUID', 
	'' AS 'Child DHW Case Num', 
	i.firstName AS 'Child First Name', 
	ISNULL (i.middleName, '') AS 'Child Middle Name', 
	i.lastName AS 'Child Last Name', 
	i.gender AS 'Child Gender (M/F)', 
	ISNULL(CONVERT(VARCHAR(10), i.birthdate, 101), '') AS 'Child Date Of Birth', 
	ISNULL(a.number + ' ' + a.street + ' ' + ISNULL ('Apt' + ' ' + a.apt, ''), '') AS 'Child Address', 
	ISNULL(a.zip, '') AS 'Child Zip Code', 
	ISNULL(h.phone, '') AS 'Child Phone', 
	'' AS 'Caregiver1 First Name', 
	'' AS 'Caregiver1 Last Name',  
	'' AS 'Caregiver2 First Name', 
	'' AS 'Caregiver2 Last Name'
FROM Enrollment AS en
	INNER JOIN [Identity] AS i ON en.personID = i.personID
	INNER JOIN Person AS p ON p.currentIdentityID = i.identityID 
		AND p.personID = i.personID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	LEFT JOIN HouseholdMember AS hm ON hm.personID = p.personID 
		AND hm.endDate IS NULL AND hm.[secondary] = 0
	LEFT JOIN Household AS h ON h.householdID = hm.householdID
	LEFT JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID 
		AND hl.endDate IS NULL and hl.[secondary] = 0
	LEFT JOIN [Address] AS a ON a.addressID = hl.addressID
WHERE en.endYear = @eYear
	AND en.active = 1
	AND en.grade != 'NG'
	AND (GETDATE() BETWEEN en.startDate AND en.endDate OR en.endDate IS NULL)
	AND en.serviceType = 'P'