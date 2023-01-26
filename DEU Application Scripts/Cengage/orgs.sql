
-- AUTHOR: Mullett, Jacob
-- EMAIL : mulletja@SD25.US
-- FILE  : orgs.sql
-- VENDOR: Cengage / NGLsync

USE pocatello

DECLARE @cDay DATE, @eYear INT;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

CREATE TABLE #orgs(
	sourcedId INT,
	[status] INT,
	dateLastModified DATETIME,
	[name] VARCHAR(50), 
	[type] VARCHAR(50),
	identifier INT,
	metaDataClassification VARCHAR(50),
	metaDataGender VARCHAR(50),
	metaDataBoarding VARCHAR(50),
	parentSourcedId INT
)

INSERT INTO #orgs
SELECT 
	sch.schoolID,
	NULL,
	NULL,
	sch.[name],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
FROM School AS sch
WHERE sch.schoolID IN(18,19,20,22,24)

SELECT 
	sourcedId,
	[status],
	dateLastModified,
	[name], 
	[type],
	identifier,
	metaDataClassification AS 'metadata.classification',
	metaDataGender AS 'metadata.gender',
	metaDataBoarding AS 'metadata.boarding',
	parentSourcedId 
FROM #orgs
DROP TABLE #orgs

