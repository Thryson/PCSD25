USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <09/05/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <09/05/2019>
-- Description:	<File 2/3 for LevelSet products, used to create roster of students and assign to classes and schools>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_levelset_student>
-- =============================================

DECLARE @eYear INT, @cDay DATE;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

SELECT DISTINCT cal.schoolID AS 'School_ID',
	se.sectionID AS 'Class_ID',
	p.personID AS 'Student_ID',
	id.lastName AS 'Last_Name',
	id.firstName AS 'First_Name',
	ISNULL(id.middleName, '') AS 'Middle_Name',
	p.studentNumber + '@sd25.me' AS 'User_Name',
	'' AS 'Password',
	cc.[value] AS 'Grade'
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
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate
