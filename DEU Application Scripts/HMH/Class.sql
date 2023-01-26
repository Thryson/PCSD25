USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/11/2019>
-- Updater:		<Mullett, Jacob>
-- Update date: <07/18/2019>
-- Description:	<File 1/3 for HMH products, Generates a list of applicable classes to be used by ClassAssignment>
-- Note 1:	<Different applciations for different grade levels, broken out here to seperate queries to give you the ability to override>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_HMH_class>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #hmhClass (
	SCHOOLYEAR INT,
	CLASSLOCALID INT,
	COURSEID INT,
	COURSENAME VARCHAR(50),
	COURSESUBJECT VARCHAR(20),
	CLASSNAME VARCHAR(50),
	CLASSDESCRIPTION VARCHAR(1),
	CLASSPERIOD VARCHAR (3),
	ORGANIZATIONTYPEID VARCHAR(3),
	ORGANIZATIONID INT,
	GRADE VARCHAR(2),
	TERMID VARCHAR(2),
	HMHAPPLICATIONS VARCHAR(10))


--Elementary Classes
INSERT INTO #hmhClass
SELECT @eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID',
	c.courseID AS 'COURSEID',
	c.[name] AS 'COURSENAME',
	'Elementary' AS 'COURSESUBJECT',
	sch.comments + ' ' + c.number + ' -' + ' '+ CONVERT(VARCHAR(8), se.number)  AS 'CLASSNAME',
	'' AS 'CLASSDESCRIPTION',
	'' AS 'CLASSPERIOD',
	'MDR' AS 'ORGANIZATIONTYPEID', 
	CASE sch.schoolID
		WHEN '1' THEN '00256986'
		WHEN '2' THEN '02129729'
		WHEN '3' THEN '00257019'
		WHEN '4' THEN '00257162'
		WHEN '5' THEN '00257069'
		WHEN '6' THEN '00257071'
		WHEN '8' THEN '00257112'
		WHEN '9' THEN '00257124'
		WHEN '10' THEN '00257136'
		WHEN '11' THEN '00257148'
		WHEN '12' THEN '00256974'
		WHEN '13' THEN '00257045'
		WHEN '14' THEN '02846123'
		END AS 'ORGANIZATIONID',
	CASE cc.[value]
		WHEN 'KG' THEN 'K'
		WHEN 'MX' THEN '3'
		ELSE cc.[value] END AS 'GRADE',
	te.[name] AS 'TERMID',
	'TC' AS 'HMHAPPLICATIONS'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		AND c.homeroom = 1
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] = 'Attendance'
	INNER JOIN CustomCourse AS cc ON cc.courseID = c.courseID 
		AND cc.attributeID = 322
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID 
		AND cal.endyear = @eYear
		AND cal.schoolID != 7
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID 
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID 
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Period] AS prd ON prd.periodID = sp.periodID


--Middle School Classes
INSERT INTO #hmhClass
SELECT @eYear AS 'SCHOOLYEAR',
	se.sectionID AS 'CLASSLOCALID',
	c.courseID AS 'COURSEID',
	c.[name] AS 'COURSENAME',
	dep.[name] AS 'COURSESUBJECT',
	sch.comments + ' ' + c.number + '-' + CONVERT(VARCHAR(8), se.number) + ' ' + c.[name] AS 'CLASSNAME',
	'' AS 'CLASSDESCRIPTION',
	'' AS 'CLASSPERIOD',
	'MDR' AS 'ORGANIZATIONTYPEID', 
	CASE sch.schoolID
		WHEN '15' THEN '00257007'
		WHEN '16' THEN '00257021'
		WHEN '17' THEN '00257057'
		WHEN '21' THEN '02176150'
		WHEN '28' THEN '11920419'
		END AS 'ORGANIZATIONID',
	CASE cc.[value]
		WHEN 'MX' THEN '7'
		ELSE cc.[value] END AS 'GRADE',
	te.[name] AS 'TERMID',
	'ED' AS 'HMHAPPLICATIONS'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		--AND dep.[name] = 'Science'
		 --OR dep.[name] = 'Social Studies'
		AND dep.[name] IN('Science','Social Studies')
	INNER JOIN CustomCourse AS cc ON cc.courseID = c.courseID 
		AND cc.attributeID = 322
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID 
		AND cal.endyear = @eYear
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID 
		AND sch.schoolID IN (15,16,17,21,28)
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))


--High School Classes
INSERT INTO #hmhClass
SELECT @eYear AS 'SCHOOLYEAR',
	s.sectionID AS 'CLASSLOCALID',
	c.courseID AS 'COURSEID',
	c.[name] AS 'COURSENAME',
	dep.[name] AS 'COURSESUBJECT',
	sch.comments + ' ' + c.number + '-' + CONVERT(VARCHAR(8), s.number) + ' ' + c.[name] AS 'CLASSNAME',
	'' AS 'CLASSDESCRIPTION',
	'' AS 'CLASSPERIOD',
	'MDR' AS 'ORGANIZATIONTYPEID', 
	CASE sch.schoolID
		WHEN '18' THEN '00257095'
		WHEN '19' THEN '00257033'
		WHEN '20' THEN '04874970'
		WHEN '22' THEN '04449719'
		END AS 'ORGANIZATIONID',
	CASE cc.[value]
		WHEN 'MX' THEN '10'
		ELSE cc.[value] END AS 'GRADE',
	te.[name] AS 'TERMID',
	--CASE
	--	WHEN dep.[name] = 'Foreign Language' THEN 'HMO'
	--	WHEN dep.[name] = 'Social Studies' THEN 'ED'
	--END AS 'HMHAPPLICATIONS'
	'HMO' AS 'HMAPPLICATIONS'
FROM Section AS s
	INNER JOIN Course AS c ON c.courseID = s.courseID 
		AND c.[name] LIKE '%spanish%'
	INNER JOIN CustomCourse AS cc ON cc.courseID = c.courseID 
		AND cc.attributeID = 322
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN('Foreign Language')
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID 
		AND cal.endyear = @eYear
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID 
		AND sch.schoolID IN (18,19,20,22)
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = s.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
INSERT INTO #hmhClass
VALUES
	(@eYear,1,1,'Test Class','Science','Test Class','','','MDR',111111,8,(SELECT TOP 1
																	      'T'+RIGHT(term.[name],1) 
																		  FROM Term 
																		  WHERE @cDay BETWEEN term.startDate AND term.endDate),
																		  'ED')

SELECT DISTINCT *
FROM #hmhClass AS hc
ORDER BY 
	CLASSNAME

DROP TABLE #hmhClass