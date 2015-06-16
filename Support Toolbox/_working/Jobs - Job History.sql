
;with cteJobHistory as (
select j.job_id, j.[name] as [JobName]
	, msdb.dbo.agent_datetime(run_date, run_time) as [RunDateTime]
	, jh.run_duration
	, stuff( stuff( replace( str(run_duration,6,0),' ','0'),3,0,':'),6,0,':') as [run_duration_hhmmss]
	, (run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 ) as [run_duration_seconds]
	--, cast( substring( cast( jh.run_date as varchar),1,4) + '/'+ substring( cast( jh.run_date as varchar),5,2) + '/'+ substring( cast( jh.run_date as varchar),7,2) as datetime) as [run_date]
	, jh.step_id, jh.step_name
from msdb..sysjobs j
join msdb..sysjobhistory jh
	on j.job_id = jh.job_id
join msdb..syscategories c
	on j.category_id = c.category_id
where c.[name] like '%syncronex%'
and j.enabled = 1
and jh.step_id > 0
and jh.run_duration > 1
--and msdb.dbo.agent_datetime(run_date, run_time) > DATEADD(d, -7, getdate())
--and datediff(d, msdb.dbo.agent_datetime(run_date, run_time) , GETDATE()) = 0
--and datediff(d, cast( substring( cast( jh.run_date as varchar),1,4) + '/'+ substring( cast( jh.run_date as varchar),5,2) + '/'+ substring( cast( jh.run_date as varchar),7,2) as datetime), GETDATE()) < 7
)
select *
from cteJobHistory jh
--join msdb..sysjobsteps js
--	on jh.job_id = js.job_id	
where DATEDIFF(d, RunDateTime, getdate()) between 0 and 30
