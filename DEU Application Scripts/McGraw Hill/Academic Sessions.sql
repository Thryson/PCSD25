USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/31/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/31/2019>
-- Description:	<File 1/17 for McGraw Hill products, used to create roster of terms>
-- Note 1:	<Force Rostered to Core Schools, may require rewrite if changes take place>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_mcgrawHill_enrollments>
-- =============================================

DECLARE @eYear INT, @cDay DATE;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT DISTINCT te.termID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	te.[name] AS 'title',
	'term' AS 'type',
	te.startDate AS 'startDate',
	te.endDate AS 'endDate',
	'' AS 'parentSourcedId',
	@eYear AS 'schoolYear'
FROM Section AS se 
	INNER JOIN Course AS c on c.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID IN (1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,28)
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