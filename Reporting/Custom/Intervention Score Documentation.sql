USE pocatello
GO

DECLARE @eYear INT;
SET @eYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END;


SELECT p.stateID,
	p.studentNumber,
	i.lastName + ', ' + i.firstName AS 'studentName',
	e.grade,
	sch.comments AS 'School',
	s.teacherDisplay
FROM Section AS s
	INNER JOIN Course AS c ON c.courseID = s.courseID AND c.departmentID IN (412)
	INNER JOIN Calendar AS cal ON cal.calendarID = c.calendarID AND cal.endYear = @eYear
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN ScheduleStructure AS ss ON ss.calendarID = cal.calendarID
	INNER JOIN Trial AS tl ON tl.structureID = ss.structureID AND tl.trialID = s.trialID AND tl.active = 1
	INNER JOIN SectionPlacement AS sp ON sp.sectionID = s.sectionID AND sp.trialID = sp.trialID
	INNER JOIN Term AS te ON te.termID = sp.termID 
	INNER JOIN Roster AS r ON r.sectionID = s.sectionID AND r.endDate IS NULL
	INNER JOIN Person AS p ON p.personID = r.personID
	INNER JOIN [Identity] AS i ON i.identityID = p.currentIdentityID AND i.personID = p.personID
	INNER JOIN Enrollment AS e ON e.personID = i.personID AND e.endDate IS NULL AND e.active = 1 AND e.endYear = @eYear
