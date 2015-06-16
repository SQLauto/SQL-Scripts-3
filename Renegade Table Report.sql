;with cteSyncTables
as (
	select case when substring( syncScriptName, len(syncScriptName) - 3, 1) = '_' then 
					substring( syncScriptName, 0, len(syncScriptName) - 3 )
					else syncScriptName end as [name]
	from (
		select replace(syncScriptName, '.tab','') as [syncScriptName]
		from syncupgradescripts
		where syncsCriptname like '%.TAB%'
	) as prelim
)
, cteDBTables as (

	select user_name(uid) + '.' + [name] as [name]
	from sysobjects
	where type = 'U'
) 
select *
from cteSyncTables s
full outer join cteDBTables t
	on s.name = t.name
where s.[name] is null