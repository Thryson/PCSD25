-- AUTHOR: Mullett, Jacob
-- EMAIL : mulletja@SD25.US
-- FILE  : enrollments.sql
-- VENDOR: Cengage / NGLsync

USE pocatello

DECLARE @cDay DATE, @eYear INT;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


CREATE TABLE #enrollments(
	sourcedId INT,
	classSourcedId INT,
	schoolSourcedId INT,
	userSourcedId INT,
	[role] VARCHAR(50),
	[status] INT,
	dateLastModified DATETIME,
	[primary] VARCHAR(20)
)


---students
INSERT INTO #enrollments
SELECT DISTINCT
	rs.rosterID,
	se.sectionID,
	dep.schoolID,
	rs.personID,
	'student',
	NULL,
	NULL,
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
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID 
		AND tl.trialID = se.trialID 
		AND tl.active = 1
--		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID 
		AND sp.trialID = sp.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
		AND ((@cDay BETWEEN te.startDate AND te.endDate AND te.[name] NOT IN ('T1','B1')) 
			OR (@cDay BETWEEN DATEADD(DD, -30, te.startDate) AND te.endDate AND te.[name] IN ('T1','B1'))
			OR (@cDay BETWEEN DATEADD(DD, -14, te.startDate) AND te.endDate AND te.[name] IN ('T2','T3','B2','B3','B4','B5','B6'))
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
		AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
				AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS i ON i.identityID = p.currentIdentityID 
		AND i.personID = p.personID
	INNER JOIN UserAccount AS ua ON ua.personID = p.personID
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.active = 1

---teachers
INSERT INTO #enrollments
SELECT DISTINCT
	ssh.historyID,
	se.sectionID,
	dep.schoolID,
	ssh.personID,
	'teacher',
	NULL,
	NULL,
	NULL
FROM Section AS se
	INNER JOIN Course AS c ON c.courseID = se.courseID 
		 AND c.[name]  IN('AP US History A',
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
			AND (@cDay BETWEEN te.startDate AND DATEADD(DD, +4, te.endDate) AND te.[name] IN ('T1','T2','T3','B1','B2','B3','B4','B5','B6')))
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID 
	AND ((rs.endDate IS NULL OR @cDay <= rs.endDate)
			AND (@cDay >= rs.startDate OR rs.startDate IS NULL))
	INNER JOIN SectionStaffHistory AS ssh ON se.sectionID = ssh.sectionID 
		AND ((ssh.endDate IS NULL OR @cDay <= ssh.endDate)
				AND (@cDay >= ssh.startDate OR ssh.startDate IS NULL))
	INNER JOIN staffMember AS sm ON ssh.personID = sm.personID
		AND ((sm.endDate IS NULL OR @cDay <= sm.endDate)
				AND (@cDay >= sm.startDate OR sm.startDate IS NULL))
	INNER JOIN UserAccount AS ua ON ua.personID = sm.personID 
		AND ua.ldapConfigurationID = '2'
WHERE sm.teacher = 1 
	AND ssh.[role] != 'C'

INSERT INTO #enrollments
VALUES
	(1,1,24,1,'teacher',NULL,NULL,NULL),
	(2,2,24,1,'teacher',NULL,NULL,NULL),
	(11,1,24,2,'student',NULL,NULL,NULL),
	(12,2,24,2,'student',NULL,NULL,NULL)

SELECT
	*
FROM #enrollments

-----------------------------
--- DUPLICATE CHECK
-----------------------------

--SELECT 
--	sourcedId,
--	COUNT(*)
--FROM #enrollments
--GROUP BY sourcedId
--HAVING COUNT(*) > 1

ORDER BY
	[role] DESC,
	schoolSourcedId
	
	
DROP TABLE #enrollments



