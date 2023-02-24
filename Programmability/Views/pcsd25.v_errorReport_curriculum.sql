USE pocatello    

-- ============================================= 
-- Author:  <Lopez, Michael>
-- Modder:  <Lopez, Michael>
-- Create date: <11/08/2019>
-- Update date: <02/24/2023>
-- Description: <Compile all existing curriculum error reports into a single view>
-- =============================================    


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
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
	INNER JOIN Person AS p ON p.personID = ssh.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE p.staffStateID IS NULL


UNION ALL


--Error ======================================== 
--Code  || Provider Data with On Site Section || 
--SE004 ========================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE004' AS 'localCode'
	,'error' AS 'status'
	,'offSiteProviderDataWithOnSiteSection' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE se.sectionID NOT IN (  
		SELECT se.sectionID  
		FROM Section AS se  
			INNER JOIN CustomSection AS cs ON cs.sectionID = se.sectionID AND cs.attributeID = 300     )
				AND (  
					se.providerIDOverride IS NOT NULL 
					OR se.providerDisplayOverride IS NOT NULL 
					OR se.providerSchoolOverride IS NOT NULL 
					OR se.providerSchoolNameOverride IS NOT NULL)  


UNION ALL


--Error ========================================== 
--Code  || CTS Primary Staff Mismatching Record || 
--SE005 ==========================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE005' AS 'localCode'
	,'warning' AS 'status'
	,'CTSSectionProviderStaffMismatch' AS 'type'
	,cal2.calendarID
	,sch2.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
	INNER JOIN Person AS p ON p.personID = ssh.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	,Calendar AS cal2
	INNER JOIN SchoolYear AS scy2 ON scy2.endYear = cal2.endYear
		AND scy2.active = 1
	INNER JOIN School AS sch2 ON sch2.schoolID = cal2.schoolID
		AND sch2.schoolID = 24 --EDC
WHERE p.staffStateID != se.providerIDOverride
	OR id.firstName + ' ' + id.lastName != se.providerDisplayOverride     


UNION ALL


--Error ====================================== 
--Code  || Missing CTS Provider Information || 
--SE006 ======================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE006' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTSSectionMissingProviderInformation' AS 'type'
	,cal2.calendarID
	,sch2.comments AS 'school'
	,cs2.[value] AS 'range'
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN (34,35) --SSHS, PVTC
	INNER JOIN CustomSchool AS cs2 ON cs2.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	,Calendar AS cal2
	INNER JOIN SchoolYear AS scy2 ON scy2.endYear = cal2.endYear
		AND scy2.active = 1
	INNER JOIN School AS sch2 ON sch2.schoolID = cal2.schoolID
		AND sch2.schoolID = 24 --EDC
WHERE se.providerIDOverride IS NULL 
	OR se.providerDisplayOverride IS NULL 


UNION ALL


--Error =================================== 
--Code  || CTS flag with Provider School || 
--SE007 ===================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE007' AS 'localCode'
	,'warning' AS 'status'
	,'CTSSectionWithProviderSchool' AS 'type'
	,cal2.calendarID
	,sch2.comments AS 'school'
	,cs2.[value] AS 'range'
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34 -- SSHS
	INNER JOIN CustomSchool AS cs2 ON cs2.schoolID = sch.schoolID
		AND cs.attributeID = 618 --618 is the "range" for the school
	,Calendar AS cal2
	INNER JOIN SchoolYear AS scy2 ON scy2.endYear = cal2.endYear
		AND scy2.active = 1
	INNER JOIN School AS sch2 ON sch2.schoolID = cal2.schoolID
		AND sch2.schoolID = 24 --EDC
WHERE se.providerSchoolNameOverride IS NOT NULL
	OR se.providerSchoolOverride IS NOT NULL


UNION ALL


--Error ================================= 
--Code  || Sections on Inactive Course || 
--SE008 =================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE008' AS 'localCode'
	,'warning' AS 'status'
	,'sectionWithInactiveCourse' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school


UNION ALL


--Error ====================================== 
--Code  || Section No Instructional Setting || 
--SE009 ======================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE009' AS 'localCode'
	,'incomplete' AS 'status'
	,'sectionNoInstructionalSetting' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
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
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
WHERE ssh.[role] IS NULL
	AND ssh.staffType = 'P'


UNION ALL


--Error =================================== 
--Code  || CTE with Provider Information || 
--SE011 ===================================  
SELECT DISTINCT co.number + '-' + CONVERT(varchar, se.number) AS 'searchableField'
	,'Course-Section' AS 'searchType'
	,'SE011' AS 'localCode'
	,'error' AS 'status'
	,'CTESectionWithProviderInformation' AS 'type'
	,cal2.calendarID
	,sch2.comments AS 'school'
	,cs2.[value] AS 'range'
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
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs2 ON cs2.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	,Calendar AS cal2
	INNER JOIN SchoolYear AS scy2 ON scy2.endYear = cal2.endYear
		AND scy2.active = 1
	INNER JOIN School AS sch2 ON sch2.schoolID = cal2.schoolID
		AND sch2.schoolID = 24 --EDC
WHERE se.providerIDOverride IS NOT NULL 
	OR se.providerDisplayOverride IS NOT NULL
	OR se.providerSchoolNameOverride IS NOT NULL
	OR se.providerSchoolOverride IS NOT NULL


UNION ALL


--Error ======================================= 
--Code  || Section Exited without Leave Code || 
--SE012 =======================================
SELECT DISTINCT per.studentNumber + '-' + co.number + '-' + trm.[name] AS 'searchableField'
	,'studentNumber-CourseNumber-Term' AS 'searchType'
	,'SE012' AS 'localCode'
	,'error' AS 'status'
	,'sectionExitedWithoutLeaveCode' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Roster AS rs
	INNER JOIN Section AS se ON se.sectionID = rs.sectionID
	INNER JOIN Trial AS tl ON tl.trialID = se.trialID
		AND tl.active = 1
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN SectionPlacement AS scp ON scp.sectionID = se.sectionID
	INNER JOIN term AS trm ON trm.termID = scp.termID
	INNER JOIN Person AS per ON per.personID = rs.personID
WHERE rs.endDate <= trm.endDate
	AND rs.exitReason IS NULL


UNION ALL


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
	,'CO001' AS 'localCode'
	,'error' AS 'status'
	,'DualCreditMismatch' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	LEFT JOIN CustomCourse AS dci ON dci.courseID = co.courseID
		AND dci.attributeID = 445
	LEFT JOIN CustomCourse AS cc ON cc.courseID = co.courseID
		AND cc.attributeID = 614
WHERE co.active = 1
	AND ((dci.[value] IS NULL OR dci.[value] = 0) AND (cc.[value] >= 1))
		OR (dci.[value] = 1 AND (cc.[value] IS NULL OR cc.[value] = 0))


UNION ALL


--Error =============================== 
--Code  || Offsite Provider Mismatch || 
--CO002 ===============================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO002' AS 'localCode'
	,'error' AS 'status'
	,'offsiteProviderMistmatch' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN (34,35) --SSHS, PVTC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN CustomCourse AS ps ON ps.courseID = co.courseID
		AND ps.attributeID = 879
	LEFT JOIN CustomCourse AS ise ON ise.courseID = co.courseID
		AND ise.attributeID = 311
WHERE ps.[value] IS NOT NULL
	AND ise.[value] != 'O'    


UNION ALL


--Error =============================== 
--Code  || Offsite Provider Mismatch || 
--CO002 ===============================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO002' AS 'localCode'
	,'error' AS 'status'
	,'offsiteProviderMistmatch' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Section AS se
	INNER JOIN Course AS co ON co.courseID = se.courseID
		AND co.active = 1
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN (34,35) --SSHS, PVTC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN CustomCourse AS ise ON ise.courseID = co.courseID
		AND ise.attributeID = 311
	LEFT JOIN CustomCourse AS ps ON ps.courseID = co.courseID
		AND ps.attributeID = 879
WHERE ps.[value] IS NULL
	AND ise.[value] = 'O'     


UNION ALL


--Error ========================================== 
--Code  || Secondary Course Missing Grade level || 
--CO003 ==========================================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO003' AS 'localCode'
	,'warning' AS 'status'
	,'secondaryCourseMissingGradeLevel' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
				AND gdlv.attributeID = 322
				)     


UNION ALL


--Error ===================================== 
--Code  || Course No Instructional Setting || 
--CO004 =====================================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO004' AS 'localCode'
	,'warning' AS 'status'
	,'courseNoInstructionalSetting' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
		AND cal.schoolID IN (15,16,17,18,19,20,21,22)
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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


UNION ALL


--Error ================================= 
--Code  || CTS Course Missing Provider || 
--CO005 =================================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO005' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTSCourseMissingProvider' AS 'type'
	,cal2.calendarID
	,sch2.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID NOT IN (34,35) --SSHS, PVTC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTS'
	,Calendar AS cal2
	INNER JOIN SchoolYear AS scy2 ON scy2.endYear = cal2.endYear
		AND scy2.active = 1
	INNER JOIN School AS sch2 ON sch2.schoolID = cal2.schoolID
		AND sch2.schoolID = 24 --EDC
WHERE co.honorsCode = 'T'
	AND co.active = 1
	AND (co.providerSchool IS NULL OR co.providerSchoolName IS NULL)


UNION ALL


--Error ============================= 
--Code  || Course Unknown Provider || 
--CO006 =============================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO006' AS 'localCode'
	,'warning' AS 'status'
	,'courseUnknownProvider' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE co.providerSchool NOT IN (0565,0607,0608,0660)
	AND co.active = 1


UNION ALL


--Error ============================== 
--Code  || CTE Course With Provider || 
--CO007 ==============================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO007' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTECourseWithProviderInformaiton' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
	INNER JOIN Department AS dep ON dep.departmentID = co.departmentID
		AND dep.[name] = 'CTE'
	,Calendar AS cal2
	INNER JOIN SchoolYear AS scy2 ON scy2.endYear = cal2.endYear
		AND scy2.active = 1
	INNER JOIN School AS sch2 ON sch2.schoolID = cal2.schoolID
		AND sch2.schoolID = 24 --EDC
WHERE co.honorsCode = 'T'
	AND co.active = 1
	AND (co.providerSchool IS NOT NULL 
		OR co.providerSchoolName IS NOT NULL
		OR co.providerDisplay IS NOT NULL
		OR co.providerID IS NOT NULL)


UNION ALL


--Error ============================= 
--Code  || Course != Course Master || 
--CO008 =============================  
SELECT co.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CO008' AS 'localCode'
	,'warning' AS 'status'
	,'courseDoesNotMatchCourseMaster' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Course AS co
	INNER JOIN Calendar AS cal ON cal.calendarID = co.calendarID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS trl ON trl.structureID = ss.structureID
		AND trl.active = 1
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID != 34
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
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
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID = 24 --EDC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE cm.[name] NOT LIKE 'Course %'
	AND cm.active = 1
	AND cm.catalogID IN (2,3)
	AND cm.courseMasterID NOT IN (  
		SELECT cm.courseMasterID   
		FROM CourseMaster AS cm  
			INNER JOIN CourseMasterAttribute AS gdlv ON gdlv.courseMasterID = cm.courseMasterID  
				AND gdlv.attributeID = 322  
		WHERE cm.catalogID IN (2,3)) 


UNION ALL


--Error ========================================
--Code  || CTS Course Master Missing Provider ||
--CM002 ========================================
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM002' AS 'localCode'
	,'incomplete' AS 'status'
	,'CTSCourseMasterMissingProvider' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,1 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID = 24 --EDC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE cm.honorsCode = 'T'
	AND cm.department = 'CTS'
	AND (cm.providerSchool IS NULL OR cm.providerSchoolName IS NULL)


UNION ALL


--Error =======================================
--Code  || Active Course Missing Honors Code ||
--CM003 =======================================
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM003' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingHonorsCode' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID = 24 --EDC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.honorsCode IS NULL


UNION ALL


--Error ======================================
--Code  || Active Course Missing Department ||
--CM004 ======================================
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM004' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingDepartment' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID = 24 --EDC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.department IS NULL


UNION ALL


--Error ================================
--Code  || Active Course Missing Type ||
--CM005 ================================
SELECT cm.number AS 'searchableField'
	,'courseNumber' AS 'searchType'
	,'CM005' AS 'localCode'
	,'incomplete' AS 'status'
	,'courseMasterMissingType' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM CourseMaster AS cm
	,Calendar AS cal
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
		AND sch.schoolID = 24 --EDC
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618 --618 is the "range" for the school
WHERE cm.active = 1
	AND cm.stateCode IS NOT NULL
	AND cm.[type] IS NULL
	

