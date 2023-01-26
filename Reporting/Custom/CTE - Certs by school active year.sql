USE pocatello

DECLARE @eYear int, @cDay date;
SET @cDay = GETDATE();
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;


SELECT id.lastName + ', ' + id.firstName AS 'studentName',
	p.personID,
	ppc.certificationName,
	ppc.certificationDate,
	ppc.attempted,
	ppc.passed,
	sch.comments AS 'primarySchool'
FROM ProgramParticipationCertification AS ppc
	INNER JOIN ProgramParticipation AS pp ON pp.participationID = ppc.participationID
	INNER JOIN Person AS p ON p.personID = pp.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Enrollment AS en ON en.personID = p.personID
		AND en.endYear = @eYear
		AND en.serviceType = 'P'
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear
		AND ppc.certificationDate BETWEEN cal.startDate AND cal.endDate
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
ORDER BY sch.comments,
	ppc.certificationName