USE pocatello    

-- ============================================= 
-- Author:  <Lopez, Michael> 
-- Modder:  <Lopez, Michael> 
-- Create date: <08/02/2021> 
-- Update date: <02/16/2023> 
-- Description: <Compile all existing Plan & Team Member error reports into single stored procedure> 
-- =============================================  


--============================== 
-- 
-- Plan Errors Code; PL--- 
-- 
--==============================     


--Error =============================================== 
--Code  || Plan with EndDate and Active Team Members || 
--PL001 ===============================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'PL001' AS 'localCode'
	,'incomplete' AS 'status'
	,'planEndedWithActiveTeamMembers' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND pl.endDate IS NOT NULL
	INNER JOIN PlanType AS plt ON plt.typeID = pl.typeID
	INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
		AND plt.module = tm.module
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND (pl.endDate < tm.endDate OR tm.endDate IS NULL)


UNION ALL

	
--Error =================================== 
--Code  || Plan unlocked or never locked || 
--PL002 ===================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'PL002' AS 'localCode'
	,'warning' AS 'status'
	,'planUnlocked' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND (pl.locked = 0 OR pl.locked IS NULL)
		AND (pl.endDate IS NULL OR GETDATE() <= pl.endDate)
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))


UNION ALL


--Error ============================= 
--Code  || Plan with no Enrollment || 
--PL003 =============================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'PL003' AS 'localCode'
	,'error' AS 'status'
	,'planOpenWithoutEnrollment' AS 'type'
	,p.personID
	,MAX(cal2.calendarID) AS calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM [Plan] AS pl
	INNER JOIN Person AS p ON p.personID = pl.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN (
			SELECT MAX(en.enrollmentID) AS enrollmentID
				,en.personID
				,MAX(en.calendarID) AS calendarID
			FROM Enrollment AS en
			WHERE en.serviceType = 'P'
			GROUP BY en.personID
				) AS x ON x.personID = pl.personID
	INNER JOIN Calendar AS cal1 ON cal1.calendarID = x.calendarID
	INNER JOIN School AS sch ON sch.schoolID = cal1.schoolID
	INNER JOIN Calendar AS cal2 ON cal2.schoolID = sch.schoolID
WHERE (pl.endDate IS NULL OR GETDATE() <= pl.endDate)
	AND pl.personID NOT IN (
		SELECT DISTINCT en.personID
		FROM Enrollment AS en
			INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
			INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
		WHERE en.serviceType = 'P'
			AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE())))
GROUP BY p.studentNumber
	,p.personID
	,sch.comments


UNION ALL


--============================== 
-- 
-- Team Member Errors Code; TM--- 
-- 
--==============================     


--Error =============================== 
--Code  || Plan with no Case Manager || 
--TM001 ===============================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'TM001' AS 'localCode'
	,'incomplete' AS 'status'
	,'planNoCaseManager' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND (pl.endDate IS NULL OR GETDATE() <= pl.endDate)
	INNER JOIN PlanType AS plt ON plt.typeID = pl.typeID
		AND (plt.abbreviation LIKE '%504%' 
			OR plt.module = 'specialed')
	LEFT JOIN TeamMember AS tm ON tm.personID = pl.personID
		AND tm.module = plt.module
		AND tm.[role] = 'Case Manager'
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND tm.staffPersonID IS NULL


UNION ALL


--Error ================================= 
--Code  || Student No Primary Couselor || 
--TM002 =================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'TM002' AS 'localCode'
	,'incomplete' AS 'status'
	,'studentNoPrimaryCounselor' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	LEFT JOIN TeamMember AS tm ON tm.personID = en.personID
		AND tm.module = 'counseling'
		AND tm.[role] = 'Counselor'
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND tm.staffPersonID IS NULL


UNION ALL


--Error ==========================================
--Code  || Plan with more than one Case Manager ||
--TM003 ==========================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'TM003' AS 'localCode'
	,'error' AS 'status'
	,'MultipleCaseManagers' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,COUNT(pl.personID) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND (pl.endDate IS NULL OR GETDATE() <= pl.endDate)
	INNER JOIN PlanType AS plt ON plt.typeID = pl.typeID
		AND (plt.abbreviation LIKE '%504%' 
			OR plt.module = 'specialed')
	INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
		AND tm.module = plt.module
		AND tm.[role] = 'Case Manager'
		AND (tm.endDate IS NULL OR GETDATE() <= tm.endDate)
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
GROUP BY p.studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
HAVING COUNT(pl.personID) > 1


UNION ALL


--Error ================================================== 
--Code  || Student With More Than One Primary Counselor || 
--TM004 ==================================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'TM004' AS 'localCode'
	,'warning' AS 'status'
	,'studentMultipleCounselors' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,COUNT(en.personID) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN TeamMember AS tm ON tm.personID = en.personID
		AND tm.module = 'counseling'
		AND tm.[role] = 'Counselor'
		AND (tm.endDate IS NULL OR GETDATE() <= tm.endDate)
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
GROUP BY p.studentNumber
	,p.personID
	,cal.calendarID
	,sch.comments
HAVING COUNT(en.personID) > 1


UNION ALL


--Error ==================================== 
--Code  || 504 Case Manager not Counselor || 
--TM005 ====================================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'TM005' AS 'localCode'
	,'warning' AS 'status'
	,'504CaseManagerNotCounselor' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND pl.typeID = 4
		AND (pl.endDate IS NULL OR GETDATE() <= pl.endDate)
	INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
		AND tm.module = 'plp'
		AND tm.[role] = 'Case Manager'
		AND (tm.endDate IS NULL OR GETDATE() <= tm.endDate)
	INNER JOIN TeamMember AS tm2 ON tm2.personID = pl.personID
		AND tm.module = 'counseling'
		AND tm.[role] != 'Counselor'
		AND (tm2.endDate IS NULL OR GETDATE() <= tm2.endDate)
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))
	AND tm.staffPersonID != tm2.staffPersonID


UNION ALL


--Error ============================ 
--Code  || Duplicate Team Members || 
--TM006 ============================
SELECT DISTINCT p.studentNumber AS 'searchableField'
	,'studentNumber' AS 'searchType'
	,'TM006' AS 'localCode'
	,'warning' AS 'status'
	,'active' + tm.module + 'TeamMemberDuplicates' AS 'type'
	,p.personID
	,cal.calendarID
	,sch.comments AS 'school'
	,0 AS 'stateReporting'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
	INNER JOIN SchoolYear AS scy ON scy.endYear = cal.endYear
		AND scy.active = 1
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN TeamMember AS tm ON tm.personID = en.personID
	INNER JOIN (SELECT tm.staffPersonID
					,tm.personID
					,tm.module
					,COUNT(*) AS 'alt'
				FROM TeamMember AS tm
				WHERE tm.startDate <= GETDATE() AND (tm.endDate IS NULL OR tm.endDate >= GETDATE())
				GROUP BY tm.staffPersonID
					,tm.personID
					,tm.module
				HAVING COUNT(*) >= 2
				) AS x ON x.staffPersonID = tm.staffPersonID
			AND x.personID = tm.personID
			AND x.module = tm.module
WHERE en.serviceType = 'P'
	AND (en.startDate <= GETDATE() AND (en.endDate IS NULL OR en.endDate >= GETDATE()))