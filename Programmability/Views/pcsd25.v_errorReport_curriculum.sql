USE pocatello    

-- ============================================= 
-- Author:  <Lopez, Michael>
-- Modder:  <Lopez, Michael>
-- Create date: <11/08/2019>
-- Update date: <02/02/2023>
-- Description: <Compile all existing curriculum error reports into a single view>
-- =============================================    
	

--============================== 
-- 
-- Enrollment Errors Code; EN--- 
-- 
--==============================     

--Error ================================ 
--Code  || Student Multiple Homerooms || 
--EN001 ================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN001' AS 'localCode'
	,'error' AS 'status'
	,'studentMultipleHomeroom' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,te.termID AS 'alt'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Course AS c ON c.courseID = se.courseID
		AND c.homeroom = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = se.sectionID
	INNER JOIN Term AS te ON te.termID = sp.termID
	INNER JOIN Person AS p ON p.personID = rs.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE rs.endDate IS NULL
		OR GETDATE() <= rs.endDate  
GROUP BY studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
	,te.termID  
HAVING COUNT(*) > 1


UNION ALL


--Error ======================================== 
--Code  || 1C2A with Previous Year Enrollment || 
--EN002 ========================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN002' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = en1.endYear - 1
		AND en2.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en1.startStatus IN ('1C','2A')
	AND en1.serviceType = 'P'
	AND (MONTH(en1.startDate) = 8 AND MONTH(en2.endDate) = 5)     


UNION ALL


--Error ===================================== 
--Code  || 1C2A Enrollments within 14 Days || 
--EN003 =====================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN003' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = en1.endyear
		AND en2.enrollmentID != en1.enrollmentID
		AND en2.serviceType = 'P'
		AND en2.startDate < en1.startDate
		AND DATEADD(DAY, 14, en2.endDate) >= en1.startDate
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en1.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE en1.startStatus IN ('1C','2A')
	AND en1.serviceType = 'P'     


UNION ALL


--Error ======================================== 
--Code  || 2A2B2C2D with Next Year Enrollment || 
--EN004 ========================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN004' AS 'localCode'
	,'warning' AS 'status'
	,'studentEndCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.serviceType = 'P'
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en2.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE en1.endStatus IN ('2A','2B','2C','2D')
	AND en1.serviceType = 'P'
	AND (MONTH(en2.startDate) = 8 AND MONTH(en1.endDate) = 5)     


UNION ALL


--Error ========================================= 
--Code  || 2A2B2C2D Enrollments within 14 Days || 
--EN005 =========================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN005' AS 'localCode'
	,'warning' AS 'status'
	,'studentStartCode' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en1
	INNER JOIN Enrollment AS en2 ON en2.personID = en1.personID
		AND en2.endYear = en1.endYear
		AND en2.enrollmentID != en1.enrollmentID
		AND en2.serviceType = 'P'
		AND en2.startDate < en1.startDate
		AND DATEADD(DAY, 14, en2.endDate) >= en1.startDate
	INNER JOIN Person AS p ON p.personID = en1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en2.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE en2.endStatus IN ('2A','2B','2C','2D')
	AND en1.serviceType = 'P'     


UNION ALL


--Error ======================================= 
--Code  || Enrollment Record with no classes || 
--EN006 =======================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN006' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentNoClasses' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
			AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN (7,33) -- Exlucde the following HS, LINC
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
			INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
					AND scy.active = 1  
			INNER JOIN School AS sch ON sch.schoolID = cal.schoolID   
				AND sch.schoolID NOT IN (34,7,33))     


UNION ALL


--Error ================================================================ 
--Code  || Enrollment or Term Record with non aligned section enddate || 
--EN007 ================================================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN007' AS 'localCode'
	,'error' AS 'status'
	,'CourseEndDateNoMatch' AS 'type'
	,p.personID
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
			INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1 
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


UNION ALL


--Error ============================================== 
--Code  || Same Class Same Period Overlapping Dates || 
--EN008 ==============================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN008' AS 'localCode'
	,'error' AS 'status'
	,'mutlipleOverlappingRepeatedClass' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
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
	OR (rs1.startDate IS NULL AND rs2.startDate IS NULL)
	OR (rs1.endDate IS NULL AND rs2.endDate IS NULL)


UNION ALL


--Error =================================== 
--Code  || Student No Primary Enrollment || 
--EN009 ===================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN009' AS 'localCode'
	,'error' AS 'status'
	,'studentNoPrimaryEnrollment' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS e1 
FULL OUTER JOIN Enrollment AS e2 ON e2.personID = e1.personID
		AND e2.serviceType = 'P'
		AND e2.endYear = YEAR(GETDATE())
		AND (GETDATE() BETWEEN e2.startDate AND e2.endDate  
			OR (GETDATE() > e2.startDate AND e2.endDate IS NULL))
	INNER JOIN Calendar AS cal ON cal.calendarID = e1.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = e1.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE e1.endYear = YEAR(GETDATE())
	AND e1.serviceType = 'S'
	AND e2.serviceType IS NULL
	AND (GETDATE() BETWEEN e1.startDate AND e1.endDate 
		OR (GETDATE() > e1.startDate AND e1.endDate IS NULL))   


UNION ALL


--Error =========================== 
--Code  || Enddate No End Status || 
--EN010 ===========================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN010' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentEnddateNoEndStatus' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.endDate IS NOT NULL
	AND en.endStatus IS NULL     


UNION ALL


--Error =========================== 
--Code  || End Status No Enddate || 
--EN011 ===========================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN011' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentEndStatusNoEnddate' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.endDate IS NULL
	AND en.endStatus IS NOT NULL     


UNION ALL


--Error =============================== 
--Code  || Startdate No Start Status || 
--EN012 ===============================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN012' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentStartdateNoStartStatus' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.startDate IS NOT NULL
	AND en.startStatus IS NULL     


UNION ALL


--Error =============================== 
--Code  || Start Status No Startdate || 
--EN013 ===============================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN013' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentStartStatusNoStartdate' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.startDate IS NULL
	AND en.startStatus IS NOT NULL   


UNION ALL


--Error ================================ 
--Code  || At Risk when Grade Below 6 || 
--EN014 ================================  
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN014' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentAtRiskGradeLessThan06' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN EnrollmentID AS eid ON eid.enrollmentID = en.enrollmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.grade NOT IN ('06','07','08','09','10','11','12')
	AND eid.atRisk = 'Y'


UNION ALL


--Error =================================== 
--Code  || Enrollment Flagged as No Show || 
--EN015 ===================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'EN015' AS 'localCode'
	,'error' AS 'status'
	,'enrollmentFlaggedNoShow' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN EnrollmentID AS eid ON eid.enrollmentID = en.enrollmentID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.[identityID] = p.currentIdentityID
WHERE en.noShow = 1


UNION ALL


--============================== 
-- 
-- Section Errors Code; SE--- 
-- 
--==============================     


--Error ================================= 
--Code  || Incomplete Staff Assignment || 
--SE001 =================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE001' AS 'localCode'
	,'error' AS 'status'
	,'incompleteStaffAssignment' AS 'type'
	,ssh.personID
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
WHERE ssh.personID IS NOT NULL
	AND (ssh.assignmentID IS NULL
		OR ssh.staffType IS NULL)     


UNION ALL


--Error ================================ 
--Code  || No Primary Staff On Course || 
--SE002 ================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE002' AS 'localCode'
	,'warning' AS 'status'
	,'noPrimaryStaffAssinged' AS 'type'
	,ssh.personID
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	LEFT JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
WHERE ssh.personID IS NULL     


UNION ALL


--Error ================================= 
--Code  || Section Staff Missing EDUID || 
--SE003 =================================  
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'staffName' AS 'searchType'
	,'SE003' AS 'localCode'
	,'error' AS 'status'
	,'sectionStaffMissingEDUID' AS 'type'
	,p.personID
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
	INNER JOIN Person AS p ON p.personID = ssh.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE p.staffStateID IS NULL     


--UNION ALL


--Error ======================================== 
--Code  || Provider Data with On Site Section || 
--SE004 ========================================  
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34 --Not Headstart
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
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE008' AS 'localCode'
	,'warning' AS 'status'
	,'sectionWithInactiveCourse' AS 'type'
	,NULL AS 'personID'
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34     


UNION ALL


--Error ====================================== 
--Code  || Section No Instructional Setting || 
--SE009 ======================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE009' AS 'localCode'
	,'incomplete' AS 'status'
	,'sectionNoInstructionalSetting' AS 'type'
	,NULL AS 'personID'
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE se.instructionalSetting IS NULL     


UNION ALL


--Error ========================================== 
--Code  || Primary Teacher not Teacher of Record|| 
--SE010 ==========================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE010' AS 'localCode'
	,'warning' AS 'status'
	,'primaryTeacherNotToR' AS 'type'
	,ssh.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
WHERE ssh.[role] IS NULL
	AND ssh.staffType = 'P'


--UNION ALL


--Error =================================== 
--Code  || CTE with Provider Information || 
--SE011 ===================================  
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	LEFT JOIN CustomCourse AS dci ON dci.courseID = co.courseID
		AND dci.attributeID = 445
	LEFT JOIN CustomCourse AS cc ON cc.courseID = co.courseID
		AND cc.attributeID = 614
WHERE co.active = 1
	AND ((dci.[value] IS NULL OR dci.[value] = 0) AND (cc.[value] >= 1))
		OR (dci.[value] = 1 AND (cc.[value] IS NULL OR cc.[value] = 0))


--Error =============================== 
--Code  || Offsite Provider Mismatch || 
--CO002 ===============================  
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
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO003' AS 'localCode'
	,'warning' AS 'status'
	,'secondaryCourseMissingGradeLevel' AS 'type'
	,NULL AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE co.[name] NOT LIKE 'Course %'
	AND co.active = 1
	AND co.courseID NOT IN (  
SELECT co.courseID   
FROM Course AS co  
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID   
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN CustomCourse AS gdlv ON gdlv.courseID = co.courseID  
		AND gdlv.attributeID = 322)     


UNION ALL


--Error ===================================== 
--Code  || Course No Instructional Setting || 
--CO004 =====================================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO004' AS 'localCode'
	,'warning' AS 'status'
	,'courseNoInstructionalSetting' AS 'type'
	,NULL AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
WHERE co.[name] NOT LIKE 'Course %'
	AND co.active = 1
	AND co.courseID NOT IN (  
		SELECT co.courseID   
		FROM Course AS co  
			INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID  
				AND cal.schoolID IN (15,16,17,18,19,20,21,22)
			INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
				AND scy.active = 1
			INNER JOIN CustomCourse AS gdlv ON gdlv.courseID = co.courseID  
				AND gdlv.attributeID = 311)   


--Error ================================= 
--Code  || CTS Course Missing Provider || 
--CO005 =================================  
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


--Error ============================= 
--Code  || Course != Course Master || 
--CO008 =============================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO008' AS 'localCode'
	,'warning' AS 'status'
	,'courseDoesNotMatchCourseMaster' AS 'type'
	,NULL AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
	INNER JOIN CourseMaster AS cm ON cm.courseMasterID = co.courseMasterID
WHERE (co.active = 1 OR cm.active = 1)
	AND (co.active != cm.active
		OR co.stateCode != cm.stateCode
		OR co.subjectType != cm.subjectType
		OR dep.[name] != cm.department
		OR co.[type] != cm.[type]
		OR co.honorsCode != cm.honorsCode
		OR co.homeroom != cm.homeroom
		OR co.attendance != cm.attendance
		OR co.[repeatable] != cm.[repeatable]
		OR co.[name] != cm.[name]
		OR co.number != cm.number
		OR co.providerSchool != cm.providerSchool
		OR co.providerSchoolName != cm.providerSchoolName
		OR co.[provider] != cm.[provider])


UNION ALL


--============================== 
-- 
-- CourseMaster Errors Code; CM--- 
-- 
--==============================     


--Error ========================================= 
--Code  || Secondary Course Missing Gradelevel || 
--CM001 =========================================  
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM001' AS 'localCode'
	,'error' AS 'status'
	,'CourseMasterMissingGradeLevel' AS 'type'
	,NULL AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE cm.[name] NOT LIKE 'Course %'
	AND cm.active = 1
	AND cm.catalogID IN (2,3)
	AND sch.schoolID = 24 --EDC
	AND cm.courseMasterID NOT IN (  
		SELECT cm.courseMasterID   
		FROM CourseMaster AS cm  
			INNER JOIN CourseMasterAttribute AS gdlv ON gdlv.courseMasterID = cm.courseMasterID  
				AND gdlv.attributeID = 322  
		WHERE cm.catalogID IN (2,3)) 


--Error ========================================
--Code  || CTS Course Master Missing Provider ||
--CM002 ========================================
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
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE cm.honorsCode = 'T'
	AND cm.department = 'CTS'
	AND (cm.providerSchool IS NULL OR cm.providerSchoolName IS NULL)


--Error =======================================
--Code  || Active Course Missing Honors Code ||
--CM003 =======================================
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM003' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingHonorsCode' AS 'type'
	,NULL AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.honorsCode IS NULL
	AND sch.schoolID = 24 --EDC


UNION ALL


--Error ======================================
--Code  || Active Course Missing Department ||
--CM004 ======================================
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM004' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingDepartment' AS 'type'
	,NULL AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.department IS NULL
	AND sch.schoolID = 24 --EDC


UNION ALL


--Error ================================
--Code  || Active Course Missing Type ||
--CM005 ================================
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM005' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingType' AS 'type'
	,NULL AS 'personID'
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.[type] IS NULL
	AND sch.schoolID = 24 --EDC

