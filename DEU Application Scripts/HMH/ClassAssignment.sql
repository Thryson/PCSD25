USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/08/2019>
-- Updater:		<Mullett, Jacob>
-- Update date: <07/24/2019>
-- Description:	<File 2/3 for HMH products, takes staff and students and assigns them to classes>
-- Note 1:	<Different applciations for different grade levels, broken out here to seperate queries to give you the ability to override>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_HMH_classAssingnment>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's 
CREATE TABLE #hmhca (
	[priority] INT,
	SCHOOLYEAR INT,
	CLASSLOCALID INT,
	LASID INT,
	[ROLE] VARCHAR(1),
	POSITION VARCHAR(1))


--Elementary Student Class Assignments
INSERT INTO #hmhca
SELECT 1 AS [priority],
	@eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID', 
	p.studentNumber AS 'LASID', 
	'S' AS 'ROLE', 
	'' AS 'POSITION'
FROM Person AS p
	INNER JOIN Roster AS rs ON rs.personID = p.personID
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Attendance'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID != 7
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))


--Middle School Student Class Assignments
INSERT INTO #hmhca
SELECT 1 AS [priority],
	@eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID', 
	p.studentNumber AS 'LASID', 
	'S' AS 'ROLE', 
	'' AS 'POSITION'
FROM Person AS p
	INNER JOIN Roster AS rs ON rs.personID = p.personID
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
--		AND dep.[name] = 'Science'
--		 OR dep.[name] = 'Social Studies'
		AND dep.[name] IN('Science','Social Studies')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))


--High School Student Class Assignments
INSERT INTO #hmhca
SELECT 1 AS [priority],
	@eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID', 
	p.studentNumber AS 'LASID', 
	'S' AS 'ROLE', 
	'' AS 'POSITION'
FROM Person AS p
	INNER JOIN Roster AS rs ON rs.personID = p.personID
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[name] LIKE '%Spanish%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN('Foreign Language')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))


--Elementary Teacher Class Assignments
INSERT INTO #hmhca
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority',
	@eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID', 
	sm.personID AS 'LASID', 
	'T' AS 'ROLE',
	'L' AS 'POSITION'
--	CASE 
--		WHEN ssh.[role] = 'T' THEN 'L'
--		ELSE 'T'
--	END AS 'POSITION'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Attendance'
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID
		AND cal.endyear = @eYear
		AND cal.schoolID != 7
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'
	AND sm.staffNumber NOT IN ('ISU', 'INTERN','Student Teacher')


--Middle School Teacher Class Assignments
INSERT INTO #hmhca
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority',
	@eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID', 
	sm.personID AS 'LASID', 
	'T' AS 'ROLE',
	'L' AS 'Position'
--	CASE 
--		WHEN ssh.[role] = 'T' THEN 'L'
--		ELSE 'T'
--	END AS 'POSITION'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
--		AND dep.[name] = 'Science'
--		 OR dep.[name] = 'Social Studies'
		AND dep.[name] IN('Science','Social Studies')
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID
		AND cal.endyear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'
	AND sm.staffNumber NOT IN ('ISU', 'INTERN','Student Teacher')


--High School Teacher Class Assignments
INSERT INTO #hmhca
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority',
	@eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID', 
	sm.personID AS 'LASID',  
	'T' AS 'ROLE', 
	'L' AS 'POSITION'
--	CASE 
--		WHEN ssh.[role] = 'T' THEN 'L'
--		ELSE 'T'
--	END AS 'POSITION'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		AND c.[name] LIKE '%Spanish%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN('Foreign Language')
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID
		AND cal.endyear = @eYear
		AND cal.schoolID IN (18,19,20,22)
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'
	AND sm.staffNumber NOT IN ('ISU', 'INTERN','Student Teacher')

INSERT INTO #hmhca
VALUES
	(1,@eYear,1,1,'T','L'),
	(1,@eYear,1,2,'S','')


SELECT DISTINCT hca.SCHOOLYEAR,
	hca.CLASSLOCALID,
	hca.LASID,
	hca.[ROLE],
	hca.POSITION
FROM #hmhca AS hca
WHERE hca.[priority] = 1
DROP TABLE #hmhca