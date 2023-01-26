USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/29/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/30/2019>
-- Description:	<File 7/7 for McGraw Hill products, used to create roster of students and staff>
-- Note 1:	<Different applciations for different grade levels, broken out here to seperate queries to give you the ability to override>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_mcgrawHill_users>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's
CREATE TABLE #mcgrawHillUsers (
	[priority] INT,
	sourcedId INT,
	[status] VARCHAR(4),
	dateLastModified VARCHAR(4),
	enabledUser VARCHAR(4),
	orgSourcedIds INT,
	[role] VARCHAR(20),
	username VARCHAR(35),
	userIds INT,
	givenName VARCHAR(75),
	familyName VARCHAR(75),
	middleName VARCHAR(4),
	identifier INT,
	email VARCHAR(35),
	sms VARCHAR(4),
	phone VARCHAR(4),
	agentSourcedIds VARCHAR(4),
	grades VARCHAR(4),
	[password] VARCHAR(4))

CREATE TABLE #duploControl(
	[duploControl] INT,
	--[priority] INT,
	sourcedId INT,
	[status] VARCHAR(4),
	dateLastModified VARCHAR(4),
	enabledUser VARCHAR(4),
	orgSourcedIds INT,
	[role] VARCHAR(20),
	username VARCHAR(35),
	userIds INT,
	givenName VARCHAR(75),
	familyName VARCHAR(75),
	middleName VARCHAR(4),
	identifier INT,
	email VARCHAR(35),
	sms VARCHAR(4),
	phone VARCHAR(4),
	agentSourcedIds VARCHAR(4),
	grades VARCHAR(4),
	[password] VARCHAR(4))
	


--EL Students Science Core and Building Blocks
INSERT INTO #mcgrawHillUsers	
SELECT 1 AS 'priority',
	p.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'student' AS 'role',
	p.studentNumber + '@sd25.me' AS 'username',
	p.studentNumber AS 'userIds',
	id.firstName AS 'givenName',
	id.lastName AS 'familyName',
	ISNULL(LEFT(id.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	p.studentNumber + '@sd25.me' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
		AND cal.schoolID IN (1,2,3,4,5,6,8,9,10,11,12,13,14)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE (rs.endDate IS NULL 
		OR @cDay <= rs.endDate)
	AND (c.number = 7100
		OR (c.homeroom = 1 AND dep.[name] = 'Attendance'))


--MS Basic Math Students
INSERT INTO #mcgrawHillUsers
SELECT 1 AS 'priority',
	p.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'student' AS 'role',
	p.studentNumber + '@sd25.me' AS 'username',
	p.studentNumber AS 'userIds',
	id.firstName AS 'givenName',
	id.lastName AS 'familyName',
	ISNULL(LEFT(id.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	p.studentNumber + '@sd25.me' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Basic Math','Life Skills Math','Prac Math (SC)')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Special Education'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate

--MS Geography 
INSERT INTO #mcgrawHillUsers
SELECT 1 AS 'priority',
	p.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'student' AS 'role',
	p.studentNumber + '@sd25.me' AS 'username',
	p.studentNumber AS 'userIds',
	id.firstName AS 'givenName',
	id.lastName AS 'familyName',
	ISNULL(LEFT(id.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	p.studentNumber + '@sd25.me' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Eastern Hemisphere Geography', 
						 'Western Hemisphere Geography')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Social Studies'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate


--MS Basic Math Students
INSERT INTO #mcgrawHillUsers
SELECT 1 AS 'priority',
	p.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'student' AS 'role',
	p.studentNumber + '@sd25.me' AS 'username',
	p.studentNumber AS 'userIds',
	id.firstName AS 'givenName',
	id.lastName AS 'familyName',
	ISNULL(LEFT(id.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	p.studentNumber + '@sd25.me' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('lifesklsmath')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Special Education'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate

--HS Core Math Students
INSERT INTO #mcgrawHillUsers
SELECT 1 AS 'priority',
	p.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'student' AS 'role',
	p.studentNumber + '@sd25.me' AS 'username',
	p.studentNumber AS 'userIds',
	id.firstName AS 'givenName',
	id.lastName AS 'familyName',
	ISNULL(LEFT(id.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	p.studentNumber + '@sd25.me' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] NOT LIKE 'Honors%'
		AND c.[name] NOT LIKE 'AP%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Math'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate

--HS Economics Students
INSERT INTO #mcgrawHillUsers
SELECT 1 AS 'priority',
	p.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'student' AS 'role',
	p.studentNumber + '@sd25.me' AS 'username',
	p.studentNumber AS 'userIds',
	id.firstName AS 'givenName',
	id.lastName AS 'familyName',
	ISNULL(LEFT(id.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	p.studentNumber + '@sd25.me' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] = 'Economics'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Social Studies'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate


--EL Teachers Science Core and Building Blocks
INSERT INTO #mcgrawHillUsers
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	sm.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'teacher' AS 'role',
	ua.username + '@sd25.us' AS 'username',
	sm.staffNumber AS 'userIds',
	sm.firstName AS 'givenName',
	sm.lastName AS 'familyName',
	ISNULL(LEFT(sm.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	ua.username + '@sd25.us' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (1,2,3,4,5,6,8,9,10,11,12,13,14)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ISNUMERIC(sm.staffNumber) = 1
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'
	AND (c.number = 7100
			OR (c.homeroom = 1 AND dep.[name] = 'Attendance'))
	

--MS Basic Math Teachers
INSERT INTO #mcgrawHillUsers
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	sm.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'teacher' AS 'role',
	ua.username + '@sd25.us' AS 'username',
	sm.staffNumber AS 'userIds',
	sm.firstName AS 'givenName',
	sm.lastName AS 'familyName',
	ISNULL(LEFT(sm.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	ua.username + '@sd25.us' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Basic Math','Life Skills Math','Prac Math (SC)')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Special Education'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ISNUMERIC(sm.staffNumber) = 1
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'

--MS Geography Teacher
INSERT INTO #mcgrawHillUsers
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	sm.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'teacher' AS 'role',
	ua.username + '@sd25.us' AS 'username',
	sm.staffNumber AS 'userIds',
	sm.firstName AS 'givenName',
	sm.lastName AS 'familyName',
	ISNULL(LEFT(sm.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	ua.username + '@sd25.us' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Eastern Hemisphere Geography', 
						 'Western Hemisphere Geography')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Social Studies'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ISNUMERIC(sm.staffNumber) = 1
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'


--HS Core Math Teachers
INSERT INTO #mcgrawHillUsers
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	sm.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'teacher' AS 'role',
	ua.username + '@sd25.us' AS 'username',
	sm.staffNumber AS 'userIds',
	sm.firstName AS 'givenName',
	sm.lastName AS 'familyName',
	ISNULL(LEFT(sm.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	ua.username + '@sd25.us' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] NOT LIKE 'Honors%'
		AND c.[name] NOT LIKE 'AP%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Math'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ISNUMERIC(sm.staffNumber) = 1
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'

--HS Economics Teachers
INSERT INTO #mcgrawHillUsers
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	sm.personID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'YES' AS 'enabledUser',
	sch.schoolID AS 'orgSourcedIds',
	'teacher' AS 'role',
	ua.username + '@sd25.us' AS 'username',
	sm.staffNumber AS 'userIds',
	sm.firstName AS 'givenName',
	sm.lastName AS 'familyName',
	ISNULL(LEFT(sm.middleName, 1), '') AS 'middleName',
	'' AS 'identifier',
	ua.username + '@sd25.us' AS 'email',
	'' AS 'sms',
	'' AS 'phone',
	'' AS 'agentSourcedIds',
	'' AS 'grades',
	'' AS 'password'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] = 'Economics'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Social Studies'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ISNUMERIC(sm.staffNumber) = 1
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'

INSERT INTO #duploControl
VALUES
	(1,1,'','','YES',24,'teacher','testteacher1@sd25.us',1,'Test Teacher 1','Teacher 1','',0,'testteacher1@sd25.us','','','','',''),
	(1,2,'','','YES',24,'student','teststudent1@sd25.me',2,'Test Student 1','Student 1','',0,'teststudent1@sd25.me','','','','','')

INSERT INTO #duploControl
SELECT DISTINCT 
	RANK() OVER(PARTITION BY mhu.sourcedId ORDER BY mhu.orgSourcedIds DESC),
	mhu.sourcedId,
	mhu.[status],
	mhu.dateLastModified,
	mhu.enabledUser,
	mhu.orgSourcedIds,
	mhu.[role],
	mhu.username,
	mhu.userIds,
	mhu.givenName,
	mhu.familyName,
	mhu.middleName,
	mhu.identifier,
	mhu.email,
	mhu.sms,
	mhu.phone,
	mhu.agentSourcedIds,
	mhu.grades,
	mhu.[password]
FROM #mcgrawHillUsers AS mhu
WHERE mhu.[priority] = 1

SELECT 
	dplc.sourcedId,
	dplc.[status],
	dplc.dateLastModified,
	dplc.enabledUser,
	dplc.orgSourcedIds,
	dplc.[role],
	dplc.username,
	dplc.userIds,
	dplc.givenName,
	dplc.familyName,
	dplc.middleName,
	dplc.identifier,
	dplc.email,
	dplc.sms,
	dplc.phone,
	dplc.agentSourcedIds,
	dplc.grades,
	dplc.[password]
FROM #duploControl AS dplc
WHERE duploControl = 1


DROP TABLE #mcgrawHillUsers, #duploControl