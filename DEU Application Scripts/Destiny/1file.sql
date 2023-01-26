USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <09/04/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <08/14/2019>
-- Description:	<File 1/1 for Destiny, This is a one file upload and includes everything for staff and students>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_destiny_1file>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #destiny (
	siteShortName VARCHAR(4),
	barcode INT,
	districtID VARCHAR(15),
	lastName VARCHAR(75),
	firstName VARCHAR(75),
	middleName VARCHAR(75),
	nickName VARCHAR(75),
	patronType VARCHAR(15),
	accessLevel VARCHAR(15),
	[status] VARCHAR (4),
	gender VARCHAR(4),
	homeroom VARCHAR(75),
	gradeLevel VARCHAR(10),
	graduationYear INT,
	birthdate VARCHAR(35),
	username VARCHAR(75),
	emailPrimary VARCHAR(35))



--Homerooms and core students for all Active students
INSERT INTO #destiny
SELECT CASE sch.comments 
		WHEN 'KMS' THEN 'NHC'
		WHEN 'NHHS' THEN 'NHC'
		ELSE sch.comments
	END AS  'siteShortName',
	p.studentNumber AS 'barcode',
	p.studentNumber AS 'districtID',
	id.lastName,
	id.firstName,
	ISNULL(id.middleName, '') AS 'middleName',
	ISNULL(id.alias, '') AS 'nickName',
	'' AS 'patronType',
	'' AS 'accessLevel',
	'A' AS 'status',
	id.gender,
	CASE 
		WHEN c.number = 0010 AND en.grade NOT IN ('PK','KM') THEN sm.lastName + ', ' + LEFT(sm.firstName, 1) + '-AM'
		WHEN c.number = 0020 AND en.grade NOT IN ('PK','KM') THEN sm.lastName + ', ' + LEFT(sm.firstName, 1) + '-PM'
		ELSE sm.lastName + ', ' + LEFT(sm.firstName, 1) 
	END AS 'homeroom',
	CASE
		WHEN en.grade IN ('KM','KA','KP') THEN 'K'
		ELSE en.grade
	END AS 'gradeLevel',
	CASE
		WHEN en.grade = 'PK' THEN cal.endYear + 13
		WHEN en.grade IN ('KM','KA','KP') THEN cal.endYear + 12
		WHEN ISNUMERIC(en.grade) = 1 THEN (12 - en.grade) + cal.endYear
		ELSE ''
	END AS 'graduationYear',
	CONVERT(VARCHAR(10), id.birthdate, 121) AS 'birthdate',
	p.studentNumber AS 'username',
	'' AS 'emailPrimary'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID NOT IN (7,23,26,27,33)
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
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Identity] AS id ON id.personID = rs.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
	INNER JOIN Enrollment AS en ON en.personID = p.personID
		AND en.grade NOT IN ('NG','OT')
		AND en.calendarID = cal.calendarID
		AND ((en.endDate IS NULL AND @cDay >= en.startDate)
			OR (@cDay BETWEEN en.startDate AND en.endDate))
		AND en.serviceType = 'P'
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON sm.personID = ssh.personID
		AND sm.schoolID = cal.schoolID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate


SELECT DISTINCT *
FROM #destiny

DROP TABLE #destiny