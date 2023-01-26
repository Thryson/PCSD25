USE pocatello
GO

DECLARE @activeYear INT;
SET @activeYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END;

SELECT DISTINCT p.personID, i.lastName + ', ' + i.firstName AS 'householdMemberOne', e.grade, posea.eligibility, p2.personID, i2.lastName + ', ' + i2.firstName AS 'householdMemberTwo', e2.grade, posea2.eligibility
FROM Enrollment AS e
JOIN [Identity] AS i ON i.personID = e.personID
JOIN Person AS p ON p.currentIdentityID = i.identityID AND p.personID = i.personID
JOIN v_POSEligibilityApplication AS posea ON posea.personID = p.personID AND posea.endYear = @activeYear
JOIN RelatedPair AS rp ON rp.personID1 = p.personID AND rp.endDate IS NULL
JOIN Person AS p2 ON p2.personID = rp.personID2
LEFT JOIN v_POSEligibilityApplication AS posea2 ON posea2.personID = p2.personID AND (posea2.endYear IS NULL OR posea2.endYear !< @activeYear)
JOIN [Identity] AS i2 ON i2.identityID = p2.currentIdentityID AND i2.personID = p2.personID
JOIN Enrollment AS e2 ON e2.personID = i2.personID
JOIN HouseholdMember AS hm ON hm.personID = rp.personID1 AND hm.endDate IS NULL AND hm.[secondary] = 0
JOIN HouseholdMember AS hm2 ON hm2.personID = rp.personID2 AND hm2.householdID = hm.householdID AND hm2.endDate IS NULL AND hm2.[secondary] = 0
WHERE e.endYear = @activeYear AND e2.endYear = @activeYear AND e.endDate IS NULL AND e2.endDate IS NULL AND e.active = 1 AND e2.active = 1 AND e.serviceType = 'P' AND e2.serviceType = 'P' AND posea2.eligibility IS NULL --AND (e.grade = 00 OR e2.grade = 00)
ORDER BY householdMemberOne