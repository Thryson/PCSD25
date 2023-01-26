USE pocatello

DECLARE @eYear int, @cDay date;  
SET @cDay = GETDATE();  
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

--SELECT hm.householdID, COUNT(*) 
--FROM Enrollment AS en
--	INNER JOIN HouseholdMember AS hm ON hm.personID = en.personID
--		AND ((hm.endDate IS NULL OR @cDay <= hm.endDate)
--			AND (hm.startDate IS NULL OR @cDay >= hm.startDate))
--WHERE en.serviceType = 'P'
--	AND ((en.endDate IS NULL OR @cDay <= en.endDate)
--		AND (en.startDate IS NULL OR @cDay >= en.startDate))
--GROUP BY householdID
--HAVING COUNT(*) > 1

SELECT hm.householdID
	,stuper.personID AS 'studentPersonID'
	,sch.schoolID
	,cal.calendarID
	--,garper.personID AS 'guardianPersonID'
	,stfper.personID AS 'staffPersonID'
	,stuid.lastName + ', ' + stuid.firstName AS 'studentName'
	,en.grade
	,sch.comments AS 'school'
	--,garid.lastName + ', ' + garid.firstName AS 'guardianName'
	,stfid.lastName + ', ' + stfid.firstName AS 'staffName'
FROM enrollment AS en
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN HouseholdMember AS hm ON hm.personID = en.personID
		AND ((hm.endDate IS NULL OR @cDay <= hm.endDate)
			AND (hm.startDate IS NULL OR @cDay >= hm.startDate))
	INNER JOIN Course AS co ON co.calendarID = cal.calendarID
		AND co.homeroom = 1
	INNER JOIN Section AS se ON se.courseID = co.courseID
	INNER JOIN Roster AS rs ON rs.sectionID = se.sectionID
		AND rs.personID = en.personID
		AND ((rs.endDate IS NULL OR @cday <= rs.endDate)
			AND (rs.startDate IS NULL OR @cDay >= rs.startDate))
	INNER JOIN SectionStaffHistory AS ssh ON ssh.sectionID = se.sectionID
		AND ssh.staffType = 'P'
		AND ssh.[role] = 'T'
		AND ((ssh.endDate IS NULL OR @cday <= ssh.endDate)
			AND (ssh.startDate IS NULL OR @cDay >= ssh.startDate))
	INNER JOIN Person AS stfper ON stfper.personID = ssh.personID
	INNER JOIN [Identity] AS stfid ON stfid.personID = stfper.personID
		AND stfid.identityID = stfper.currentIdentityID
	INNER JOIN Person AS stuper ON stuper.personID = en.personID
	INNER JOIN [Identity] AS stuid ON stuid.personID = stuper.personID
		AND stuid.identityID = stuper.currentIdentityID
	--INNER JOIN RelatedPair AS rp ON rp.personID1 = stuid.personID
	--	AND rp.guardian = 1
	--	AND ((rp.endDate IS NULL OR @cDay <= rp.endDate)
	--		AND (rp.startDate IS NULL OR @cDay >= rp.startDate))
	--INNER JOIN Person AS garper ON garper.personID = rp.personID2
	--INNER JOIN [Identity] AS garid ON garid.personID = garper.personID
		--AND garid.identityID = garper.currentIdentityID
WHERE en.serviceType = 'P'
	AND ((en.endDate IS NULL OR @cDay <= en.endDate)
		AND (en.startDate IS NULL OR @cDay >= en.startDate))
	AND hm.householdID IN 
		(SELECT hm.householdID
		FROM Enrollment AS en
			INNER JOIN HouseholdMember AS hm ON hm.personID = en.personID
				AND ((hm.endDate IS NULL OR @cDay <= hm.endDate)
					AND (hm.startDate IS NULL OR @cDay >= hm.startDate))
		WHERE en.serviceType = 'P'
			AND ((en.endDate IS NULL OR @cDay <= en.endDate)
				AND (en.startDate IS NULL OR @cDay >= en.startDate))
		GROUP BY householdID
		HAVING COUNT(*) > 1)
ORDER BY hm.householdID