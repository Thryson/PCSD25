--
--
--
--
USE pocatello
DECLARE @eYear INT
SET @eYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR,1,GETDATE())) ELSE YEAR(GETDATE()) END;

CREATE TABLE #transTracks(
	[Rank] INT
	,ID VARCHAR(50)
	,FirstName VARCHAR(50)
	,MiddleName VARCHAR(50)
	,LastName VARCHAR(50)
	,MailingAddress VARCHAR(50)
	,MailingCity VARCHAR(50)
	,MailingState VARCHAR(50)
	,MailZipCode INT
	,ResidenceAddress VARCHAR(50)
	,ResidenceCity VARCHAR(50)
	,ResidenceState VARCHAR(50)
	,ResidenceZipCode INT
	,ParentGuardian	VARCHAR(50)
	,HomePhone VARCHAR(20)
	,FatherWorkPhone VARCHAR(50)
	,MotherWorkPhone VARCHAR(50)
	,Birthdate VARCHAR(20)
	,Grade VARCHAR(5)
	,School CHAR(5)
	,Prog VARCHAR(15)
	,EthnicCode VARCHAR(25)
	,Sex VARCHAR(15)
	,[Language] VARCHAR(25)
	,[Primary Handicap] VARCHAR(25)
	)

INSERT INTO #transTracks(
	[Rank] 
	,ID
	,FirstName
	,MiddleName
	,LastName
	,MailingAddress
	,MailingCity
	,MailingState
	,MailZipCode
	,ResidenceAddress
	,ResidenceCity
	,ResidenceState
	,ResidenceZipCode
	,ParentGuardian
	,HomePhone
	,FatherWorkPhone
	,MotherWorkPhone
	,Birthdate
	,Grade
	,School
	,Prog
	,EthnicCode
	,Sex
	,[Language]
	,[Primary Handicap]
	)
SELECT DISTINCT
	RANK()OVER(PARTITION BY	p.studentNumber
			   ORDER BY id2.personID DESC, cs.attributeID DESC)
	,p.studentNumber
	,id.firstName
	,CASE
		WHEN id.middleName IS NULL THEN ''
		ELSE SUBSTRING(id.middleName,1,1)
	 END
	,id.lastName
	,''
	,ad.city
	,ad.[state]
	,ad.zip
	,CASE
		WHEN ad.tag IS NULL AND ad.prefix IS NULL THEN ad.number+' '+ad.street
		WHEN ad.prefix IS NULL THEN ad.number+' '+ad.street+' '+ad.tag
		WHEN ad.tag IS NULL THEN ad.prefix+' '+ad.number+' '+ad.street
		WHEN ad.tag IS NOT NULL THEN ad.number+' '+ad.street+' '+ad.tag
		WHEN ad.prefix IS NOT NULL THEN ad.prefix+' '+ad.number+' '+ad.street+' '+ad.tag
		ELSE ad.number+' '+ad.street
	 END
	,ad.city
	,ad.[state]
	,ad.zip
	,id2.firstName+' '+id2.lastName
	,CASE
		WHEN h2.phone IS NOT NULL THEN h2.phone
		WHEN h2.phone IS NULL THEN con2.cellPhone 
	 END
	--ISNULL(h2.phone, con2.cellPhone)
	,''
	,''
	,CONVERT(VARCHAR(10), id.birthdate, 121)
	,enr.grade
	,sch.number
	,CASE
		WHEN cs.attributeID = 663 THEN 1
		ELSE 0
	 END
	,''
	,id.gender
	,''
	,0
FROM Person AS p
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Enrollment AS enr ON enr.personID = p.personID
		AND enr.active = 1
		AND enr.serviceType = 'P'
		AND (enr.endDate IS NULL 
				OR GETDATE() BETWEEN enr.startDate AND enr.endDate)
	INNER JOIN Calendar AS cal ON cal.calendarID = enr.calendarID
		AND cal.endYear = @eYear
	INNER JOIN CustomStudent AS cs ON cs.personID = enr.personID
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID 
		AND hm.mailing = 1
		AND hm.endDate IS NULL
		AND hm.[secondary] = 0
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND hl.endDate IS NULL
	INNER JOIN [Address] AS ad ON ad.addressID = hl.addressID
		AND ad.postOfficeBox = 0
	INNER JOIN RelatedPair AS rp ON rp.personID1 = p.personID
		AND rp.guardian = 1
		AND rp.seq = 1
	INNER JOIN Person AS p2 ON p2.personID = rp.personID2
	INNER JOIN [Identity] AS id2 ON  rp.personID2 = id2.personID
		AND id2.identityID = p2.currentIdentityID
	INNER JOIN Contact AS con ON con.personID = p.personID
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN HouseholdMember AS hm2 ON hm2.personID = id2.personID
		AND hm2.mailing = 1
		AND hm2.endDate IS NULL
		AND hm2.[secondary] = 0
	INNER JOIN Household AS h2 ON h2.householdID = hm2.householdID
	INNER JOIN Contact AS con2 ON con2.personID = id2.personID
--ORDER BY id.lastName


SELECT 
	ID
	,FirstName
	,MiddleName
	,LastName
--	,CASE
--		WHEN MailingAddress IS NULL THEN ''
--		ELSE MailingAddress
--	 END AS MailingAddress
	,MailingAddress
	,MailingCity
	,MailingState
	,MailZipCode
	,ResidenceAddress
	,ResidenceCity
	,ResidenceState
	,ResidenceZipCode
	,ParentGuardian
	,ISNULL(HomePhone, '(999)-999-9999') AS HomePhone
	,FatherWorkPhone
	,MotherWorkPhone
	,Birthdate
	,Grade
	,School
	,Prog
	,EthnicCode
	,Sex
	,[Language]
	,[Primary Handicap]
FROM #transTracks
WHERE
	[Rank] = 1
ORDER BY 
	LastName
DROP TABLE #transTracks






