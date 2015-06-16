
/*
	TABLE TO HOLD THE JOBS AND SCHEDULE TO BETTER HELP FOR SCHEDULING
	
	
*/
create table jobs
(
	job
	,job_description
	,frequency
	,hour int
	,minute int
	, avgduration int
	, avgduration_display nvarchar(10)
)