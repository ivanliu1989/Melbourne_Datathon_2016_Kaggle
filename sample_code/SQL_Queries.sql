/*-----------------------------------------------------------------------------------------------------
 Data Science Melbourne Datathon 2016

 Some SQL Code to get you started with Micorsoft SQL Server

 Download free verision from 
 https://www.microsoft.com/en-au/server-cloud/products/sql-server-editions/sql-server-express.aspx

-------------------------------------------------------------------------------------------------------*/


CREATE DATABASE DATATHON2016

GO

USE DATATHON2016 

/*------------
drop table job_impressions_all
go
drop table job_clicks_all
go
drop table job_searches_all
go
drop table jobs_all

------------*/

GO

/*--------------------------------
loading the data
----------------------------------*/

CREATE TABLE job_impressions_all
(
	job_id	int
,	user_id	int
,	session_id	int
,	search_id	int
,	search_ranking	tinyint
,	mobile_user	tinyint
,	created_at	DATETIME
)

GO

BULK INSERT job_impressions_all
FROM 'H:\phil\DataScienceMelbourne\datathon2016\seekdata\Data\Demo\job_impressions_all.csv'
WITH
(
MAXERRORS = 0,
FIRSTROW = 2,
FIELDTERMINATOR = '\t',
ROWTERMINATOR = '\n'
)

GO

--SELECT TOP 10 * FROM job_impressions_all 


CREATE TABLE job_clicks_all
(
	job_id	int
,	user_id	int
,	session_id	int
,	search_id	int
,	created_at	DATETIME
)


GO

BULK INSERT job_clicks_all
FROM 'H:\phil\DataScienceMelbourne\datathon2016\seekdata\Data\Demo\job_clicks_all.csv'
WITH
(
MAXERRORS = 0,
FIRSTROW = 2,
FIELDTERMINATOR = '\t',
ROWTERMINATOR = '\n'
)

GO

CREATE TABLE job_searches_all
(
	user_id	int
,	search_id	int
,	raw_location	varchar(320)
,	location_id	varchar(13)
,	latitude	float
,	longitude	float
,	query	varchar(331)
,	mobile_user	tinyint
,	created_at	DATETIME
)

GO

BULK INSERT job_searches_all
FROM 'H:\phil\DataScienceMelbourne\datathon2016\seekdata\Data\Demo\job_searches_all.csv'
WITH
(
MAXERRORS = 0,
FIRSTROW = 2,
FIELDTERMINATOR = '\t',
ROWTERMINATOR = '\n'
)


GO


CREATE TABLE jobs_all
(
	job_id	int
,	title	varchar(238)
,	raw_location	varchar(255)
,	location_id	varchar(42)
,	subclasses	smallint
,	salary_type	varchar(1)
,	salary_min	int
,	salary_max	int
,	raw_job_type	varchar(217)
,	abstract	NTEXT
,	Segment	varchar(7)
,	hat	smallint
)

GO

BULK INSERT jobs_all
FROM 'H:\phil\DataScienceMelbourne\datathon2016\seekdata\Data\Demo\jobs_all.csv'
WITH
(
MAXERRORS = 0,
FIRSTROW = 2,
FIELDTERMINATOR = '\t',
ROWTERMINATOR = '\n'
)

--SELECT TOP 10 * FROM jobs_all

/* ------------------------
 COUNTS
-------------------------- */

select count(*) from jobs_all
--1,439,436

select count(*) from job_searches_all
--468,885

select count(*) from job_clicks_all 
--677,176

select count(* ) from job_impressions_all
--15,685,324









/*------------------------------------------------
Maybe useful for the Kaggle Comp
aim is to identyfiy Hotel and Tourism Category
--------------------------------------------------*/


CREATE TABLE kaggle_sample_submission
(
	job_id	int
,	hat	tinyint
)

go

BULK INSERT kaggle_sample_submission
FROM 'H:\phil\DataScienceMelbourne\datathon2016\seekdata\Data\Demo\kaggle_sample_submission.csv'
WITH
(
MAXERRORS = 0,
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)

go



SELECT TOP 10 * FROM jobs_all

-- our target group 
SELECT TOP 100 * 
FROM jobs_all
WHERE HAT = 1

-- those not hotel or tourism
SELECT TOP 100 * 
FROM jobs_all
WHERE HAT = 0

-- does salary type differentiate HAT category 
SELECT salary_type, avg(HAT * 1.0) AS PERCENT_hat, count(*) as count
FROM jobs_all
WHERE HAT <> -1
GROUP BY salary_type


/*------------------------------
salary_type	PERCENT_hat	count
NULL	0.000000	2
h	0.055549	17498
y	0.099793	1222031
----------------------------*/

SELECT avg(HAT * 1.0) AS PERCENT_hat, COUNT(*) AS COUNT 
FROM jobs_all
WHERE HAT <> -1
AND 
(TITLE like ('%CHEF%') or TITLE like ('%BARISTA%'))

/*------------
PERCENT_hat	COUNT
0.971736	33754

97% of cases where title contains 'chef' or 'barista' are in the HAT category

--------------*/


-- FIRST KAGGLE SUBMISSION
-- this is the barista benchmark
-- https://inclass.kaggle.com/c/melbourne-datathon-2016/leaderboard
SELECT JOB_ID
		,(CASE 
			WHEN (TITLE LIKE ('%CHEF%') or TITLE LIKE ('%BARISTA%')) THEN 1
			ELSE 0
		 END) AS HAT
FROM jobs_all
WHERE HAT = -1
-- you can right click on the results pane and 'save as'



/*--------------------------
an example of a join
----------------------------*/

--the difference between the 'created at' field in the impressions and clicks table
SELECT 
A.*
,B.CREATED_AT AS created_at_clicks
,DATEDIFF(SS,A.created_at,B.created_at) as time_difference_in_seconds
FROM 
job_impressions_all A INNER JOIN job_clicks_all B
ON A.job_id = B.job_id
AND A.user_id = B.user_id
AND A.session_id = B.session_id
AND A.search_id = B.search_id
order by user_id, session_id,search_id,created_at
























