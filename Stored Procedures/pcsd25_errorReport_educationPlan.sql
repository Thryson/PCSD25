USE pocatello    

-- ============================================= 
-- Author:  <Lopez, Michael> 
-- Modder:  <Lopez, Michael> 
-- Create date: <08/02/2021> 
-- Update date: <08/02/2021> 
-- Description: <Compile all existing Plan & Team Member error reports into single stored procedure> 
-- =============================================    

DECLARE @eYear int, @cDay date;  
SET @cDay = GETDATE();  
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;      

DECLARE @errorReport TABLE  (
	searchableField VARCHAR(100)
	,searchType VARCHAR(100)   
	,searchLocation VARCHAR(100)   
	,verificationID VARCHAR(50)   
	,verificationType VARCHAR(50)
	,localCode VARCHAR(5)
	,[status] VARCHAR(10)
	,[type] VARCHAR(50)
	,calendarID INT
	,school VARCHAR(5)
	,alt INT)      
	
	

--============================== 
-- 
-- Plan Errors Code; PL--- 
-- 
--==============================     


--Error ============================ 
--Code  || Plan with Null Enddate || 
--PL001 ============================  
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>PLP>General>Documents' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'PL001' AS 'localCode'
	,'incomplete' AS 'status'
	,'planMissingEnddate' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND pl.endDate IS NULL
		AND pl.typeID = 4
WHERE en.serviceType = 'P'
	AND (en.endDate IS NULL OR @cDay <= en.endDate)

	
--Error =================================== 
--Code  || Plan unlocked or never locked || 
--PL002 ===================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>PLP>General>Documents' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'PL002' AS 'localCode'
	,'incomplete' AS 'status'
	,'planUnlocked' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND (pl.locked = 0 OR pl.locked IS NULL)
		AND pl.typeID = 4
		AND (pl.endDate IS NULL OR @cDay <= pl.endDate)
WHERE en.serviceType = 'P'
	AND (en.endDate IS NULL OR @cDay <= en.endDate)



--============================== 
-- 
-- Team Member Errors Code; TM--- 
-- 
--==============================     


--Error =============================== 
--Code  || 504 with no Case Manager || 
--TM001 ===============================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>PLP>General>Documents' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'TM001' AS 'localCode'
	,'error' AS 'status'
	,'504NoCaseManager' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND pl.typeID = 4
		AND (pl.endDate IS NULL OR @cDay <= pl.endDate)
WHERE en.serviceType = 'P'
	AND (en.endDate IS NULL OR @cDay <= en.endDate)
	AND pl.personID NOT IN (
		SELECT tm.personID 
		FROM TeamMember AS tm 
		WHERE tm.module = 'plp'
			AND tm.[role] = 'Case Manager'
			AND (tm.endDate IS NULL OR @cDay <= tm.endDate))


--Error ================================= 
--Code  || Student No Primary Couselor || 
--TM002 =================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>Counseling>General>TeamMembers' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'TM002' AS 'localCode'
	,'warning' AS 'status'
	,'studentNoCounselor' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
WHERE en.serviceType = 'P'
	AND (en.endDate IS NULL OR @cDay <= en.endDate)
	AND en.personID NOT IN (
		SELECT tm.personID 
		FROM TeamMember AS tm 
		WHERE tm.module = 'counseling'
			AND tm.[role] = 'Counselor'
			AND (tm.endDate IS NULL OR @cDay <= tm.endDate))


--Error ========================================== 
--Code  || 504 with more than one Case Manager || 
--TM003 ==========================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>PLP>General>Documents' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'TM003' AS 'localCode'
	,'error' AS 'status'
	,'504MultipleCaseManagers' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,COUNT(pl.personID) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND pl.typeID = 4
		AND (pl.endDate IS NULL OR @cDay <= pl.endDate)
	INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
		AND tm.module = 'plp'
		AND tm.[role] = 'Case Manager'
		AND (tm.endDate IS NULL OR @cDay <= tm.endDate)
WHERE en.serviceType = 'P'
	AND (en.endDate IS NULL OR @cDay <= en.endDate)
GROUP BY id.lastName
	,id.firstName
	,p.personID
	,cal.calendarID
	,sch.comments
HAVING COUNT(pl.personID) > 1


--Error ================================================== 
--Code  || Student With More Than One Primary Counselor || 
--TM004 ==================================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>PLP>General>Documents' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'TM004' AS 'localCode'
	,'warning' AS 'status'
	,'studentMultipleCounselors' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,COUNT(en.personID) AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN TeamMember AS tm ON tm.personID = en.personID
		AND tm.module = 'counseling'
		AND tm.[role] = 'Counselor'
		AND (tm.endDate IS NULL OR @cDay <= tm.endDate)
WHERE en.serviceType = 'P'
	AND (en.endDate IS NULL OR @cDay <= en.endDate)
GROUP BY id.lastName
	,id.firstName
	,p.personID
	,cal.calendarID
	,sch.comments
HAVING COUNT(en.personID) > 1


--Error ==================================== 
--Code  || 504 Case Manager not Counselor || 
--TM005 ====================================
INSERT INTO @errorReport
SELECT DISTINCT id.lastName + ', ' + id.firstName AS 'searchableField'
	,'studentName' AS 'searchType'
	,'studentInformation>PLP>General>TeamMembers' AS 'searchLocation'
	,p.personID AS 'verificationID'
	,'personID' AS 'verificationType'
	,'TM005' AS 'localCode'
	,'warning' AS 'status'
	,'504CaseManagerNotCounselor' AS 'type'
	,cal.calendarID
	,sch.comments AS 'school'
	,1 AS 'alt'
FROM Enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN Person AS p ON p.personID = en.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN [Plan] AS pl ON pl.personID = en.personID
		AND pl.typeID = 4
		AND (pl.endDate IS NULL OR @cDay <= pl.endDate)
	INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
		AND tm.module = 'plp'
		AND tm.[role] = 'Case Manager'
		AND (tm.endDate IS NULL OR @cDay <= tm.endDate)
	INNER JOIN TeamMember AS tm2 ON tm2.personID = pl.personID
		AND tm.module = 'counseling'
		AND tm.[role] != 'Counselor'
		AND (tm2.endDate IS NULL OR @cDay <= tm2.endDate)
WHERE en.serviceType = 'P'
	AND tm.staffPersonID != tm2.staffPersonID
	AND (en.endDate IS NULL OR @cDay <= en.endDate)


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
FROM @errorReport AS er
--WHERE er.localCode NOT IN ('', '')    


/*  
DROP TABLE @errorReport
*/