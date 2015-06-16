
select sjh.job_id, max(convert(varchar, sjh.run_date, 102)) as [last_run_date]
from msdb..sysjobhistory sjh
join msdb..sysjobs sj
	on sjh.job_id = sj.job_id
join (	
	select j.job_id
	FROM  msdb.dbo.sysjobs j (NOLOCK)
	INNER JOIN msdb.dbo.sysjobschedules js (NOLOCK) ON j.job_id = js.job_id
	INNER JOIN msdb.dbo.sysschedules s (NOLOCK) ON js.schedule_id = s.schedule_id
	INNER JOIN msdb.dbo.syscategories c (NOLOCK) ON j.category_id = c.category_id
	WHERE ( 
		j.enabled = 0 
		or s.enabled = 0
	)
	and c.name not in ( 'Database Maintenance', 'Data Collector', '[Uncategorized (Local)]' )
) j
	on sj.job_id = j.job_id
group by sjh.job_id