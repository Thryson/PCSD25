USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <09/05/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <09/05/2019>
-- Description:	<File 3/3 for LevelSet products, used to create roster of students and assign to classes and schools>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_levelset_teacher>
-- =============================================

DECLARE @eYear INT, @cDay DATE;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's
CREATE TABLE #levelsetTeacher (
	[priority] INT,
	School_ID INT,
	Class_ID INT,
	Class_Name VARCHAR(45),
	Teacher_ID INT,
	First_Name VARCHAR(75),
	Last_Name VARCHAR(75),
	Login_Name VARCHAR(45),
	[Password] VARCHAR(4),
	Grade INT,
	Email VARCHAR(45))

--HS Basic English Teachers 9 & 10
INSERT INTO #levelsetTeacher
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority',
	cal.schoolID AS 'School_ID',
	se.sectionID AS 'Class_ID',
	sch.comments + ' ' + c.number + '-' + CONVERT(VARCHAR(8), se.number) AS 'Class_Name',
	sm.personID AS 'Teacher_ID',
	sm.firstName AS 'First_Name',
	sm.lastName AS 'Last_Name',
	ua.username + '@sd25.us' AS 'Login_Name',
	'' AS 'Password',
	cc.[value] AS 'Grade',
	ua.username + '@sd25.us' AS 'Email'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] LIKE '%Basic Eng%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Special Education'
	INNER JOIN CustomCourse AS cc ON cc.courseID = c.courseID 
		AND cc.attributeID = 322
		AND cc.[value] IN ('9','10')
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
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'


SELECT DISTINCT lst.School_ID,
	lst.Class_ID,
	lst.Class_Name,
	lst.Teacher_ID,
	lst.First_Name,
	lst.Last_Name,
	lst.Login_Name,
	lst.[Password],
	lst.Grade,
	lst.Email
FROM #levelsetTeacher AS lst
WHERE lst.[priority] = 1


DROP TABLE #levelsetTeacher