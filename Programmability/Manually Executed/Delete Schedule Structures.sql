--Delete Schedule Structures

		-- Parameters
		--Be sure to fill in the Parameters below
		--================================================
		Declare @Initials varchar(4)='WH'
		Declare @SupportCase varchar(20) = '597334'
		Declare @Description varchar(50)='Delete Schedule Structure'
		Declare @Calendar  int = 122
		Declare @Structure VARCHAR(255) ='Raider Academy-9th'

/*		
SELECT *
FROM SectionPlacement
where periodid IN
(select periodid 
from period 
where periodScheduleID IN
(SELECT periodScheduleID
FROM PeriodSchedule
where  structureID in
(select structureID
from ScheduleStructure
where calendarID =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)))



SELECT * 
FROM GradeLevel
where  structureID in
(select structureID
from ScheduleStructure
where calendarID =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)


SELECT *
FROM Period
where periodScheduleID IN
(SELECT periodScheduleID
FROM PeriodSchedule
where  structureID in
(select structureID
from ScheduleStructure
where calendarID =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0))


SELECT *
FROM [day]
where periodScheduleID IN
(select periodScheduleID 
FROM PeriodSchedule
where structureID in
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0))


SELECT *
FROM PeriodSchedule
where structureID in
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)

SELECT *
FROM LessonPlanPreferenceCourse
where termid IN 
(select termid 
from term 
where termscheduleid IN 
(select termscheduleid 
from TermSchedule
where structureID IN 
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)))
PRINT N'Lesson Plan Preference Records Deleted'


SELECT * 
FROM Term
where termscheduleid IN
(select termscheduleid
FROM Termschedule
where structureid IN
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0))


SELECT * 
FROM TermSchedule
where structureid IN
(select structureiD 
from schedulestructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)


--Deletes any Trials
SELECT * 
FROM trial
where structureid IN
(select structureiD 
from schedulestructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)

SELECT * 
FROM ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0

*/

/******************************************************************************************************/


DELETE
FROM SectionPlacement
where periodid IN
(select periodid 
from period 
where periodScheduleID IN
(SELECT periodScheduleID
FROM PeriodSchedule
where  structureID in
(select structureID
from ScheduleStructure
where calendarID =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)))
PRINT N'Section Placement Records Deleted'



DELETE 
FROM GradeLevel
where  structureID in
(select structureID
from ScheduleStructure
where calendarID =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)
PRINT N'Grade Level Deleted'

DELETE
FROM Period
where periodScheduleID IN
(SELECT periodScheduleID
FROM PeriodSchedule
where  structureID in
(select structureID
from ScheduleStructure
where calendarID =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0))
PRINT N'Period Records Deleted'

DELETE
FROM [day]
where periodScheduleID IN
(select periodScheduleID 
FROM PeriodSchedule
where structureID in
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0))
PRINT N'Days Deleted'

DELETE
FROM PeriodSchedule
where structureID in
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)
PRINT N'Period Schedules Deleted'


DELETE 
FROM LessonPlanPreferenceCourse
where termid IN 
(select termid 
from term 
where termscheduleid IN 
(select termscheduleid 
from TermSchedule
where structureID IN 
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)))
PRINT N'Lesson Plan Preference Records Deleted'

DELETE 
FROM Term
where termscheduleid IN
(select termscheduleid
FROM Termschedule
where structureid IN
(select structureID
from ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0))
PRINT N'Terms Deleted'

DELETE 
FROM TermSchedule
where structureid IN
(select structureiD 
from schedulestructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)
PRINT N'Term Schedules Deleted'

--Deletes any Trials
DELETE 
FROM trial
where structureid IN
(select structureiD 
from schedulestructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0)
PRINT N'Trials Deleted'

DELETE 
FROM ScheduleStructure
where calendarID  =@Calendar and CHARINDEX (',' + CAST(name AS VARCHAR(255)) + ',', ',' + @Structure + ',') > 0
PRINT N' Schedule Structure Deleted'

insert into CampusVersionHistory ([timestamp], [version], [type], [message])
				select GETDATE(), 'Sugar_'+@SupportCase+'_'+@Initials, 'Support', @Description
			