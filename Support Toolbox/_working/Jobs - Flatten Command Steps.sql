
declare @command_list nvarchar(max)

select @command_list = COALESCE(@command_list+' ==> ' ,'') + command
from (
	select distinct j.job_id, js.command
	from msdb..sysjobs j
	join msdb..sysjobsteps js
		on j.job_id = js.job_id
	join msdb..syscategories c
		on j.category_id = c.category_id
	where c.[name] like '%syncronex%'
	and j.enabled = 1
	) a
	
select @command_list	
