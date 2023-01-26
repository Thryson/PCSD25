USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <10/18/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <08/02/2021>
-- Description:	<File 1/1 for 504 Plan Automation>
-- Note 1:  Will Add, Update and End Staff Members assoicated with plp Module base 504 plans
-- Note 2:	This is the manually excuted version of this script and does not match the SP 100%, PRINT lines and Drop Tables must be removed
-- Procedure Name:  dbo.pcsd25_automation_504teamMembers
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


--==============================
--
--	Sub Query 1a: Add Counselor to 504 as Case Manager When not already assigned
--
--==============================
PRINT 'Primary Counselors added to 504s'
INSERT INTO TeamMember
(personID, staffPersonID, districtID, lastName, firstName, title, startDate, endDate, comments, [role], module, homePhone, workPhone, cellPhone, email, agency)
SELECT DISTINCT pl.personID,
	ea.personID AS 'staffPersonID'
	,sch.districtID
	,id.lastName
	,id.firstName
	,ea.title
	,IIF(cal.startDate < ea.startDate, ea.startDate, cal.startDate) AS 'startDate'
	,cal.endDate AS 'endDate'
	,'PCSD25 Data Team Automation' AS 'comments'
	,'Case Manager' AS 'role'
	,'plp'  AS 'module'
	,ct.homePhone
	,ct.workPhone
	,ct.cellPhone
	,CASE 
		WHEN ct.email LIKE '%@sd25.us' THEN ct.email
		WHEN ct.secondaryEmail LIKE '%@sd25.us' THEN ct.secondaryEmail
		ELSE NULL
	END AS 'email'
	,ea.assignmentID AS 'agency'
FROM [Plan] AS pl
	INNER JOIN Enrollment AS en ON en.personID = pl.personID
		AND en.serviceType = 'P'
		AND (en.endDate IS NULL OR @cDay <= en.endDate)
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN TeamMember As tm ON tm.personID = pl.personID
		AND tm.module = 'counseling'
		AND tm.[role] = 'Counselor'
		AND (tm.endDate IS NULL OR @cDay <= tm.endDate)
	INNER JOIN EmploymentAssignment AS ea ON ea.personID = tm.staffPersonID
		AND ea.schoolID = sch.schoolID
		AND (ea.endDate IS NULL OR @cDay <= ea.endDate) 
	INNER JOIN Person AS p ON p.personID = ea.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Contact AS ct ON ct.personID = id.personID
WHERE pl.typeID = 4
	AND (@cDay < pl.endDate OR pl.endDate IS NULL)
	AND cal.schoolID = ea.schoolID
	AND NOT EXISTS (
		SELECT tm.personID 
		FROM TeamMember AS tm
		WHERE tm.staffPersonID = ea.personID
			AND tm.personID = pl.personID
			AND tm.module = 'plp'
			AND tm.[role] = 'Case Manager'
			AND @cDay < tm.endDate)


--==============================
--
--	Sub Query 2: Add District Student Services Director and Secratary to 504 When not already assigned
--
--==============================
PRINT '' PRINT ''
PRINT '---------------------------------------------------'
PRINT 'District administrative staff added to 504s'
INSERT INTO TeamMember
(personID, staffPersonID, districtID, lastName, firstName, title, startDate, endDate, comments, [role], module, homePhone, workPhone, cellPhone, email, agency)
SELECT DISTINCT pl.personID
	,p.personID AS 'staffPersonID'
	,en.districtID
	,id.lastName
	,id.firstName
	,ea.title
	,cal.startDate
	,cal.endDate
	,'PCSD25 Data Team Automation' AS 'comments'
	,'Service Provider' AS 'role'
	,'plp' AS 'module'
	,ct.homePhone
	,ct.workPhone
	,ct.cellPhone
	,CASE
		WHEN ct.email LIKE '%@sd25.us' THEN ct.email
		WHEN ct.secondaryEmail LIKE '%@sd25.us' THEN ct.secondaryEmail
		ELSE NULL
	END AS 'email'
	,ea.assignmentID AS 'agency'
FROM [Plan] AS pl
	INNER JOIN Enrollment AS en ON en.personID = pl.personID
		AND en.serviceType = 'P'
		AND (en.endDate IS NULL OR @cDay <= en.endDate)
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN EmploymentAssignment AS ea ON ea.districtID = en.districtID
		AND (ea.endDate IS NULL OR @cDay <= ea.endDate)
		AND ea.advisor = 1
		AND ea.schoolID = 24
	INNER JOIN Department AS dep ON dep.departmentID = ea.departmentID
		AND dep.[name] = 'Student Services'
	INNER JOIN Person AS p ON p.personID = ea.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Contact AS ct ON ct.personID = id.personID
WHERE pl.typeID = 4
	AND (@cDay < pl.endDate OR pl.endDate IS NULL)
	AND NOT EXISTS (
		SELECT tm.personID 
		FROM TeamMember AS tm
		WHERE tm.staffPersonID = p.personID
			AND tm.module = 'plp'
			AND tm.[role] IN ('Service Provider', 'Case Manager')
			AND tm.personID = pl.personID
			AND @cDay < tm.endDate)


--==============================
--
--	Sub Query 3: Add Bldg Admin, Sec. Registrars, Elem. Secrataries and non-primary Counselors to 504 When not already assigned
--
--==============================
PRINT '' PRINT '' 
PRINT '---------------------------------------------------'
PRINT 'Additional Local Building staff added to 504s'
INSERT INTO TeamMember
(personID, staffPersonID, districtID, lastName, firstName, title, startDate, endDate, comments, [role], module, homePhone, workPhone, cellPhone, email, agency)
SELECT DISTINCT pl.personID
	,ea.personID AS 'staffPersonID'
	,sch.districtID
	,id.lastName
	,id.firstName
	,ea.title
	,IIF(cal.startDate < pl.startDate, pl.startDate, cal.startDate) AS 'startDate'
	,cal.endDate
	,'PCSD25 Data Team Automation' AS 'comments'
	,'Service Provider' AS 'role'
	,'plp' AS 'module'
	,ct.homePhone
	,ct.workPhone
	,ct.cellPhone
	,CASE 
		WHEN ct.email LIKE '%@sd25.us' THEN ct.email
		WHEN ct.secondaryEmail LIKE '%@sd25.us' THEN ct.secondaryEmail
		ELSE NULL
	END AS 'email'
	,ea.assignmentID AS 'agency'
FROM [Plan] AS pl
	INNER JOIN Enrollment AS en ON en.personID = pl.personID
		AND en.serviceType = 'P'
		AND (en.endDate IS NULL OR @cDay <= en.endDate)
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN EmploymentAssignment AS ea ON ea.schoolID = sch.schoolID
		AND (ea.endDate IS NULL OR @cDay <= ea.endDate)
		AND ea.advisor = 1
	INNER JOIN Person AS p ON p.personID = ea.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Contact AS ct ON ct.personID = id.personID
WHERE pl.typeID = 4
	AND (@cDay < pl.endDate OR pl.endDate IS NULL)
	AND cal.schoolID = ea.schoolID
	AND NOT EXISTS (
		SELECT tm.personID 
		FROM TeamMember AS tm
		WHERE tm.staffPersonID = ea.personID
			AND tm.module = 'plp'
			AND tm.[role] IN ('Service Provider', 'Case Manager')
			AND tm.personID = pl.personID
			AND @cDay < tm.endDate)


--==============================
--
--	Sub Query 4: Add Teachers to 504 When not already assigned
--
--==============================
PRINT '' PRINT '' 
PRINT '---------------------------------------------------'
PRINT 'Teachers added to 504s'
INSERT INTO TeamMember
(personID, staffPersonID, districtID, lastName, firstName, title, startDate, endDate, comments, [role], module, homePhone, workPhone, cellPhone, email, agency)
SELECT DISTINCT pl.personID,
	ssh.personID AS 'staffPersonID'
	,sch.districtID
	,id.lastName
	,id.firstName
	,ea.title
	,DATEADD(DAY, -8 ,ISNULL(ssh.startDate, te.startDate)) AS 'startDate'
	,ISNULL(ssh.endDate, te.endDate) AS 'endDate'
	,'PCSD25 Data Team Automation' AS 'comments'
	,'Read-Only'AS 'role'
	,'plp'  AS 'module'
	,ct.homePhone
	,ct.workPhone
	,ct.cellPhone
	,CASE 
		WHEN ct.email LIKE '%@sd25.us' THEN ct.email
		WHEN ct.secondaryEmail LIKE '%@sd25.us' THEN ct.secondaryEmail
		ELSE NULL
	END AS 'email'
	,ea.assignmentID AS 'agency'
FROM [Plan] AS pl
	INNER JOIN Roster AS rs ON rs.personID = pl.personID
		AND (@cDay < rs.endDate OR rs.endDate IS NULL)
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND (@cDay < ssh.endDate OR ssh.endDate IS NULL)
	INNER JOIN EmploymentAssignment AS ea ON ea.personID = ssh.personID
		AND ea.schoolID = sch.schoolID
		AND (ea.endDate IS NULL OR @cDay <= ea.endDate)
	INNER JOIN Person AS p ON p.personID = ssh.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Contact AS ct ON ct.personID = id.personID
WHERE pl.typeID = 4
	AND (@cDay < pl.endDate OR pl.endDate IS NULL)
	AND NOT EXISTS (
		SELECT tm.personID 
		FROM TeamMember AS tm
		WHERE tm.staffPersonID = ssh.personID
			AND tm.module = 'plp' 
			AND tm.personID = pl.personID
			AND tm.endDate = te.endDate
			AND @cDay < tm.endDate)


--==============================
--
--	Sub Query 5 (Parts 1-5): Collect list of potential endDates for teacher assignments and select the lowest among them
--
--==============================
PRINT '' PRINT ''
PRINT '---------------------------------------------------'
PRINT '504 Plan active check'
		-- Part 1: Check for plan endDate less than current member endDate
		-- This checks for All staff on plan not just teachers
		SELECT tm.personID,
			tm.staffPersonID,
			pl.endDate
		INTO #planEndDate
		FROM [Plan] AS pl
			INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
				AND tm.module = 'plp'
		WHERE @cDay BETWEEN pl.startDate AND pl.endDate
			AND pl.typeID = 4
			AND (pl.endDate < tm.endDate OR tm.endDate IS NULL)

PRINT '' PRINT ''
PRINT '---------------------------------------------------'
PRINT '504 student active roster check'
		-- Part 2: Check for roster or term endDate less than current member endDate
		-- This checks for only teachers as it is checking roster and term dates
		INSERT INTO #planEndDate
		SELECT pl.personID,
			tm.staffPersonID,
			ISNULL(rs.endDate, te.enddate)
		FROM [Plan] AS pl
			INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
				AND tm.module = 'plp'
				AND tm.[role] NOT IN ('Case Manager', 'Service Provider')
			INNER JOIN Roster AS rs ON rs.personID = pl.personID
			INNER JOIN Section AS se ON se.sectionID = rs.sectionID
			INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
				AND ssh.personID = tm.staffPersonID
			INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
			INNER JOIN Trial AS tl ON tl.trialID = sp.trialID
				AND tl.active = 1
			INNER JOIN Term AS te ON te.termID = sp.termID
				AND @cDay BETWEEN DATEADD(DAY, -8, te.startDate) AND te.endDate
		WHERE @cDay BETWEEN pl.startDate AND pl.endDate
			AND pl.typeID = 4
			AND ISNULL(rs.endDate, te.enddate) < pl.endDate
			AND (ISNULL(rs.endDate, te.enddate) < tm.endDate OR tm.endDate IS NULL)


PRINT '' PRINT ''
PRINT '---------------------------------------------------'
PRINT '504 Teaching Staff active check'
		-- Part 3: Check for teaching staff or term endDate less than current member endDate
		INSERT INTO #planEndDate
		SELECT pl.personID,
			tm.staffPersonID,
			ISNULL(ssh.endDate, te.endDate)
		FROM [Plan] AS pl
			INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
				AND tm.module = 'plp'
				AND tm.[role] NOT IN ('Case Manager', 'Service Provider')
			INNER JOIN Roster AS rs ON rs.personID = tm.personID
			INNER JOIN Section AS se ON se.sectionID = rs.sectionID
			INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
				AND ssh.personID = tm.staffPersonID
			INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
			INNER JOIN Trial AS tl ON tl.trialID = sp.trialID
				AND tl.active = 1
			INNER JOIN Term AS te ON te.termID = sp.termID
				AND @cDay BETWEEN DATEADD(DAY, -8, te.startDate) AND te.endDate
		WHERE @cDay BETWEEN pl.startDate AND pl.endDate
			AND pl.typeID = 4
			AND ISNULL(ssh.endDate, te.endDate) < pl.endDate
			AND ISNULL(ssh.endDate, te.endDate) < rs.endDate
			AND (ISNULL(ssh.endDate, te.endDate) < tm.endDate OR tm.endDate IS NULL)

PRINT '' PRINT ''
PRINT '---------------------------------------------------'
PRINT '504 optimal date select and move'
		-- Part 4: Select the lowest of all above dates and move to second table
		SELECT ped.personID,
			ped.staffPersonID,
			MIN(ped.endDate) AS 'endDate'
		INTO #planEndDate2
		FROM #planEndDate AS ped
		GROUP BY ped.personID,
			ped.staffPersonID

PRINT '' PRINT ''
PRINT '---------------------------------------------------'
PRINT '504 TeamMember conditional endDate'
		-- Part 5: Acutal Update provided date is lower than current will not affect anyone other than teachers
		UPDATE TeamMember
		SET endDate = ped.endDate
		FROM TeamMember AS tm
			INNER JOIN #planEndDate2 AS ped ON ped.personID = tm.personID
				AND tm.staffPersonID = ped.staffPersonID
				AND (ped.endDate < tm.endDate OR tm.endDate IS NULL)
		WHERE tm.module = 'plp'
			AND tm.[role] NOT IN ('Case Manager', 'Service Provider')
			AND tm.startDate < ped.endDate


PRINT '' PRINT ''
PRINT '---------------------------------------------------'
PRINT '504 TeamMember endDate when assingment has changed'
		-- Part 6: Check Agency & AssingmentID's for any staff member who has changed assingments
		UPDATE TeamMember
		SET endDate = ea.endDate
		FROM TeamMember AS tm
			INNER JOIN EmploymentAssignment AS ea ON ea.assignmentID = tm.agency
				AND ea.endDate IS NOT NULL
				AND tm.staffPersonID = ea.personID --Saftey Check 1
		WHERE tm.module = 'plp'
			AND tm.endDate > ea.endDate
			AND tm.startDate < ea.endDate --Safety Check 2
			AND ISNUMERIC(tm.agency) = 1
PRINT '---------------------------------------------------'

DROP TABLE #planEndDate,
	#planEndDate2