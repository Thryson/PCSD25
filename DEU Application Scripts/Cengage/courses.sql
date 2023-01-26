
-- AUTHOR: Mullett, Jacob
-- EMAIL : mulletja@SD25.US
-- FILE  : courses.sql
-- VENDOR: Cengage / NGLsync

USE pocatello

DECLARE @cDay DATE, @eYear INT;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

CREATE TABLE #courses(
	sourcedId INT,
	[status] INT,
	dateLastModified DATETIME,
	schoolYearId INT,
	metadataDuration DATETIME,
	title VARCHAR(50),
	courseCode INT,
	grade INT,
	orgSourcedId INT,
	subjects INT
)



INSERT INTO #courses
SELECT DISTINCT
	c.courseID
	,NULL
	,NULL
	,cal.calendarID
	,NULL
	,c.[name] --+ ' - Period ' + pd.[name] + ' - Term ' + te.[name],
	,NULL
	,c.grade
	,NULL
	,NULL
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
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
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
--	INNER JOIN [Period] AS pd ON pd.periodID = sp.periodID

INSERT INTO #courses
VALUES
	(1,NULL,NULL,1,NULL,'Test History',NULL,NULL,NULL,NULL),
	(2,NULL,NULL,2,NULL,'Test Speech',NULL,NULL,NULL,NULL)

SELECT 
	sourcedId,
	[status],
	dateLastModified,
	schoolYearId,
	metadataDuration AS 'metadata.duration',
	title,
	courseCode,
	grade,
	orgSourcedId,
	subjects 
FROM #courses
ORDER BY
	sourcedId
DROP 
TABLE #courses

