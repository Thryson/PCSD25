USE pocatello
GO

SELECT c.courseID,
	c.[number] 'courseNumber',
	c.[name] AS 'courseName',
	cal.endYear,
	c.[provider],
	'courseTable' AS 'location',
	sch.comments AS 'school'
FROM Course AS c
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear IN (2019,2020)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE c.[provider] = 0244
