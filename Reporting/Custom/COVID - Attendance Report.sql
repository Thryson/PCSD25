USE pocatello

DECLARE @eYear INT, @cDay DATE;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--student count
SELECT COUNT(*) AS 'stuCount'
FROM Enrollment AS en
WHERE en.serviceType = 'P'
	AND en.endYear = @eYear
	AND ((en.endDate IS NULL AND @cDay > en.startDate) OR (@cDay BETWEEN en.startDate AND en.endDate))


--PD Counts Whole
SELECT SUM(CONVERT(int, x.pdCountBase)) AS 'totalPeriods'
FROM (SELECT CASE
		WHEN en.grade IN ('01','02','03','04','05') THEN '2'
		WHEN en.grade IN ('06','07','08') THEN '7'
		WHEN en.grade IN ('09','10','11','12') THEN '5'
		ELSE '1'
	END AS 'pdCountBase'
FROM Enrollment AS en
WHERE en.serviceType = 'P'
	AND en.endYear = @eYear
	AND ((en.endDate IS NULL AND @cDay > en.startDate) OR (@cDay BETWEEN en.startDate AND en.endDate))
) AS x

--Todays by student
SELECT x.studentNumber,
	x.school,
	CONVERT(decimal(5,2),MAX(x.pdCount)) / CONVERT(decimal(5,2),x.pdCountBase) AS 'abCount'
FROM (SELECT DISTINCT p.studentNumber,
	sch.comments AS 'school',
	pd.[name] AS 'period',
	atte.[status],
	DENSE_RANK() OVER(PARTITION BY p.studentNumber ORDER BY p.studentNumber, pd.[name] DESC) AS 'pdCount',
	CASE
		WHEN en.grade IN ('01','02','03','04','05') THEN '2'
		WHEN en.grade IN ('06','07','08') THEN '7'
		WHEN en.grade IN ('09','10','11','12') THEN '5'
		ELSE '1'
	END AS 'pdCountBase'
FROM Attendance AS att
	INNER JOIN AttendanceExcuse AS atte ON atte.excuseID = att.excuseID
	INNER JOIN Calendar AS cal ON cal.calendarID = att.calendarID
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.personID = att.personID
		AND en.endYear = @eYear
		AND en.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Period] AS pd ON pd.periodID = att.periodID
		AND pd.nonInstructional = 0
WHERE att.[date] = @cDay
	AND atte.[status] = 'A'
) AS x
GROUP BY x.studentNumber,
	x.school,
	x.pdCountBase

--Last week by student
SELECT x.studentNumber,
	x.school,
	CONVERT(decimal(5,2),MAX(x.pdCount)) / CONVERT(decimal(5,2),x.pdCountBase) AS 'abCount'
FROM (SELECT DISTINCT p.studentNumber,
	sch.comments AS 'school',
	pd.[name] AS 'period',
	atte.[status],
	DENSE_RANK() OVER(PARTITION BY p.studentNumber ORDER BY p.studentNumber, pd.[name] DESC) AS 'pdCount',
	CASE
		WHEN en.grade IN ('01','02','03','04','05') THEN '2'
		WHEN en.grade IN ('06','07','08') THEN '7'
		WHEN en.grade IN ('09','10','11','12') THEN '5'
		ELSE '1'
	END AS 'pdCountBase'
FROM Attendance AS att
	INNER JOIN AttendanceExcuse AS atte ON atte.excuseID = att.excuseID
	INNER JOIN Calendar AS cal ON cal.calendarID = att.calendarID
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.personID = att.personID
		AND en.endYear = @eYear
		AND en.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Period] AS pd ON pd.periodID = att.periodID
		AND pd.nonInstructional = 0
WHERE att.[date] = DATEADD(dd, -7, @cDay)
	AND atte.[status] = 'A'
) AS x
GROUP BY x.studentNumber,
	x.school,
	x.pdCountBase

--Today by period/school
SELECT DISTINCT sch.comments AS 'school',
	pd.[name] AS 'period',
	atte.[status],
	COUNT(*) AS 'count'
FROM Attendance AS att
	INNER JOIN AttendanceExcuse AS atte ON atte.excuseID = att.excuseID
	INNER JOIN Calendar AS cal ON cal.calendarID = att.calendarID
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.personID = att.personID
		AND en.endYear = @eYear
		AND en.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Period] AS pd ON pd.periodID = att.periodID
		AND pd.nonInstructional = 0
WHERE att.[date] = @cDay
	AND atte.[status] = 'A'
	AND pd.[name] != '00'
GROUP BY sch.comments,
	pd.[name],
	atte.[status]
ORDER BY sch.comments,
	pd.[name]


--Last week by period/school
SELECT DISTINCT sch.comments AS 'school',
	pd.[name] AS 'period',
	atte.[status],
	COUNT(*) AS 'count'
FROM Attendance AS att
	INNER JOIN AttendanceExcuse AS atte ON atte.excuseID = att.excuseID
	INNER JOIN Calendar AS cal ON cal.calendarID = att.calendarID
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.personID = att.personID
		AND en.endYear = @eYear
		AND en.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Period] AS pd ON pd.periodID = att.periodID
		AND pd.nonInstructional = 0
WHERE att.[date] = DATEADD(dd, -7, @cDay)
	AND atte.[status] = 'A'
	AND pd.[name] != '00'
GROUP BY sch.comments,
	pd.[name],
	atte.[status]
ORDER BY sch.comments,
	pd.[name]
