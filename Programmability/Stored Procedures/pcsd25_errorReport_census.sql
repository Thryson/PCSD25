USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Modder:		<Lopez, Michael>
-- Create date: <05/21/2019>
-- Update date: <11/01/2021>
-- Description:	<Compile all existing census error reports into stored procedure>
-- =============================================

DECLARE @eYear int, @cDay date;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

DECLARE @errorReport2 TABLE (
	searchableField varchar(100)
	,searchType varchar(100)
	,searchLocation varchar(100)
	,verificationID int
	,verificationType varchar(50)
	,localCode varchar(5)
	,[status] varchar(10)
	,[type] varchar(50)
	,calendarID int
	,school varchar(5)
	,[number] varchar (100)
	,[street] varchar (100)
	,[apt] varchar (100)
	,stateReporting int
	,alt int)

DECLARE @errorReport TABLE  (
	searchableField varchar(100)
	,searchType varchar(100)
	,searchLocation varchar(100)
	,verificationID int
	,verificationType varchar(50)
	,localCode varchar(5)
	,[status] varchar(10)
	,[type] varchar(50)
	,calendarID int
	,school varchar(5)
	,stateReporting int
	,alt int)

DECLARE @nameArray TABLE (
	 vari varchar(5))

DECLARE @nameArray2 TABLE (
	 vari varchar(5))

INSERT INTO @nameArray VALUES 
	('.') 
	,(',')
	,('/')
	,('\')
	,('|')
	,('?')
	,('`')
	,('~')
	,('"')
	,(':')
	,(';')

INSERT INTO @nameArray2 VALUES 
	(' Jr')
	,(' Sr')
	,(' I')
	,(' II')
	,(' III')
	,(' IV')
	,(' V')

--==============================
--
--	Guardian Errors Code; GU---
--
--==============================


--Error	==================================
--Code  || Guardian Multiple Households ||
--GU001	==================================
INSERT INTO @errorReport
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hm.modifiedDate, hm.householdID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'guardianName' AS 'searchType'
		,'search>household>members' AS 'searchLocation'
		,rp.personID2 AS 'verificationID'
		,'guardianPersonID' AS 'verificationType'
		,'GU001' AS 'localCode'
		,'error' AS 'status'
		,'guardianMultipleHouseholdMembership' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
			AND rp.guardian = 1
			AND (@cDay BETWEEN rp.startDate AND rp.endDate
				OR (@cDay > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN [Identity] AS id ON id.personID = rp.personID2
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
			AND (@cDay BETWEEN hm.startDate AND hm.endDate
				OR (@cDay > hm.startDate AND hm.endDate IS NULL))
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
WHERE x.duplicateNumber != 1


--Error	=========================================
--Code  || Guardian Multiple Primary Addresses ||
--GU002	=========================================
INSERT INTO @errorReport
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'guardianName' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,rp.personID2 AS 'verificationID'
		,'guardianPersonID' AS 'verificationType'
		,'GU002' AS 'localCode'
		,'error' AS 'status'
		,'guardianMultiplePrimaryAddresses' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
			AND rp.guardian = 1
			AND (@cDay BETWEEN rp.startDate AND rp.endDate
				OR (@cDay > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN [Identity] AS id ON id.personID = rp.personID2
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
			AND (@cDay BETWEEN hm.startDate AND hm.endDate
				OR (@cDay > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.[secondary] = 0
			AND (@cDay BETWEEN hl.startDate AND hl.endDate
				OR (@cDay > hl.startDate AND hl.endDate IS NULL))
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
WHERE x.duplicateNumber != 1


--Error	=========================================
--Code  || Guardian Multiple Mailing Addresses ||
--GU003	=========================================
INSERT INTO @errorReport
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'guardianName' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,rp.personID2 AS 'verificationID'
		,'guardianPersonID' AS 'verificationType'
		,'GU003' AS 'localCode'
		,'error' AS 'status'
		,'guardianMultipleMailingAddresses' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
			AND rp.guardian = 1
			AND (@cDay BETWEEN rp.startDate AND rp.endDate
				OR (@cDay > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN [Identity] AS id ON id.personID = rp.personID2
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
			AND (@cDay BETWEEN hm.startDate AND hm.endDate
				OR (@cDay > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.mailing = 1
			AND (@cDay BETWEEN hl.startDate AND hl.endDate
				OR (@cDay > hl.startDate AND hl.endDate IS NULL))
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
WHERE x.duplicateNumber != 1


--==============================
--
--	Household Errors; Code HH---
--
--==============================


--Error	=================================
--Code  || Household No Primary Address||
--HH001	=================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>household' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'HH001' AS 'localCode'
	,'error' AS 'status'
	,'householdNoPrimaryAddress' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN HouseholdMember AS hm ON hm.personID = en.personID
		AND (@cDay BETWEEN hm.startDate AND hm.endDate
			OR (@cDay > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	LEFT JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND hl.[secondary] = 0
		AND (@cDay BETWEEN hl.startDate AND hl.endDate
			OR (@cDay > hl.startDate AND hl.endDate IS NULL))
WHERE hl.addressID IS NULL
	AND en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))


--Archived For Future use after better cleanups
--DID NOT RECIEVE RE-WRITE ON LAST UPDATE
--Error	====================================
--Code  || Household Contact No Birthdate ||
--HH002	====================================
--INSERT INTO @errorReport
--SELECT DISTINCT p.personID AS 'verificationID',
--	p.personID AS 'searchableField',
--	'HH002' AS 'code',
--	'incomplete' AS 'status',
--	'serach>allPeople>demographics' AS 'location',
--	'householdMemberNoBirthdate' AS 'type',
--	i.modifiedByID,
--	i.modifiedDate,
--	0 AS 'alt'
--FROM Enrollment AS e
--	INNER JOIN Calendar AS cal ON cal.calendarID = e.calendarID
--		AND cal.endYear = @eYear
--	INNER JOIN RelatedPair AS rp ON rp.personID1 = e.personID
--	INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID1
--		AND (@cDay BETWEEN hm.startDate AND hm.endDate
--			OR (@cDay > hm.startDate AND hm.endDate IS NULL))
--	INNER JOIN Household AS h ON h.householdID = hm.householdID
--	INNER JOIN HouseholdMember AS hm2 ON hm2.personID = rp.personID2
--		AND (@cDay BETWEEN hm2.startDate AND hm2.endDate
--			OR (@cDay > hm2.startDate AND hm2.endDate IS NULL))
--	INNER JOIN Household AS h2 ON h2.householdID = hm2.householdID
--	INNER JOIN [Identity] AS i ON i.personID = hm2.personID
--	INNER JOIN Person AS p ON p.personID = i.personID
--		AND p.currentIdentityID = i.identityID
--WHERE h.householdID = h2.householdID
--	AND i.birthdate IS NULL
--	AND e.active = 1


--Error	=================================
--Code  || Household Member Name Sytax ||
--HH003	=================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentsHouseholdMemberName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,rp.personID2 AS 'verificationID'
	,'HouseholdMemberPersonID' AS 'verificationType'
	,'HH003' AS 'localCode'
	,'warning' AS 'status'
	,'householdMemberNameSyntax' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID1
		AND hm.[private] = 0
		AND (@cDay BETWEEN hm.startDate AND hm.endDate
			OR (@cDay > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdMember AS hm2 ON hm2.personID = rp.personID2
		AND hm2.[private] = 0
		AND (@cDay BETWEEN hm2.startDate AND hm2.endDate
			OR (@cDay > hm2.startDate AND hm2.endDate IS NULL))
	INNER JOIN Household AS h2 ON h2.householdID = hm2.householdID
	INNER JOIN [Identity] AS id ON id.personID = hm2.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN @nameArray AS na ON id.firstName LIKE '%' + na.vari + '%'
		OR id.middleName LIKE '%' + na.vari + '%'
		OR id.lastName LIKE '%' + na.vari + '%'
		OR LEN(id.firstName) != LEN(REVERSE(id.firstName))
		OR LEN(id.middleName) != LEN(REVERSE(id.middleName))
		OR LEN(id.lastName) != LEN(REVERSE(id.lastName))
WHERE h.householdID = h2.householdID
	AND en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))


--Error	=================================
--Code  || Household Member Name Sytax ||
--HH003	=================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentsHouseholdMemberName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,rp.personID2 AS 'verificationID'
	,'HouseholdMemberPersonID' AS 'verificationType'
	,'HH003' AS 'localCode'
	,'warning' AS 'status'
	,'householdMemberNameSyntax' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID1
		AND hm.[private] = 0
		AND (@cDay BETWEEN hm.startDate AND hm.endDate
			OR (@cDay > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdMember AS hm2 ON hm2.personID = rp.personID2
		AND hm2.[private] = 0
		AND (@cDay BETWEEN hm2.startDate AND hm2.endDate
			OR (@cDay > hm2.startDate AND hm2.endDate IS NULL))
	INNER JOIN Household AS h2 ON h2.householdID = hm2.householdID
	INNER JOIN [Identity] AS id ON id.personID = hm2.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN @nameArray2 AS na ON id.firstName LIKE '%' + na.vari
		OR id.middleName LIKE '%' + na.vari
		OR id.lastName LIKE '%' + na.vari
WHERE h.householdID = h2.householdID
	AND en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))


--==============================
--
--	Student Errors; Code ST---
--
--==============================

--Error	=========================
--Code  || Student No Birthdate||
--ST001	=========================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>demographics' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST001' AS 'localCode'
	,'error' AS 'status'
	,'studentNoBirthdate' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE id.birthdate IS NULL
	AND en.endYear = @eYear
	AND en.serviceType = 'P'


--Error	========================
--Code  || Student Name Syntax||
--ST002	========================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>demographics' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST002' AS 'localCode'
	,'warning' AS 'status'
	,'studentNameSyntax' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN @nameArray AS na ON id.firstName LIKE '%' + na.vari + '%'
		OR id.middleName LIKE '%' + na.vari + '%'
		OR id.lastName LIKE '%' + na.vari + '%'
		OR LEN(id.firstName) != LEN(REVERSE(id.firstName))
		OR LEN(id.middleName) != LEN(REVERSE(id.middleName))
		OR LEN(id.lastName) != LEN(REVERSE(id.lastName))
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))


--Error	========================
--Code  || Student Name Syntax||
--ST002	========================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>demographics' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST002' AS 'localCode'
	,'warning' AS 'status'
	,'studentNameSyntax' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN @nameArray2 AS na ON id.firstName LIKE '%' + na.vari
		OR id.middleName LIKE '%' + na.vari
		OR id.lastName LIKE '%' + na.vari
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))


--Error	=================================
--Code  || Student Incomplete Relation ||
--ST003	=================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>allPeople>relationships' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
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
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = p.personID
		AND (rp.endDate IS NULL
			OR @cDay < rp.endDate)
		AND (rp.startDate IS NULL 
			OR rp.[name] LIKE 'Mother & Father'
			OR rp.[name] IS NULL )
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))


--Error	=========================
--Code  || Student No Guardian ||
--ST004	=========================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>allPeople>relationships' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST004' AS 'localCode'
	,'error' AS 'status'
	,'studentNoGuardians' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,COUNT(*) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = 2020
		AND cal.schoolID NOT IN (29,31)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	LEFT JOIN RelatedPair AS rp ON rp.personID1 = p.personID 
		AND rp.guardian = 1
		AND (@cDay BETWEEN rp.startDate AND rp.endDate
			OR (@cDay > rp.startDate AND rp.endDate IS NULL))
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
	AND rp.personID2 IS NULL
GROUP BY id.lastName + ', ' + id.firstName
	,p.studentNumber
	,cal.calendarID
	,sch.comments
HAVING COUNT(*) = 1


--Error	============================================
--Code  || Student Multiple Primary Memberships ||
--ST005	============================================
INSERT INTO @errorReport
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hm.modifiedDate, hm.householdID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'studentName' AS 'searchType'
		,'search>household>members' AS 'searchLocation'
		,p.studentNumber AS 'verificationID'
		,'studentNumber' AS 'verificationType'
		,'ST005' AS 'localCode'
		,'error' AS 'status'
		,'studentMultiplePrimaryMembership' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
			AND hm.[secondary] = 0
			AND (@cDay BETWEEN hm.startDate AND hm.endDate
				OR (@cDay > hm.startDate AND hm.endDate IS NULL))
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
WHERE x.duplicateNumber != 1


--Error	========================================
--Code  || Student Multiple Primary Addresses ||
--ST006	========================================
INSERT INTO @errorReport
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'studentName' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,p.studentNumber AS 'verificationID'
		,'studentNumber' AS 'verificationType'
		,'ST006' AS 'localCode'
		,'error' AS 'status'
		,'studentMultiplePrimaryAddresses' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
			AND hm.[secondary] = 0
			AND (@cDay BETWEEN hm.startDate AND hm.endDate
				OR (@cDay > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.[secondary] = 0
			AND (@cDay BETWEEN hl.startDate AND hl.endDate
				OR (@cDay > hl.startDate AND hl.endDate IS NULL))
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
WHERE x.duplicateNumber != 1


--Error	========================================
--Code  || Student Multiple Mailing Addresses ||
--ST007	========================================
INSERT INTO @errorReport
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY hl.modifiedDate, hl.addressID DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'studentName' AS 'searchType'
		,'search>household' AS 'searchLocation'
		,p.studentNumber AS 'verificationID'
		,'studentNumber' AS 'verificationType'
		,'ST007' AS 'localCode'
		,'error' AS 'status'
		,'studentMultipleMailingAddresses' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID
			AND hm.[secondary] = 0
			AND (@cDay BETWEEN hm.startDate AND hm.endDate
				OR (@cDay > hm.startDate AND hm.endDate IS NULL))
		INNER JOIN Household AS h ON h.householdID = hm.householdID
		INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
			AND hl.mailing = 1
			AND (@cDay BETWEEN hl.startDate AND hl.endDate
				OR (@cDay > hl.startDate AND hl.endDate IS NULL))
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
WHERE x.duplicateNumber != 1


--Error	=====================================
--Code  || Student More Than Two Guardians ||
--ST008	=====================================
INSERT INTO @errorReport
SELECT DISTINCT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM (
	SELECT RANK() OVER (PARTITION BY p.personID ORDER BY p.personID, rp.personID2 DESC) AS 'duplicateNumber'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'studentName' AS 'searchType'
		,'search>allPeople>relationships' AS 'searchLocation'
		,p.studentNumber AS 'verificationID'
		,'studentNumber' AS 'verificationType'
		,'ST008' AS 'localCode'
		,'warning' AS 'status'
		,'studentMoreThanTwoGuardians' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
		INNER JOIN RelatedPair AS rp oN rp.personID1 = p.personID
			AND rp.guardian = 1
			AND (@cDay BETWEEN rp.startDate AND rp.endDate
				OR (@cDay > rp.startDate AND rp.endDate IS NULL))
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
WHERE x.duplicateNumber >= 3


--Error	====================================
--Code  || Student With Underage Guardian ||
--ST009	====================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>allPeople>relationships' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST009' AS 'localCode'
	,'error' AS 'status'
	,'studentWithUnderageGuardian' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID	
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID
		AND p.personID = id.personID
	INNER JOIN RelatedPair AS rp ON p.personID = rp.personID1
		AND rp.guardian = 1
		AND (@cDay BETWEEN rp.startDate AND rp.endDate
			OR (@cDay > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN Person AS p2 ON p2.personID = rp.personID2
	INNER JOIN [Identity] AS id2 ON id2.personID = p2.personID
		AND id2.identityID = p2.currentIdentityID
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
	AND ((0 + CONVERT(CHAR(8), @cDay, 112) - CONVERT(CHAR(8), id2.birthdate, 112)) / 10000) < 18


--DID NOT RECIEVE RE-WRITE ON LAST UPDATE
--Error	========================================
--Code  || Student With Nonhousehold Guardian ||
--ST010	========================================
--INSERT INTO @errorReport
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
--		AND (@cDay BETWEEN rp.startDate AND rp.endDate
--			OR (@cDay > rp.startDate AND rp.endDate IS NULL))
--WHERE e.endyear = @eYear
--	AND rp.relatedPairGUID NOT IN (
--		SELECT rp.relatedPairGUID
--		FROM Household AS h
--		INNER JOIN HouseholdMember AS hm ON hm.householdID = h.householdID 
--			AND hm.enddate IS NULL
--		INNER JOIN RelatedPair AS rp ON hm.personID = rp.personID2 
--			AND rp.guardian = 1
--			AND (@cDay BETWEEN rp.startDate AND rp.endDate
--				OR (@cDay > rp.startDate AND rp.endDate IS NULL)))


--Error	========================================
--Code  || Student Mulitple Similar Addresses ||
--ST011	========================================
INSERT INTO @errorReport2
SELECT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>household' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST011' AS 'localCode'
	,'error' AS 'status'
	,'studentMultipleSimlarAddresses' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,a.number
	,a.street
	,a.apt
	,0 AS 'stateReporting'
	,COUNT(*) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID 
		AND (@cDay BETWEEN hm.startDate AND hm.endDate
			OR (@cDay > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID 
		AND (@cDay BETWEEN hl.startDate AND hl.endDate
			OR (@cDay > hl.startDate AND hl.endDate IS NULL))
	INNER JOIN [Address] AS a ON a.addressID = hl.addressID
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
GROUP BY id.lastName + ', ' + id.firstName
	,p.studentNumber
	,cal.calendarID
	,sch.comments
	,a.number
	,a.street
	,a.apt
HAVING COUNT(*) >= 2


INSERT INTO @errorReport
SELECT DISTINCT er2.searchableField
	,er2.searchType
	,er2.searchLocation
	,er2.verificationID
	,er2.verificationType
	,er2.localCode
	,er2.[status]
	,er2.[type]
	,er2.calendarID
	,er2.school
	,er2.stateReporting
	,er2.alt
FROM @errorReport2 AS er2


--Error	========================================
--Code  || Student Age Outside Of Grade Range ||
--ST012	========================================
INSERT INTO @errorReport
SELECT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,1 AS 'stateReporting'
	,0 AS 'alt'
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
		,p.studentNumber AS 'verificationID'
		,'studentNumber' AS 'verificationType'
		,id.lastName + ', ' + id.firstName AS 'searchableField'
		,'studentName' AS 'searchType'
		,'ST012' AS 'localCode'
		,'warning' AS 'status'
		,'search>allPeople>demographics' AS 'searchLocation'
		,'studentAgeOutsideGradeRange' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		LEFT JOIN Enrollment AS e2 ON e2.personID = en.personID
			AND e2.endYear = @eYear - 1
		INNER JOIN [Identity] AS id ON id.personID = en.personID
		INNER JOIN Person AS p ON p.personID = id.personID
			AND p.currentIdentityID = id.identityID
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND en.grade != 'NG'
) AS x
WHERE x.[priority] = 1
	AND ((0 + CONVERT(CHAR(8), @cDay, 112) - CONVERT(CHAR(8), x.birthdate, 112)) / 10000) NOT BETWEEN x.grade + 5 AND x.grade + 6
	AND (x.enrollmentID IS NULL OR x.grade NOT BETWEEN x.grade2 AND x.grade2 + 1)


--Error	====================================
--Code  || Student Incomplete Immigration ||
--ST013	====================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST013' AS 'localCode'
	,'error' AS 'status'
	,'studentIncompleteImmigration' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND ((id.immigrant = 1 AND (id.birthCountry IS NULL OR id.dateEnteredUS IS NULL))
		OR (id.dateEnteredUS IS NOT NULL AND id.immigrant IS NULL))


--Error	===============================================
--Code  || Student US Citizen with Immigration marked||
--ST014	===============================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST014' AS 'localCode'
	,'warning' AS 'status'
	,'studentUSBirthWithImmigrationData' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (id.birthCountry = 'US' 
		AND (id.dateEnteredUS IS NOT NULL 
			OR id.dateEnteredUSSchool IS NOT NULL))


--Error	==========================================================
--Code  || Student with Immigration Marked but no Home Langague ||
--ST015	==========================================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST015' AS 'localCode'
	,'incomplete' AS 'status'
	,'studentImmigrationWithNoHomeLanguage' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND id.immigrant = 1
	AND id.homePrimaryLanguage IS NULL


--Error	==============================================================
--Code  || Student without Immigration but Immigration Data Entered ||
--ST016	==============================================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>allPeople>demographics' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'ST016' AS 'localCode'
	,'warning' AS 'status'
	,'studentNoImmigrationWithImmigrationData' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (id.immigrant = 0 OR id.immigrant IS NULL)
	AND (id.dateEnteredState IS NOT NULL
		OR id.birthCountry NOT IN ('US',''))
			


--==============================
--
--	Relation Errors; Code RE---
--
--==============================

--Error	=========================================
--Code  || Relation Mailing Contact No Address ||
--RE001	=========================================
--Part 1 of 2
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentRelationName' AS 'searchType'
	,'search>allPeople>households' AS 'searchLocation'
	,en.personID AS 'verificationID'
	,'studentPersonID' AS 'verificationType'
	,'RE001' AS 'localCode'
	,'error' AS 'status'
	,'relationMailingContactNoAddress' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.mailing = 1
		AND (@cDay BETWEEN rp.startDate AND rp.endDate
			OR (@cDay > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	LEFT JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
		AND hm.[secondary] = 0
		AND (@cDay BETWEEN hm.startDate AND hm.endDate
			OR (@cDay > hm.startDate AND hm.endDate IS NULL))
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
	AND hm.householdID IS NULL


--Error	=========================================
--Code  || Relation Mailing Contact No Address ||
--RE001	=========================================
--Part 2 of 2
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentRelationName' AS 'searchType'
	,'search>allPeople>households' AS 'searchLocation'
	,en.personID AS 'verificationID'
	,'studentPersonID' AS 'verificationType'
	,'RE001' AS 'localCode'
	,'error' AS 'status'
	,'relationMailingContactNoAddress' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,0 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
		AND rp.mailing = 1
		AND (@cDay BETWEEN rp.startDate AND rp.endDate
			OR (@cDay > rp.startDate AND rp.endDate IS NULL))
	INNER JOIN [Identity] AS id ON id.personID = rp.personID2
	INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
		AND p.personID = id.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = rp.personID2
		AND hm.[secondary] = 0
		AND (@cDay BETWEEN hm.startDate AND hm.endDate
			OR (@cDay > hm.startDate AND hm.endDate IS NULL))
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	LEFT JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID 
		AND hl.mailing = 1
		AND (@cDay BETWEEN hl.startDate AND hl.endDate
			OR (@cDay > hl.startDate AND hl.endDate IS NULL))
WHERE en.endYear = @eYear
	AND en.serviceType = 'P'
	AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
	AND hl.householdID IS NULL


--Error	=========================================
--Code  || Relation Messenger Contact No Phone ||
--RE002	=========================================
INSERT INTO @errorReport
SELECT x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
	,0 AS 'stateReporting'
	,SUM(x.maskCount) AS 'alt'
FROM (
	SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
		,'studentRelationName' AS 'searchType'
		,'search>allPeople>demographics' AS 'searchLocation'
		,en.personID AS 'verificationID'
		,'studentPersonID' AS 'verificationType'
		,'RE002' AS 'localCode'
		,'error' AS 'status'
		,'relationMessengerContactNoPhoneMask' AS 'type'
		,cal.calendarID
		,sch.comments AS 'school'
		,ISNULL(mp.phoneMask, 0) + ISNULL(mp.textMask, 0) + ISNULL(me.emailMask, 0) AS 'maskCount'
	FROM Enrollment AS en
		INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			AND cal.endYear = @eYear
		INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = en.personID
			AND rp.messenger = 1
			AND (@cDay BETWEEN rp.startDate AND rp.endDate
				OR (@cDay > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN [Identity] AS id ON id.personID = rp.personID2
		INNER JOIN Person AS p ON p.currentIdentityID = id.identityID 
			AND p.personID = id.personID
		INNER JOIN Contact AS c ON c.personID = p.personID
		LEFT JOIN v_MessengerPhone AS mp ON mp.personID = p.personID
		LEFT JOIN v_MessengerEmail AS me ON me.personID = p.personID
	WHERE en.endYear = @eYear
		AND en.serviceType = 'P'
		AND (en.startDate >= @cDay AND (en.endDate IS NULL OR en.endDate <= @cDay))
) AS x
GROUP BY x.searchableField
	,x.searchType
	,x.searchLocation
	,x.verificationID
	,x.verificationType
	,x.localCode
	,x.[status]
	,x.[type]
	,x.calendarID
	,x.school
HAVING SUM(x.maskCount) <= 0


--Output Error Report
SELECT DISTINCT er.searchableField
	,er.searchType
	,er.searchLocation
	,er.verificationID
	,er.verificationType
	,er.localCode
	,er.[status]
	,er.[type]
	,er.calendarID
	,er.school
	,er.stateReporting
FROM @errorReport AS er
WHERE
	status = 'warning'


/*
DROP TABLE @errorReport,
	@errorReport2,
	#nameArray
*/