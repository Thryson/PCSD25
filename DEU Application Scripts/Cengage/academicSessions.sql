
-- AUTHOR: Mullett, Jacob
-- EMAIL : mulletja@SD25.US
-- FILE  : academicSessions.sql
-- VENDOR: Cengage / NGLsync

USE pocatello

DECLARE @cDay DATE, @eYear INT;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

CREATE TABLE #academicSessions(
	sourcedId INT,
	[status] INT,
	dateLastModified DATETIME,
	title VARCHAR(50),
	[type] VARCHAR(20),
	startDate VARCHAR(10),
	endDate VARCHAR(10),
	parentSourcedId INT,
	school INT
)

INSERT INTO #academicSessions

SELECT 
	te.termID,
	NULL,
	NULL,
	te.[name],
	NULL,
	CONVERT(DATE,te.startDate,126),
	CONVERT(DATE,te.endDate,126),
	NULL,
	cal.schoolID
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		AND c.[name] IN ('AP US History A',
						 'AP US History B',
						 'AP US History C',
						 'speech')
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN('English','Social Studies')
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
INSERT INTO #academicSessions
VALUES
	(1,NULL,NULL,'T1',NULL,'2021-08-25','2021-11-19',NULL,24)
	

SELECT DISTINCT *
FROM #academicSessions
DROP TABLE #academicSessions


