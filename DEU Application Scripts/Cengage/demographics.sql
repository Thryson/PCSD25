
-- AUTHOR: Mullett, Jacob
-- EMAIL : mulletja@SD25.US
-- FILE  : demographics.sql
-- VENDOR: Cengage / NGLsync
-- NOT A REQUIRED FILE

USE pocatello



CREATE TABLE #demographics(
	userSourcedId INT,
	[status] INT,
	dateLastModified DATETIME,
	birthdate DATE,
	sex VARCHAR(20),
	americanIndianOrAlaskaNative INT,
	asian INT,
	blackOrAfricanAmerican INT,

)
SELECT *
FROM #demographics
DROP TABLE 
	#demographics