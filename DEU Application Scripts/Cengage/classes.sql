
-- AUTHOR: Mullett, Jacob
-- EMAIL : mulletja@SD25.US
-- FILE  : classes.sql
-- VENDOR: Cengage / NGLsync

USE pocatello

DECLARE @cDay DATETIME, @eYear DATETIME;
SET @cDay = GETDATE()
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR,1,@cDay)) ELSE YEAR(@cDay) END

CREATE TABLE #classes(
	sourcedId INT,
	[status] INT,
	dateLastModified DATETIME,
	title VARCHAR(50),
	grade INT,
	courseSourcedId INT,
	classCode INT,
	classType VARCHAR(25),
	[location] VARCHAR(25),
	schoolSourcedId INT,
	termSourcedId INT,
	subjects VARCHAR(25)
)

INSERT INTO #classes
SELECT DISTINCT
	se.sectionID,
	NULL,
	NULL,
	c.[name] + ' - Period ' + pd.[name] + ' - Term ' + te.[name],
	NULL,
	c.courseID,
	NULL,
	NULL,
	NULL,
	cal.schoolID,
	te.termID,
	NULL
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		 AND c.[name] IN ('AP US History A',
						  'AP US History B',
						  'AP US History C',
						  'speech')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			OR (@cDay BETWEEN te.startDate AND DATEADD(DD, 7, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN [Period] AS pd ON pd.periodID = sp.periodID

INSERT INTO #classes
VALUES
	(1,NULL,NULL,'Test History Course',NULL,1,NULL,NULL,NULL,24,1,NULL),
	(2,NULL,NULL,'Test Speech Course',NULL,2,NULL,NULL,NULL,24,2,NULL)

SELECT *
FROM #classes
ORDER BY 
	sourcedId
DROP TABLE #classes


