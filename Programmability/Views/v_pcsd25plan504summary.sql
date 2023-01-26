USE pocatello

SELECT stup.personID AS 'studentPersonID'
	,cal.calendarID
	,sch.comments AS 'school'
	,cs.[value] AS 'range'
	,stuid.lastName + ', ' + stuid.firstName AS 'studentName'
	,pltp.[name] AS 'planVersion'
	,ISNULL(pl.locked, 0) AS 'planLocked'
	,pl.startDate AS 'planStartDate'
	,pl.endDate AS 'planEndDate'
	,SUM(CASE WHEN tm.[role] IS NOT NULL THEN 1 ELSE 0 END) AS 'totalActiveStaff'
	,SUM(CASE WHEN tm.[role] = 'Case Manager' THEN 1 ELSE 0 END) AS 'countTeamManager'
	,SUM(CASE WHEN tm.[role] = 'Service Provider' THEN 1 ELSE 0 END) AS 'countServicer'
	,SUM(CASE WHEN tm.[role] = 'Read-Only' THEN 1 ELSE 0 END) AS 'countTeacher'
FROM [Plan] AS pl
	INNER JOIN PlanType AS pltp ON pltp.typeID = pl.typeID
		AND pltp.abbreviation LIKE '%504%'
		AND pltp.active = 1
	INNER JOIN TeamMember AS tm ON tm.personID = pl.personID
		AND tm.module = 'plp'
		AND ((tm.endDate IS NULL OR GETDATE() <= tm.endDate)
			AND (tm.startDate IS NULL OR GETDATE() >= tm.startDate))
	INNER JOIN Enrollment AS en ON en.personID = pl.personID
		AND en.serviceType = 'P'
		AND ((en.endDate IS NULL OR GETDATE() <= en.endDate)
			AND (en.startDate IS NULL OR GETDATE() >= en.startDate))
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN CustomSchool AS cs ON cs.schoolID = sch.schoolID 
		AND cs.attributeID = 618
	INNER JOIN Person AS stup ON stup.personID = en.personID
	INNER JOIN [Identity] AS stuid ON stuid.personID = stup.personID
		AND stuid.identityID = stup.currentIdentityID
WHERE ((pl.endDate IS NULL OR GETDATE() <= pl.endDate)
		AND (pl.startDate IS NULL OR GETDATE() >= pl.startDate))
GROUP BY stup.personID
	,cal.calendarID
	,sch.comments
	,cs.[value]
	,stuid.lastName
	,stuid.firstName
	,pltp.[name]
	,pl.locked
	,pl.startDate
	,pl.endDate
	