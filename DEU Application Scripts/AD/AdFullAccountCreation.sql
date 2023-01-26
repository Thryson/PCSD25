USE pocatello

DECLARE @cDay DATE, @eYear INT
SET @cDay = GETDATE()
SET @eYear = CASE WHEN MONTH(@cDay) >= 8 THEN YEAR(DATEADD(YEAR, 1, @cDay)) ELSE YEAR(@cDay) END;

CREATE TABLE #ADusers(
	[rank] INT,
	username VARCHAR(50),
	built_pass VARCHAR(50),
	lastName VARCHAR(50),
	firstName VARCHAR(50),
	displayName VARCHAR(50),
	school VARCHAR(25),
	gradeFlag VARCHAR(10)
)

INSERT INTO #ADusers
SELECT DISTINCT
--	RANK() OVER(PARTITION BY ua.username ORDER BY en.endYear) as [rank],
	RANK() OVER(PARTITION BY ua.username ORDER BY en.serviceType, en.endYear) as [rank],	--- MADE A CHANGE TO ORDER BY en.serviceType IN RANKING. MADE FOR A DIFFERENCE IN 9 FOR THE RESULTING ROWS. ---
	ua.username,
    lower(SUBSTRING (firstName, 1, 1)) + LOWER(SUBSTRING (lastName, 1, 1)) +  REPLACE(CONVERT(VARCHAR(10), birthdate, 1), '/', '') AS built_pass,
	id.lastName,
	id.firstName,
	id.firstName +' '+ id.lastName AS displayName,
	sch.comments AS school,
	CASE
		WHEN en.grade IN('09','10','11','12') THEN 'hs'
		WHEN en.grade IN('06','07','08') THEN 'ms'
		WHEN en.grade IN('NG','PK','23','24','25','KG','KA','KM','KP','00','01','02','03','04','05') THEN 'es'
	END AS 'gradeFlag'
FROM Enrollment AS en
	INNER JOIN [Identity] AS id ON id.personID = en.personID
	INNER JOIN Person AS p ON p.personID = id.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN Calendar AS cal ON cal.calendarID = en.calendarID
		AND cal.endYear = @eYear --IN(@eYear, YEAR(DATEADD(YEAR,1,@cDay)))		 
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
	INNER JOIN UserAccount AS ua ON ua.personID = p.personID
WHERE 
	en.serviceType IN ('P','S')
	AND en.endDate IS NULL
		--OR @cDay <= en.endDate
ORDER BY gradeFlag

SELECT 
	username,
	built_pass,
	lastName,
	firstName,
	displayName,
	school,
	gradeFlag
FROM #ADusers
WHERE 
	[rank] = 1
GROUP BY
	username,
	built_pass,
	lastName,
	firstName,
	displayName,
	school,
	gradeFlag
HAVING 
	COUNT(*) = 1
ORDER BY
	gradeFlag,
	lastName,
	firstName
DROP TABLE
	#ADusers
