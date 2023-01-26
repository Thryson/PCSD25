USE pocatello
GO

DECLARE @eYear INT;
SET @eYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END;

SELECT sch.comments AS 'school',
	e.serviceType AS 'enrollmentType',
	COUNT(*) AS 'enrollmenCounts'
FROM Enrollment AS e
	INNER JOIN Calendar AS cal ON cal.calendarID = e.calendarID 
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.comments IS NOT NULL
	LEFT JOIN CustomStudent AS cs ON cs.enrollmentID = e.enrollmentID 
		AND cs.attributeID = 903
WHERE e.endYear = @eYear
	AND e.active = 1
	AND (GETDATE() > e.startDate AND e.endDate IS NULL OR GETDATE() < e.endDate)
	AND ((e.serviceType = 'P' AND cs.attributeID != 903 OR cs.attributeID IS NULL) OR (e.serviceType = 'S' AND cs.attributeID = 903))
GROUP BY sch.comments,
	e.serviceType
ORDER BY sch.comments