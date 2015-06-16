SELECT	j.name
	--, j.job_id
	--j.originating_server_id
	--, js.step_id
	, substring( 
		js.command
		,  CHARINDEX('set @jobname', js.command)
		,  CHARINDEX('set @cfgfile', js.command) - CHARINDEX('set @jobname', js.command)
		)
	, substring( 
		js.command
		,  CHARINDEX('set @cfgfile', js.command)
		,  CHARINDEX('set @cmd', js.command) - CHARINDEX('set @cfgfile', js.command)
		)
--	, js.command
	, j.enabled 
FROM	msdb.dbo.sysjobs j
JOIN	msdb.dbo.sysjobsteps js
	ON	js.job_id = j.job_id 
WHERE j.name like '%export%'
and js.command LIKE N'%@jobname%'
and j.enabled = 1
order by 1