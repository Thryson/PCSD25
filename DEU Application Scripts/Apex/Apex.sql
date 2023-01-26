USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <08/16/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <08/16/2019>
-- Description:	<File 1/1 for Apex, used to create roster of students, teachers and schools to be assigned manually>
-- Note 1:	<Seperated by person type for overrides>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_apex_1file>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #apex (
	schoolName VARCHAR(45),
	schoolID INT,
	userID INT,
	[role] VARCHAR(4),
	emailAddress VARCHAR(35),
	firstName VARCHAR(75),
	lastName VARCHAR(75))


--Credit Recovery Students
INSERT INTO #apex
SELECT CASE 
		WHEN sch.schoolID = 29 THEN 'New Horizon High School'
		WHEN sch.schoolID = 31 THEN 'Summer School (7-12)'
		ELSE sch.[name]
	END AS 'schoolName',
	CASE 
		WHEN sch.schoolID = 29 THEN 22
		WHEN sch.schoolID = 31 THEN 34
		ELSE sch.schoolID
	END AS 'schoolID',
	p.personID AS 'userID',
	'S' AS 'role',
	p.studentNumber + '@sd25.me' AS 'emailAddress',
	id.firstName,
	id.lastName
FROM roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[name] LIKE 'Credit%'
		OR c.[name] LIKE 'Online learning%'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,18,19,20,21,22,28,29,31,34)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1')))
--			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6')))
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID

--Credit Recovery Teachers
INSERT INTO #apex
SELECT CASE 
		WHEN sch.schoolID = 29 THEN 'New Horizon High School'
		WHEN sch.schoolID = 31 THEN 'Summer School (7-12)'
		ELSE sch.[name]
	END AS 'schoolName',
	CASE 
		WHEN sch.schoolID = 29 THEN 22
		WHEN sch.schoolID = 31 THEN 34
		ELSE sch.schoolID
	END AS 'schoolID',
	ssh.personID AS 'userID',
	'T' AS 'role',
	ua.username + '@sd25.us' AS 'emailAddress',
	sm.firstName,
	sm.lastName
FROM roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[name] LIKE 'Credit%'
		OR c.[name] LIKE 'Online learning%'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,18,19,20,21,22,28,29,31,34)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -7, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1')))
--			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID
		AND ua.ldapConfigurationID = '2'


--Credit Recovery Administrators
INSERT INTO #apex
SELECT CASE 
		WHEN sch.schoolID = 29 THEN 'New Horizon High School'
		WHEN sch.schoolID = 31 THEN 'Summer School (7-12)'
		ELSE sch.[name]
	END AS 'schoolName',
	CASE 
		WHEN sch.schoolID = 29 THEN 22
		WHEN sch.schoolID = 31 THEN 34
		ELSE sch.schoolID
	END AS 'schoolID',
	sm.personID AS 'userID',
	'SC' AS 'role',
	ua.username + '@sd25.us' AS 'emailAddress',
	sm.firstName,
	sm.lastName
FROM staffMember AS sm
	INNER JOIN School AS sch ON sch.schoolID = sm.schoolID
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID
		AND ua.ldapConfigurationID = '2'
WHERE ((sm.endDate IS NULL OR @cDay <= sm.endDate)
			AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	AND (sm.title LIKE '%Asst. Principal%'
		OR sm.personID IN (22881, 46166))


--Homebound Students tuesday-friday
INSERT INTO #apex
SELECT 'New Horizon High School' AS 'schoolName',
	'22' AS schoolID,
	p.personID AS 'userID',
	'S' AS 'role',
	p.studentNumber + '@sd25.me' AS 'emailAddress',
	id.firstName,
	id.lastName 
FROM Person AS p
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Enrollment AS en ON en.personID = id.personID
		AND ((@cDay BETWEEN en.startDate AND en.endDate)
				OR (en.startDate < @cDay AND en.endDate IS NULL))
		AND en.endYear = @eYear
	INNER JOIN attendanceCode AS atc ON atc.personID = en.personID
		AND DATEPART(dw, GETDATE()) IN (3,4,5,6) 
WHERE atc.[date] = DATEADD(DAY, -1, CAST(GETDATE()AS DATE))
	AND atc.code = 'HBD'


--Homebound Students monday
INSERT INTO #apex
SELECT 'New Horizon High School' AS 'schoolName',
	'22' AS schoolID,
	p.personID AS 'userID',
	'S' AS 'role',
	p.studentNumber + '@sd25.me' AS 'emailAddress',
	id.firstName,
	id.lastName 
FROM Person AS p
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Enrollment AS en ON en.personID = id.personID
		AND ((@cDay BETWEEN en.startDate AND en.endDate)
				OR (en.startDate < @cDay AND en.endDate IS NULL))
		AND en.endYear = @eYear
	INNER JOIN attendanceCode AS atc ON atc.personID = en.personID
		AND DATEPART(dw, GETDATE()) = 2
WHERE atc.[date] = DATEADD(DAY, -3, CAST(GETDATE()AS DATE))
	AND atc.code = 'HBD'


--Single teacher rosters
INSERT INTO #apex
SELECT 'New Horizon High School' AS 'schoolName',
	'22' AS schoolID,
	p.personID AS 'userID',
	'T' AS 'role',
	ua.username + '@sd25.us' AS 'emailAddress',
	id.firstName,
	id.lastName
FROM Person AS p
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN UserAccount AS ua ON ua.personID = p.personID
		AND ua.ldapConfigurationID = '2'
WHERE p.personID IN (39709, 102723)


SELECT DISTINCT *
FROM #apex AS a
ORDER BY a.[role]

DROP TABLE #apex