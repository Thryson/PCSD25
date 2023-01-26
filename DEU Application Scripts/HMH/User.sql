USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/11/2019>
-- Updater:		<Mullett, Jacob>
-- Update date: <07/18/2019>
-- Description:	<File 3/3 for HMH products, Generates a list of applicable staff and studnets>
-- Note 1:	<Different applciations for different grade levels, broken out here to seperate queries to give you the ability to override>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- Note 3:	<This query is a work in progress and needs to be updated to the standard, split out all grade ranges as seperate queries>
-- File Name:  <DEU_HMH_users>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's
CREATE TABLE #hmhusers (
	[priority] INT,
	SCHOOLYEAR INT,
	[ROLE] VARCHAR(4),
	LASID INT,
	SASID VARCHAR(10),
	FIRSTNAME VARCHAR(75),
	MIDDLENAME VARCHAR(75),
	LASTNAME VARCHAR(75),
	GRADE VARCHAR(6),
	USERNAME VARCHAR(35),
	[PASSWORD] VARCHAR(4),
	ORGANIZATIONTYPEID VARCHAR(4),
	ORGANIZATIONID INT,
	PRIMARYEMAIL VARCHAR(35),
	HMHAPPLICATIONS VARCHAR(20))
	 
--All Staff
INSERT INTO #hmhusers
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority', 
	@eYear - 1 AS 'SCHOOLYEAR', 
	'T' AS 'ROLE', 
	sm.personID AS 'LASID', 
	'' AS 'SASID', 
	sm.firstName AS 'FIRSTNAME', 
	ISNULL(sm.middleName, '') AS 'MIDDLENAME', 
	sm.lastName AS 'LASTNAME',
	CASE 
		WHEN sm.schoolID BETWEEN 1 AND 14 THEN 'K-5'
		WHEN sm.schoolID IN (15,16,17,21,28) THEN '6-8'
		WHEN sm.schoolID IN (18,19,20,22) THEN '9-12'
	END AS 'GRADE',
	ua.username + '@sd25.us' AS 'USERNAME', 
	'' AS 'PASSWORD', 
	'MDR' AS 'ORGANIZATIONTYPEID',
	CASE sm.schoolID
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
		WHEN '15' THEN '00257007'
		WHEN '16' THEN '00257021'
		WHEN '17' THEN '00257057'
		WHEN '18' THEN '00257095'
		WHEN '19' THEN '00257033' 
		WHEN '20' THEN '04874970' 
		WHEN '21' THEN '02176150'
		WHEN '22' THEN '04449719'
		WHEN '28' THEN '11920419'
		--ELSE 'No School' 
	END AS 'ORGANIZATIONID',
	ua.username + '@sd25.us' AS 'PRIMARYEMAIL',
	CASE
		WHEN sm.schoolID BETWEEN 1 AND 14 THEN 'TC'
		WHEN sm.schoolID IN (15,16,17,21,28) THEN 'ED'
		WHEN sm.schoolID IN (18,19,20,22) AND dep.[name] = 'Foreign Language' THEN 'HMO'
--		WHEN sm.schoolID IN (18,19,20,22) AND dep.[name] = 'Social Studies' THEN 'ED'
		ELSE 'No School' 
	END AS 'HMHAPPLICATIONS'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID	
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID 
		AND cal.endyear = @eYear
		AND cal.schoolID != 7
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
	AND ((dep.[name] = 'Attendance' AND cal.schoolID BETWEEN 1 AND 14) 
		OR (dep.[name] = 'Science' AND cal.schoolID IN (15,16,17,21,28))
		OR (c.[name] LIKE '%Spanish%' AND cal.schoolID IN(18,19,20,22)))
		OR (dep.[name] = 'Social Studies' AND cal.schoolID IN(15,16,17,21,28))



--All Students
INSERT INTO #hmhusers
SELECT 1 AS 'priority',
	@eYear - 1 AS 'SCHOOLYEAR', 
	'S' AS 'ROLE', 
	p.studentNumber AS 'LASID', 
	p.stateID AS 'SASID', 
	i.firstName AS 'FIRSTNAME', 
	ISNULL (i.middleName, '') AS 'MIDDLENAME', 
	i.lastName AS 'LASTNAME', 
	CASE en.grade
		WHEN 'OT' THEN '3'
		WHEN 'KG' THEN 'K'
		WHEN '01' THEN '1' 
		WHEN '02' THEN '2'
		WHEN '03' THEN '3'
		WHEN '04' THEN '4'
		WHEN '05' THEN '5'
		WHEN '06' THEN '6'
		WHEN '07' THEN '7'
		WHEN '08' THEN '8'
		WHEN '09' THEN '9'
		WHEN 'KP' THEN 'K'
		WHEN 'KA' THEN 'K'
		WHEN 'KM' THEN 'K'
		WHEN '24' THEN 'PK'
		ELSE en.grade 
	END AS 'GRADE',
	p.studentNumber + '@sd25.me' AS 'USERNAME', 
	NULL AS 'PASSWORD', 
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
		WHEN '15' THEN '00257007'
		WHEN '16' THEN '00257021'
		WHEN '17' THEN '00257057'
		WHEN '18' THEN '00257095'
		WHEN '19' THEN '00257033' 
		WHEN '20' THEN '04874970' 
		WHEN '21' THEN '02176150'
		WHEN '22' THEN '04449719'
		WHEN '28' THEN '11920419'
		--ELSE 'No School' 
	END AS 'ORGANIZATIONID',
	NULL AS 'PRIMARYEMAIL',
	CASE
		WHEN cal.schoolID BETWEEN 1 AND 14 THEN 'TC'
		WHEN cal.schoolID IN (15,16,17,21,28) THEN 'ED'
		WHEN cal.schoolID IN (18,19,20,22) THEN 'HMO' --AND dep.[name] = 'Foreign Language' THEN 'HMO'
--		WHEN cal.schoolID IN (18,19,20,22) AND dep.[name] = 'Social Studies' THEN 'ED'
	END AS 'HMHAPPLICATIONS'
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID 
		AND cal.endyear = @eYear
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID 
		AND sch.schoolID != 7
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
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Person AS p ON p.personID = rs.personID 
	INNER JOIN [Identity] AS i ON i.identityID = p.currentIdentityID 
		AND i.personID = p.personID
	INNER JOIN Enrollment AS en ON en.personID = p.personID 
		AND en.calendarID = c.calendarID
		AND en.active = 1
WHERE (dep.[name] = 'Attendance' AND cal.schoolID BETWEEN 1 AND 14) 
	OR (dep.[name] = 'Science' AND cal.schoolID IN (15,16,17,21,28))
	OR (c.[name] LIKE '%Spanish%' AND cal.schoolID IN (18,19,20,22))
	OR (dep.[name] = 'Social Studies' AND cal.schoolID IN(15,16,17,18,19,20,21,22,28))

INSERT INTO #hmhusers
VALUES
	(1,@eYear,'T',1,'','Test Teacher 1','','Teacher 1','k-12','testteacher1@sd25.us','','MDR',111111,'testteacher1@sd25.us','TC'),
	(1,@eYear,'S',2,'','Test Student 1','','Student 1','k-12','teststudent1@sd25.us','','MDR',111111,'teststudent1@sd25.us','TC')


SELECT DISTINCT 
	hu.SCHOOLYEAR,
	hu.[ROLE],
	hu.LASID,
	hu.SASID,
	hu.FIRSTNAME,
	hu.MIDDLENAME,
	hu.LASTNAME,
	hu.GRADE,
	hu.USERNAME,
	hu.[PASSWORD],
	hu.ORGANIZATIONTYPEID,
	hu.ORGANIZATIONID,
	hu.PRIMARYEMAIL,
	hu.HMHAPPLICATIONS
FROM #hmhusers AS hu
WHERE hu.[priority] = 1
	
DROP TABLE #hmhusers