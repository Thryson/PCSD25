 USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/15/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/18/2019>
-- Description:	<File 7/8 for Pearson products, Used to create roster of teachers>
-- Note 1:	<Different queries for different grade levels, broken out here to give you the ability to override where needed>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_staff>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #pearsonStaff (
	[priority] INT,
	staff_code INT, 
	last_name VARCHAR(25), 
	first_name VARCHAR(25), 
	middle_name VARCHAR(25), 
	email VARCHAR(25), 
	title VARCHAR(30), 
	staff_number INT, 
	federated_id VARCHAR(25))

--Elementary School Math
INSERT INTO #pearsonStaff
SELECT 
	CASE
		WHEN ssh.[role] = 'T' THEN RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID DESC, ssh.assignmentID DESC, sm.title DESC) 
		WHEN ssh.[role] = 'C' THEN 1
	END AS 'priority',
	--1 AS 'priority',
	sm.personID AS 'staff_code', 
	sm.lastName AS 'last_name', 
	sm.firstName AS 'first_name',  
	ISNULL(sm.middleName, '') AS 'middle_name', 
	ua.username + '@sd25.us' AS 'email', 
	sm.title AS 'title', 
	sm.staffNumber AS 'staff_number',
	ua.username + '@sd25.us' AS 'federated_id'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
		--AND c.homeroom = 1
		AND c.[name] = 'ICS Mathematics'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (1,2,3,4,5,6,8,7,9,10,11,12,13,14)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.trialID = se.trialID 
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))--######## REMEMBER +7
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
		--AND sm.staffNumber NOT IN('ISU','student teacher')
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] IN('T','C')


--Middle School English and Math
INSERT INTO #pearsonStaff
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID DESC, ssh.assignmentID DESC, sm.title DESC) AS 'priority', 
	sm.personID AS 'staff_code', 
	sm.lastName AS 'last_name', 
	sm.firstName AS 'first_name',  
	ISNULL(sm.middleName, '') AS 'middle_name', 
	ua.username + '@sd25.us' AS 'email', 
	sm.title AS 'title', 
	sm.staffNumber AS 'staff_number',
	ua.username + '@sd25.us' AS 'federated_id'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN('English','Math')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.trialID = se.trialID 
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
		--AND sm.staffNumber NOT IN('ISU','student teacher')
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] = 'T'


--High School English Social Studies & Science Teachers
INSERT INTO #pearsonStaff
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID DESC, ssh.assignmentID DESC, sm.title DESC) AS 'priority', 
	sm.personID AS 'staff_code', 
	sm.lastName AS 'last_name', 
	sm.firstName AS 'first_name',  
	ISNULL(sm.middleName, '') AS 'middle_name', 
	ua.username + '@sd25.us' AS 'email', 
	sm.title AS 'title', 
	sm.staffNumber AS 'staff_number',
	ua.username + '@sd25.us' AS 'federated_id'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN ('English','Science','Social Studies')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.trialID = se.trialID 
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
		--AND sm.staffNumber NOT IN('student teacher', 'ISU')
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] = 'T'

---------------------------------------------------------------------------------------------
--STAFF OVERRIDE EXCEPTIONS...
---------------------------------------------------------------------------------------------
INSERT INTO #pearsonStaff
SELECT DISTINCT
	RANK() OVER(PARTITION BY p.personID ORDER BY ea.title ),
	p.personID AS 'staff_code', 
	id.lastName AS 'last_name', 
	id.firstName AS 'first_name',  
	ISNULL(id.middleName, '') AS 'middle_name', 
	ua.username + '@sd25.us' AS 'email', 
	ea.title AS 'title', 
	p.staffNumber AS 'staff_number',
	ua.username + '@sd25.us' AS 'federated_id'
FROM Person AS p
	INNER JOIN [Identity] AS id ON p.currentIdentityID = id.identityID
	INNER JOIN UserAccount AS ua ON ua.personID = p.personID
		AND ua.ldapConfigurationID = 2
	INNER JOIN EmploymentAssignment AS ea ON ea.personID = p.personID
		AND ea.endDate IS NULL
WHERE 
	p.personID IN( 37204,
				   38196,
				   33409,
				   49729,
				   39398,
				   34755,
				   29875,
				   94296,
				   22958,
				   39253,
				   39009) 
INSERT INTO #pearsonStaff
VALUES
	(1,1,'Teacher 1','Test Teacher 1','','testteacher1@sd25.us','Training Account',1,'testteacher1@sd25.us')
---------------------------------------------------------------------------------------------


SELECT DISTINCT 
	ps.staff_code,
	ps.last_name,
	ps.first_name,
	ps.middle_name,
	ps.email,
	ps.title,
	ps.staff_number,
	ps.federated_id
FROM #pearsonStaff AS ps
WHERE ps.[priority] = 1
ORDER BY
	staff_code
DROP TABLE #pearsonStaff