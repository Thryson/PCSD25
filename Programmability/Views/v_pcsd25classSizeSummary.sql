USE pocatello

-- =============================================
-- Author:		<Lopez, Michael>
-- Modder:		<Lopez, Michael>
-- Create date: <09/01/2021>
-- Update date: <09/01/2021>
-- Description:	<Class Roster Summary by Calendar>
-- =============================================

DECLARE @classSizeReport TABLE (
	personID INT
	,sectionID INT
	,school VARCHAR(10)
	,[range] VARCHAR(10)
	,courseName VARCHAR(100)
	,sectionNumber INT
	,homeroom INT
	,calendarID INT
	,endYear INT
	,classGrade VARCHAR(10)
	,enrollmentGrade VARCHAR(10))

INSERT INTO @classSizeReport
SELECT DISTINCT rs.personID
	,se.sectionID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,co.[name] AS 'courseName'
	,se.number AS 'sectionNumber'
	,co.homeroom
	,cal.calendarID
	,cal.endYear
	,CASE cc.[value]
		WHEN '1' THEN '01'
		WHEN '2' THEN '02'
		WHEN '3' THEN '03'
		WHEN '4' THEN '04'
		WHEN '5' THEN '05'
		WHEN '6' THEN '06'
		WHEN '7' THEN '07'
		WHEN '8' THEN '08'
		WHEN '9' THEN '09'
	ELSE cc.[value] END AS 'classGrade'
	,CASE en.grade
		WHEN 'KA' THEN 'KG'
		WHEN 'KP' THEN 'KG'
		WHEN '00' THEN 'KG'
	ELSE en.grade END AS 'enrollmentGrade'
FROM roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
	INNER JOIN CustomCourse AS cc ON cc.courseID = co.courseID
		AND cc.attributeID = 322
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN Enrollment AS en ON en.calendarID = cal.calendarID
		AND en.personID = rs.personID
		AND en.serviceType = 'P'
		AND en.grade IN ('KA','KP','KM','00','KG','01','02','03','04','05','06','07','08','09','10','11','12','SCE')
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID
		AND cs.attributeID = 618
WHERE rs.endDate IS NULL
	AND se.sectionID IN (
		SELECT se2.sectionID
		FROM Section AS se2
			INNER JOIN Trial AS tl2 ON tl2.trialID = se2.trialID
				AND tl2.active = 1
			INNER JOIN SectionPlacement AS sp2 ON sp2.sectionID = se2.sectionID
			INNER JOIN [Period] AS pd2 ON pd2.periodID = sp2.periodID
				AND pd2.nonInstructional = 0)

SELECT *
	,CASE
		WHEN (csr.classGrade = 'MX' AND csr.homeroom = 1 AND csr.[range] = 'EL') THEN csr.enrollmentGrade
	ELSE csr.classGrade END AS 'logicalGrade'
FROM @classSizeReport AS csr
