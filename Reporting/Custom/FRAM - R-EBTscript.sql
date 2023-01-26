----------------------------------
-- FINDS STUDENTS WHO ARE APPLICANTS OR ENROLLED INT FRAM PROGRAM
-- AUTHOR: JACOB MULLETT
-- DATE	 : 05/18/2021 
----------------------------------
USE pocatello

CREATE TABLE #REBT(
	[priority] INT,
	idStuID INT,
	lastName VARCHAR(50),
	firstName VARCHAR(50),
	middleName VARCHAR(50),
	gender VARCHAR(5),
	birthDate DATE,
	schoolID INT,
	schoolName VARCHAR(50),
	gradeLevel VARCHAR(5),
	schoolEntryDate DATE,
	schoolExitDate DATE,
	econDisStatus VARCHAR(5),
	econDisDetermination DATE,
	Address1 VARCHAR(50),
	Address2 VARCHAR(50),
	City VARCHAR(50),
	[State] VARCHAR(50),
	zip INT,
	Phone VARCHAR,
	ParentGuardianFirstName VARCHAR(50),
	ParentGuardianLastName VARCHAR(50),
	ParentGuardianDOB DATE
	)

INSERT INTO #REBT
SELECT DISTINCT
	RANK() OVER(PARTITION BY per.stateID ORDER BY pel.startDate) AS 'priority',
	per.stateID,
	ide.lastName,
	ide.firstName,
	ide.middleName,
	ide.gender,
	ide.birthdate,
	sch.schoolID,
	sch.[name],
	enr.grade,
	enr.startDate,
	enr.endDate,
	pel.eligibility AS econDisStatus,
	pel.startDate AS econDisDetermination,
	CASE
		WHEN [add].apt IS NOT NULL THEN [add].number+' '+[add].street+' '+[add].tag+' '+[add].apt
		WHEN [add].tag IS NOT NULL THEN [add].number+' '+[add].street+' '+[add].tag
		WHEN [add].tag IS NULL THEN [add].number+' '+[add].street
	END AS 'Address1',
	'' AS 'Address2',
	[add].city,
	[add].[state],
	[add].zip,
	'' AS phone,
	id2.firstName,
	id2.lastName,
	id2.birthdate
FROM Enrollment AS enr
	INNER JOIN Person AS per ON per.personID = enr.personID
	INNER JOIN [Identity] AS ide ON ide.identityID = per.currentIdentityID
	INNER JOIN POSEligibility AS pel ON pel.personID = per.personID
--		AND (GETDATE() BETWEEN pel.startDate AND pel.endDate
--			OR GETDATE() > pel.startDate AND pel.endDate IS NULL)
--		AND pel.startDate BETWEEN '2020-07-01' AND '2021-05-01'
		AND pel.startDate BETWEEN '2021-05-01' AND '2021-05-28'
		AND pel.eligibility IN('D','F','R','E')
--		AND pel.applicationID IS NOT NULL
	INNER JOIN calendar AS cal ON cal.calendarID = enr.calendarID
		AND cal.endYear = 2021
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.[name] NOT LIKE '%elementary%'
		AND sch.schoolID NOT IN(7,33)
	INNER JOIN HouseholdMember AS hme ON hme.personID = per.personID
		AND hme.endDate IS NULL
		AND hme.[secondary] = 0
	INNER JOIN HouseholdLocation AS hlo ON hlo.householdID = hme.householdID
		AND hlo.endDate IS NULL
	INNER JOIN [Address] AS [add] ON [add].addressID = hlo.addressID
		AND [add].postOfficeBox != 1
		AND [add].street NOT LIKE '%Box%'
	INNER JOIN RelatedPair AS rp ON rp.personID2 = per.personID
		AND rp.seq = 1
	INNER JOIN [Identity] AS id2 ON id2.personID = rp.personID1
	INNER JOIN Person AS per2 ON per2.currentIdentityID = id2.identityID

WHERE
	enr.serviceType = 'P'
	AND enr.endDate IS NULL
ORDER BY
	per.stateID,
	[priority]

SELECT 
	idStuID,
	lastName,
	firstName,
	middleName,
	gender,
	birthDate,
	schoolID,
	schoolName,
	gradeLevel,
	schoolEntryDate,
	schoolExitDate,
	econDisStatus,
	econDisDetermination,
	Address1,
	Address2,
	City,
	[State],
	zip,
	Phone,
	ParentGuardianFirstName,
	ParentGuardianLastName,
	ParentGuardianDOB 
FROM #REBT
WHERE [priority] = 1
DROP TABLE #REBT




/*
SELECT *
FROM POSEligibility
WHERE 
	GETDATE() BETWEEN startDate AND endDate
	AND eligibility IN('F','R')
	AND applicationID IS NOT NULL
*/
/*
SELECT *
FROM Homeless

SELECT 
	tab.[name],
	col.[name]
FROM sys.all_columns AS col
	INNER JOIN sys.tables AS tab ON tab.object_id = col.object_id
WHERE 
	col.[name] LIKE '%homeless%'
*/