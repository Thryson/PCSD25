
-- AUTHOR: Mullett, Jacob
-- EMAIL : mulletja@SD25.US
-- FILE  : users.sql
-- VENDOR: Cengage / NGLsync

USE pocatello

DECLARE @cDay DATE, @eYear INT;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

CREATE TABLE #Users(
	sourcedId VARCHAR(25),
	[status] VARCHAR(25),
	dateLastModified DATETIME,
	orgSourcedIds INT,
	[role] VARCHAR(50),
	username VARCHAR(25),
	userId INT,
	givenName VARCHAR(25),
	familyName VARCHAR(25),
	identifier VARCHAR(25),
	email VARCHAR(25),
	sms VARCHAR(25),
	phone VARCHAR(25),
	agents VARCHAR(25)
)


--TEACHERS
INSERT INTO #users
SELECT DISTINCT
	ua.personID,
	NULL,
	NULL,
	cal.schoolID,
	'teacher',
	ua.username + '@sd25.us',
	sm.staffNumber,
	firstName,
	lastName,
	NULL,
	ua.username + '@sd25.us',
	NULL,
	NULL,
	NULL
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		 AND c.[name] IN ('AP US History A',
						  'AP US History B',
						  'AP US History C',
						  'speech')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
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
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.active = 1
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'


--STUDENTS
INSERT INTO #Users
SELECT DISTINCT
	ua.personID,
	NULL,
	NULL,
	cal.schoolID,
	'student',
	ua.username + '@sd25.me',
	p.studentNumber,
	firstName,
	lastName,
	NULL,
	ua.username + '@sd25.me',
	NULL,
	NULL,
	NULL
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID
		 AND c.[name] IN ('AP US History A',
						  'AP US History B',
						  'AP US History C',
						  'speech')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
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
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS id ON id.identityID = p.currentIdentityID 
		AND id.personID = p.personID
	INNER JOIN UserAccount AS ua ON ua.personID = p.personID
		AND ua.ldapConfigurationID = '2'
	INNER JOIN Enrollment AS en ON en.personID = p.personID
		AND en.active = 1
		AND en.serviceType = 'P'

INSERT INTO #Users
VALUES
	(1,NULL,NULL,24,'teacher','testteacher1@sd25.us',1,'Test','Teacher',NULL,'testteacher1@sd25.us',NULL,NULL,NULL),
	(2,NULL,NULL,24,'student','teststudent1@sd25.us',2,'Test','Student',NULL,'teststudent1@sd25.us',NULL,NULL,NULL)

SELECT *
FROM #users
ORDER BY 
	[role] DESC,
	sourcedId 
DROP TABLE 
	#users


