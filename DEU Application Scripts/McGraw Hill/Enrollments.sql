USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/31/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/31/2019>
-- Description:	<File 4/7 for McGraw Hill products, used to assign both Teachers and Students to Sections, Schools & Users>
-- Note 1:	<Different applciations for different grade levels, broken out here to seperate queries to give you the ability to override>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_mcgrawHill_enrollments>
-- =============================================

DECLARE @eYear INT, @cDay DATE;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's
CREATE TABLE #mcgrawHillEnrollments (
	[priority] INT,
	sourcedId INT,
	[status] VARCHAR(4),
	dateLastmodified VARCHAR(4),
	classSourcedId Int,
	schoolSourcedId INT,
	userSourcedId INT,
	[role] VARCHAR(20),
	[primary] VARCHAR(4),
	beginDate DATE,
	endDate DATE)


--EL Core Science and Building Blocks Students
INSERT INTO #mcgrawHillEnrollments
SELECT 1 AS 'priority',
	rs.rosterID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	p.personID AS 'userSourcedId',
	'student' AS 'role',
	'' AS 'primary',
	ISNULL(rs.startdate, te.startDate) AS 'beginDate',
	ISNULL(rs.endDate, te.endDate) AS 'endDate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
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


--MS Basic Math Courses
INSERT INTO #mcgrawHillEnrollments
SELECT 1 AS 'priority',
	rs.rosterID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	p.personID AS 'userSourcedId',
	'student' AS 'role',
	'' AS 'primary',
	ISNULL(rs.startdate, te.startDate) AS 'beginDate',
	ISNULL(rs.endDate, te.endDate) AS 'endDate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Basic Math','Life Skills Math','Prac Math (SC)')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Special Education'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
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

--MS Geography Courses
INSERT INTO #mcgrawHillEnrollments
SELECT 1 AS 'priority',
	rs.rosterID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	p.personID AS 'userSourcedId',
	'student' AS 'role',
	'' AS 'primary',
	ISNULL(rs.startdate, te.startDate) AS 'beginDate',
	ISNULL(rs.endDate, te.endDate) AS 'endDate'
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


--HS Basic Math Courses
INSERT INTO #mcgrawHillEnrollments
SELECT 1 AS 'priority',
	rs.rosterID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	p.personID AS 'userSourcedId',
	'student' AS 'role',
	'' AS 'primary',
	ISNULL(rs.startdate, te.startDate) AS 'beginDate',
	ISNULL(rs.endDate, te.endDate) AS 'endDate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('lifesklsmath')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Special Education'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
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

--HS Core Math Courses
INSERT INTO #mcgrawHillEnrollments
SELECT 1 AS 'priority',
	rs.rosterID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	p.personID AS 'userSourcedId',
	'student' AS 'role',
	'' AS 'primary',
	ISNULL(rs.startdate, te.startDate) AS 'beginDate',
	ISNULL(rs.endDate, te.endDate) AS 'endDate'
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

--HS Economics courses
INSERT INTO #mcgrawHillEnrollments
SELECT 1 AS 'priority',
	rs.rosterID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	p.personID AS 'userSourcedId',
	'student' AS 'role',
	'' AS 'primary',
	ISNULL(rs.startdate, te.startDate) AS 'beginDate',
	ISNULL(rs.endDate, te.endDate) AS 'endDate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] = 'Economics'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Social Studies'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
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


--EL Core Science and Building Blocks Teachers
INSERT INTO #mcgrawHillEnrollments
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.historyID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	ssh.personID AS 'userSourcedId',
	'teacher' AS 'role',
	'' AS 'primary',
	ISNULL(ssh.startdate, te.startDate) AS 'beginDate',
	ISNULL(ssh.endDate, te.endDate) AS 'endDate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
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
INSERT INTO #mcgrawHillEnrollments
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.historyID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	ssh.personID AS 'userSourcedId',
	'teacher' AS 'role',
	'' AS 'primary',
	ISNULL(ssh.startdate, te.startDate) AS 'beginDate',
	ISNULL(ssh.endDate, te.endDate) AS 'endDate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Basic Math','Life Skills Math','Prac Math (SC)')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Special Education'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
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

--MS Geography Teachers
INSERT INTO #mcgrawHillEnrollments
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.historyID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	ssh.personID AS 'userSourcedId',
	'teacher' AS 'role',
	'' AS 'primary',
	ISNULL(ssh.startdate, te.startDate) AS 'beginDate',
	ISNULL(ssh.endDate, te.endDate) AS 'endDate'
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
INSERT INTO #mcgrawHillEnrollments
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.historyID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	ssh.personID AS 'userSourcedId',
	'teacher' AS 'role',
	'' AS 'primary',
	ISNULL(ssh.startdate, te.startDate) AS 'beginDate',
	ISNULL(ssh.endDate, te.endDate) AS 'endDate'
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
INSERT INTO #mcgrawHillEnrollments
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.historyID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	se.sectionID AS 'classSourcedId',
	sch.schoolID AS 'schoolSourcedId',
	ssh.personID AS 'userSourcedId',
	'teacher' AS 'role',
	'' AS 'primary',
	ISNULL(ssh.startdate, te.startDate) AS 'beginDate',
	ISNULL(ssh.endDate, te.endDate) AS 'endDate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] = 'Economics'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Social Studies'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
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


INSERT INTO #mcgrawHillEnrollments
VALUES
	(1,1,'','',1,24,1,'teacher','','',''),
	(1,2,'','',1,24,2,'student','','','')

SELECT DISTINCT mhe.sourcedId,
	mhe.[status],
	mhe.dateLastmodified,
	mhe.classSourcedId,
	mhe.schoolSourcedId,
	mhe.userSourcedId,
	mhe.[role],
	mhe.[primary],
	mhe.beginDate,
	mhe.endDate
FROM #mcgrawHillEnrollments AS mhe
WHERE mhe.[priority] = 1
ORDER BY
	sourcedId
DROP TABLE #mcgrawHillEnrollments