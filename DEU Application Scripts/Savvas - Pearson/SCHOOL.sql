USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/15/2019>
-- Updater:		<Lopez, Michael>
-- Update date: <08/28/2019>
-- Description:	<File 6/8 for Pearson products, Used to create roster of schools>
-- Note 1:	<This file is the query template, it is saved as a stored procedure in the database and must be updated accordingly>
-- File Name:  <DEU_pearson_schools>
-- =============================================

--This TempTable removed the dependence on UNION's & Nested Queries
CREATE TABLE #pearsonSchool(
	school_code INT,
	school_name VARCHAR(75),
	district_code INT,
	grade_start VARCHAR(5),
	grade_end VARCHAR(5),
	address_1 VARCHAR(75),
	address_2 VARCHAR(75),
	city VARCHAR(30),
	[state] VARCHAR(4),
	zip INT,
	phone VARCHAR(25))


--All Schools
INSERT INTO #pearsonSchool
SELECT sch.schoolID AS 'school_code', 
	sch.[name] AS 'school_name', 
	34 AS 'district_code', 
	CASE
		WHEN sch.[name] LIKE '%elementary%' THEN 'KG'
		WHEN sch.[name] LIKE '%middle%' THEN '06'
		WHEN sch.[name] LIKE '%high%' THEN '09'
		WHEN sch.[name] LIKE '%education center%' THEN 'KG'
	END AS 'grade_start',
	CASE
		WHEN sch.[name] LIKE '%elementary%' THEN '05'
		WHEN sch.[name] LIKE '%middle%' THEN '08'
		WHEN sch.[name] LIKE '%high%' THEN '12'
		WHEN sch.[name] LIKE '%education center%' THEN '12'
	END AS 'grade_end',
	sch.[address] AS 'address_1', 
	'' AS 'address_2', 
	sch.city, 
	sch.[state], 
	SUBSTRING(sch.zip,1,5), 
	sch.phone
FROM School AS sch
WHERE sch.schoolID IN (1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,28)
ORDER BY
	sch.schoolID

SELECT DISTINCT *
FROM #pearsonSchool

DROP TABLE #pearsonSchool


-------------------------------------
--no reason to make more than one query 
--for school file.
-------------------------------------
/*
--Middle Schools
INSERT INTO #pearsonSchool
SELECT sch.schoolID AS 'school_code', 
	sch.[name] AS 'school_name', 
	34 AS 'district_code', 
	6 AS 'grade_start', 
	8 AS 'grade_end', 
	sch.[address] AS 'address_1', 
	'' AS 'address_2', 
	sch.city, 
	sch.[state], 
	sch.zip, 
	sch.phone
FROM School AS sch
WHERE sch.schoolID IN (15,16,17,21,28)


--High Schools
INSERT INTO #pearsonSchool
SELECT sch.schoolID AS 'school_code', 
	sch.[name] AS 'school_name', 
	34 AS 'district_code', 
	9 AS 'grade_start', 
	12 AS 'grade_end', 
	sch.[address] AS 'address_1', 
	'' AS 'address_2', 
	sch.city, 
	sch.[state], 
	sch.zip, 
	sch.phone
FROM School AS sch
WHERE sch.schoolID IN (18,19,20,22)

--EDC
INSERT INTO #pearsonSchool
SELECT sch.schoolID AS 'school_code', 
	sch.[name] AS 'school_name', 
	34 AS 'district_code', 
	9 AS 'grade_start', 
	12 AS 'grade_end', 
	sch.[address] AS 'address_1', 
	'' AS 'address_2', 
	sch.city, 
	sch.[state], 
	sch.zip, 
	sch.phone
FROM School AS sch
WHERE sch.schoolID IN (24)
*/
