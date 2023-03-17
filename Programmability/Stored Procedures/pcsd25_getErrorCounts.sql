-- =============================================
-- Author:		<Lopez, Michael>
-- Create date: <07/19/2022>
-- Modder:		<Mullett, Jacob>
-- Update date: <03/17/2023>
-- Description:	<Compile all existing error reports, insert into temptables and calculate totals>
-- =============================================

DECLARE @censusCount int
	,@curriculumCount int
	,@educationPlanCount int;

SET @censusCount = (SELECT COUNT(*) FROM pcsd25.v_errorReport_census)
SET @curriculumCount = (SELECT COUNT(*) FROM pcsd25.v_errorReport_curriculum)
SET @educationPlanCount = (SELECT COUNT(*) FROM pcsd25.v_errorReport_educationPlan)

INSERT INTO pcsd25.DailyErrorSummary
	(censusCount,curriculumCount,educationPlanCount,modifiedByID,modifiedDate)
VALUES (@censusCount
	,@curriculumCount
	,@educationPlanCount
	,NULL
	,GETDATE())