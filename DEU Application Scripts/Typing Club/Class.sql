USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/24/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/24/2019>
-- Description:	<File 1/4 for Typing Club products, creates list of classes & staff>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_typingClub_class>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT DISTINCT se.sectionID AS 'class-id',
	ssh.personID AS 'instructor-id',
	cal.schoolID AS 'school-id',
	sch.comments + ' ' + c.number + '-' + CONVERT(VARCHAR, se.number) AS 'name',
	NULL AS 'description',
	CASE
		WHEN cc.[value] = 'MX' AND cal.schoolID IN (15,16,17,21,28) THEN 7
		WHEN cc.[value] = 'MX' AND cal.schoolID NOT IN (15,16,17,21,28) THEN 3
		ELSE cc.[value]
	END AS 'grade',
	'update' AS 'action'
FROM Section AS se
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.number IN ('3010','4010','5010','7030','10221','10201','10202')
	INNER JOIN CustomCourse AS cc ON cc.courseID = c.courseID 
		AND cc.attributeID = 322
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
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
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
ORDER BY
	ssh.personID