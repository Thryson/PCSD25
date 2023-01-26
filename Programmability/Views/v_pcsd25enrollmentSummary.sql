USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Modder:		<Lopez, Michael>
-- Create date: <08/31/2021>
-- Update date: <08/31/2021>
-- Description:	<Enrollment Counts and ADM by Calendar>
-- =============================================

DECLARE @cDay date;
SET @cDay = GETDATE();

DECLARE @enrollmentReport TABLE (
	personID INT
	,enrollmentID INT
	,grade VARCHAR(5)
	,school VARCHAR(15)
	,[range] VARCHAR(5)
	,calendarID INT
	,endYear INT
	,enrollmentStartDate DATETIME
	,enrollmentEndDate DATETIME
	,enrolledInstructionDays INT
	,totalInstructionDays INT)


--==============================
--
--	Agg current enrolled instructional days & total instructional days up this point in the given calendar
--
--==============================


INSERT INTO @enrollmentReport
SELECT en.personID
	,en.enrollmentID
	,en.grade
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,cal.calendarID
	,cal.endYear
	,en.startDate AS 'enrollmentStartDate'
	,en.endDate AS 'enrollmentEndDate'
	,SUM(CAST(dy.[instruction] AS INT)) AS 'enrolledInstructionDays'
	,x.totalInstructionDays
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
		AND ss.structureID = en.structureID
	INNER JOIN [Day] AS dy ON dy.calendarID = cal.calendarID
		AND dy.[date] < @cDay
		AND ((dy.[date] >= en.startDate AND en.endDate IS NULL) 
			OR dy.[date] BETWEEN en.startDate AND en.endDate)
		AND dy.instruction = 1
	INNER JOIN PeriodSchedule AS ps ON ps.periodScheduleID = dy.periodScheduleID
		AND ps.structureID = ss.structureID
	INNER JOIN (SELECT cal.calendarID
					,ss.structureID
					,ps.periodScheduleID
					,SUM(CAST(dy.[instruction] AS INT)) AS 'totalInstructionDays'
				FROM Calendar AS cal 
					INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
					INNER JOIN [Day] AS dy ON dy.calendarID = cal.calendarID
						AND dy.[date] < @cDay
						AND dy.instruction = 1
					INNER JOIN PeriodSchedule AS ps ON ps.periodScheduleID = dy.periodScheduleID
						AND ps.structureID = ss.structureID
				GROUP BY cal.calendarID
					,ss.structureID
					,ps.periodScheduleID
				) AS x ON x.calendarID = cal.calendarID
		AND x.structureID = en.structureID
		AND x.periodScheduleID = ps.periodScheduleID
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID
		AND cs.attributeID = 618
WHERE en.serviceType = 'P'
	AND en.grade IN ('KA','KP','KM','00','KG','01','02','03','04','05','06','07','08','09','10','11','12','SCE')
GROUP BY en.personID
	,en.enrollmentID
	,en.grade
	,sch.comments
	,cs.[value]
	,cal.calendarID
	,cal.endYear
	,en.startDate
	,en.endDate
	,x.totalInstructionDays


--==============================
--
--	Calculate ADM per person (global ADM can be calculated by summing this number parsed by calendar) & output data
--
--==============================


SELECT tpen.personID
	,tpen.enrollmentID
	,CASE tpen.grade
		WHEN 'KA' THEN 'KG'
		WHEN 'KP' THEN 'KG'
		WHEN '00' THEN 'KG'
	ELSE tpen.grade END AS 'grade'
	,tpen.school
	,tpen.[range]
	,tpen.calendarID
	,tpen.endYear
	,tpen.enrollmentStartDate
	,tpen.enrollmentEndDate
	,tpen.enrolledInstructionDays
	,tpen.totalInstructionDays
	,SUM(CAST(tpen.enrolledInstructionDays AS decimal) / CAST(tpen.totalInstructionDays AS decimal)) AS 'averageDailyMembership'
FROM @enrollmentReport AS tpen
GROUP BY tpen.personID
	,tpen.enrollmentID
	,tpen.grade
	,tpen.school
	,tpen.[range]
	,tpen.calendarID
	,tpen.endYear
	,tpen.enrollmentStartDate
	,tpen.enrollmentEndDate
	,tpen.enrolledInstructionDays
	,tpen.totalInstructionDays
ORDER BY tpen.endYear