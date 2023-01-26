USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/15/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/15/2019>
-- Description:	<File 8/8 for Pearson products, Used to create roster of students>
-- Note 1:	<Different queries for different grade levels, broken out here to give you the ability to override where needed>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_student>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #pearsonStudent (
	student_code INT,
	last_name VARCHAR(50),
	first_name VARCHAR(50),
	middle_name VARCHAR(35),
	gender_code VARCHAR(10),
	dob VARCHAR(1),
	email VARCHAR(25),
	student_number INT,
	federated_id VARCHAR(25))

--Elementary School Math Students
INSERT INTO #pearsonStudent
SELECT p.personID AS 'student_code',
	i.lastName AS 'last_name',
	i.firstName AS 'first_name',
	ISNULL (i.middleName, '') AS 'middle_name',
	i.gender AS 'gender_code',
	'' AS 'dob',
	p.studentNumber + '@sd25.me' AS 'email',
	p.studentNumber AS 'student_number',
	p.studentNumber + '@sd25.me' AS 'federated_id'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
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
		AND sp.trialID = sp.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS i ON i.identityID = p.currentIdentityID 
		AND i.personID = p.personID


--Middle School English and Math Students
INSERT INTO #pearsonStudent
SELECT p.personID AS 'student_code',
	i.lastName AS 'last_name',
	i.firstName AS 'first_name',
	ISNULL (i.middleName, '') AS 'middle_name',
	i.gender AS 'gender_code',
	'' AS 'dob',
	p.studentNumber + '@sd25.me' AS 'email',
	p.studentNumber AS 'student_number',
	p.studentNumber + '@sd25.me' AS 'federated_id'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN ('English','Social Studies','Math')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.trialID = se.trialID 
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = sp.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS i ON i.identityID = p.currentIdentityID 
		AND i.personID = p.personID


--High School English, Social Studies & Science Students
INSERT INTO #pearsonStudent
SELECT p.personID AS 'student_code',
	i.lastName AS 'last_name',
	i.firstName AS 'first_name',
	ISNULL (i.middleName, '') AS 'middle_name', 
	i.gender AS 'gender_code', 
	'' AS 'dob', 
	p.studentNumber + '@sd25.me' AS 'email', 
	p.studentNumber AS 'student_number', 
	p.studentNumber + '@sd25.me' AS 'federated_id'
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
		AND sp.trialID = sp.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS i ON i.identityID = p.currentIdentityID 
		AND i.personID = p.personID

INSERT INTO #pearsonStudent
VALUES
	(2,'Student 1','Test Student 1','','M','','teststudent1@sd25.me',2,'teststudent1@sd25.me')

SELECT DISTINCT *
FROM #pearsonStudent
ORDER BY
	student_code,
	last_name

DROP TABLE #pearsonStudent