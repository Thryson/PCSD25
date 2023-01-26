USE pocatello

--UPDATE TeamMember
--SET endDate = '2021-07-27 00:00:00'
--	,comments = 'Automatic Yearly Update PCSD25 Data Team on 08/02/2021'
--WHERE module = 'plp'
--	AND [role] = 'Case Manager'
--	AND endDate IS NULL



--SELECT *
--FROM TeamMember
--WHERE module = 'plp'
--	AND ([role] != 'Case Manager' OR [role] IS NULL)


--DELETE
--FROM TeamMember
--WHERE module = 'plp'
--	AND ([role] != 'Case Manager' OR [role] IS NULL)



--SELECT * 
--FROM TeamMember
--	INNER JOIN SEPTeamMeetingAttendance AS tma ON tma.teamID = TeamMember.teamID
--WHERE TeamMember.module = 'plp'
--	AND (TeamMember.[role] != 'Case Manager' OR TeamMember.[role] IS NULL)

--DELETE tma
--FROM SEPTeamMeetingAttendance AS tma
--	INNER JOIN TeamMember AS tm ON tm.teamID = tma.teamID
--		AND tm.module = 'plp'
--		AND (tm.[role] != 'Case Manager' OR tm.[role] IS NULL)

--SELECT tm.teamID
--	,tm2.teamID
--	,tm.personID
--	,tm2.personID
--	,tm.staffPersonID
--	,tm2.staffPersonID
--	,tm.startDate
--	,tm2.startDate
--	,tm.endDate
--	,tm2.endDate
--FROM TeamMember AS tm
--	INNER JOIN TeamMember AS tm2 ON tm2.personID = tm.personID
--		AND tm2.staffPersonID != tm.staffPersonID
--		AND tm2.module = 'counseling'
--		AND tm2.[role] = 'Counselor'
--		AND (tm2.endDate IS NULL OR GETDATE() <= tm2.endDate)
--		AND tm2.startDate > tm.startDate
--WHERE (tm.endDate IS NULL OR GETDATE() <= tm.endDate)
--	AND tm.module = 'counseling'
--	AND tm.[role] = 'Counselor'
--	AND YEAR(tm.startDate) != YEAR(GETDATE())

--This script removes duplicate counsolers from previous school years but will not touch this years assingments

--UPDATE tm
--SET tm.endDate = DATEADD(DAY, -1, tm2.startDate)
--FROM TeamMember AS tm
--	INNER JOIN TeamMember AS tm2 ON tm2.personID = tm.personID
--		AND tm2.staffPersonID != tm.staffPersonID
--		AND tm2.module = 'counseling'
--		AND tm2.[role] = 'Counselor'
--		AND (tm2.endDate IS NULL OR GETDATE() <= tm2.endDate)
--		AND tm2.startDate > tm.startDate
--WHERE (tm.endDate IS NULL OR GETDATE() <= tm.endDate)
--	AND tm.module = 'counseling'
--	AND tm.[role] = 'Counselor'
--	AND YEAR(tm.startDate) != YEAR(GETDATE())