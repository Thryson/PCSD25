USE pocatello
-------------------------------------------------------------------------------
-- Author: Jacob Mullett
-- Date last modified: 11/08/2021 @16:35
-- Description: FRAM Data for P-EBT upload that food service does
-------------------------------------------------------------------------------
DECLARE @cDay DATETIME = GETDATE();
DECLARE @endYear INT =  CASE 
							WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 0, @cDay)) 
							WHEN MONTH(@cDay) >= 1 THEN YEAR(DATEADD(YEAR,-1, @cDay))
						END;

CREATE TABLE #p_ebt(
	[priority] INT
	,idStuID INT
	,lastName VARCHAR(50)
	,firstName VARCHAR(50)
	,middleName VARCHAR(50)
	,gender VARCHAR(1)
	,birthdate DATE
	,schoolID VARCHAR(10)
	,SchoolName VARCHAR(50)
	,gradeLevel VARCHAR(10)
	,schoolEntryDate DATE
	,schoolExitDate VARCHAR(10)
	,econDisStatus VARCHAR(10)
	,econDisDetermination DATE
	,Address1 VARCHAR(50)
	,Address2 VARCHAR(50)
	,city VARCHAR(50)
	,[state] VARCHAR(50)
	,zip INT
	,Phone VARCHAR(25)
	,ParentGuardianFirstName VARCHAR(50)
	,parentGuardianLastName VARCHAR(50)
	,parentGuardianDOB DATE
)
INSERT INTO #p_ebt
SELECT DISTINCT
	DENSE_RANK() OVER(PARTITION BY per.studentNumber ORDER BY enr.startDate DESC, pel.startDate DESC, rpa.personID2 DESC, [add].postOfficeBox ) AS 'Priority'
	,per.stateID AS idStuID
	,ide.lastName
	,ide.firstName
	,ide.middleName
	,ide.gender
	,ide.birthdate
	,sch.number AS 'schoolID'
	,sch.[name] AS 'SchoolName'
	,enr.grade AS gradeLevel
	,enr.startDate AS schoolEntryDate
	,'' AS schoolExitDate
	,pel.eligibility AS econDisStatus
	,pel.startDate AS econDisDetermination
	,CASE -- CHANGE THIS TO USE ISNULL() FUNCTIONS WITHIN THE CASE STATEMENT
		WHEN [add].postOfficeBox = 1 THEN 'P.O. Box '+[add].number
		WHEN [add].apt IS NOT NULL AND [add].prefix IS NOT NULL THEN [add].number+' '+[add].prefix+' '+[add].street+' Apt. '+[add].apt
		WHEN [add].apt IS NOT NULL THEN [add].number+' '+[add].street+' Apt. '+[add].apt
		WHEN [add].prefix IS NOT NULL THEN [add].number+' '+[add].prefix+' '+[add].street
		WHEN [add].prefix IS NULL THEN [add].number+' '+[add].street
	END AS Address1
	,'' AS Address2
	,[add].city
	,[Add].[state]
	,[add].zip
	,'' AS Phone
	,id2.firstName AS ParentGuardianFirstName
	,id2.lastName AS ParentGuardianLastName
	,CASE
		WHEN id2.birthdate IS NOT NULL THEN id2.birthdate
	END AS parentGuardianDOB
FROM Person AS per
	INNER JOIN [Identity] AS ide ON ide.identityID = per.currentIdentityID
	INNER JOIN Enrollment AS enr ON enr.personID = per.personID
		AND enr.active = 1
		AND enr.serviceType = 'P'
		AND enr.endDate >= '2021-05-01'
	INNER JOIN RelatedPair AS rpa ON rpa.personID1 = per.personID
		AND rpa.seq = 1		
	INNER JOIN Person AS per2 ON per2.personID = rpa.personID2
	INNER JOIN [Identity] AS id2 ON id2.[identityID] = per2.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = enr.calendarID
		AND cal.endYear = @endYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN('23','34','31','27')
	INNER JOIN HouseholdMember AS hme ON hme.personID = per.personID
		AND hme.[secondary] = 0
		AND hme.endDate IS NULL
	INNER JOIN Household AS hou ON hou.householdID = hme.householdID
	INNER JOIN HouseholdLocation AS hlo ON hlo.householdID = hou.householdID
		AND hlo.[secondary] = 0
		AND (hlo.endDate > GETDATE() OR hlo.endDate IS NULL)
	INNER JOIN FreeReducedHouseholdMember AS frh ON frh.personID = per.personID
	INNER JOIN [Address] AS [add] ON [add].addressID = hlo.addressID
	INNER JOIN POSAccountAccess AS paa ON paa.personID = per.personID
	INNER JOIN POSAccount AS pac ON pac.accountID = paa.accountID
	INNER JOIN POSEligibility AS pel ON pel.personID = per.personID
		--AND pel.startDate BETWEEN '08-24-'+CAST(@endYear-1 AS VARCHAR(10)) AND '08-24-'+CAST(@endYear AS VARCHAR(10))
		AND pel.eligibility != 'S'
		AND pel.endYear = 2021
ORDER BY
	ide.lastName
	,ide.firstName

SELECT 
	 idStuID
	,lastName
	,firstName
	,middleName
	,gender
	,birthdate
	,schoolID
	,SchoolName
	,gradeLevel
	,schoolEntryDate
	,schoolExitDate
	,econDisStatus
	,econDisDetermination
	,Address1
	,Address2
	,city
	,[state]
	,zip
	,Phone
	,ParentGuardianFirstName
	,ParentGuardianLastName
	,parentGuardianDOB
FROM #p_ebt AS ebt
WHERE 
	[priority] = 1
ORDER BY
	schoolID
	,lastName
	,firstName
DROP TABLE #p_ebt