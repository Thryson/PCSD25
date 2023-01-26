--------------------------------------------------------------
--Location:		O:i-ready/finalProject
--Client App:	i-ready
--				DEU
--Author:		Jacob Mullett
--Date:			04/14/2021
--File:			staff.sql
--------------------------------------------------------------
USE pocatello

DECLARE @eYear INT, @cDay DATETIME;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT DISTINCT 'id-pocat73143' AS 'Client ID',
	cal.schoolID AS 'School ID',
	ua.username + '@sd25.us' AS 'Staff Member SIS ID',
	sm.firstName AS 'First Name',
	sm.lastName AS 'Last Name',
	'teacher' AS 'role',
	ua.username + '@sd25.us' AS 'Email',
	ua.username + '@sd25.us' AS 'Username',
	'*****************' AS 'Password',
	'' AS 'Partner ID',
	'' AS 'Action',
	'' AS 'Reserved1',
	'' AS 'Reserved2',
	'' AS 'Reserved3',
	'' AS 'Reserved4',
	'' AS 'Reserved5',
	'' AS 'Reserved6',
	'' AS 'Reserved7',
	'' AS 'Reserved8',
	'' AS 'Reserved9',
	'' AS 'Reserved10'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[name] LIKE 'Acceleration%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN ('English','Language Arts','Math')
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