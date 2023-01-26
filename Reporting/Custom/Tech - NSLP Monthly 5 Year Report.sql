USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <01/07/2020>
-- Updater:		<Lopez, Michael>
-- Update date: <01/09/2019>
-- Description:	<File 1/1 for FRAM & eRate reporting>
-- Note 1:	<Query 1 extracts enrollment counts based on month and exports to temp table includes schoolID for aggregation>
-- Note 2:	<Query 2 extracts F & R status for current schools year and aggregates with enrollment counts, exports to temp table>
-- Note 3:	<Query 3 calculates percentage NSLP data and changes for readability>
-- File Name:  <> !Not currently stored procedure!
-- =============================================

DECLARE @eYear INT, @cDay DATETIME;

--Replaces duplicate use of GETDATE()
SET @cDay = GETDATE();

--Removes the need to JOIN the SchoolYear Table and check for active
--Allows your roster outside the active year window if needed
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


-- ==============
-- |Current Year|
-- ==============

SELECT cal.schoolID,
	SUM(CASE WHEN en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		THEN 1 ELSE 0 END) AS 'AugEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		THEN 1 ELSE 0 END) AS 'SepEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'OctEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'NovEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'DecEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'JanEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'FebEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'MarEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'AprEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'MayEnr'
INTO #eRateTemp
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.schoolID NOT IN  (29,31,34)
		AND cal.endYear = @eYear
WHERE en.serviceType = 'P'
	AND en.endYear = @eYear
GROUP BY cal.schoolID

SELECT sch.comments AS 'school',
	ert.AugEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		THEN 1 ELSE 0 END) AS 'AugNLSP',
	ert.SepEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (pose.enddate IS NULL OR pose.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		THEN 1 ELSE 0 END) AS 'SepNLSP',
	ert.OctEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (pose.enddate IS NULL OR pose.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'OctNLSP',
	ert.NovEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (pose.enddate IS NULL OR pose.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'NovNLSP',
	ert.DecEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (pose.enddate IS NULL OR pose.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'DecNLSP',
	ert.JanEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (pose.enddate IS NULL OR pose.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'JanNLSP',
	ert.FebEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (pose.enddate IS NULL OR pose.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'FebNLSP',
	ert.MarEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND (pose.enddate IS NULL OR pose.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'MarNLSP',
	ert.AprEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND (pose.enddate IS NULL OR pose.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'AprNLSP',
	ert.MayEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND (pose.enddate IS NULL OR pose.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear))
		AND en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear))
		THEN 1 ELSE 0 END) AS 'MayNSLP'
INTO #eRateTemp2
FROM #eRateTemp AS ert
	INNER JOIN Calendar As cal ON cal.schoolID = ert.schoolID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.endYear = @eYear
		AND en.serviceType = 'P'
	INNER JOIN POSEligibility AS pose ON pose.personID = en.personID
		AND pose.endYear = @eYear
GROUP BY sch.comments,
	ert.AugEnr,
	ert.SepEnr,
	ert.OctEnr,
	ert.NovEnr,
	ert.DecEnr,
	ert.JanEnr,
	ert.FebEnr,
	ert.MarEnr,
	ert.AprEnr,
	ert.MayEnr

SELECT ert.school,
	ert.AugEnr,
	ert.AugNLSP,
	CAST(ROUND(ert.AugNLSP * 100.0 / ert.AugEnr, 2) AS numeric(36,2)) AS 'AugPer',
	ert.SepEnr,
	ert.SepNLSP,
	CAST(ROUND(ert.SepNLSP * 100.0 / ert.SepEnr, 2) AS numeric(36,2)) AS 'SepPer',
	ert.OctEnr,
	ert.OctNLSP,
	CAST(ROUND(ert.OctNLSP * 100.0 / ert.OctEnr, 2) AS numeric(36,2)) AS 'OctPer',
	ert.NovEnr,
	ert.NovNLSP,
	CAST(ROUND(ert.NovNLSP * 100.0 / ert.NovEnr, 2) AS numeric(36,2)) AS 'NovPer',
	ert.DecEnr,
	ert.DecNLSP,
	CAST(ROUND(ert.DecNLSP * 100.0 / ert.DecEnr, 2) AS numeric(36,2)) AS 'DecPer',
	ert.JanEnr,
	ert.JanNLSP,
	CAST(ROUND(ert.JanNLSP * 100.0 / ert.JanEnr, 2) AS numeric(36,2)) AS 'JanPer',
	ert.FebEnr,
	ert.FebNLSP,
	CAST(ROUND(ert.FebNLSP * 100.0 / ert.FebEnr, 2) AS numeric(36,2)) AS 'FebPer',
	ert.MarEnr,
	ert.MarNLSP,
	CAST(ROUND(ert.MarNLSP * 100.0 / ert.MarEnr, 2) AS numeric(36,2)) AS 'MarPer',
	ert.AprEnr,
	ert.AprNLSP,
	CAST(ROUND(ert.AprNLSP * 100.0 / ert.AprEnr, 2) AS numeric(36,2)) AS 'AprPer',
	ert.MayEnr,
	ert.MayNSLP,
	CAST(ROUND(ert.MayNSLP * 100.0 / ert.MayEnr, 2) AS numeric(36,2)) AS 'MayPer'
FROM #eRateTemp2 AS ert

DROP TABLE #eRateTemp, 
	#eRateTemp2


-- ==================
-- |Current Year - 1|
-- ==================

SELECT cal.schoolID,
	SUM(CASE WHEN en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		THEN 1 ELSE 0 END) AS 'AugEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 2))  
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		THEN 1 ELSE 0 END) AS 'SepEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'OctEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'NovEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'DecEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'JanEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'FebEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'MarEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'AprEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'MayEnr'
INTO #eRateTemp
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.schoolID NOT IN (29,31,34)
		AND cal.endYear = (@eYear - 1)
WHERE en.serviceType = 'P'
	AND en.endYear = (@eYear - 1)
GROUP BY cal.schoolID

SELECT sch.comments AS 'school',
	ert.AugEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		THEN 1 ELSE 0 END) AS 'AugNLSP',
	ert.SepEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (pose.enddate IS NULL OR pose.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		THEN 1 ELSE 0 END) AS 'SepNLSP',
	ert.OctEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (pose.enddate IS NULL OR pose.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'OctNLSP',
	ert.NovEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (pose.enddate IS NULL OR pose.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'NovNLSP',
	ert.DecEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (pose.enddate IS NULL OR pose.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'DecNLSP',
	ert.JanEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (pose.enddate IS NULL OR pose.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'JanNLSP',
	ert.FebEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (pose.enddate IS NULL OR pose.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'FebNLSP',
	ert.MarEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND (pose.enddate IS NULL OR pose.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'MarNLSP',
	ert.AprEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND (pose.enddate IS NULL OR pose.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'AprNLSP',
	ert.MayEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND (pose.enddate IS NULL OR pose.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		AND en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 1)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 1))
		THEN 1 ELSE 0 END) AS 'MayNSLP'
INTO #eRateTemp2
FROM #eRateTemp AS ert
	INNER JOIN Calendar As cal ON cal.schoolID = ert.schoolID
		AND cal.endYear = (@eYear - 1)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.endYear = (@eYear - 1)
		AND en.serviceType = 'P'
	INNER JOIN POSEligibility AS pose ON pose.personID = en.personID
		AND pose.endYear = (@eYear - 1)
GROUP BY sch.comments,
	ert.AugEnr,
	ert.SepEnr,
	ert.OctEnr,
	ert.NovEnr,
	ert.DecEnr,
	ert.JanEnr,
	ert.FebEnr,
	ert.MarEnr,
	ert.AprEnr,
	ert.MayEnr

SELECT ert.school,
	ert.AugEnr,
	ert.AugNLSP,
	CAST(ROUND(ert.AugNLSP * 100.0 / ert.AugEnr, 2) AS numeric(36,2)) AS 'AugPer',
	ert.SepEnr,
	ert.SepNLSP,
	CAST(ROUND(ert.SepNLSP * 100.0 / ert.SepEnr, 2) AS numeric(36,2)) AS 'SepPer',
	ert.OctEnr,
	ert.OctNLSP,
	CAST(ROUND(ert.OctNLSP * 100.0 / ert.OctEnr, 2) AS numeric(36,2)) AS 'OctPer',
	ert.NovEnr,
	ert.NovNLSP,
	CAST(ROUND(ert.NovNLSP * 100.0 / ert.NovEnr, 2) AS numeric(36,2)) AS 'NovPer',
	ert.DecEnr,
	ert.DecNLSP,
	CAST(ROUND(ert.DecNLSP * 100.0 / ert.DecEnr, 2) AS numeric(36,2)) AS 'DecPer',
	ert.JanEnr,
	ert.JanNLSP,
	CAST(ROUND(ert.JanNLSP * 100.0 / ert.JanEnr, 2) AS numeric(36,2)) AS 'JanPer',
	ert.FebEnr,
	ert.FebNLSP,
	CAST(ROUND(ert.FebNLSP * 100.0 / ert.FebEnr, 2) AS numeric(36,2)) AS 'FebPer',
	ert.MarEnr,
	ert.MarNLSP,
	CAST(ROUND(ert.MarNLSP * 100.0 / ert.MarEnr, 2) AS numeric(36,2)) AS 'MarPer',
	ert.AprEnr,
	ert.AprNLSP,
	CAST(ROUND(ert.AprNLSP * 100.0 / ert.AprEnr, 2) AS numeric(36,2)) AS 'AprPer',
	ert.MayEnr,
	ert.MayNSLP,
	CAST(ROUND(ert.MayNSLP * 100.0 / ert.MayEnr, 2) AS numeric(36,2)) AS 'MayPer'
FROM #eRateTemp2 AS ert

DROP TABLE #eRateTemp, 
	#eRateTemp2




-- ==================
-- |Current Year - 2|
-- ==================

SELECT cal.schoolID,
	SUM(CASE WHEN en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		THEN 1 ELSE 0 END) AS 'AugEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		THEN 1 ELSE 0 END) AS 'SepEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'OctEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'NovEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'DecEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'JanEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'FebEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'MarEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'AprEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'MayEnr'
INTO #eRateTemp3
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.schoolID NOT IN (29,31,34)
		AND cal.endYear = (@eYear - 2)
WHERE en.serviceType = 'P'
	AND en.endYear = (@eYear - 2)
GROUP BY cal.schoolID

SELECT sch.comments AS 'school',
	ert.AugEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		THEN 1 ELSE 0 END) AS 'AugNLSP',
	ert.SepEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (pose.enddate IS NULL OR pose.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		THEN 1 ELSE 0 END) AS 'SepNLSP',
	ert.OctEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (pose.enddate IS NULL OR pose.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'OctNLSP',
	ert.NovEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (pose.enddate IS NULL OR pose.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'NovNLSP',
	ert.DecEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (pose.enddate IS NULL OR pose.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'DecNLSP',
	ert.JanEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (pose.enddate IS NULL OR pose.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'JanNLSP',
	ert.FebEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (pose.enddate IS NULL OR pose.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'FebNLSP',
	ert.MarEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND (pose.enddate IS NULL OR pose.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'MarNLSP',
	ert.AprEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND (pose.enddate IS NULL OR pose.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'AprNLSP',
	ert.MayEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND (pose.enddate IS NULL OR pose.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		AND en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 2)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 2))
		THEN 1 ELSE 0 END) AS 'MayNSLP'
INTO #eRateTemp4
FROM #eRateTemp3 AS ert
	INNER JOIN Calendar As cal ON cal.schoolID = ert.schoolID
		AND cal.endYear = (@eYear - 2)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.endYear = (@eYear - 2)
		AND en.serviceType = 'P'
	INNER JOIN POSEligibility AS pose ON pose.personID = en.personID
		AND pose.endYear = (@eYear - 2)
GROUP BY sch.comments,
	ert.AugEnr,
	ert.SepEnr,
	ert.OctEnr,
	ert.NovEnr,
	ert.DecEnr,
	ert.JanEnr,
	ert.FebEnr,
	ert.MarEnr,
	ert.AprEnr,
	ert.MayEnr

SELECT ert.school,
	ert.AugEnr,
	ert.AugNLSP,
	CAST(ROUND(ert.AugNLSP * 100.0 / ert.AugEnr, 2) AS numeric(36,2)) AS 'AugPer',
	ert.SepEnr,
	ert.SepNLSP,
	CAST(ROUND(ert.SepNLSP * 100.0 / ert.SepEnr, 2) AS numeric(36,2)) AS 'SepPer',
	ert.OctEnr,
	ert.OctNLSP,
	CAST(ROUND(ert.OctNLSP * 100.0 / ert.OctEnr, 2) AS numeric(36,2)) AS 'OctPer',
	ert.NovEnr,
	ert.NovNLSP,
	CAST(ROUND(ert.NovNLSP * 100.0 / ert.NovEnr, 2) AS numeric(36,2)) AS 'NovPer',
	ert.DecEnr,
	ert.DecNLSP,
	CAST(ROUND(ert.DecNLSP * 100.0 / ert.DecEnr, 2) AS numeric(36,2)) AS 'DecPer',
	ert.JanEnr,
	ert.JanNLSP,
	CAST(ROUND(ert.JanNLSP * 100.0 / ert.JanEnr, 2) AS numeric(36,2)) AS 'JanPer',
	ert.FebEnr,
	ert.FebNLSP,
	CAST(ROUND(ert.FebNLSP * 100.0 / ert.FebEnr, 2) AS numeric(36,2)) AS 'FebPer',
	ert.MarEnr,
	ert.MarNLSP,
	CAST(ROUND(ert.MarNLSP * 100.0 / ert.MarEnr, 2) AS numeric(36,2)) AS 'MarPer',
	ert.AprEnr,
	ert.AprNLSP,
	CAST(ROUND(ert.AprNLSP * 100.0 / ert.AprEnr, 2) AS numeric(36,2)) AS 'AprPer',
	ert.MayEnr,
	ert.MayNSLP,
	CAST(ROUND(ert.MayNSLP * 100.0 / ert.MayEnr, 2) AS numeric(36,2)) AS 'MayPer'
FROM #eRateTemp4 AS ert

DROP TABLE #eRateTemp3, 
	#eRateTemp4

-- ==================
-- |Current Year - 3|
-- ==================

SELECT cal.schoolID,
	SUM(CASE WHEN en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		THEN 1 ELSE 0 END) AS 'AugEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		THEN 1 ELSE 0 END) AS 'SepEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'OctEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'NovEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'DecEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'JanEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'FebEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'MarEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'AprEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'MayEnr'
INTO #eRateTemp5
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.schoolID NOT IN (29,31,34)
		AND cal.endYear = (@eYear - 3)
WHERE en.serviceType = 'P'
	AND en.endYear = (@eYear - 3)
GROUP BY cal.schoolID

SELECT sch.comments AS 'school',
	ert.AugEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		THEN 1 ELSE 0 END) AS 'AugNLSP',
	ert.SepEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (pose.enddate IS NULL OR pose.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		THEN 1 ELSE 0 END) AS 'SepNLSP',
	ert.OctEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (pose.enddate IS NULL OR pose.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'OctNLSP',
	ert.NovEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (pose.enddate IS NULL OR pose.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'NovNLSP',
	ert.DecEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (pose.enddate IS NULL OR pose.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'DecNLSP',
	ert.JanEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (pose.enddate IS NULL OR pose.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'JanNLSP',
	ert.FebEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (pose.enddate IS NULL OR pose.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'FebNLSP',
	ert.MarEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND (pose.enddate IS NULL OR pose.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'MarNLSP',
	ert.AprEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND (pose.enddate IS NULL OR pose.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'AprNLSP',
	ert.MayEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND (pose.enddate IS NULL OR pose.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		AND en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 3)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 3))
		THEN 1 ELSE 0 END) AS 'MayNSLP'
INTO #eRateTemp6
FROM #eRateTemp5 AS ert
	INNER JOIN Calendar As cal ON cal.schoolID = ert.schoolID
		AND cal.endYear = (@eYear - 3)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.endYear = (@eYear - 3)
		AND en.serviceType = 'P'
	INNER JOIN POSEligibility AS pose ON pose.personID = en.personID
		AND pose.endYear = (@eYear - 3)
GROUP BY sch.comments,
	ert.AugEnr,
	ert.SepEnr,
	ert.OctEnr,
	ert.NovEnr,
	ert.DecEnr,
	ert.JanEnr,
	ert.FebEnr,
	ert.MarEnr,
	ert.AprEnr,
	ert.MayEnr

SELECT ert.school,
	ert.AugEnr,
	ert.AugNLSP,
	CAST(ROUND(ert.AugNLSP * 100.0 / ert.AugEnr, 2) AS numeric(36,2)) AS 'AugPer',
	ert.SepEnr,
	ert.SepNLSP,
	CAST(ROUND(ert.SepNLSP * 100.0 / ert.SepEnr, 2) AS numeric(36,2)) AS 'SepPer',
	ert.OctEnr,
	ert.OctNLSP,
	CAST(ROUND(ert.OctNLSP * 100.0 / ert.OctEnr, 2) AS numeric(36,2)) AS 'OctPer',
	ert.NovEnr,
	ert.NovNLSP,
	CAST(ROUND(ert.NovNLSP * 100.0 / ert.NovEnr, 2) AS numeric(36,2)) AS 'NovPer',
	ert.DecEnr,
	ert.DecNLSP,
	CAST(ROUND(ert.DecNLSP * 100.0 / ert.DecEnr, 2) AS numeric(36,2)) AS 'DecPer',
	ert.JanEnr,
	ert.JanNLSP,
	CAST(ROUND(ert.JanNLSP * 100.0 / ert.JanEnr, 2) AS numeric(36,2)) AS 'JanPer',
	ert.FebEnr,
	ert.FebNLSP,
	CAST(ROUND(ert.FebNLSP * 100.0 / ert.FebEnr, 2) AS numeric(36,2)) AS 'FebPer',
	ert.MarEnr,
	ert.MarNLSP,
	CAST(ROUND(ert.MarNLSP * 100.0 / ert.MarEnr, 2) AS numeric(36,2)) AS 'MarPer',
	ert.AprEnr,
	ert.AprNLSP,
	CAST(ROUND(ert.AprNLSP * 100.0 / ert.AprEnr, 2) AS numeric(36,2)) AS 'AprPer',
	ert.MayEnr,
	ert.MayNSLP,
	CAST(ROUND(ert.MayNSLP * 100.0 / ert.MayEnr, 2) AS numeric(36,2)) AS 'MayPer'
FROM #eRateTemp6 AS ert

DROP TABLE #eRateTemp5, 
	#eRateTemp6

-- ==================
-- |Current Year - 4|
-- ==================


SELECT cal.schoolID,
	SUM(CASE WHEN en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		THEN 1 ELSE 0 END) AS 'AugEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		THEN 1 ELSE 0 END) AS 'SepEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		THEN 1 ELSE 0 END) AS 'OctEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		THEN 1 ELSE 0 END) AS 'NovEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		THEN 1 ELSE 0 END) AS 'DecEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'JanEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'FebEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'MarEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'AprEnr',
	SUM(CASE WHEN en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'MayEnr'
INTO #eRateTemp7
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.schoolID NOT IN (29,31,34)
		AND cal.endYear = (@eYear - 4)
WHERE en.serviceType = 'P'
	AND en.endYear = (@eYear - 4)
GROUP BY cal.schoolID

SELECT sch.comments AS 'school',
	ert.AugEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		AND en.startdate < EOMONTH('08/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		THEN 1 ELSE 0 END) AS 'AugNLSP',
	ert.SepEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (pose.enddate IS NULL OR pose.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		AND en.startdate < EOMONTH('09/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '09/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		THEN 1 ELSE 0 END) AS 'SepNLSP',
	ert.OctEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (pose.enddate IS NULL OR pose.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		AND en.startdate < EOMONTH('10/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '10/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		THEN 1 ELSE 0 END) AS 'OctNLSP',
	ert.NovEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (pose.enddate IS NULL OR pose.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		AND en.startdate < EOMONTH('11/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '11/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		THEN 1 ELSE 0 END) AS 'NovNLSP',
	ert.DecEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (pose.enddate IS NULL OR pose.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		AND en.startdate < EOMONTH('12/' + '01/' + CONVERT(VARCHAR, @eYear - 5)) 
		AND (en.enddate IS NULL OR en.endDate > '12/' + '01/' + CONVERT(VARCHAR, @eYear - 5))
		THEN 1 ELSE 0 END) AS 'DecNLSP',
	ert.JanEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (pose.enddate IS NULL OR pose.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('01/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND (en.enddate IS NULL OR en.endDate > '01/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'JanNLSP',
	ert.FebEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (pose.enddate IS NULL OR pose.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('02/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '02/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'FebNLSP',
	ert.MarEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND (pose.enddate IS NULL OR pose.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('03/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '03/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'MarNLSP',
	ert.AprEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND (pose.enddate IS NULL OR pose.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('04/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '04/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'AprNLSP',
	ert.MayEnr,
	SUM(CASE WHEN pose.eligibility IN ('F','R') 
		AND pose.startDate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND (pose.enddate IS NULL OR pose.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		AND en.startdate < EOMONTH('05/' + '01/' + CONVERT(VARCHAR, @eYear - 4)) 
		AND (en.enddate IS NULL OR en.endDate > '05/' + '01/' + CONVERT(VARCHAR, @eYear - 4))
		THEN 1 ELSE 0 END) AS 'MayNSLP'
INTO #eRateTemp8
FROM #eRateTemp7 AS ert
	INNER JOIN Calendar As cal ON cal.schoolID = ert.schoolID
		AND cal.endYear = (@eYear - 4)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.endYear = (@eYear - 4)
		AND en.serviceType = 'P'
	INNER JOIN POSEligibility AS pose ON pose.personID = en.personID
		AND pose.endYear = (@eYear - 4)
GROUP BY sch.comments,
	ert.AugEnr,
	ert.SepEnr,
	ert.OctEnr,
	ert.NovEnr,
	ert.DecEnr,
	ert.JanEnr,
	ert.FebEnr,
	ert.MarEnr,
	ert.AprEnr,
	ert.MayEnr

SELECT ert.school,
	ert.AugEnr,
	ert.AugNLSP,
	CAST(ROUND(ert.AugNLSP * 100.0 / ert.AugEnr, 2) AS numeric(36,2)) AS 'AugPer',
	ert.SepEnr,
	ert.SepNLSP,
	CAST(ROUND(ert.SepNLSP * 100.0 / ert.SepEnr, 2) AS numeric(36,2)) AS 'SepPer',
	ert.OctEnr,
	ert.OctNLSP,
	CAST(ROUND(ert.OctNLSP * 100.0 / ert.OctEnr, 2) AS numeric(36,2)) AS 'OctPer',
	ert.NovEnr,
	ert.NovNLSP,
	CAST(ROUND(ert.NovNLSP * 100.0 / ert.NovEnr, 2) AS numeric(36,2)) AS 'NovPer',
	ert.DecEnr,
	ert.DecNLSP,
	CAST(ROUND(ert.DecNLSP * 100.0 / ert.DecEnr, 2) AS numeric(36,2)) AS 'DecPer',
	ert.JanEnr,
	ert.JanNLSP,
	CAST(ROUND(ert.JanNLSP * 100.0 / ert.JanEnr, 2) AS numeric(36,2)) AS 'JanPer',
	ert.FebEnr,
	ert.FebNLSP,
	CAST(ROUND(ert.FebNLSP * 100.0 / ert.FebEnr, 2) AS numeric(36,2)) AS 'FebPer',
	ert.MarEnr,
	ert.MarNLSP,
	CAST(ROUND(ert.MarNLSP * 100.0 / ert.MarEnr, 2) AS numeric(36,2)) AS 'MarPer',
	ert.AprEnr,
	ert.AprNLSP,
	CAST(ROUND(ert.AprNLSP * 100.0 / ert.AprEnr, 2) AS numeric(36,2)) AS 'AprPer',
	ert.MayEnr,
	ert.MayNSLP,
	CAST(ROUND(ert.MayNSLP * 100.0 / ert.MayEnr, 2) AS numeric(36,2)) AS 'MayPer'
FROM #eRateTemp8 AS ert

DROP TABLE #eRateTemp7, 
	#eRateTemp8