SELECT DISTINCT s.lastName + ', ' + s.firstName AS 'Name', CONVERT(VARCHAR(30), s.birthdate, 101) AS 'Birthdate', a.number + ' ' + a.street + ', ' + a.city + ' ' +a.[state] + ' ' + a.zip AS [Address]
FROM student s
JOIN HouseholdMember hm ON s.personID = hm.personID AND hm.endDate IS NULL
JOIN Household h ON hm.householdID = h.householdID
JOIN HouseholdLocation hl ON h.householdID = hl.householdID AND hl.endDate IS NULL AND hl.[secondary] = '0'
JOIN [Address] a ON hl.addressID = a.addressID
WHERE s.schoolID = '7' AND s.endYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END AND s.endDate IS NULL