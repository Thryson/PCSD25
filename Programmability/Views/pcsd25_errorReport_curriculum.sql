USE pocatello    

-- ============================================= 
-- Author:  <Lopez, Michael>
-- Modder:  <Lopez, Michael>
-- Create date: <11/08/2019>
-- Update date: <10/15/2021>
-- Description: <Compile all existing curriculum error reports into single stored procedure>
-- =============================================    

DECLARE @eYear int, @cDay date;  
SET @cDay = GETDATE();  
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;      

DECLARE @errorReport TABLE (
	searchableField varchar(100)
	,searchType varchar(100)   
	,searchLocation varchar(100)   
	,verificationID varchar(50)   
	,verificationType varchar(50)
	,localCode varchar(5)
	,[status] varchar(10)
	,[type] varchar(50)
	,calendarID int
	,school varchar(5)
	,stateReporting int
	,alt int)      
	
DECLARE @errorReport2 TABLE (
	searchableField varchar(100)
	,searchType varchar(100)
	,searchLocation varchar(100)
	,verificationID varchar(50)
	,verificationType varchar(50)
	,localCode varchar(5)
	,[status] varchar(10)
	,[type] varchar(50)
	,calendarID int
	,school varchar(5)
	,stateReporting int
	,alt int)
	

--============================== 
-- 
-- Enrollment Errors Code; EN--- 
-- 
--==============================     

--Error ================================ 
--Code  || Student Multiple Homerooms || 
--EN001 ================================  
INSERT INTO @errorReport2
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Schedule' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'EN001' AS 'localCode'
	,'error' AS 'status'
	,'studentMultipleHomeroom' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,te.termID AS 'alt'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE rs.endDate IS NULL
		OR @cDay <= rs.endDate  
GROUP BY id.lastName + ', ' + id.firstName
	,p.personID
	,cal.calendarID
	,sch.comments
	,te.termID  
HAVING COUNT(*) > 1


INSERT INTO @errorReport
SELECT er2.searchableField
	,er2.searchType
	,er2.searchLocation
	,er2.verificationID
	,er2.verificationType
	,er2.localCode
	,er2.[status]
	,er2.[type]
	,er2.calendarID
	,er2.school
	,er2.stateReporting
	,er2.alt
FROM @errorReport2 AS er2     


--Error ======================================== 
--Code  || 1C2A with Previous Year Enrollment || 
--EN002 ========================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Enrollments' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'EN002' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = @eYear - 1
		AND en2.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en1.startStatus IN ('1C','2A')
	AND en1.serviceType = 'P'
	AND (MONTH(en1.startDate) = 8 AND MONTH(en2.endDate) = 5)     


--Error ===================================== 
--Code  || 1C2A Enrollments within 14 Days || 
--EN003 =====================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Enrollments' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'EN003' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = @eYear
		AND en2.enrollmentID != en1.enrollmentID
		AND en2.serviceType = 'P'
		AND en2.startDate < en1.startDate
		AND DATEADD(DAY, 14, en2.endDate) >= en1.startDate
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE en1.startStatus IN ('1C','2A')
	AND en1.serviceType = 'P'     


--Error ======================================== 
--Code  || 2A2B2C2D with Next Year Enrollment || 
--EN004 ========================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Enrollments' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'EN004' AS 'localCode'
	,'warning' AS 'status'
	,'studentEndCode' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = @eYear
		AND en2.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
		AND cal.endYear = @eYear - 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en1.endStatus IN ('2A','2B','2C','2D')
	AND en1.serviceType = 'P'
	AND (MONTH(en2.startDate) = 8 AND MONTH(en1.endDate) = 5)     


--Error ========================================= 
--Code  || 2A2B2C2D Enrollments within 14 Days || 
--EN005 =========================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Enrollments' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'EN005' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = @eYear
		AND en2.enrollmentID != en1.enrollmentID
		AND en2.serviceType = 'P'
		AND en2.startDate < en1.startDate
		AND DATEADD(DAY, 14, en2.endDate) >= en1.startDate
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE en2.endStatus IN ('2A','2B','2C','2D')
	AND en1.serviceType = 'P'     


--Error ======================================= 
--Code  || Enrollment Record with no classes || 
--EN006 =======================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Enrollments' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'EN006' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentNoClasses' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN (34,7,33)
WHERE en.serviceType = 'P'
	AND en.grade NOT IN ('NG','OT')
	AND en.personID NOT IN (   
		SELECT DISTINCT rs.personID   
		FROM Roster AS rs   
			INNER JOIN Section AS se ON se.sectionID = rs.sectionID   
			INNER JOIN Trial AS tl ON tl.trialID = se.trialID   
				AND tl.active = 1   
			INNER JOIN Course AS co ON co.courseID = se.courseID   
			INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID   
				AND cal.endYear = @eYear   
			INNER JOIN School AS sch ON sch.schoolID = cal.schoolID   
				AND sch.schoolID NOT IN (34,7,33))     


--Error =============================================== 
--Code  || Enrollment or Term Record with no Classes || 
--EN007 ===============================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Schedule' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'EN007' AS 'localCode'
	,'error' AS 'status'
	,'enrollment/TermWithNoClasses' AS 'type'
	,x.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM (
		SELECT rs.personID  
			,te.[name]  
			,cal.calendarID  
			,MAX(ISNULL(rs.endDate, te.endDate)) AS 'maxEndDate'  
			,te.endDate AS 'termEndDate'  
			,en.endDate AS 'enrolEndDate'  
		FROM roster AS rs  
			INNER JOIN Section AS se ON se.sectionID = rs.sectionID  
			INNER JOIN Trial AS tl ON tl.trialID = se.trialID  
				AND tl.active = 1  
			INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID  
			INNER JOIN [Period] AS pd ON pd.periodID = sp.periodID  
				AND pd.nonInstructional = 0  
			INNER JOIN Term AS te ON te.termID = sp.termID  
			INNER JOIN Course AS co ON co.courseID = se.courseID  
			INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID  
				AND cal.endYear = @eYear  
			INNER JOIN Enrollment AS en ON en.personID = rs.personID  
				AND en.calendarID = cal.calendarID  
		WHERE ISNULL(rs.startDate, te.startDate) >= en.startDate 
				AND (ISNULL(rs.endDate, te.endDate) <= en.enddate OR en.endDate IS NULL)
		GROUP BY rs.personID  
			,te.[name]  
			,cal.calendarID  
			,te.endDate  
			,en.endDate    
		HAVING (MAX(ISNULL(rs.endDate, te.endDate)) < te.endDate  
				AND en.endDate > te.endDate)  
					OR (MAX(ISNULL(rs.endDate, te.endDate)) < en.endDate  
						AND en.endDate < te.endDate)
				) AS x
	INNER JOIN Person AS p ON p.personID = x.personID
	INNER JOIN [Identity] AS id ON p.personID = id.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN School AS sch ON sch.schoolID = x.calendarID     


--Error ============================================== 
--Code  || Same Class Same Period Overlapping Dates || 
--EN008 ==============================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>General>Schedule' AS 'searchLocation'
	,co.number + '-' + pd.[name] AS 'verificationID'
	,'courseNumber-period' AS 'verificationType'
	,'EN008' AS 'localCode'
	,'error' AS 'status'
	,'mutlipleOverlappingRepeatedClass' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
		AND sp.trialID = tl.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID
	INNER JOIN [Period] AS pd ON pd.periodID = sp.periodID
		AND pd.nonInstructional = 0
	INNER JOIN Roster AS rs1 ON rs1.sectionID = se.sectionID
	INNER JOIN Roster AS rs2 ON rs1.personID = rs2.personID
		AND rs2.sectionID = rs1.sectionID
		AND rs2.rosterID > rs1.rosterID
	INNER JOIN Person AS p ON p.personID = rs1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE ISNULL(rs2.startDate, te.startDate) < ISNULL(rs1.endDate, te.endDate)     


--Error =================================== 
--Code  || Student No Primary Enrollment || 
--EN009 ===================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>enrollment' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'EN009' AS 'localCode'
	,'error' AS 'status'
	,'studentNoPrimaryEnrollment' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS e1 FULL OUTER JOIN Enrollment AS e2 ON e2.personID = e1.personID
		AND e2.serviceType = 'P'
		AND e2.endYear = @eYear
		AND (@cDay BETWEEN e2.startDate AND e2.endDate  
			OR (@cDay > e2.startDate AND e2.endDate IS NULL))
	INNER JOIN Calendar AS cal ON cal.calendarID = e1.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = e1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE e1.endYear = @eYear
	AND e1.serviceType = 'S'
	AND e2.serviceType IS NULL
	AND (@cDay BETWEEN e1.startDate AND e1.endDate 
		OR (@cDay > e1.startDate AND e1.endDate IS NULL))   


--Error =========================== 
--Code  || Enddate No End Status || 
--EN010 ===========================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>enrollment' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'EN010' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentEnddateNoEndStatus' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.endYear = @eYear
	AND en.endDate IS NOT NULL
	AND en.endStatus IS NULL     


--Error =========================== 
--Code  || End Status No Enddate || 
--EN011 ===========================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>enrollment' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'EN011' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentEndStatusNoEnddate' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.endYear = @eYear
	AND en.endDate IS NULL
	AND en.endStatus IS NOT NULL     


--Error =============================== 
--Code  || Startdate No Start Status || 
--EN012 ===============================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>enrollment' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'EN012' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentStartdateNoStartStatus' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.endYear = @eYear
	AND en.startDate IS NOT NULL
	AND en.startStatus IS NULL     


--Error =============================== 
--Code  || Start Status No Startdate || 
--EN013 ===============================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>enrollment' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'EN013' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentStartStatusNoStartdate' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.endYear = @eYear
	AND en.startDate IS NULL
	AND en.startStatus IS NOT NULL   


--Error ================================ 
--Code  || At Risk when Grade Below 6 || 
--EN014 ================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>enrollment' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'EN014' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentAtRiskGradeLessThan06' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN EnrollmentID AS eid ON eid.enrollmentID = en.enrollmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.grade NOT IN ('06','07','08','09','10','11','12')
	AND eid.atRisk = 'Y'


--Error =================================== 
--Code  || Enrollment Flagged as No Show || 
--EN015 ===================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'search>student>enrollment' AS 'searchLocation'
	,p.studentNumber AS 'verificationID'
	,'studentNumber' AS 'verificationType'
	,'EN015' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentFlaggedNoShow' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN EnrollmentID AS eid ON eid.enrollmentID = en.enrollmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.noShow = 1

	

--============================== 
-- 
-- Section Errors Code; SE--- 
-- 
--==============================     


--Error ================================= 
--Code  || Incomplete Staff Assignment || 
--SE001 =================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section>StaffHistory' AS 'searchLocation'
	,ssh.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE001' AS 'localCode'
	,'error' AS 'status'
	,'incompleteStaffAssignment' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
WHERE ssh.personID IS NOT NULL
	AND (ssh.assignmentID IS NULL
		OR ssh.staffType IS NULL)     


--Error ================================ 
--Code  || No Primary Staff On Course || 
--SE002 ================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section>StaffHistory' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE002' AS 'localCode'
	,'warning' AS 'status'
	,'noPrimaryTeacher' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	LEFT JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
WHERE ssh.personID IS NULL     


--Error ================================= 
--Code  || Section Staff Missing EDUID || 
--SE003 =================================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'staffName' AS 'searchType'
	,'Census>People>Staff>Demographics' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'SE003' AS 'localCode'
	,'error' AS 'status'
	,'sectionStaffMissingEDUID' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
	INNER JOIN Person AS p ON p.personID = ssh.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE p.staffStateID IS NULL     


--Error ======================================== 
--Code  || Provider Data with On Site Section || 
--SE004 ========================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section>Section' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE004' AS 'localCode'
	,'error' AS 'status'
	,'offSiteProviderDataWithOnSiteSection' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE se.sectionID NOT IN (  
		SELECT se.sectionID  
		FROM Section AS se  
			INNER JOIN CustomSection AS cs ON cs.sectionID = se.sectionID AND cs.attributeID = 300     )
				AND (  
					se.providerIDOverride IS NOT NULL 
					OR se.providerDisplayOverride IS NOT NULL 
					OR se.providerSchoolOverride IS NOT NULL 
					OR se.providerSchoolNameOverride IS NOT NULL)  


--Error ========================================== 
--Code  || CTS Primary Staff Mismatching Record || 
--SE005 ==========================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section>Section' AS 'searchLocation'
	,ssh.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE005' AS 'localCode'
	,'warning' AS 'status'
	,'CTSSectionProviderStaffMismatch' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.honorsCode = 'T'
		AND co.active = 1
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTS'
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
	INNER JOIN Person AS p ON p.personID = ssh.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE p.staffStateID != se.providerIDOverride
	OR id.firstName + ' ' + id.lastName != se.providerDisplayOverride     


--Error ====================================== 
--Code  || Missing CTS Provider Information || 
--SE006 ======================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section>Section' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE006' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTSSectionMissingProviderInformation' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN CustomSection AS cs ON cs.sectionID = se.sectionID 
		AND cs.attributeID = 300 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.honorsCode = 'T'
		AND co.active = 1
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTS'
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE se.providerIDOverride IS NULL 
	OR se.providerDisplayOverride IS NULL 
  


--Error ==================================== 
--Code  || CTS flag without 0565 Provider || 
--SE007 ====================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section>Section' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE007' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTSSectionFlagWithout0565' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN CustomSection AS cs ON cs.sectionID = se.sectionID 
		AND cs.attributeID = 300 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.honorsCode = 'T'
		AND co.active = 1
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTS'
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE se.providerSchoolOverride != 0565
	OR se.providerSchoolOverride IS NULL


--Error ================================= 
--Code  || Sections on Inactive Course || 
--SE008 =================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE008' AS 'localCode'
	,'warning' AS 'status'
	,'sectionWithInactiveCourse' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 0
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34     


--Error ====================================== 
--Code  || Section No Instructional Setting || 
--SE009 ======================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE009' AS 'localCode'
	,'incomplete' AS 'status'
	,'sectionNoInstructionalSetting' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE se.instructionalSetting IS NULL     


--Error ========================================== 
--Code  || Primary Teacher not Teacher of Record|| 
--SE010 ==========================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE010' AS 'localCode'
	,'warning' AS 'status'
	,'primaryTeacherNotToR' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
WHERE ssh.[role] IS NULL
	AND ssh.staffType = 'P'


--Error =================================== 
--Code  || CTE with Provider Information || 
--SE011 ===================================  
INSERT INTO @errorReport
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'Course/Section>Course>Section>Section' AS 'searchLocation'
	,se.sectionID AS 'verificationID'
	,'sectionID' AS 'verificationType'
	,'SE011' AS 'localCode'
	,'error' AS 'status'
	,'CTESectionWithProviderInformation' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN CustomSection AS cs ON cs.sectionID = se.sectionID 
		AND cs.attributeID = 300 
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.honorsCode = 'T'
		AND co.active = 1
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTE'
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE se.providerIDOverride IS NOT NULL 
	OR se.providerDisplayOverride IS NOT NULL
	OR se.providerSchoolNameOverride IS NOT NULL
	OR se.providerSchoolOverride IS NOT NULL


--============================== 
-- 
-- Course Errors Code; CO--- 
-- 
--==============================     


--Error ========================== 
--Code  || Dual Credit Mismatch || 
--CO001 ==========================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO001' AS 'localCode'
	,'error' AS 'status'
	,'DualCreditMismatch' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
		AND co.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	LEFT JOIN CustomCourse AS dci ON dci.courseID = co.courseID
		AND dci.attributeID = 445
	LEFT JOIN CustomCourse AS cc ON cc.courseID = co.courseID
		AND cc.attributeID = 614
WHERE ((dci.[value] IS NULL OR dci.[value] = 0) AND (cc.[value] >= 1))
		OR (dci.[value] = 1 AND (cc.[value] IS NULL OR cc.[value] = 0))


--Error =============================== 
--Code  || Offsite Provider Mismatch || 
--CO002 ===============================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO002' AS 'localCode'
	,'error' AS 'status'
	,'offsiteProviderMistmatch' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomCourse AS ps ON ps.courseID = co.courseID
		AND ps.attributeID = 879
	LEFT JOIN CustomCourse AS ise ON ise.courseID = co.courseID
		AND ise.attributeID = 311
WHERE ps.[value] IS NOT NULL
	AND ise.[value] != 'O'    
	


--Error =============================== 
--Code  || Offsite Provider Mismatch || 
--CO002 ===============================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO002' AS 'localCode'
	,'error' AS 'status'
	,'offsiteProviderMistmatch' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomCourse AS ise ON ise.courseID = co.courseID
		AND ise.attributeID = 311
	LEFT JOIN CustomCourse AS ps ON ps.courseID = co.courseID
		AND ps.attributeID = 879
WHERE ps.[value] IS NULL
	AND ise.[value] = 'O'     


--Error ========================================== 
--Code  || Secondary Course Missing Grade level || 
--CO003 ==========================================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO003' AS 'localCode'
	,'warning' AS 'status'
	,'secondaryCourseMissingGradeLevel' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE co.[name] NOT LIKE 'Course %'
	AND co.active = 1
	AND co.courseID NOT IN (  
SELECT co.courseID   
FROM Course AS co  
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID  
		AND cal.endYear = @eYear  
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)  
	INNER JOIN CustomCourse AS gdlv ON gdlv.courseID = co.courseID  
		AND gdlv.attributeID = 322)     


--Error ===================================== 
--Code  || Course No Instructional Setting || 
--CO004 =====================================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO004' AS 'localCode'
	,'warning' AS 'status'
	,'courseNoInstructionalSetting' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE co.[name] NOT LIKE 'Course %'
	AND co.active = 1
	AND co.courseID NOT IN (  
		SELECT co.courseID   
		FROM Course AS co  
			INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID  
				AND cal.endYear = @eYear  
				AND cal.schoolID IN (15,16,17,18,19,20,21,22)  
			INNER JOIN CustomCourse AS gdlv ON gdlv.courseID = co.courseID  
				AND gdlv.attributeID = 311)   


--Error ================================= 
--Code  || CTS Course Missing Provider || 
--CO005 =================================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO005' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTSCourseMissingProvider' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTS'
WHERE co.honorsCode = 'T'
	AND co.active = 1
	AND (co.providerSchool IS NULL OR co.providerSchoolName IS NULL)


--Error ============================= 
--Code  || Course Unknown Provider || 
--CO006 =============================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO006' AS 'localCode'
	,'warning' AS 'status'
	,'courseUnknownProvider' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE co.providerSchool NOT IN (0565,0607,0608,0660)
	AND co.active = 1


--Error ============================== 
--Code  || CTE Course With Provider || 
--CO007 ==============================  
INSERT INTO @errorReport
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,co.courseID AS 'verificationID'
	,'courseID' AS 'verificationType'
	,'CO007' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTECourseWithProviderInformaiton' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTE'
WHERE co.honorsCode = 'T'
	AND co.active = 1
	AND (co.providerSchool IS NOT NULL 
		OR co.providerSchoolName IS NOT NULL
		OR co.providerDisplay IS NOT NULL
		OR co.providerID IS NOT NULL)


--============================== 
-- 
-- CourseMaster Errors Code; CM--- 
-- 
--==============================     


--Error ========================================= 
--Code  || Secondary Course Missing Gradelevel || 
--CM001 =========================================  
INSERT INTO @errorReport
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,cm.courseMasterID AS 'verificationID'
	,'courseMasterID' AS 'verificationType'
	,'CM001' AS 'localCode'
	,'error' AS 'status'
	,'CourseMasterMissingGradeLevel' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
WHERE cm.[name] NOT LIKE 'Course %'
	AND cm.active = 1
	AND cm.catalogID IN (2,3)
	AND cm.courseMasterID NOT IN (  
		SELECT cm.courseMasterID   
		FROM CourseMaster AS cm  
			INNER JOIN CourseMasterAttribute AS gdlv ON gdlv.courseMasterID = cm.courseMasterID  
				AND gdlv.attributeID = 322  
		WHERE cm.catalogID IN (2,3))    


--Error =======================================
--Code  || CTS Course Master Missing Provider||
--CM002 =======================================
INSERT INTO @errorReport
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,cm.courseMasterID AS 'verificationID'
	,'courseMasterID' AS 'verificationType'
	,'CM002' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTSCourseMasterMissingProvider' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
WHERE cm.honorsCode = 'T'
	AND cm.department = 'CTS'
	AND (cm.providerSchool IS NULL OR cm.providerSchoolName IS NULL)


--Error =======================================
--Code  || Active Course Missing Honors Code ||
--CM003 =======================================
INSERT INTO @errorReport
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,cm.courseMasterID AS 'verificationID'
	,'courseMasterID' AS 'verificationType'
	,'CM003' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingHonorsCode' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.honorsCode IS NULL


--Error ======================================
--Code  || Active Course Missing Department ||
--CM004 ======================================
INSERT INTO @errorReport
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,cm.courseMasterID AS 'verificationID'
	,'courseMasterID' AS 'verificationType'
	,'CM004' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingDepartment' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.department IS NULL


--Error ================================
--Code  || Active Course Missing Type ||
--CM005 ================================
INSERT INTO @errorReport
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'Course/Section>Course' AS 'searchLocation'
	,cm.courseMasterID AS 'verificationID'
	,'courseMasterID' AS 'verificationType'
	,'CM005' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingType' AS 'type'
	,'000' AS 'calendarID'
	,'EDC' AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.[type] IS NULL


SELECT  er.searchableField
	,er.searchType
	,er.searchLocation
	,er.verificationID
	,er.verificationType
	,er.localCode
	,er.[status]
	,er.[type]
	,er.calendarID
	,er.school
	,er.stateReporting
FROM @errorReport AS er
WHERE er.localCode NOT IN ('EN001', 'SE009', 'CO004')


/*
DROP TABLE ##errorReport
	,##errorReport2
*/