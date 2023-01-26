 USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/15/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/15/2019>
-- Description:	<File 5/8 for Pearson products, Used to assign students to sections>
-- Note 1:	<Different queries for different grade levels, broken out here to give you the ability to override where needed>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_pifSectionStudent>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #pearsonPIFSectionStudent (
	section_student_code INT,
	student_code INT,
	native_section_code INT,
	date_start VARCHAR(10), 
	date_end VARCHAR(10),
	school_year INT)

--Elementary School Math Classes
INSERT INTO #pearsonPIFSectionStudent
SELECT rs.rosterID AS 'section_student_code', 
	rs.personID AS 'student_code', 
	se.sectionID AS 'native_section_code', 
	CONVERT(VARCHAR(10), ISNULL(rs.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(rs.endDate, te.endDate), 121) AS 'date_end',  
	@eYear - 1 AS 'school_year'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND  c.[name] = 'ICS Mathematics'
		--AND c.[name] LIKE '%AM attend%'
		 --OR c.[homeroom] = 1
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))


--Middle School English Math Student Classes
INSERT INTO #pearsonPIFSectionStudent
SELECT rs.rosterID AS 'section_student_code', 
	rs.personID AS 'student_code', 
	se.sectionID AS 'native_section_code', 
	CONVERT(VARCHAR(10), ISNULL(rs.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(rs.endDate, te.endDate), 121) AS 'date_end',  
	@eYear - 1 AS 'school_year'
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
		AND sp.trialID = sp.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))


--High School English Social Studeis & Science Student Classes
INSERT INTO #pearsonPIFSectionStudent
SELECT rs.rosterID AS 'section_student_code', 
	rs.personID AS 'student_code', 
	se.sectionID AS 'native_section_code', 
	CONVERT(VARCHAR(10), ISNULL(rs.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(rs.endDate, te.endDate), 121) AS 'date_end',  
	@eYear - 1 AS 'school_year'
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))

-- STUDENT OVERRIDES
INSERT INTO #pearsonPIFSectionStudent
VALUES
	(1,2,1,'','',@eYear-1)
	,(2,2,2,'','',@eYear-1)
	,(3,2,3,'','',@eYear-1)
	,(4,2,4,'','',@eYear-1)
	,(5,2,5,'','',@eYear-1)
	,(6,2,6,'','',@eYear-1)
	,(7,2,7,'','',@eYear-1)
	,(8,2,8,'','',@eYear-1)
	,(9,2,9,'','',@eYear-1)
	,(10,2,10,'','',@eYear-1)
	,(11,2,11,'','',@eYear-1)
	,(12,2,12,'','',@eYear-1)

SELECT DISTINCT *
FROM #pearsonPIFSectionStudent
ORDER BY
	student_code



DROP TABLE  #pearsonPIFSectionStudent