USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/24/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/24/2019>
-- Description:	<File 3/4 for Typing Club products, creates list of schools>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_typingClub_school>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT DISTINCT sch.schoolID AS 'school-id',
	sch.[name] AS 'name',
	sch.[address] + ' ' + sch.city + ', ' + sch.[state] + ' ' + sch.zip AS 'address',
	'update' AS 'action'
FROM Section AS se
	INNER JOIN Course AS c ON c.CourseID = se.courseID
		AND c.number IN ('3010','4010','5010','7030','10221','10201','10202')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID