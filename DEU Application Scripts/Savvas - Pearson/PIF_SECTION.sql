USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/12/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/18/2019>
-- Description:	<File 3/8 for Pearson products, Used create roster of sections>
-- Note 1:	<Different queries for different grade levels, broken out here to give you the ability to override where needed>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_pif_section>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #pearsonPIFSection (
	native_section_code INT, 
	school_code INT,
	section_type VARCHAR(25),
	section_type_description VARCHAR(5),
	date_start VARCHAR(10), 
	date_end VARCHAR(10),
	school_year INT,
	course_number INT,
	course_name VARCHAR(40),
	section_name VARCHAR(60),
	section_number VARCHAR (20),
	subjects VARCHAR(25),
	grades VARCHAR(50),
	class_type VARCHAR(10))

--Elementary School Math sections
INSERT INTO #pearsonPIFSection
SELECT se.sectionID AS 'native_section_code', 
	cal.schoolID AS 'school_code', 
	'Trimester' AS 'section_type', 
	te.[name] AS 'section_type_description', 
	CONVERT(VARCHAR(10), te.startDate, 121) AS 'date_start', 
	CONVERT(VARCHAR(10), te.endDate, 121) AS 'date_end',  
	@eYear - 1 AS 'school_year', 
	c.number AS 'course_number', 
	CASE
		WHEN RIGHT(c.[name],2)='KG' THEN 'ICS Mathematics' + ' ' + RIGHT(c.[name],2)
		WHEN RIGHT(c.[name],2)!='KG' THEN 'ICS Mathematics' + ' ' + RIGHT(c.[name],4)--static due to student renders on course = AM attendance in the course join
	END AS 'course_name',
	'ICS Mathematics' + '-' + CONVERT(VARCHAR(3), se.number)+'-'+te.[name] AS 'section_name', 
	c.number + '-' + CONVERT(VARCHAR(3), se.number) AS 'section_number', 
	'Math' AS 'subjects', 
	'KG,01,02,03,04,05' AS 'grades', 
	'scheduled' AS 'class_type'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		AND c.[name] LIKE '%AM attend%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		--AND dep.[name] IN('English','Math')
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
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))


--Middle School English and Math Classes
INSERT INTO #pearsonPIFSection
SELECT se.sectionID AS 'native_section_code', 
	cal.schoolID AS 'school_code', 
	'Trimester' AS 'section_type', 
	te.[name] AS 'section_type_description', 
	CONVERT(VARCHAR(10), te.startDate, 121) AS 'date_start', 
	CONVERT(VARCHAR(10), te.endDate, 121) AS 'date_end',  
	@eYear - 1 AS 'school_year', 
	c.number AS 'course_number', 
	c.[name] AS 'course_name', 
	CASE
		WHEN dep.[name] LIKE '%English%' THEN 'English - Term: ' + te.[name] + ' - Period: ' + prd.[name] 
		WHEN dep.[name] LIKE '%Math%'	   THEN 'Math - Term: ' + te.[name] + ' - Period: ' + prd.[name]
	END AS 'section_name', 
	c.number + '-' + CONVERT(VARCHAR(3), se.number) AS 'section_number', 
	dep.[name] AS 'subjects', 
	'06,07,08' AS 'grades', 
	'scheduled' AS 'class_type'
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
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Period] AS prd ON prd.periodID = sp.periodID


--High School English, Social Studies & Science Classes
INSERT INTO #pearsonPIFSection
SELECT se.sectionID AS 'native_section_code', 
	cal.schoolID AS 'school_code', 
	'Trimester' AS 'section_type', 
	te.[name] AS 'section_type_description', 
	CONVERT(VARCHAR(10), te.startDate, 121) AS 'date_start', 
	CONVERT(VARCHAR(10), te.endDate, 121) AS 'date_end',  
	@eYear - 1 AS 'school_year', 
	c.number AS 'course_number', 
	c.[name] AS 'course_name', 
	CASE
		WHEN dep.[name] LIKE '%English%' THEN 'English - Term: ' + te.[name] + ' - Period: ' + prd.[name] 
		WHEN dep.[name] LIKE '%Science%' THEN 'Science - Term: ' + te.[name] + ' - Period: ' + prd.[name]	-----------------------------------	LEFT OFF FORMATING SECTION NAMES FOR SECTIONS
		WHEN dep.[name] LIKE '%Social%' THEN 'Social Studies - Term: ' + te.[name] + ' - Period: ' + prd.[name]
	END AS 'section_name', 
	c.number + '-' + CONVERT(VARCHAR(3), se.number) AS 'section_number', 
	dep.[name] AS 'subjects', 
	'09,10,11,12' AS 'grades', 
	'scheduled' AS 'class_type'
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
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Period] AS prd ON prd.periodID = sp.periodID

---------------------------------------------------------------------------------------------
--STAFF OVERRIDE EXCEPTIONS...
---------------------------------------------------------------------------------------------
INSERT INTO #pearsonPIFSection 
VALUES
	(000001,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0001-1','Test','KG,01,02,03,04,05','scheduled'),
	(000002,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0002-1','Test','KG,01,02,03,04,05','scheduled'),
	(000003,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0003-1','Test','KG,01,02,03,04,05','scheduled'),
	(000004,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0004-1','Test','KG,01,02,03,04,05','scheduled'),
	(000005,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0005-1','Test','KG,01,02,03,04,05','scheduled'),
	(000006,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0006-1','Test','KG,01,02,03,04,05','scheduled'),
	(000007,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0007-1','Test','KG,01,02,03,04,05','scheduled'),
	(000008,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0008-1','Test','KG,01,02,03,04,05','scheduled'),
	(000009,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0009-1','Test','KG,01,02,03,04,05','scheduled'),
	(000010,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0010-1','Test','KG,01,02,03,04,05','scheduled'),
	(000011,24,'Trimester','T1','2021-08-25','2021-11-19',2022,0001,'Instruction Course','Instruction Course T1','0011-1','Test','KG,01,02,03,04,05','scheduled'),
	(000012,24,'Trimester','T1','2021-08-25','2021-11-19',@eYear,0001,'Instruction Course','Instruction Course T1','0012-1','Test','KG,01,02,03,04,05','scheduled');


SELECT DISTINCT *
FROM #pearsonPIFSection
ORDER BY
	school_code
DROP TABLE #pearsonPIFSection
/*
-- Section Override For Training accounts
INSERT INTO #pearsonPIFSection
SELECT se.sectionID AS 'native_section_code', 
	cal.schoolID AS 'school_code', 
	'Trimester' AS 'section_type', 
	te.[name] AS 'section_type_description', 
	CONVERT(VARCHAR(10), te.startDate, 121) AS 'date_start', 
	CONVERT(VARCHAR(10), te.endDate, 121) AS 'date_end',  
	@eYear - 1 AS 'school_year', 
	c.number AS 'course_number', 
	c.[name] AS 'course_name', 
	c.[name] + '-' + CONVERT(VARCHAR(3), se.number)+'-'+te.[name] AS 'section_name', 
	c.number + '-' + CONVERT(VARCHAR(3), se.number) AS 'section_number', 
	'Math' AS 'subjects', 
	'' AS 'grades', 
	'scheduled' AS 'class_type'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		AND c.[name] LIKE '%Test Course%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (1,2,3,4,5,6,8,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22,28)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -4, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
*/

