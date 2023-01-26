USE pocatello


CREATE TABLE #stem(
	[rank] int,
	eduid int,
	fname VARCHAR(50),
	lname VARCHAR(50),
	school VARCHAR(50),
	grade VARCHAR(10),
	reportComment VARCHAR(50)
)

INSERT INTO #stem
SELECT 
	RANK() OVER(PARTITION BY p.stateID ORDER BY sch.[name] DESC)
	,p.stateID AS EDUID
	,id.firstName
	,id.lastName
	,sch.[name]
	,enr.grade
	,rc.[name]
FROM Enrollment AS enr
	INNER JOIN ReportCommentPerson AS rcp ON rcp.personID = enr.personID
		AND commentID = 5
	INNER JOIN ReportComment AS rc ON rc.commentID = rcp.commentID
	INNER JOIN Calendar AS cal ON enr.calendarID = cal.calendarID
	INNER JOIN Person AS p ON p.personID = enr.personID
	INNER JOIN [Identity] AS id ON id.personID = p.personID
		AND id.identityID = p.currentIdentityID
	INNER JOIN School AS sch ON sch.schoolID = cal.schoolID
WHERE 
	enr.grade = 12

SELECT 
	eduid
	,fname
	,lname
	,school
	,grade
	,reportComment
FROM #stem
WHERE
	[rank] = 1
ORDER BY
	lname

DROP TABLE #stem