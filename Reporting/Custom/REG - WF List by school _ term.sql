USE pocatello

DECLARE @eYear int, @cDay date;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT tc.personID,
	tc.schoolName,
	tc.courseName,
	tc.startTerm,
	tc.grade,
	tc.score
FROM TranscriptCourse AS tc
WHERE tc.endYear = @eYear
	AND tc.score = 'WF'
ORDER BY schoolName