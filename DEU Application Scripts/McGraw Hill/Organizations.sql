USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/29/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/29/2019>
-- Description:	<File 6/7 for McGraw Hill products, used to create roster of schools>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_mcgrawHill_organizations>
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT sch.schoolID AS 'sourcedId',
	'' AS 'status',
	'' AS 'dateLastModified',
	sch.[name],
	'school' AS 'type',
	'' AS 'identifier',
	'' AS 'parentSourcedId'
FROM School AS sch
WHERE sch.schoolID NOT IN (7,23,26,27,33)