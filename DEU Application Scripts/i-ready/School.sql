--------------------------------------------------------------
--Location:		O:i-ready/finalProject
--Client App:	i-ready
--				DEU
--Author:		Jacob Mullett
--Date:			11/15/2019
--File:			schoo.sql
--------------------------------------------------------------
USE pocatello

DECLARE @eYear INT, @cDay DATETIME;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


--CLASS #'s FOR I_ready 22801, 22802, 22803, 26961, 26962, 26963
SELECT DISTINCT 'id-pocat73143' AS 'Client ID',
	cal.schoolID AS 'School ID',
	sch.[name] AS 'School Name',
	di.[name] AS 'District Name',
	di.[state] AS 'State',
	'' AS 'NCES ID',
	'' AS 'Partner ID',
	'' AS 'Action',
	'' AS 'Reserved1',
	'' AS 'Reserved2',
	'' AS 'Reserved3',
	'' AS 'Reserved4',
	'' AS 'Reserved5',
	'' AS 'Reserved6',
	'' AS 'Reserved7',
	'' AS 'Reserved8',
	'' AS 'Reserved9',
	'' AS 'Reserved10'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.[name] LIKE 'Acceleration%'
	INNER JOIN Department AS dep ON dep.departmentID = c.departmentID
		AND dep.[name] IN ('English','Language Arts','Math')
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,21,28)
		AND @cDay BETWEEN cal.startDate - 14 AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN District AS di ON sch.districtID = di.districtID