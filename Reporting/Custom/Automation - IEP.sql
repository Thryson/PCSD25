USE pocatello

DECLARE @eYear int, @cDay date;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


--Create Plan
--INSERT INTO [Plan]
--(personID, typeID, districtID, startDate, endDate, label, createdDate, createdByID, modifiedDate, modifiedByID, locked)
--SELECT p.personID,
--	3 AS 'typeID',
--	sch.districtID,
--	'2019-08-26 00:00:00' AS 'startDate',
--	'2020-06-05 00:00:00' AS 'endDate',
--	'Annual' AS 'label',
--	GETDATE() AS 'createdDate',
--	86061 AS 'createdByID',
--	GETDATE() AS 'modifiedDate',
--	86061 AS 'modifiedByID',
--	1 AS 'locked'
--FROM Person AS p
--	INNER JOIN Enrollment AS en ON p.personID = en.personID
--		AND en.serviceType = 'P'
--	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
--		AND cal.endYear = 2020
--	INNER JOIN School AS sch ON cal.schoolID = sch.schoolID
--WHERE p.personID = 93701
--	AND NOT EXISTS(
--		SELECT * 
--		FROM [Plan] AS pl
--		WHERE pl.personID = p.personID
--			AND pl.typeID = 3
--			AND YEAR(pl.endDate) = cal.endYear)


--teachers
INSERT INTO TeamMember
(personID, staffPersonID, districtID, lastName, firstName, title, startDate, endDate, [role], module, homePhone, workPhone, cellPhone, email)
SELECT DISTINCT pl.personID,
	ssh.personID AS 'staffPersonID',
	sch.districtID,
	id.lastName,
	id.firstName,
	ea.title,
	DATEADD(DAY, -7 ,ISNULL(ssh.startDate, te.startDate)) AS 'startDate',
	ISNULL(ssh.endDate, te.endDate) AS 'endDate',
	'Read-Only'AS 'role',
	'plp'  AS 'module',
	ct.homePhone,
	ct.workPhone,
	ct.cellPhone,
	CASE 
		WHEN ct.email LIKE '%@sd25.us' THEN ct.email
		WHEN ct.secondaryEmail LIKE '%@sd25.us' THEN ct.secondaryEmail
	END AS 'email'
FROM [Plan] AS pl
	INNER JOIN Roster AS rs ON rs.personID = pl.personID
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = 2020
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
		AND GETDATE() BETWEEN DATEADD(DAY, -7, te.startDate) AND te.endDate
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.[role] = 'T'
		AND ssh.staffType = 'P'
	INNER JOIN EmploymentAssignment AS ea ON ea.personID = ssh.personID
		AND ea.schoolID = sch.schoolID
	INNER JOIN Person AS p ON p.personID = ssh.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Contact AS ct ON ct.personID = id.personID
WHERE pl.typeID = 4
	AND NOT EXISTS (
		SELECT tm.personID 
		FROM TeamMember AS tm
		WHERE tm.staffPersonID = ssh.personID
			AND tm.module = 'plp' 
			AND tm.[role] = 'Read-Only'
			AND tm.personID = pl.personID)


--Principals & Registration Staff
INSERT INTO TeamMember
(personID, staffPersonID, districtID, lastName, firstName, title, startDate, endDate, [role], module, homePhone, workPhone, cellPhone, email)
SELECT DISTINCT pl.personID,
	ea.personID AS 'staffPersonID',
	sch.districtID,
	id.lastName,
	id.firstName,
	ea.title,
	pl.startDate,
	pl.endDate,
	'Service Provider' AS 'role',
	'plp' AS 'module',
	ct.homePhone,
	ct.workPhone,
	ct.cellPhone,
	CASE 
		WHEN ct.email LIKE '%@sd25.us' THEN ct.email
		WHEN ct.secondaryEmail LIKE '%@sd25.us' THEN ct.secondaryEmail
	END AS 'email'
FROM [Plan] AS pl
	INNER JOIN Roster AS rs ON rs.personID = pl.personID
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = 2020
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
		AND GETDATE() BETWEEN DATEADD(DAY, -7, te.startDate) AND te.endDate
	INNER JOIN EmploymentAssignment AS ea ON ea.title IN 
		('Principal Elementary',
		'8.0 Principal Secretary Elem',
		'Asst. Principal Middle School',
		'Principal Middle School',
		'Principal High School',
		'Asst. Principal - Senior High',
		'7 Registrar Middle School',
		'8 Registrar HS')
		AND ea.schoolID = sch.schoolID
		AND (ea.endDate IS NULL OR GETDATE() <= ea.endDate) 
	INNER JOIN Person AS p ON p.personID = ea.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Contact AS ct ON ct.personID = id.personID
WHERE pl.typeID = 4
	AND NOT EXISTS (
		SELECT tm.personID 
		FROM TeamMember AS tm
		WHERE tm.staffPersonID = ea.personID
			AND tm.module = 'plp'
			AND tm.[role] = 'Service Provider'
			AND tm.personID = pl.personID)

--504 Tonya, Randi, Cami & Tiffany
INSERT INTO TeamMember
(personID, staffPersonID, districtID, lastName, firstName, title, startDate, endDate, [role], module, homePhone, workPhone, cellPhone, email)
SELECT DISTINCT pl.personID,
	p.personID AS 'staffPersonID',
	en.districtID,
	id.lastName,
	id.firstName,
	ea.title,
	pl.startDate,
	ISNULL(pl.endDate, cal.endDate) AS 'endDate',
	'Service Provider' AS 'role',
	'plp' AS 'module',
	ct.homePhone,
	ct.workPhone,
	ct.cellPhone,
	CASE 
		WHEN ct.email LIKE '%@sd25.us' THEN ct.email
		WHEN ct.secondaryEmail LIKE '%@sd25.us' THEN ct.secondaryEmail
	END AS 'email'
FROM [Plan] AS pl
	INNER JOIN Enrollment AS en ON en.personID = pl.personID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN EmploymentAssignment AS ea ON ea.title IN ('8  Admin Asst Title 1','Director Of Student Support Services')
		AND ea.districtID = en.districtID
		AND (ea.endDate IS NULL OR GETDATE() <= ea.endDate)
	INNER JOIN Person AS p ON p.personID = ea.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Contact AS ct ON ct.personID = id.personID
WHERE pl.typeID = 4
	AND GETDATE() BETWEEN pl.startDate AND pl.endDate
	AND NOT EXISTS (
		SELECT tm.personID 
		FROM TeamMember AS tm
		WHERE tm.staffPersonID = p.personID
			AND tm.module = 'plp'
			AND tm.[role] = 'Service Provider'
			AND tm.personID = pl.personID)


--SELECT * FROM Calendar AS cal WHERE cal.endyear = 2020
--SELECT * FROM EmploymentAssignment AS ea WHERE ea.personID IN (39715,33155)


--UPDATE [Plan]
--SET endDate = cal.endDate,
--	startDate = DATEADD(DAY, -14, cal.startDate)
--FROM Calendar AS cal
--	INNER JOIN SchoolYear AS sy ON sy.endYear = cal.endYear
--		AND sy.active = 1
--	INNER JOIN [Plan] AS pl ON pl.startDate BETWEEN DATEADD(DAY, -30, cal.startDate) AND cal.endDate
--		--AND pl.endDate IS NULL

--SELECT * 
--FROM [Plan] AS pl
--WHERE pl.personID = 56126

--SELECT * 
--FROM TeamMember AS tm
--WHERE tm.personID = 56126

--SELECT * FROM SEPAccommodations
--SELECT * FROM SEPAccommodationPlan