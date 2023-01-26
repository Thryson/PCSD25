USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <09/05/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <09/05/2019>
-- Description:	<File 1/3 for LevelSet products, used to create a roster of Schools>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_levleset_school>
-- =============================================

DECLARE @eYear INT, @cDay DATE;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

SELECT sch.schoolID AS 'School_ID',
	sch.[name] AS 'School_Name'
FROM School as sch
WHERE sch.schoolID IN (18,19,20,22)