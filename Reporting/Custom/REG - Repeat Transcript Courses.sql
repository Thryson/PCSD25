USE pocatello

DECLARE @eYear INT, @cDay DATETIME;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--This report id's courses that have already been transcripted 
--SELECT DISTINCT tc1.personID
--	,tc1.courseNumber
--	,tc1.courseName
--	,tc1.score
--	,tc2.courseNumber
--	,tc2.courseName
--	,tc2.score
--FROM TranscriptCourse AS tc1
--	INNER JOIN TranscriptCourse AS tc2 ON tc2.personID = tc1.personID
--		AND tc2.endYear BETWEEN @eYear - 3 AND @eYear
--		AND tc2.transcriptID > tc1.transcriptID
--		AND (tc2.courseName = tc1.courseName
--			OR tc2.courseNumber = tc1.courseNumber)
--WHERE tc1.repeatCourse = 0
--	AND tc2.repeatCourse = 0
--	AND tc1.score IN ('A','B','C','D','P')
--	AND tc1.honorsCode != 'B'
--	AND tc1.grade IN ('09','10','11','12')


--This report id's courses that are on the schedule and already on the transcript (must be run prior to term ending)
SELECT DISTINCT p.personID,
	id.lastName + ', ' + id.firstName AS 'studentName',
	sch.comments,
	c.[name] AS 'currentCourseName',
	c.Number AS 'currentCourseNumber',
	te.[name] AS 'currentCourseTerm',
	tc.courseName AS 'transcriptCourseName',
	tc.courseNumber AS 'transcriptCourseNumber',
	tc.grade AS 'transcriptGrade',
	tc.score AS 'transcriptScore'
FROM Person AS p
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Roster AS rs ON rs.personID = id.personID
		AND (rs.endDate IS NULL OR @cDay <= rs.endDate)
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[repeatable] = 0
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] != 'Special Education'
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (18,19,20,22)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID
		AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
		AND @cDay <= te.endDate
	INNER JOIN TranscriptCourse AS tc ON tc.personID = p.personID
		AND (tc.courseNumber = c.number OR tc.courseName = c.[name])
		AND tc.grade IN ('09','10','11','12')
ORDER BY sch.comments,
	studentName


