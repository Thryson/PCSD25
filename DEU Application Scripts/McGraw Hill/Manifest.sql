USE pocatello 

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <08/01/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <08/01/2019>
-- Description:	<File 5/7 for McGraw Hill products, used to define file type & inclusions>
-- Note 1:	<This is a static file and will need to manually updated as needed>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_mcgrawHill_manifest>
-- =============================================

SELECT 1.0 AS 'manifest.version',
	1.1 AS 'oneroster.version',
	'bulk' AS 'file.academicSessions',
	'absent' AS 'file.categories',
	'bulk' AS 'file.classes',
	'absent' AS 'file.classResources',
	'bulk' AS 'file.courses',
	'absent' AS 'file.courseResources',
	'absent' AS 'file.demographics',
	'bulk' AS 'file.enrollments',
	'absent' AS 'file.lineItems',
	'bulk' AS 'file.orgs',
	'absent' AS 'file.resources',
	'absent' AS 'file.results',
	'bulk' AS 'file.users',
	'bigDaddyMike' AS 'source.systemName',
	'swgLrd' AS 'source.systemCode'