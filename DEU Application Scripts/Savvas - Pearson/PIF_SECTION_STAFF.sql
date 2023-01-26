USE pocatello
-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/15/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/18/2019>
-- Description:	<File 4/8 for Pearson products, Used assign staff to sections>
-- Note 1:	<Different queries for different grade levels, broken out here to give you the ability to override where needed>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_pif_section_staff>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #pearsonPIFSection (
	[priority] INT,
	section_teacher_code INT,
	staff_code INT,
	native_section_code INT,
	date_start VARCHAR(10),
	date_end VARCHAR(10),
	school_year INT,
	teacher_of_record VARCHAR(4),
	teaching_assignment VARCHAR(30))


--Elementary School Teachers(math)
INSERT INTO #pearsonPIFSection
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.sectionStaffID AS 'section_teacher_code', 
	sm.personID AS 'staff_code', 
	se.sectionID AS 'native_section_code', 
	CONVERT(VARCHAR(10), ISNULL(ssh.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(ssh.endDate, te.endDate), 121) AS 'date_end',  
	@eYear - 1 AS 'school_year', 
	--'true' AS 'teacher_of_record', 
	CASE
		WHEN sm.staffNumber IN('ISU','INTERN','Student Teacher') THEN 'false'
		ELSE 'true'
	END AS 'teacher_of_record',
	sm.title AS 'teaching_assignment'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (1,2,3,4,5,6,8,7,9,10,11,12,13,14)
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON sm.personID = ssh.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
		AND sm.title != 'Coach'
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] = 'T'


--Middle School English and Math Teacher Classes
INSERT INTO #pearsonPIFSection
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.sectionStaffID AS 'section_teacher_code', 
	sm.personID AS 'staff_code', 
	se.sectionID AS 'native_section_code', 
	CONVERT(VARCHAR(10), ISNULL(ssh.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(ssh.endDate, te.endDate), 121) AS 'date_end',  
	@eYear - 1 AS 'school_year', 
	--'true' AS 'teacher_of_record', 
	CASE
		WHEN sm.staffNumber IN('ISU','INTERN','Student Teacher') THEN 'false'
		ELSE 'true'
	END AS 'teacher_of_record',
	sm.title AS 'teaching_assignment'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN('English','Math')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON sm.personID = ssh.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] = 'T'


--High School English, Social Studies & Science Teacher Classes
INSERT INTO #pearsonPIFSection
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.sectionStaffID AS 'section_teacher_code', 
	sm.personID AS 'staff_code', 
	se.sectionID AS 'native_section_code', 
	CONVERT(VARCHAR(10), ISNULL(ssh.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(ssh.endDate, te.endDate), 121) AS 'date_end',   
	@eYear - 1 AS 'school_year', 
	--'true' AS 'teacher_of_record', 
	CASE
		WHEN sm.staffNumber IN('ISU','INTERN','Student Teacher') THEN 'false'
		ELSE 'true'
	END AS 'teacher_of_record',
	sm.title AS 'teaching_assignment'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN ('English','Science','Social Studies')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON sm.personID = ssh.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] = 'T'

---------------------------------------------------------------------------------------------
--STAFF OVERRIDE EXCEPTIONS...
---------------------------------------------------------------------------------------------
INSERT INTO #pearsonPIFSection
VALUES
	(1,000001,37204,000001,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000002,38196,000002,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000003,33409,000003,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000004,49729,000004,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000005,39398,000005,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000006,34755,000006,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000007,29875,000007,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000008,94296,000008,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000009,22958,000009,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000010,39253,000010,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000011,39009,000011,'2021-08-25','2021-11-19',2022,'true','Teacher'),
	(1,000012,00001,000012,'2021-08-25','2021-11-19',2022,'true','Teacher Training Account')


SELECT DISTINCT pps.section_teacher_code,
	pps.staff_code,
	pps.native_section_code,
	pps.date_start,
	pps.date_end,
	pps.school_year,
	pps.teacher_of_record,
	pps.teaching_assignment
FROM #pearsonPIFSection AS pps
WHERE pps.[priority] = 1
ORDER BY
	section_teacher_code ASC


DROP TABLE #pearsonPIFSection

/*
-- Staff Section Assignment Override
INSERT INTO #pearsonPIFSection
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	ssh.sectionStaffID AS 'section_teacher_code', 
	sm.personID AS 'staff_code', 
	se.sectionID AS 'native_section_code', 
	CONVERT(VARCHAR(10), ISNULL(ssh.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(ssh.endDate, te.endDate), 121) AS 'date_end',  
	@eYear - 1 AS 'school_year', 
	--'true' AS 'teacher_of_record', 
	CASE
		WHEN ssh.[role] = 'C' THEN 'false'
		WHEN ssh.[role] = 'T' THEN 'true'
	END AS 'teacher_of_record',
	sm.title AS 'teaching_assignment'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[name] LIKE '%test course%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (1,2,3,4,5,6,8,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22,28)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
--		AND tl.trialID = se.trialID 
--		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -7, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -4, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON sm.personID = ssh.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
		AND sm.title != 'Coach'
		AND sm.title =  'Technology Training Specialist'
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
--	AND ssh.[role] = 'T'
*/


