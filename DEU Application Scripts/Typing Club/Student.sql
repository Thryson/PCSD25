USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/24/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/24/2019>
-- Description:	<File 1/4 for Typing Club products, creates list of students>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_typingClub_Student>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

SELECT DISTINCT p.personID AS 'student-id',
	se.sectionID AS 'class-id',
	sch.schoolID AS 'school-id',
	id.firstName AS 'first name',
	id.lastName AS 'last name',
	p.studentNumber AS 'username',
	p.studentNumber + '@sd25.me' AS 'email',
	'random' AS 'password',
	0 AS 'force-password-update',
	CASE
		WHEN en.grade IN ('KA','KP','KM') THEN 'K'
		WHEN en.grade = 'OT' THEN '3'
		WHEN en.grade = '01' THEN '1'
		WHEN en.grade = '02' THEN '2'
		WHEN en.grade = '03' THEN '3'
		WHEN en.grade = '04' THEN '4'
		WHEN en.grade = '05' THEN '5'
		WHEN en.grade = '06' THEN '6'
		WHEN en.grade = '07' THEN '7'
		WHEN en.grade = '08' THEN '8'
	END AS 'grade',
	'update' AS 'action'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.number IN ('3010','4010','5010','7030','10221','10201','10202')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.trialID = tl.trialID 
		AND sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Enrollment AS en ON en.personID = rs.personID
		AND en.calendarID = c.calendarID
		AND en.active = 1
		AND en.grade != 'NG'
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND p.currentIdentityID = id.identityID
WHERE 
	(rs.endDate IS NULL OR @cDay <= rs.endDate)
	AND (rs.startDate IS NULL
		OR @cDay > = rs.startDate)
ORDER BY
	se.sectionID