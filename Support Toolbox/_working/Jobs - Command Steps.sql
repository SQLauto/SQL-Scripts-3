

select j.[name], js.command
from msdb..sysjobs j
join msdb..sysjobsteps js
	on j.job_id = js.job_id
join (
	select job_id
	from msdb..sysjobsteps	
	group by job_id
	having COUNT(*) = 1
	) prelim
	on js.job_id = prelim.job_id
join msdb..syscategories c
	on j.category_id = c.category_id
where c.[name] like '%syncronex%'
and j.enabled = 1
	