USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Modder:		<Lopez, Michael>
-- Create date: <05/21/2019>
-- Update date: <01/26/2023>
-- Description:	<Compile all existing census error reports into view>
-- =============================================


--==============================
--
--	Guardian Errors Code; GU---
--
--==============================


--Error	==================================
--Code  || Guardian Multiple Households ||
--GU001	==================================

SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hm.modifiedDate, hm.householdID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'guardianName' AS 'searchType'
		,'search>household>members' AS 'searchLocation'
		,'GU001' AS 'localCode'
		,'error' AS 'status'
		,'guardianMultipleHouseholdMembership' AS 'type'
		,rp.personID2 AS 'personID'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
			AND rp.guardian = 1
			AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
				OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN [Identity] AS id ON id.personID = rp.personID2
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
			AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
				OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
	WHERE en.serviceType = 'P'
		AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.duplicateNumber != 1


UNION ALL


--Error	=========================================
--Code  || Guardian Multiple Primary Addresses ||
--GU002	=========================================

SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM ( 
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'guardianName' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,'GU002' AS 'localCode'
		,'error' AS 'status'
		,'guardianMultiplePrimaryAddresses' AS 'type'
		,rp.personID2 AS 'personID'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
			AND rp.guardian = 1
			AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
				OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN [Identity] AS id ON id.personID = rp.personID2
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
			AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
				OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.[secondary] = 0
			AND (GETDATE() BETWEEN hl.startDate AND hl.endDate
				OR (GETDATE() > hl.startDate AND hl.endDate IS NULL))
	WHERE en.serviceType = 'P'
		AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.duplicateNumber != 1


UNION ALL


--Error	=========================================
--Code  || Guardian Multiple Mailing Addresses ||
--GU003	=========================================
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'guardianName' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,'GU003' AS 'localCode'
		,'error' AS 'status'
		,'guardianMultipleMailingAddresses' AS 'type'
		,rp.personID2 AS 'personID'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
			AND rp.guardian = 1
			AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
				OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN [Identity] AS id ON id.personID = rp.personID2
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
			AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
				OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.mailing = 1
			AND (GETDATE() BETWEEN hl.startDate AND hl.endDate
				OR (GETDATE() > hl.startDate AND hl.endDate IS NULL))
	WHERE en.serviceType = 'P'
		AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.duplicateNumber != 1


UNION ALL


--Error	===========================
--Code  || Guardian No Birthdate ||
--GU004	===========================
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'guardianName' AS 'searchType'
	,'serach>allPeople>demographics' AS 'searchLocation'
	,'HH002' AS 'localCode'
	,'incomplete' AS 'status'
	,'guardianNoBirthdate' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.guardian = 1
		AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
			OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE id.birthdate IS NULL
	AND en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))


UNION ALL


--==============================
--
--	Household Errors; Code HH---
--
--==============================


--Error	=================================
--Code  || Household No Primary Address||
--HH001	=================================

SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>household' AS 'searchLocation'
	,'HH001' AS 'localCode'
	,'error' AS 'status'
	,'householdNoPrimaryAddress' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN HouseholdMember AS hm ON hm.personID = en.personID
		AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
			OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	LEFT JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND hl.[secondary] = 0
		AND (GETDATE() BETWEEN hl.startDate AND hl.endDate
			OR (GETDATE() > hl.startDate AND hl.endDate IS NULL))
WHERE hl.addressID IS NULL
	AND en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))


UNION ALL


--This report was limited down to just Guardians, this slot is open for another report
--Error	==========
--Code  || ---- ||
--HH002	==========



--Error	=================================
--Code  || Household Member Name Sytax ||
--HH003	=================================

SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentsHouseholdMemberName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,'HH003' AS 'localCode'
	,'warning' AS 'status'
	,'householdMemberNameSyntax' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID1
		AND hm.[private] = 0
		AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
			OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdMember AS hm2 ON hm2.personID = rp.personID2
		AND hm2.[private] = 0
		AND (GETDATE() BETWEEN hm2.startDate AND hm2.endDate
			OR (GETDATE() > hm2.startDate AND hm2.endDate IS NULL))
	INNER JOIN Household AS h2 ON h2.householdID = hm2.householdID
	INNER JOIN [Identity] AS id ON id.personID = hm2.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE h.householdID = h2.householdID
	AND en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND (id.firstName LIKE '%[!@#$%^&*()0123456789-_=+{}\|;:",.<>/?]%'
		OR id.middleName LIKE '%[!@#$%^&*()0123456789-_=+{}\|;:",.<>/?]%'
		OR id.lastName LIKE '%[!@#$%^&*()0123456789-_=+{}\|;:",.<>/?]%'
		OR LEN(id.firstName) != LEN(REVERSE(id.firstName))
		OR LEN(id.middleName) != LEN(REVERSE(id.middleName))
		OR LEN(id.lastName) != LEN(REVERSE(id.lastName))
		OR RIGHT(id.firstName, 3) IN (' Jr', ' Sr', ' I', ' III', ' III', ' IV', ' V')
		OR RIGHT(id.middleName, 3) IN (' Jr', ' Sr', ' I', ' III', ' III', ' IV', ' V')
		OR RIGHT(id.lastName, 3) IN (' Jr', ' Sr', ' I', ' III', ' III', ' IV', ' V')
		)


UNION ALL


--==============================
--
--	Student Errors; Code ST---
--
--==============================

--Error	=========================
--Code  || Student No Birthdate||
--ST001	=========================

SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>student>demographics' AS 'searchLocation'
	,'ST001' AS 'localCode'
	,'error' AS 'status'
	,'studentNoBirthdate' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE id.birthdate IS NULL
	AND en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))


UNION ALL


--Error	========================
--Code  || Student Name Syntax||
--ST002	========================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>student>demographics' AS 'searchLocation'
	,'ST002' AS 'localCode'
	,'warning' AS 'status'
	,'studentNameSyntax' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND (id.firstName LIKE '%[!@#$%^&*()0123456789-_=+{}\|;:",.<>/?]%'
		OR id.middleName LIKE '%[!@#$%^&*()0123456789-_=+{}\|;:",.<>/?]%'
		OR id.lastName LIKE '%[!@#$%^&*()0123456789-_=+{}\|;:",.<>/?]%'
		OR LEN(id.firstName) != LEN(REVERSE(id.firstName))
		OR LEN(id.middleName) != LEN(REVERSE(id.middleName))
		OR LEN(id.lastName) != LEN(REVERSE(id.lastName))
		OR RIGHT(id.firstName, 3) IN (' Jr', ' Sr', ' I', ' III', ' III', ' IV', ' V')
		OR RIGHT(id.middleName, 3) IN (' Jr', ' Sr', ' I', ' III', ' III', ' IV', ' V')
		OR RIGHT(id.lastName, 3) IN (' Jr', ' Sr', ' I', ' III', ' III', ' IV', ' V')
		)


UNION ALL


--This report was consolidated down to a single query, this slot is open for another report
--Error	==========
--Code  || ---- ||
--ST002	==========




--Error	=================================
--Code  || Student Incomplete Relation ||
--ST003	=================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>allPeople>relationships' AS 'searchLocation'
	,'ST003' AS 'localCode'
	,'incomplete' AS 'status'
	,CASE
		WHEN rp.startDate IS NULL 
			AND (rp.[name] LIKE 'Mother & Father' OR rp.[name] IS NULL) THEN 'noRelationType, noRelationStartDate'
		WHEN rp.startDate IS NULL 
			AND (rp.[name] NOT LIKE 'Mother & Father' OR rp.[name] IS NOT NULL) THEN 'noRelationStartDate'
		WHEN rp.startDate IS NOT NULL 
			AND (rp.[name] LIKE 'Mother & Father' OR rp.[name] IS NULL) THEN 'noRelationType'
	END AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = p.personID
		AND (rp.endDate IS NULL
			OR GETDATE() < rp.endDate)
		AND (rp.startDate IS NULL 
			OR rp.[name] LIKE 'Mother & Father'
			OR rp.[name] IS NULL )
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))


UNION ALL


--Error	=========================
--Code  || Student No Guardian ||
--ST004	=========================
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
		SELECT DISTINCT p.studentNumber AS 'searchableField'
			,'studentNumber' AS 'searchType'
			,'search>allPeople>relationships' AS 'searchLocation'
			,'ST004' AS 'localCode'
			,'error' AS 'status'
			,'studentNoGuardians' AS 'type'
			,p.personID
			,cal.calendarID
			,sch.comments AS 'school'
			,0 AS 'stateReporting'
			,COUNT(*) AS 'alt'
		FROM Enrollment AS en
			INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
				AND cal.schoolID NOT IN (29,31) --Not JDC Schools
			INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
			INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
			INNER JOIN [Identity] AS id ON id.personID = en.personID
			INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
				AND p.personID = id.personID
			LEFT JOIN RelatedPair AS rp ON rp.personID1 = p.personID 
				AND rp.guardian = 1
				AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
					OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
		WHERE en.serviceType = 'P'
			AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
		GROUP BY id.lastName + ', ' + id.firstName
			,p.studentNumber
			,p.personID
			,cal.calendarID
			,sch.comments
		HAVING COUNT(*) = 1
	) AS x

UNION ALL


--Error	============================================
--Code  || Student Multiple Primary Memberships ||
--ST005	============================================
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hm.modifiedDate, hm.householdID DESC) AS 'duplicateNumber'
		,p.studentNumber AS 'searchableField'
		,'studentNumber' AS 'searchType'
		,'search>household>members' AS 'searchLocation'
		,'ST005' AS 'localCode'
		,'error' AS 'status'
		,'studentMultiplePrimaryMembership' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
			AND hm.[secondary] = 0
			AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
				OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
	WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.duplicateNumber != 1


UNION ALL


--Error	========================================
--Code  || Student Multiple Primary Addresses ||
--ST006	========================================
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,p.studentNumber AS 'searchableField'
		,'studentNumber' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,'ST006' AS 'localCode'
		,'error' AS 'status'
		,'studentMultiplePrimaryAddresses' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
			AND hm.[secondary] = 0
			AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
				OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.[secondary] = 0
			AND (GETDATE() BETWEEN hl.startDate AND hl.endDate
				OR (GETDATE() > hl.startDate AND hl.endDate IS NULL))
	WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.duplicateNumber != 1


UNION ALL


--Error	========================================
--Code  || Student Multiple Mailing Addresses ||
--ST007	========================================
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,p.studentNumber AS 'searchableField'
		,'studentNumber' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,'ST007' AS 'localCode'
		,'error' AS 'status'
		,'studentMultipleMailingAddresses' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
			AND hm.[secondary] = 0
			AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
				OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.mailing = 1
			AND (GETDATE() BETWEEN hl.startDate AND hl.endDate
				OR (GETDATE() > hl.startDate AND hl.endDate IS NULL))
	WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.duplicateNumber != 1


UNION ALL


--Error	=====================================
--Code  || Student More Than Two Guardians ||
--ST008	=====================================
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY p.personID, rp.personID2 DESC) AS 'duplicateNumber'
		,p.studentNumber AS 'searchableField'
		,'studentNumber' AS 'searchType'
		,'search>allPeople>relationships' AS 'searchLocation'
		,'ST008' AS 'localCode'
		,'warning' AS 'status'
		,'studentMoreThanTwoGuardians' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN RelatedPair AS rp oN rp.personID1 = p.personID
			AND rp.guardian = 1
			AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
				OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
	WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.duplicateNumber >= 3


UNION ALL


--Error	====================================
--Code  || Student With Underage Guardian ||
--ST009	====================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>allPeople>relationships' AS 'searchLocation'
	,'ST009' AS 'localCode'
	,'error' AS 'status'
	,'studentWithUnderageGuardian' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID
		AND p.personID = id.personID
	INNER JOIN RelatedPair AS rp ON p.personID = rp.personID1
		AND rp.guardian = 1
		AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
			OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN Person AS p2 ON p2.personID = rp.personID2
	INNER JOIN [Identity] AS id2 ON id2.personID = p2.personID
		AND id2.identityID = p2.currentIdentityID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND ((0 + CONVERT(CHAR(8), GETDATE(), 112) - CONVERT(CHAR(8), id2.birthdate, 112)) / 10000) < 18


UNION ALL


--DID NOT RECIEVE RE-WRITE ON LAST UPDATE
--Error	========================================
--Code  || Student With Nonhousehold Guardian ||
--ST010	========================================
--
--SELECT DISTINCT e.personID AS 'verificationID',
--	e.personID AS 'searchableField',
--	'ST010' AS 'code',
--	'warning' AS 'status',
--	'search>student>relationships' AS 'location',
--	'studentWithNonhouseholdGuardian' AS 'type',
--	NULL AS 'modifiedByID',
--	NULL AS 'modifiedDate'
--FROM Enrollment AS e
--	INNER JOIN [Identity] AS i ON i.personID = e.personID
--	INNER JOIN Person AS p ON p.currentIdentityID = i.identityID 
--		AND p.personID = i.personID
--	INNER JOIN RelatedPair AS rp ON p.personID = rp.personID1
--		AND rp.guardian = 1
--		AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
--			OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
--WHERE e.endyear = @eYear
--	AND rp.relatedPairGUID NOT IN (
--		SELECT rp.relatedPairGUID
--		FROM Household AS h
--		INNER JOIN HouseholdMember AS hm ON hm.householdID = h.householdID 
--			AND hm.enddate IS NULL
--		INNER JOIN RelatedPair AS rp ON hm.personID = rp.personID2 
--			AND rp.guardian = 1
--			AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
--				OR (GETDATE() > rp.startDate AND rp.endDate IS NULL)))


--Error	========================================
--Code  || Student Mulitple Similar Addresses ||
--ST011	========================================
SELECT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
FROM (
	SELECT p.studentNumber AS 'searchableField'
		,'studentNumber' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,'ST011' AS 'localCode'
		,'error' AS 'status'
		,'studentMultipleSimlarAddresses' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
		,a.number
		,a.street
		,a.apt
		,0 AS 'stateReporting'
		,COUNT(*) AS 'alt'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
			AND p.personID = id.personID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID 
			AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
				OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID 
			AND (GETDATE() BETWEEN hl.startDate AND hl.endDate
				OR (GETDATE() > hl.startDate AND hl.endDate IS NULL))
		INNER JOIN [Address] AS a ON a.addressID = hl.addressID
	WHERE en.serviceType = 'P'
		AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	GROUP BY id.lastName + ', ' + id.firstName
		,p.studentNumber
		,p.personID
		,cal.calendarID
		,sch.comments
		,a.number
		,a.street
		,a.apt
	HAVING COUNT(*) >= 2
	) AS x


UNION ALL


--Error	========================================
--Code  || Student Age Outside Of Grade Range ||
--ST012	========================================
SELECT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,1 AS 'stateReporting'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY en.grade DESC, en.startdate DESC) AS 'priority'
		,CASE en.grade
			WHEN '01' THEN 1
			WHEN '02' THEN 2
			WHEN '03' THEN 3
			WHEN '04' THEN 4
			WHEN '05' THEN 5
			WHEN '06' THEN 6
			WHEN '07' THEN 7
			WHEN '08' THEN 8
			WHEN '09' THEN 9
			WHEN '10' THEN 10
			WHEN '11' THEN 11
			WHEN '12' THEN 12
		END AS 'grade'
		,e2.enrollmentID
		,CASE e2.grade
			WHEN '01' THEN 1
			WHEN '02' THEN 2
			WHEN '03' THEN 3
			WHEN '04' THEN 4
			WHEN '05' THEN 5
			WHEN '06' THEN 6
			WHEN '07' THEN 7
			WHEN '08' THEN 8
			WHEN '09' THEN 9
			WHEN '10' THEN 10
			WHEN '11' THEN 11
			WHEN '12' THEN 12
		END AS 'grade2'
		,id.birthdate
		,p.studentNumber AS 'searchableField'
		,'studentNumber' AS 'searchType'
		,'ST012' AS 'localCode'
		,'warning' AS 'status'
		,'search>allPeople>demographics' AS 'searchLocation'
		,'studentAgeOutsideGradeRange' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		LEFT JOIN Enrollment AS e2 ON e2.personID = en.personID
			AND e2.serviceType = 'P'
			AND e2.endYear = en.endYear - 1
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
	WHERE en.serviceType = 'P'
		AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
) AS x
WHERE x.[priority] = 1
	AND ((0 + CONVERT(CHAR(8), GETDATE(), 112) - CONVERT(CHAR(8), x.birthdate, 112)) / 10000) NOT BETWEEN x.grade + 5 AND x.grade + 6
	AND (x.enrollmentID IS NULL OR x.grade NOT BETWEEN x.grade2 AND x.grade2 + 1)


UNION ALL


--Error	====================================
--Code  || Student Incomplete Immigration ||
--ST013	====================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,'ST013' AS 'localCode'
	,'error' AS 'status'
	,'studentIncompleteImmigration' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND ((id.immigrant = 1 AND (id.birthCountry IS NULL OR id.dateEnteredUS IS NULL))
		OR (id.dateEnteredUS IS NOT NULL AND id.immigrant IS NULL))


UNION ALL


--Error	===============================================
--Code  || Student US Citizen with Immigration marked||
--ST014	===============================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,'ST014' AS 'localCode'
	,'warning' AS 'status'
	,'studentUSBirthWithImmigrationData' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND (id.birthCountry = 'US' 
		AND (id.dateEnteredUS IS NOT NULL 
			OR id.dateEnteredUSSchool IS NOT NULL
			OR id.dateEnteredState IS NOT NULL))


UNION ALL


--Error	==========================================================
--Code  || Student with Immigration Marked but no Home Langague ||
--ST015	==========================================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,'ST015' AS 'localCode'
	,'incomplete' AS 'status'
	,'studentImmigrationWithNoHomeLanguage' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND id.immigrant = 1
	AND id.homePrimaryLanguage IS NULL


UNION ALL


--Error	==============================================================
--Code  || Student without Immigration but Immigration Data Entered ||
--ST016	==============================================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,'ST016' AS 'localCode'
	,'warning' AS 'status'
	,'studentNoImmigrationWithImmigrationData' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND ((id.immigrant = 0 OR id.immigrant IS NULL)
		AND id.usCitizen != 'C')
	AND (id.dateEnteredState IS NOT NULL
		OR id.birthCountry NOT IN ('US',''))


UNION ALL


--Error	=====================================
--Code  || Student with Expired Immigration ||
--ST017	======================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,'ST017' AS 'localCode'
	,'error' AS 'status'
	,'studentImmigrationExpired' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND (((0 + CONVERT(CHAR(8), GETDATE(), 112) - CONVERT(CHAR(8), id.dateEnteredUS, 112)) / 10000) > 3
		OR ((0 + CONVERT(CHAR(8), GETDATE(), 112) - CONVERT(CHAR(8), id.dateEnteredUSSchool, 112)) / 10000) > 3
		OR ((0 + CONVERT(CHAR(8), GETDATE(), 112) - CONVERT(CHAR(8), id.dateEnteredState, 112)) / 10000) > 3
		)		


UNION ALL


--==============================
--
--	Relation Errors; Code RE---
--
--==============================

--Error	=========================================
--Code  || Relation Mailing Contact No Address ||
--RE001	=========================================
--Part 1 of 2
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentRelationName' AS 'searchType'
	,'search>allPeople>households' AS 'searchLocation'
	,'RE001' AS 'localCode'
	,'error' AS 'status'
	,'relationMailingContactNoAddress' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.mailing = 1
		AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
			OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	LEFT JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
		AND hm.[secondary] = 0
		AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
			OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND hm.householdID IS NULL


UNION ALL


--Error	=========================================
--Code  || Relation Mailing Contact No Address ||
--RE001	=========================================
--Part 2 of 2
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentRelationName' AS 'searchType'
	,'search>allPeople>households' AS 'searchLocation'
	,'RE001' AS 'localCode'
	,'error' AS 'status'
	,'relationMailingContactNoAddress' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.mailing = 1
		AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
			OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
		AND hm.[secondary] = 0
		AND (GETDATE() BETWEEN hm.startDate AND hm.endDate
			OR (GETDATE() > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	LEFT JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID 
		AND hl.mailing = 1
		AND (GETDATE() BETWEEN hl.startDate AND hl.endDate
			OR (GETDATE() > hl.startDate AND hl.endDate IS NULL))
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND hl.householdID IS NULL


UNION ALL


--Error	=========================================
--Code  || Relation Messenger Contact No Phone ||
--RE002	=========================================
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentRelationName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,'RE002' AS 'localCode'
	,'error' AS 'status'
	,'relationMessengerContactNoPhoneMask' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.messenger = 1
		AND (GETDATE() BETWEEN rp.startDate AND rp.endDate
			OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN Contact AS c ON c.personID = p.personID
	LEFT JOIN v_MessengerPhone AS mp ON mp.personID = p.personID
	LEFT JOIN v_MessengerEmail AS me ON me.personID = p.personID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND ISNULL(mp.phoneMask, 0) + ISNULL(mp.textMask, 0) + ISNULL(me.emailMask, 0) <= 0


