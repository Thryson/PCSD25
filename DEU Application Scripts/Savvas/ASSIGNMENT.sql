USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/11/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/18/2019>
-- Description:	<File 1/8 for Pearson products, Used to assign staff to schools>
-- Note 1:	<Different queries for different grade levels, broken out here to give you the ability to override where needed>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_assignment>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #pearsonassignment (
	[priority] INT,
	native_assignment_code INT, 
	staff_code INT, 
	school_year INT, 
	institution_code INT, 
	date_start DATE, 
	date_end DATE, 
	grades VARCHAR(25), 
	position_code VARCHAR(40))


--Elementery Math Teacher school assignments---UPDATED 05/11/2021---
INSERT INTO #pearsonassignment
SELECT DISTINCT DENSE_RANK() OVER(PARTITION BY sm.assignmentID ORDER BY te.termID) AS 'priority', 
	sm.assignmentID AS 'native_assignment_code', 
	sm.personID AS 'staff_code', 
	@eYear - 1 AS 'school_year', 
	sm.schoolID AS 'institution_code', 
	CONVERT(VARCHAR(10), ISNULL(ssh.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(ssh.endDate, te.endDate), 121) AS 'date_end',  
	'KG,01,02,03,04,05' AS 'grades',
	sm.title AS 'position_code'
FROM Section AS se
	INNER JOIN Course AS c ON se.courseID = c.courseID
		AND c.[name] = 'ICS Mathematics'
		--AND c.homeroom = 1
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON c.calendarID = cal.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (1,2,3,4,5,6,8,7,9,10,11,12,13,14)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON cal.calendarID = ss.calendarID
	INNER JOIN Trial AS t ON ss.structureID = t.structureID 
		AND se.trialID = t.trialID 
		AND t.active = 1
	INNER JOIN SectionPlacement AS sp ON se.sectionID = sp.sectionID 
		AND t.trialID = sp.trialID
	INNER JOIN Term AS te ON sp.termID = te.termID 
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
	AND ssh.[role] = 'T'

--Middle School English and Math Teacher Schools
INSERT INTO #pearsonassignment
SELECT DISTINCT DENSE_RANK() OVER(PARTITION BY sm.assignmentID ORDER BY te.termID) AS 'priority', 
	sm.assignmentID AS 'native_assignment_code', 
	sm.personID AS 'staff_code', 
	@eYear - 1 AS 'school_year', 
	sm.schoolID AS 'institution_code', 
	CONVERT(VARCHAR(10), ISNULL(ssh.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(ssh.endDate, te.endDate), 121) AS 'date_end', 
	'06,07,08' AS 'grades', 
	sm.title AS 'position_code'
FROM Section AS se
	INNER JOIN Course AS c ON se.courseID = c.courseID 
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN('English','Math')
	INNER JOIN Calendar AS cal ON c.calendarID = cal.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON cal.calendarID = ss.calendarID
	INNER JOIN Trial AS t ON ss.structureID = t.structureID 
		AND se.trialID = t.trialID 
		AND t.active = 1
	INNER JOIN SectionPlacement AS sp ON se.sectionID = sp.sectionID 
		AND t.trialID = sp.trialID
	INNER JOIN Term AS te ON sp.termID = te.termID 
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
	AND ssh.[role] = 'T'


--High School English Social Studies & Science Teacher Schools
INSERT INTO #pearsonassignment
SELECT DISTINCT DENSE_RANK() OVER(PARTITION BY sm.assignmentID ORDER BY te.termID) AS 'priority', 
	sm.assignmentID AS 'native_assignment_code', 
	sm.personID AS 'staff_code', 
	@eYear - 1 AS 'school_year', 
	sm.schoolID AS 'institution_code', 
	CONVERT(VARCHAR(10), ISNULL(ssh.startdate, te.startDate), 121) AS 'date_start', 
	CONVERT(VARCHAR(10), ISNULL(ssh.endDate, te.endDate), 121) AS 'date_end', 
	'09,10,11,12' AS 'grades', 
	sm.title AS 'position_code'
FROM Section AS se
	INNER JOIN Course AS c ON se.courseID = c.courseID 
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN ('Science','English','Social Studies')
	INNER JOIN Calendar AS cal ON c.calendarID = cal.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
		--AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON cal.calendarID = ss.calendarID
	INNER JOIN Trial AS t ON ss.structureID = t.structureID 
		AND se.trialID = t.trialID 
		AND t.active = 1
	INNER JOIN SectionPlacement AS sp ON se.sectionID = sp.sectionID 
		AND t.trialID = sp.trialID
	INNER JOIN Term AS te ON sp.termID = te.termID 
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
	AND ssh.[role] = 'T'

----------------------------------------------------------------------------------------------
-- STAFF EXCEPTIONS... THIS BLOCK IS USED TO ACCOMIDATE FOR RELEVANT STAFF WHO NEED TO VIEW --
-- THE APPLICATION FOR UNDERSTANDING AND TRAINING PURPOSES, BUT WHOM ARE NOT ASSIGNED TO    --
-- A SECTION/COURSE IN THE CONVENTIONAL MANNER. THIS BLOCK IS A STATIC FORM OF ROSTERING.   --											    
----------------------------------------------------------------------------------------------

INSERT INTO #pearsonassignment
SELECT DISTINCT
	RANK() OVER(PARTITION BY p.personID ORDER BY ea.title ),
	ea.assignmentID AS 'native_assignment_code', 
	ea.personID AS 'staff_code', 
	@eYear - 1 AS 'school_year', 
	'24' AS 'institution_code', 
	'2021-08-01' AS 'date_start',
	'2021-10-20' AS 'date_end',
	'06,07,08' AS 'grades', 
	ea.title AS 'position_code'
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
INSERT INTO #pearsonassignment
VALUES
	(1,000001,00001,@eYear-1,24,(SELECT TOP 1 ter.startDate 
								 FROM Term AS ter 
								 WHERE @cDay BETWEEN ter.startDate AND ter.endDate
									AND SUBSTRING(ter.[name],1,1) LIKE 'T%'),(SELECT TOP 1 ter.endDate
																					 FROM Term AS ter 
																					 WHERE @cDay BETWEEN ter.startDate AND ter.endDate
																						AND SUBSTRING(ter.[name],1,1) LIKE 'T%'),
																					 'KG,01,02,03,04,05','Training Account')
---------------------------------------------------------------------------------------------

SELECT DISTINCT pa.native_assignment_code,
	pa.staff_code,
	pa.school_year,
	pa.institution_code,
	pa.date_start,
	pa.date_end,
	pa.grades,
	pa.position_code
FROM #pearsonassignment AS pa
WHERE pa.[priority] = 1
ORDER BY
	pa.institution_code
	,pa.native_assignment_code
	,pa.staff_code
DROP TABLE #pearsonassignment

