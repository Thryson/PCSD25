USE pocatello
DECLARE @eYear INT, @cDay DATETIME;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END; 

SELECT x.personID,
    x.[name],
    x.grade,
    sch.comments AS 'school',
    SUM(x.creditsEarned) AS totalcreds,
	e.endYear
FROM (
    SELECT DISTINCT p.personID,
		i.lastName + ', ' + i.firstName AS [name],
		e.grade,
		tcr.creditsEarned,
		tc.transcriptID        
    FROM Person AS p
        INNER JOIN Enrollment AS e ON e.personID = p.personID
        INNER JOIN [Identity] AS i ON i.personID = p.personID
            AND i.identityID = p.currentIdentityID
        INNER JOIN TranscriptCourse AS tc ON tc.personID = p.personID
            AND tc.grade IN (09, 10, 11, 12)
        INNER JOIN TranscriptCredit AS tcr ON tcr.transcriptID = tc.transcriptID
    WHERE e.grade IN ('09', '10', '11', '12')
        AND e.serviceType = 'P'
        AND e.active = 1
        AND (e.endStatus IN ('1A', '1B')
                OR e.endStatus IS NULL)
        AND e.endYear = @eYear
    ) AS x
    INNER JOIN Enrollment AS e ON x.personID = e.personID
        AND e.serviceType = 'P'
        AND e.active = 1
        AND e.endYear = @eYear
    INNER JOIN Calendar AS cal ON cal.calendarID = e.calendarID
       -- AND cal.schoolID != 22
    INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
--WHERE sch.comments = 'PHS'
GROUP BY x.personID,
    x.[name],
    x.grade,
    sch.comments,
	e.endYear
HAVING (x.grade = 09 AND SUM(x.creditsEarned) <= 9)
    OR (x.grade = 10 AND SUM(x.creditsEarned) <= 22)
    OR (x.grade = 11 AND SUM(x.creditsEarned) <= 35)
	OR (x.grade = 12 AND SUM(x.creditsEarned) <= 46)
ORDER BY 
	sch.comments,
	[name]

