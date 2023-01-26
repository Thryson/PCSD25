-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/15/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <07/15/2019>
-- Description:	<File 2/8 for Pearson products, Used to add district information>
-- Note 1:	<This file is used to upload district information to pearson and does not technically need to be included the upload>
-- Note 2:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_code_distrct>
-- =============================================


SELECT '34' AS 'district_code', 
	'Pocatello/Chubbuck School District 25' AS 'district_name', 
	'3115 Pole Line Road' AS 'address_1', 
	'' AS 'address_2', 
	'Pocatello' AS 'city', 
	'ID' AS 'state', 
	'83201-6119' AS 'zip', 
	'208-232-3563' AS 'phone'