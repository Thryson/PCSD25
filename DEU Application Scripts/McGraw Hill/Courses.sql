USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/29/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/30/2019>
-- Description:	<File 3/7 for McGraw Hill products, used to create roster of courses & assign schools>
-- Note 1:	<Different applciations for different grade levels, broken out here to seperate queries to give you the ability to override>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_mcgrawHill_courses>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's
CREATE TABLE #mcgrawHillCourses (
	sourcedId INT,
	[status] VARCHAR(4),
	dateLastModified VARCHAR(4),
	schoolYearSourcedId VARCHAR(4),
	title VARCHAR(35),
	courseCode INT,
	grades VARCHAR(4),
	orgSourcedId INT,
	subjects VARCHAR(4),
	subjectCodes VARCHAR(4))


--Science Core and Building Blocks Courses
INSERT INTO #mcgrawHillCourses
SELECT c.courseID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'' AS 'schoolYearSourcedId',
	c.[name] AS 'title',
	c.number AS 'courseCode',
	CASE cc.[value] 
		WHEN 'MX' THEN '3'
		WHEN 'KG' THEN 'K'
		ELSE cc.[value]
	END AS 'grades',
	cal.schoolID AS 'orgSourcedId',
	'' AS 'subjects',
	'' AS 'subjectCodes'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
	LEFT JOIN CustomCourse AS cc ON cc.courseID = c.courseID
		AND cc.attributeID = 322
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (1,2,3,4,5,6,8,9,10,11,12,13,14)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
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
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
WHERE c.number = 7100
	OR (c.homeroom = 1 AND dep.[name] = 'Attendance')


--MS Basic Math Courses
INSERT INTO #mcgrawHillCourses
SELECT c.courseID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'' AS 'schoolYearSourcedId',
	c.[name] AS 'title',
	c.number AS 'courseCode',
	CASE cc.[value] 
		WHEN 'MX' THEN '7'
		ELSE cc.[value]
	END AS 'grades',
	cal.schoolID AS 'orgSourcedId',
	'' AS 'subjects',
	'' AS 'subjectCodes'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Basic Math',
						 'Life Skills Math',
						 'Prac Math (SC)')
	LEFT JOIN CustomCourse AS cc ON cc.courseID = c.courseID
		AND cc.attributeID = 322
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

--MS Geography
INSERT INTO #mcgrawHillCourses
SELECT c.courseID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'' AS 'schoolYearSourcedId',
	c.[name] AS 'title',
	c.number AS 'courseCode',
	CASE cc.[value] 
		WHEN 'MX' THEN '7'
		ELSE cc.[value]
	END AS 'grades',
	cal.schoolID AS 'orgSourcedId',
	'' AS 'subjects',
	'' AS 'subjectCodes'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('Eastern Hemisphere Geography', 
						 'Western Hemisphere Geography')
	LEFT JOIN CustomCourse AS cc ON cc.courseID = c.courseID
		AND cc.attributeID = 322
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


--MS Basic Math Courses
INSERT INTO #mcgrawHillCourses
SELECT c.courseID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'' AS 'schoolYearSourcedId',
	c.[name] AS 'title',
	c.number AS 'courseCode',
	CASE cc.[value] 
		WHEN 'MX' THEN '7'
		ELSE cc.[value]
	END AS 'grades',
	cal.schoolID AS 'orgSourcedId',
	'' AS 'subjects',
	'' AS 'subjectCodes'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] IN ('lifesklsmath')
	LEFT JOIN CustomCourse AS cc ON cc.courseID = c.courseID
		AND cc.attributeID = 322
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

--HS Core Math Courses
INSERT INTO #mcgrawHillCourses
SELECT c.courseID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'' AS 'schoolYearSourcedId',
	c.[name] AS 'title',
	c.number AS 'courseCode',
	CASE cc.[value] 
		WHEN 'MX' THEN '10'
		ELSE cc.[value]
	END AS 'grades',
	cal.schoolID AS 'orgSourcedId',
	'' AS 'subjects',
	'' AS 'subjectCodes'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] NOT LIKE 'Honors%'
		AND c.[name] NOT LIKE 'AP%'
	LEFT JOIN CustomCourse AS cc ON cc.courseID = c.courseID
		AND cc.attributeID = 322
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

--HS Economics courses
INSERT INTO #mcgrawHillCourses
SELECT c.courseID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	'' AS 'schoolYearSourcedId',
	c.[name] AS 'title',
	c.number AS 'courseCode',
	CASE cc.[value] 
		WHEN 'MX' THEN '10'
		ELSE cc.[value]
	END AS 'grades',
	cal.schoolID AS 'orgSourcedId',
	'' AS 'subjects',
	'' AS 'subjectCodes'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.[name] = 'Economics'
	LEFT JOIN CustomCourse AS cc ON cc.courseID = c.courseID
		AND cc.attributeID = 322
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

INSERT INTO #mcgrawHillCourses
VALUES
	(1,'','','','Test Course',1,10,24,'','')


SELECT DISTINCT *
FROM #mcgrawHillCourses

DROP TABLE #mcgrawHillCourses