USE pocatello
DECLARE @eYear INT
SET @eYear = CASE WHEN MONTH(GETDATE()) >= 8 THEN YEAR(DATEADD(YEAR,1,GETDATE())) ELSE YEAR(GETDATE()) END;

CREATE TABLE #transTracks(
	ID VARCHAR(50),
	FirstName VARCHAR(50),
	MiddleName VARCHAR(50),
	LastName VARCHAR(50),
	MailingAddress VARCHAR(50),
	MailingCity VARCHAR(50),
	MailingState VARCHAR(50),
	MailZipCode INT,
	ResidenceAddress VARCHAR(50),
	ResidenceCity VARCHAR(50),
	ResidenceState VARCHAR(50),
	ResidenceZipCode INT,
	ParentGuardian	VARCHAR(50),
	HomePhone INT,
	FatherWorkPhone INT,
	MotherWorkPhone INT,
	Birthdate DATE,
	Grade VARCHAR(2),
	School VARCHAR(30),
	Prog VARCHAR(15),
	Sex VARCHAR(1),
	[Language] VARCHAR(25),
	[Primary Handicap] VARCHAR(25)
	)

INSERT INTO #transTracks(ID,
						 FirstName,
						 MiddleName,
						 LastName,
						 MailingAddress,
						 MailingCity,
						 MailingState,
						 MailZipCode,
						 ResidenceAddress,
						 ResidenceCity,
						 ResidenceState,
						 ResidenceZipCode
						 )
SELECT DISTINCT
	p.studentNumber,
	id.firstName,
	id.middleName,
	id.lastName,
	CASE 
		WHEN ad.street LIKE '%BOX%' THEN ad.number + ' ' + ad.street--FIX ADDRESSES
		WHEN ad.prefix IS NOT NULL THEN ad.prefix + ' ' + ad.number + ' ' + ad.street
		ELSE ad.number + ' ' + ad.street 
	END,
	ad.city,
	ad.[state],
	ad.zip,
	'',
	ad.city,
	ad.[state],
	ad.zip 
FROM Person AS p
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Enrollment AS enr ON enr.personID = p.personID
		AND enr.active = 1
		AND enr.serviceType = 'P'
	INNER JOIN Calendar AS cal ON cal.calendarID = enr.calendarID
		AND cal.endYear = 2021--@eYear
	INNER JOIN HouseholdMember AS hm ON hm.personID = p.personID 
		AND hm.mailing = 1
		AND hm.endDate IS NULL
	INNER JOIN Household AS h ON h.householdID = hm.householdID
	INNER JOIN HouseholdLocation AS hl ON hl.householdID = h.householdID
		AND hl.endDate IS NULL
	INNER JOIN [Address] AS ad ON ad.addressID = hl.addressID
ORDER BY id.lastName

--GUARDIAN INFORMATION
--SELECT DISTINCT

--FROM Person AS p
--	INNER JOIN [Identity] AS id ON id.personID = p.personID
--		AND id.identityID = p.currentIdentityID
--	INNER JOIN Enrollment AS enr ON enr.personID = p.personID
--		AND enr.active = 1
--		AND enr.serviceType = 'P'
--	INNER JOIN Calendar AS cal ON cal.calendarID = enr.calendarID
--		AND cal.endYear = 2021--@eYear
--	INNER JOIN 	



--SELECT *
--FROM Address
--WHERE street LIKE '%BOX%'

SELECT *
FROM #transTracks
DROP TABLE #transTracks





