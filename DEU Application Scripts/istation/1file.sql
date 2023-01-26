USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <08/14/2019>
-- Updater:		<Mullett, Jacob>
-- Update date: <08/04/2021>
-- Description:	<File 1/1 for Istation, This is a one file upload and includes everything per student>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_istation_1file>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #istationfile (
	[priority] INT,
	campus_id INT,
	id INT,
	fname VARCHAR(75),
	lname VARCHAR(75),
	mi VARCHAR(4),
	login_id VARCHAR(35),
	[password] VARCHAR(4),
	grade VARCHAR(4),
	tfname VARCHAR(75),
	tlname VARCHAR(75),
	email VARCHAR(35),
	tid VARCHAR(30),
	tlogin_id VARCHAR(35),
	cid INT,
	class_name VARCHAR(45),
	[period] VARCHAR(4),
	state_sid INT,
	stparty_id VARCHAR(75),
	ttparty_id VARCHAR(75),
	birthdate DATE)


--Elementary Core & SPED Istation roster all on Attendance
INSERT INTO #istationfile
SELECT RANK() OVER(PARTITION BY ssh.sectionID ORDER BY ssh.sectionID, ssh.assignmentID DESC) AS 'priority',
	cal.schoolID AS 'campus_id',
	p.studentNumber AS 'id',
	id.firstName AS 'fname',
	id.lastName AS 'lname',
	ISNULL(LEFT(id.middleName, 1), '') AS 'mi',
	p.studentNumber AS 'login_id',
	'' AS 'password',
	CASE en.grade
		--WHEN 'PK' THEN '-1'
		WHEN 'KA' THEN '0'
		WHEN 'KP' THEN '0'
		WHEN 'KM' THEN '0'
		WHEN '01' THEN '1'
		WHEN '02' THEN '2'
		WHEN '03' THEN '3'
		WHEN '04' THEN '4'
		WHEN '05' THEN '5'
		WHEN '06' THEN '6'
		WHEN '07' THEN '7'
		WHEN '08' THEN '8'
		WHEN '09' THEN '9'
		ELSE en.grade
	END,
	sm.firstName AS 'tfname',
	sm.lastName AS 'tlname',
	ua.username + '@sd25.us' AS 'email',
	sm.staffNumber AS 'tid',
	ua.username AS 'tlogin_id',
	se.sectionID AS 'cid',
	sch.comments + ' ' + c.[name] + '-' + CONVERT(VARCHAR, se.number) AS 'class_name',
	'' AS 'period',
	p.stateID AS 'state_sid',
	p.studentNumber + '@sd25.me' AS 'stparty_id',
	ua.username + '@sd25.us' AS 'ttparty_id',
	CONVERT(varchar, id.birthdate, 23) AS 'birthdate'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
--		AND dep.[name] = 'Attendance'
	INNER JOIN Calendar AS cal oN cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID != 7
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Enrollment AS en ON en.personID = p.personID
		AND en.calendarID = cal.calendarID
		AND en.grade NOT IN ('NG','OT','PK')
		AND (en.endDate IS NULL 
			OR @cDay <= en.endDate)
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON sm.personID = ssh.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'
	AND (rs.endDate IS NULL 
		OR @cDay <= rs.endDate)
	AND (rs.startDate IS NULL
		OR @cDay >= rs.startDate)
-------------------------------STAFF OVERRIDE
INSERT INTO #istationfile
VALUES
	(1,3,1,'Test','Student','','teststudent1@sd25.me','',10,'Test','Teacher','testteacher1@sd25.us',1,'testteacher1',1,'Test Course','','','teststudent1@sd25.me','testteacher1@sd25.us','1990-01-01')

SELECT DISTINCT isf.campus_id,
	isf.id,
	isf.fname,
	isf.lname,
	isf.mi,
	isf.login_id,
	isf.[password],
	isf.grade,
	isf.tfname,
	isf.tlname,
	isf.email,
	isf.tid,
	isf.tlogin_id,
	isf.cid,
	isf.class_name,
	isf.[period],
	isf.state_sid,
	isf.stparty_id,
	isf.ttparty_id,
	isf.birthdate
FROM #istationfile AS isf
WHERE isf.[priority] = 1

DROP TABLE #istationfile


