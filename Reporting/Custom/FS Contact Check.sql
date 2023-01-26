USE pocatello

SELECT x.studentName,
	x.personID,
	SUM(x.FSCheck + FSCheck2) AS 'guardianContact'
FROM ( 
	SELECT i.lastName + ', ' + i.firstName AS 'studentName',
		p.personID, 
		CASE 
			WHEN mp.phoneMask >= 128 THEN 1
			ELSE 0
		END AS 'FSCheck', 
		CASE 
			WHEN mp.textMask >= 128 THEN 1
			ELSE 0
		END AS 'FSCheck2'
	FROM Enrollment AS e
		INNER JOIN [Identity] AS i ON i.personID = e.personID
		INNER JOIN Person AS p ON p.personID = i.personID
			AND p.currentIdentityID = i.identityID
		INNER JOIN RelatedPair AS rp ON rp.personID1 = p.personID
			AND rp.guardian = 1
			AND (GETDATE() BETWEEN rp.startDate AND rp.endDate 
				OR (GETDATE() > rp.startDate AND rp.endDate IS NULL))
		INNER JOIN v_MessengerPhone AS mp ON rp.personID2 = mp.personID
	WHERE e.active = 1
		AND e.serviceType = 'P'
		AND (GETDATE() BETWEEN e.startDate AND e.endDate 
			OR (GETDATE() > e.startDate AND e.endDate IS NULL))
	) AS x
GROUP BY x.studentName,
	x.personID
HAVING SUM(x.FSCheck + FSCheck2) = 0

	


