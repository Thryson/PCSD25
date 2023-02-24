USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Modder:		<Lopez, Michael>
-- Create date: <05/21/2019>
-- Update date: <02/21/2023>
-- Description:	<Compile all existing census error reports into a single view>
-- =============================================


--==============================
--
--	Guardian Errors Code; GU---
--
--==============================


--Error	==================================
--Code  || Guardian Multiple Households ||
--GU001	==================================

SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'guardianName' AS 'searchType'
	,'GU001' AS 'localCode'
	,'error' AS 'status'
	,'guardianMultipleHouseholdMembership' AS 'type'
	,rp.personID2 AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
GROUP BY id.lastName
	,id.firstName
	,rp.personID2
	,cal.calendarID
	,sch.comments
	,cs.[value]
	,rp.personID1
HAVING COUNT(*) >= 2


UNION ALL


--Error	=========================================
--Code  || Guardian Multiple Primary Addresses ||
--GU002	=========================================

SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'guardianName' AS 'searchType'
	,'GU002' AS 'localCode'
	,'error' AS 'status'
	,'guardianMultiplePrimaryAddresses' AS 'type'
	,rp.personID2 AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
GROUP BY id.lastName
	,id.firstName
	,rp.personID2
	,cal.calendarID
	,sch.comments
	,cs.[value]
	,rp.personID1
HAVING COUNT(*) >= 2



UNION ALL


--Error	=========================================
--Code  || Guardian Multiple Mailing Addresses ||
--GU003	=========================================
SELECT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'guardianName' AS 'searchType'
	,'GU003' AS 'localCode'
	,'error' AS 'status'
	,'guardianMultipleMailingAddresses' AS 'type'
	,rp.personID2 AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
GROUP BY id.lastName
	,id.firstName
	,rp.personID2
	,cal.calendarID
	,sch.comments
	,cs.[value]
	,rp.personID1
HAVING COUNT(*) >= 2



UNION ALL


--Error	===========================
--Code  || Guardian No Birthdate ||
--GU004	===========================
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'guardianName' AS 'searchType'
	,'HH002' AS 'localCode'
	,'incomplete' AS 'status'
	,'guardianNoBirthdate' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,'HH001' AS 'localCode'
	,'error' AS 'status'
	,'householdNoPrimaryAddress' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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


--Report was removed, this slot is open
--Error	==========
--Code  || ---- ||
--HH002	==========



--Error	=================================
--Code  || Household Member Name Sytax ||
--HH003	=================================

SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentsHouseholdMemberName' AS 'searchType'
	,'HH003' AS 'localCode'
	,'warning' AS 'status'
	,'householdMemberNameSyntax' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,'ST001' AS 'localCode'
	,'error' AS 'status'
	,'studentNoBirthdate' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,'ST002' AS 'localCode'
	,'warning' AS 'status'
	,'studentNameSyntax' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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


--Error	===============================
--Code  || Student No Relation Type  ||
--ST003	===============================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST003' AS 'localCode'
	,'incomplete' AS 'status'
	,'invalidOrNoRelationType' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = p.personID
		AND (rp.endDate IS NULL
			OR GETDATE() <= rp.endDate)
		AND (rp.[name] LIKE 'Mother and Father'
			OR rp.[name] IS NULL )
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))


UNION ALL


--Error	=========================
--Code  || Student No Guardian ||
--ST004	=========================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST004' AS 'localCode'
	,'error' AS 'status'
	,'studentNoGuardians' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,COUNT(*) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.schoolID NOT IN (29,31) --Not JDC Schools
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	LEFT JOIN RelatedPair AS rp ON rp.personID1 = p.personID 
		AND (rp.guardian = 1 OR rp.[name] = 'Emancipated')
		AND (rp.startDate <= GETDATE() AND (rp.endDate IS NULL OR rp.endDate >= GETDATE()))
WHERE rp.guardian IS NULL
	AND en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
GROUP BY id.lastName
	,id.firstName
	,p.studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
	,cs.[value]
HAVING COUNT(*) = 1


UNION ALL


--Error	============================================
--Code  || Student Multiple Primary Memberships ||
--ST005	============================================
SELECT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST005' AS 'localCode'
	,'error' AS 'status'
	,'studentMultiplePrimaryMembership' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
		AND hm.[secondary] = 0
		AND (hm.startDate <= GETDATE() AND (hm.endDate IS NULL OR hm.endDate >= GETDATE()))
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
GROUP BY p.studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
	,cs.[value]
HAVING COUNT(*) >= 2


UNION ALL


--Error	========================================
--Code  || Student Multiple Primary Addresses ||
--ST006	========================================
SELECT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST006' AS 'localCode'
	,'error' AS 'status'
	,'studentMultiplePrimaryAddresses' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
		AND hm.[secondary] = 0
		AND (hm.startDate <= GETDATE() AND (hm.endDate IS NULL OR hm.endDate >= GETDATE()))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND hl.[secondary] = 0
		AND (hl.startDate <= GETDATE() AND (hl.endDate IS NULL OR hl.endDate >= GETDATE()))
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
GROUP BY p.studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
	,cs.[value]
HAVING COUNT(*) >= 2


UNION ALL


--Error	========================================
--Code  || Student Multiple Mailing Addresses ||
--ST007	========================================
SELECT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST007' AS 'localCode'
	,'warning' AS 'status'
	,'studentMultipleMailingAddresses' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
		AND hm.[secondary] = 0
		AND (hm.startDate <= GETDATE() AND (hm.endDate IS NULL OR hm.endDate >= GETDATE()))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND hl.mailing = 1
		AND (hl.startDate <= GETDATE() AND (hl.endDate IS NULL OR hl.endDate >= GETDATE()))
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
GROUP BY p.studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
	,cs.[value]
HAVING COUNT(*) >= 2


UNION ALL


--Error	=====================================
--Code  || Student More Than Two Guardians ||
--ST008	=====================================
SELECT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST008' AS 'localCode'
	,'warning' AS 'status'
	,'studentMoreThanTwoGuardians' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,COUNT(*) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN RelatedPair AS rp oN rp.personID1 = p.personID
		AND rp.guardian = 1
		AND (rp.startDate <= GETDATE() AND (rp.endDate IS NULL OR rp.endDate >= GETDATE()))
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
GROUP BY p.studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
	,cs.[value]
HAVING COUNT(*) > 2


UNION ALL


--Error	====================================
--Code  || Student With Underage Guardian ||
--ST009	====================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST009' AS 'localCode'
	,'error' AS 'status'
	,'studentWithUnderageGuardian' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID
		AND p.personID = id.personID
	INNER JOIN RelatedPair AS rp ON p.personID = rp.personID1
		AND rp.guardian = 1
		AND rp.[name] != 'Emancipated'
		AND rp.personID1 != rp.personID2
		AND (rp.startDate <= GETDATE() AND (rp.endDate IS NULL OR rp.endDate >= GETDATE()))
	INNER JOIN Person AS p2 ON p2.personID = rp.personID2
	INNER JOIN [Identity] AS id2 ON id2.personID = p2.personID
		AND id2.identityID = p2.currentIdentityID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND ((0 + CONVERT(CHAR(8), GETDATE(), 112) - CONVERT(CHAR(8), id2.birthdate, 112)) / 10000) < 18


UNION ALL


--Error	====================================
--Code  || Student No Relation Start Date ||
--ST010	====================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST002' AS 'localCode'
	,'incomplete' AS 'status'
	,'noRelationStartDate' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = p.personID
		AND rp.startDate IS NULL 
		AND (rp.endDate IS NULL OR rp.endDate >= GETDATE())
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))


UNION ALL


--Error	========================================
--Code  || Student Multiple Similar Addresses ||
--ST011	========================================
SELECT x.searchableField
	,x.searchType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,x.[range]
	,x.stateReporting
	,x.alt
FROM (
	SELECT p.studentNumber AS 'searchableField'
		,'studentNumber' AS 'searchType'
		,'ST011' AS 'localCode'
		,'error' AS 'status'
		,'studentMultipleSimlarAddresses' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
		,cs.[value] AS 'range'
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
		INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
			AND cs.attributeID = 618 --618 is the "range" for the school
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
			AND p.personID = id.personID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID 
			AND (hm.startDate <= GETDATE() AND (hm.endDate IS NULL OR hm.endDate >= GETDATE()))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID 
			AND (hl.startDate <= GETDATE() AND (hl.endDate IS NULL OR hl.endDate >= GETDATE()))
		INNER JOIN [Address] AS a ON a.addressID = hl.addressID
	WHERE en.serviceType = 'P'
		AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	GROUP BY p.studentNumber
		,p.personID
		,cal.calendarID
		,sch.comments
		,cs.[value]
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
	,x.localCode
	,x.[status]
	,x.[type]
	,x.personID
	,x.calendarID
	,x.school
	,x.[range]
	,x.stateReporting
	,x.alt
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
		,'studentAgeOutsideGradeRange' AS 'type'
		,p.personID
		,cal.calendarID
		,sch.comments AS 'school'
		,cs.[value] AS 'range'
		,1 AS 'stateReporting'
		,0 AS 'alt'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
			AND cs.attributeID = 618 --618 is the "range" for the school
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
	,'ST013' AS 'localCode'
	,'error' AS 'status'
	,'studentIncompleteImmigration' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
		AND (id.immigrant IS NOT NULL
			OR id.dateEnteredUS IS NOT NULL)
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND ((id.immigrant IS NULL OR id.immigrant = 0)
		OR (id.dateEnteredUS IS NOT NULL 
			OR id.dateEnteredUSSchool IS NOT NULL
			OR id.dateEnteredState IS NOT NULL)
		OR id.homePrimaryLanguage IS NULL
		OR (id.birthCountry IS NULL OR id.birthCountry = 'US' OR id.birthCountry = ''))


UNION ALL


--Error	===============================================
--Code  || Student US Citizen with Immigration marked||
--ST014	===============================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST014' AS 'localCode'
	,'error' AS 'status'
	,'studentUSBirthWithImmigrationData' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
		AND id.birthCountry = 'US' 
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND (id.dateEnteredUS IS NOT NULL 
		OR id.dateEnteredUSSchool IS NOT NULL
		OR id.dateEnteredState IS NOT NULL)


UNION ALL


--Error	===============
--Code  || Open slot ||
--ST015	===============



--Error	===============
--Code  || Open slot ||
--ST016	===============



--Error	=====================================
--Code  || Student with Expired Immigration ||
--ST017	======================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'ST017' AS 'localCode'
	,'error' AS 'status'
	,'studentImmigrationExpired' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,'RE001' AS 'localCode'
	,'error' AS 'status'
	,'relationMailingContactNoAddress' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.mailing = 1
		AND (rp.startDate <= GETDATE() AND (rp.endDate IS NULL OR rp.endDate >= GETDATE()))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	LEFT JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
		AND hm.[secondary] = 0
		AND (hm.startDate <= GETDATE() AND (hm.endDate IS NULL OR hm.endDate >= GETDATE()))
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
	,'RE001' AS 'localCode'
	,'error' AS 'status'
	,'relationMailingContactNoAddress' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.mailing = 1
		AND (rp.startDate <= GETDATE() AND (rp.endDate IS NULL OR rp.endDate >= GETDATE()))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
		AND hm.[secondary] = 0
		AND (hm.startDate <= GETDATE() AND (hm.endDate IS NULL OR hm.endDate >= GETDATE()))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	LEFT JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID 
		AND hl.mailing = 1
		AND (hl.startDate <= GETDATE() AND (hl.endDate IS NULL OR hl.endDate >= GETDATE()))
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND hl.householdID IS NULL


UNION ALL


--Error	=========================================
--Code  || Relation Messenger Contact No Phone ||
--RE002	=========================================
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentRelationName' AS 'searchType'
	,'RE002' AS 'localCode'
	,'error' AS 'status'
	,'relationMessengerContactNoPhoneEmailMask' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.messenger = 1
		AND (rp.startDate <= GETDATE() AND (rp.endDate IS NULL OR rp.endDate >= GETDATE()))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN Contact AS c ON c.personID = p.personID
	LEFT JOIN v_MessengerPhone AS mp ON mp.personID = p.personID
	LEFT JOIN v_MessengerEmail AS me ON me.personID = p.personID
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND ISNULL(mp.phoneMask, 0) + ISNULL(mp.textMask, 0) + ISNULL(me.emailMask, 0) <= 0


UNION ALL


--============================== 
-- 
-- Enrollment Errors Code; EN--- 
-- 
--==============================     

--Error ================================ 
--Code  || Student Multiple Homerooms || 
--EN001 ================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN001' AS 'localCode'
	,'error' AS 'status'
	,'studentMultipleHomeroom' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,te.termID AS 'alt'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE rs.endDate IS NULL
		OR GETDATE() <= rs.endDate  
GROUP BY studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
	,te.termID 
	,cs.[value]
HAVING COUNT(*) > 1


UNION ALL


--Error ======================================== 
--Code  || 1C2A with Previous Year Enrollment || 
--EN002 ========================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN002' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = en1.endYear - 1
		AND en2.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE en1.startStatus IN ('1C','2A')
	AND en1.serviceType = 'P'
	AND (MONTH(en1.startDate) = 8 AND MONTH(en2.endDate) = 5)     


UNION ALL


--Error ===================================== 
--Code  || 1C2A Enrollments within 14 Days || 
--EN003 =====================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN003' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = en1.endyear
		AND en2.enrollmentID != en1.enrollmentID
		AND en2.serviceType = 'P'
		AND en2.startDate < en1.startDate
		AND DATEADD(DAY, 14, en2.endDate) >= en1.startDate
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE en1.startStatus IN ('1C','2A')
	AND en1.serviceType = 'P'     


UNION ALL


--Error ======================================== 
--Code  || 2A2B2C2D with Next Year Enrollment || 
--EN004 ========================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN004' AS 'localCode'
	,'warning' AS 'status'
	,'studentEndCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en2.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE en1.endStatus IN ('2A','2B','2C','2D')
	AND en1.serviceType = 'P'
	AND (MONTH(en2.startDate) = 8 AND MONTH(en1.endDate) = 5)     


UNION ALL


--Error ========================================= 
--Code  || 2A2B2C2D Enrollments within 14 Days || 
--EN005 =========================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN005' AS 'localCode'
	,'warning' AS 'status'
	,'studentEndCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = en1.endYear
		AND en2.enrollmentID != en1.enrollmentID
		AND en2.serviceType = 'P'
		AND en2.startDate < en1.startDate
		AND DATEADD(DAY, 14, en2.endDate) >= en1.startDate
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en2.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE en2.endStatus IN ('2A','2B','2C','2D')
	AND en1.serviceType = 'P'     


UNION ALL


--Error ======================================= 
--Code  || Enrollment Record with no Classes || 
--EN006 =======================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN006' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentNoClasses' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN (7,33) -- Exlucde the following HS, LINC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE en.serviceType = 'P'
	AND en.grade NOT IN ('NG','OT')
	AND en.personID NOT IN (   
		SELECT DISTINCT rs.personID   
		FROM Roster AS rs   
			INNER JOIN Section AS se ON se.sectionID = rs.sectionID   
			INNER JOIN Trial AS tl ON tl.trialID = se.trialID   
				AND tl.active = 1   
			INNER JOIN Course AS co ON co.courseID = se.courseID   
			INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
			INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
					AND scy.active = 1  
			INNER JOIN School AS sch ON sch.schoolID = cal.schoolID   
				AND sch.schoolID NOT IN (34,7,33))     


UNION ALL


--Error ================================================================ 
--Code  || Enrollment or Term Record with non aligned section enddate || 
--EN007 ================================================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN007' AS 'localCode'
	,'error' AS 'status'
	,'CourseEndDateNoMatch' AS 'type'
	,p.personID
	,x.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM (
		SELECT rs.personID  
			,te.[name]  
			,cal.calendarID  
			,MAX(ISNULL(rs.endDate, te.endDate)) AS 'maxEndDate'  
			,te.endDate AS 'termEndDate'  
			,en.endDate AS 'enrolEndDate'  
		FROM roster AS rs  
			INNER JOIN Section AS se ON se.sectionID = rs.sectionID  
			INNER JOIN Trial AS tl ON tl.trialID = se.trialID  
				AND tl.active = 1  
			INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID  
			INNER JOIN [Period] AS pd ON pd.periodID = sp.periodID  
				AND pd.nonInstructional = 0  
			INNER JOIN Term AS te ON te.termID = sp.termID  
			INNER JOIN Course AS co ON co.courseID = se.courseID  
			INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID  
			INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1 
			INNER JOIN Enrollment AS en ON en.personID = rs.personID  
				AND en.calendarID = cal.calendarID  
		WHERE ISNULL(rs.startDate, te.startDate) >= en.startDate 
				AND (ISNULL(rs.endDate, te.endDate) <= en.enddate OR en.endDate IS NULL)
		GROUP BY rs.personID  
			,te.[name]  
			,cal.calendarID  
			,te.endDate  
			,en.endDate    
		HAVING (MAX(ISNULL(rs.endDate, te.endDate)) < te.endDate  
				AND en.endDate > te.endDate)  
					OR (MAX(ISNULL(rs.endDate, te.endDate)) < en.endDate  
						AND en.endDate < te.endDate)
				) AS x
	INNER JOIN Person AS p ON p.personID = x.personID
	INNER JOIN [Identity] AS id ON p.personID = id.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN School AS sch ON sch.schoolID = x.calendarID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school


UNION ALL


--Error ============================================== 
--Code  || Same Class Same Period Overlapping Dates || 
--EN008 ==============================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN008' AS 'localCode'
	,'error' AS 'status'
	,'mutlipleOverlappingRepeatedClass' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
	INNER JOIN [Period] AS pd ON pd.periodID = sp.periodID
		AND pd.nonInstructional = 0
	INNER JOIN Roster AS rs1 ON rs1.sectionID = se.sectionID
	INNER JOIN Roster AS rs2 ON rs1.personID = rs2.personID
		AND rs2.sectionID = rs1.sectionID
		AND rs2.rosterID > rs1.rosterID
	INNER JOIN Person AS p ON p.personID = rs1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE ISNULL(rs2.startDate, te.startDate) < ISNULL(rs1.endDate, te.endDate)
	OR (rs1.startDate IS NULL AND rs2.startDate IS NULL)
	OR (rs1.endDate IS NULL AND rs2.endDate IS NULL)


UNION ALL


--Error =================================== 
--Code  || Student No Primary Enrollment || 
--EN009 ===================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN009' AS 'localCode'
	,'error' AS 'status'
	,'studentNoPrimaryEnrollment' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS e1 
	FULL OUTER JOIN Enrollment AS e2 ON e2.personID = e1.personID
		AND e2.serviceType = 'P'
		AND e2.endYear = YEAR(GETDATE())
		AND (GETDATE() BETWEEN e2.startDate AND e2.endDate  
			OR (GETDATE() > e2.startDate AND e2.endDate IS NULL))
	INNER JOIN Calendar AS cal ON cal.calendarID = e1.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN Person AS p ON p.personID = e1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE e1.endYear = YEAR(GETDATE())
	AND e1.serviceType = 'S'
	AND e2.serviceType IS NULL
	AND (GETDATE() BETWEEN e1.startDate AND e1.endDate 
		OR (GETDATE() > e1.startDate AND e1.endDate IS NULL))   


UNION ALL


--Error ================================
--Code  || Enrollment Incomplete Exit || 
--EN010 ================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN010' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentIncompleteExit' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE (en.endDate IS NOT NULL AND en.endStatus IS NULL)
	OR (en.endDate IS NULL AND en.endStatus IS NOT NULL)


UNION ALL


--Error	=================================
--Code  || Enrollment Incomplete Start ||
--EN011	=================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN011' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentIncompleteStart' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE (en.startDate IS NOT NULL AND en.startStatus IS NULL)
	OR (en.startDate IS NULL AND en.startStatus IS NOT NULL)


UNION ALL


--Error	===============
--Code  || Open slot ||
--EN012	=============== 
  

--Error	===============
--Code  || Open slot ||
--EN013	=============== 


--Error ================================ 
--Code  || At Risk when Grade Below 6 || 
--EN014 ================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN014' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentAtRiskGradeLessThan06' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN EnrollmentID AS eid ON eid.enrollmentID = en.enrollmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.grade NOT IN ('06','07','08','09','10','11','12')
	AND eid.atRisk = 'Y'


UNION ALL


--Error =================================== 
--Code  || Enrollment Flagged as No Show || 
--EN015 ===================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN015' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentFlaggedNoShow' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN EnrollmentID AS eid ON eid.enrollmentID = en.enrollmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.noShow = 1