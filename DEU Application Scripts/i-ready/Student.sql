--------------------------------------------------------------
--Location:		O:i-ready/finalProject
--Client App:	i-ready
--				DEU
--Author:		Jacob Mullett
--Date:			04/14/2021
--------------------------------------------------------------
USE pocatello

DECLARE @eYear INT, @cDay DATETIME;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT DISTINCT 'id-pocat73143' AS 'Client ID',
	cal.schoolID AS 'School ID',
	p.studentNumber + '@sd25.me' AS 'Student SIS ID',
	p.studentNumber AS 'Student Number',
	id.firstName AS 'First Name',
	id.lastName AS 'Last Name',
	enr.grade AS 'Grade Level',
	p.studentNumber + '@sd25.me' AS 'User Name',
	'' AS 'Password',
	CONVERT(VARCHAR, id.birthdate, 101) AS 'DOB',
	'' AS 'Ethnicity',
	'' AS 'Hispanic',
	'' AS 'Gender',
	'' AS 'Economically Disadvantaged',
	'' AS 'English Learner',
	'' AS 'Special Education',
	'' AS 'Migrant',
	'' AS 'Math Developmental Level',
	'' AS 'English Developmental Level',
	'' AS 'Partner ID',
	'' AS 'Action',
	'' AS 'RTI Level',
	'' AS 'Gifted/Talented',
	'' AS 'Reserved1',
	'' AS 'Reserved2',
	'' AS 'Reserved3',
	'' AS 'Reserved4',
	'' AS 'Reserved5',
	'' AS 'Reserved6',
	'' AS 'Reserved7',
	'' AS 'Reserved8'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[name] LIKE 'Acceleration%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN ('Language Arts','Math')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID 
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
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
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS id ON id.identityID = p.currentIdentityID 
		AND id.personID = p.personID
	INNER JOIN Enrollment AS enr ON enr.personID = p.personID
		AND enr.endYear = @eYear
		AND enr.grade IN('06','07','08')
WHERE (rs.endDate IS NULL OR @cDay <= rs.endDate)
	AND (@cDay >= rs.startDate OR rs.startDate IS NULL)