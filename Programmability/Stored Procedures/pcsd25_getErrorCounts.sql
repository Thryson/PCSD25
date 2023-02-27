-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/19/2022>
-- Modder:		<Lopez, Michael>
-- Update date: <02/27/2023>
-- Description:	<Compile all existing error reports, insert into temptables and calculate totals>
-- =============================================

DECLARE @censusCount int
	,@curriculumCount int
	,@educationPlanCount int;


SELECT * 
INTO #censusReport
FROM pcsd25.v_errorReport_census 

SELECT * 
INTO #curriculumReport
FROM pcsd25.v_errorReport_curriculum

SELECT *
INTO #educationPlanReport
FROM pcsd25.v_errorReport_educationPlan

SET @censusCount = (SELECT COUNT(*) FROM #censusReport)
SET @curriculumCount = (SELECT COUNT(*) FROM #curriculumReport)
SET @educationPlanCount = (SELECT COUNT(*) FROM #educationPlanReport)

INSERT INTO pcsd25.DailyErrorSummary
	(censusCount,curriculumCount,educationPlanCount,modifiedByID,modifiedDate)
VALUES (@censusCount
	,@curriculumCount
	,@educationPlanCount
	,NULL
	,GETDATE())

--DROP TABLE #censusReport
--	,#curriculumReport
--	,#educationPlanReport