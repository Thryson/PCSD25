SELECT DISTINCT s.lastName + ', ' + s.firstName AS 'Name', s.gender, s.grade, csbc.[value] AS 'BirthCertificate', csmc.[value] AS 'Media Certified', t.inbus AS 'Bus Number',
CASE 
	WHEN ics1.complianceLabelID + ics3.complianceLabelID + ics4.complianceLabelID + ics5.complianceLabelID + ics9.complianceLabelID + ics13.complianceLabelID <= 6 THEN 'Complete' 
	ELSE 'Not Complete' END AS 'Immunization'
FROM student s
LEFT JOIN CustomStudent csmc ON s.personID = csmc.personID AND csmc.attributeID = '755'
LEFT JOIN CustomStudent csbc ON s.personID = csbc.personID AND csbc.attributeID = '275'
JOIN ImmComplianceStatus ics1 ON s.personID = ics1.personID AND s.endYear = ics1.endYear AND ics1.vaccineID = '1'
JOIN ImmComplianceStatus ics3 ON s.personID = ics3.personID AND s.endYear = ics3.endYear AND ics3.vaccineID = '3'
JOIN ImmComplianceStatus ics4 ON s.personID = ics4.personID AND s.endYear = ics4.endYear AND ics4.vaccineID = '4'
JOIN ImmComplianceStatus ics5 ON s.personID = ics5.personID AND s.endYear = ics5.endYear AND ics5.vaccineID = '5'
JOIN ImmComplianceStatus ics9 ON s.personID = ics9.personID AND s.endYear = ics9.endYear AND ics9.vaccineID = '9'
JOIN ImmComplianceStatus ics13 ON s.personID = ics13.personID AND s.endYear = ics13.endYear AND ics13.vaccineID = '13'
LEFT JOIN Transportation t ON s.personID = t.personID AND t.endDate IS NULL
WHERE s.schoolID = '6' AND s.endDate IS NULL AND s.endYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR, 1, GETDATE())) ELSE YEAR(GETDATE()) END
ORDER BY s.grade