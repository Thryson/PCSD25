USE pocatello

DECLARE @eYear int, @cDay date;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;



SELECT p.personID,
	sch.comments,
	CASE hl.[secondary]
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'		
	END AS 'secondaryAddress',
	ad.number,
	ad.street
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endyear = 2020
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
		AND (hm.endDate IS NULL OR GETDATE() BETWEEN hm.startDate AND hm.endDate)
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND (hl.endDate IS NULL OR GETDATE() BETWEEN hl.startDate AND hl.endDate)
	INNER JOIN [Address] AS ad ON ad.addressID = hl.addressID
WHERE ad.number LIKE 'RR %'
	AND en.serviceType = 'P'
	AND (en.endDate IS NULL OR GETDATE() BETWEEN en.startDate AND en.endDate)
	AND en.endYear = 2020
ORDER BY hl.[secondary]


SELECT p.personID,
	id.lastName + ', ' + id.firstName AS 'name',
	sch.comments AS 'school',
	CASE 
		WHEN ad.[state] = 'ID' THEN ISNULL(els.comments, 'ERROR') 
		ELSE ''
		END AS 'elementarySchool',
	CASE 
		WHEN ad.[state] = 'ID' THEN ISNULL(mss.comments, 'ERROR') 
		ELSE ''
		END AS 'middleSchool',
	CASE 
		WHEN ad.[state] = 'ID' THEN ISNULL(hss.comments, 'ERROR') 
		ELSE ''	 
		END AS 'highSchool'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endyear = 2020
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
		AND hm.[secondary] = 0
		AND (hm.endDate IS NULL OR GETDATE() BETWEEN hm.startDate AND hm.endDate)
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND hl.[secondary] = 0
		AND (hl.endDate IS NULL OR GETDATE() BETWEEN hl.startDate AND hl.endDate)
	INNER JOIN [Address] AS ad ON ad.addressID = hl.addressID
	LEFT JOIN SchoolBoundary AS el ON el.addressID = ad.addressID AND el.schoolID IN (1,2,3,4,5,6,8,9,10,11,12,13,14)
	LEFT JOIN School AS els ON els.schoolID = el.schoolID
	LEFT JOIN SchoolBoundary AS ms ON ms.addressID = ad.addressID AND ms.schoolID IN (15,16,17,28)
	LEFT JOIN School AS mss ON mss.schoolID = ms.schoolID
	LEFT JOIN SchoolBoundary As hs ON hs.addressID = ad.addressID AND hs.schoolID IN (18,19,20)
	LEFT JOIN School AS hss ON hss.schoolID = hs.schoolID
WHERE en.serviceType = 'P'
	AND (en.endDate IS NULL OR GETDATE() BETWEEN en.startDate AND en.endDate)
	AND en.endYear = 2020
	AND (el.schoolID IS NULL OR ms.schoolID IS NULL OR hs.schoolID IS NULL)
ORDER BY hl.[secondary]
