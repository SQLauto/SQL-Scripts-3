IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_JobInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_JobInfo]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_JobInfo]
	  @job_name_keyword nvarchar(50) = null
	  , @job_step_keyword nvarchar(50) = null
AS
/*
	[dbo].[support_JobInfo]
	
	$History:  $
*/
BEGIN
	

	;with cteJobs as (
		select j.job_id, j.[name] as [job_name]
		, c.[name] as [Category]
		, msdb.dbo.agent_datetime(next_run_date, next_run_time) as [next_run_datetime]
		, CONVERT(varchar, cast( substring( cast( js.next_run_date as varchar),1,4) + '/'+ substring( cast( js.next_run_date as varchar),5,2) + '/'+ substring( cast( js.next_run_date as varchar),7,2) as date), 101) as [NextRunDate]
		, SUBSTRING( right('0' + cast(next_run_time as varchar), 6),1,2)+':'+SUBSTRING(right( '0' + cast(next_run_time as varchar), 6),3,2)+':'+SUBSTRING(right( '0' + cast(next_run_time as varchar), 6),5,2) as [NextRunTime]
		, case 
			WHEN s.freq_type = 0x1 -- OneTime
				   THEN
					   'Once on '
					 + CONVERT(
								  CHAR(10)
								, CAST( CAST( s.active_start_date AS VARCHAR ) AS DATETIME )
								, 102 -- yyyy.mm.dd
							   )
			   WHEN s.freq_type = 0x4 -- Daily
				   THEN 'Daily'
			   WHEN s.freq_type = 0x8 -- weekly
				   THEN
					   CASE
						   WHEN s.freq_recurrence_factor = 1
							   THEN 'Weekly on '
						   WHEN s.freq_recurrence_factor > 1
							   THEN 'Every '
								  + CAST( s.freq_recurrence_factor AS VARCHAR )
								  + ' weeks on '
					   END
					 + LEFT(
								 CASE WHEN s.freq_interval &  1 =  1 THEN 'Sunday, '    ELSE '' END
							   + CASE WHEN s.freq_interval &  2 =  2 THEN 'Monday, '    ELSE '' END
							   + CASE WHEN s.freq_interval &  4 =  4 THEN 'Tuesday, '   ELSE '' END
							   + CASE WHEN s.freq_interval &  8 =  8 THEN 'Wednesday, ' ELSE '' END
							   + CASE WHEN s.freq_interval & 16 = 16 THEN 'Thursday, '  ELSE '' END
							   + CASE WHEN s.freq_interval & 32 = 32 THEN 'Friday, '    ELSE '' END
							   + CASE WHEN s.freq_interval & 64 = 64 THEN 'Saturday, '  ELSE '' END
							 , LEN(
										CASE WHEN s.freq_interval &  1 =  1 THEN 'Sunday, '    ELSE '' END
									  + CASE WHEN s.freq_interval &  2 =  2 THEN 'Monday, '    ELSE '' END
									  + CASE WHEN s.freq_interval &  4 =  4 THEN 'Tuesday, '   ELSE '' END
									  + CASE WHEN s.freq_interval &  8 =  8 THEN 'Wednesday, ' ELSE '' END
									  + CASE WHEN s.freq_interval & 16 = 16 THEN 'Thursday, '  ELSE '' END
									  + CASE WHEN s.freq_interval & 32 = 32 THEN 'Friday, '    ELSE '' END
									  + CASE WHEN s.freq_interval & 64 = 64 THEN 'Saturday, '  ELSE '' END
								   )  - 1  -- LEN() ignores trailing spaces
						   )
			   WHEN s.freq_type = 0x10 -- monthly
				   THEN
					   CASE
						   WHEN s.freq_recurrence_factor = 1
							   THEN 'Monthly on the '
						   WHEN s.freq_recurrence_factor > 1
							   THEN 'Every '
								  + CAST( s.freq_recurrence_factor AS VARCHAR )
								  + ' months on the '
					   END
					 + CAST( s.freq_interval AS VARCHAR )
					 + CASE
						   WHEN s.freq_interval IN ( 1, 21, 31 ) THEN 'st'
						   WHEN s.freq_interval IN ( 2, 22     ) THEN 'nd'
						   WHEN s.freq_interval IN ( 3, 23     ) THEN 'rd'
						   ELSE 'th'
					   END
			   WHEN s.freq_type = 0x20 -- monthly relative
				   THEN
					   CASE
						   WHEN s.freq_recurrence_factor = 1
							   THEN 'Monthly on the '
						   WHEN s.freq_recurrence_factor > 1
							   THEN 'Every '
								  + CAST( s.freq_recurrence_factor AS VARCHAR )
								  + ' months on the '
					   END
					 + CASE s.freq_relative_interval
						   WHEN 0x01 THEN 'first '
						   WHEN 0x02 THEN 'second '
						   WHEN 0x04 THEN 'third '
						   WHEN 0x08 THEN 'fourth '
						   WHEN 0x10 THEN 'last '
					   END
					 + CASE s.freq_interval
						   WHEN  1 THEN 'Sunday'
						   WHEN  2 THEN 'Monday'
						   WHEN  3 THEN 'Tuesday'
						   WHEN  4 THEN 'Wednesday'
						   WHEN  5 THEN 'Thursday'
						   WHEN  6 THEN 'Friday'
						   WHEN  7 THEN 'Saturday'
						   WHEN  8 THEN 'day'
						   WHEN  9 THEN 'week day'
						   WHEN 10 THEN 'weekend day'
					   END
			   WHEN s.freq_type = 0x40
				   THEN 'Automatically starts when SQLServerAgent starts.'
			   WHEN s.freq_type = 0x80
				   THEN 'Starts whenever the CPUs become idle'
			   ELSE ''
		   END
			+ CASE
			   WHEN j.enabled = 0 THEN ''
			   WHEN j.job_id IS NULL THEN ''
			   WHEN s.freq_subday_type = 0x1 OR s.freq_type = 0x1
				   THEN ' at '
					+ Case  -- Depends on time being integer to drop right-side digits
						when(s.active_start_time % 1000000)/10000 = 0 then 
								  '12'
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100)))
								+ convert(char(2),(s.active_start_time % 10000)/100) 
								+ ' AM'
						when (s.active_start_time % 1000000)/10000< 10 then
								convert(char(1),(s.active_start_time % 1000000)/10000) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ convert(char(2),(s.active_start_time % 10000)/100) 
								+ ' AM'
						when (s.active_start_time % 1000000)/10000 < 12 then
								convert(char(2),(s.active_start_time % 1000000)/10000) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ convert(char(2),(s.active_start_time % 10000)/100) 
								+ ' AM'
						when (s.active_start_time % 1000000)/10000< 22 then
								convert(char(1),((s.active_start_time % 1000000)/10000) - 12) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ convert(char(2),(s.active_start_time % 10000)/100) 
								+ ' PM'
						else	convert(char(2),((s.active_start_time % 1000000)/10000) - 12)
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ convert(char(2),(s.active_start_time % 10000)/100) 
								+ ' PM'
					end
			   WHEN s.freq_subday_type IN ( 0x2, 0x4, 0x8 )
				   THEN ' every '
					 + CAST( s.freq_subday_interval AS VARCHAR )
					 + CASE freq_subday_type
						   WHEN 0x2 THEN ' second'
						   WHEN 0x4 THEN ' minute'
						   WHEN 0x8 THEN ' hour'
					   END
					 + CASE
						   WHEN s.freq_subday_interval > 1 THEN 's'
						   ELSE '' -- Added default 3/21/08; John Arnott
					   END
			   ELSE ''
		   END
		 + CASE
			   WHEN s.enabled = 0 THEN ''
			   WHEN j.job_id IS NULL THEN ''
			   WHEN s.freq_subday_type IN ( 0x2, 0x4, 0x8 )
				   THEN ' between '
					+ Case  -- Depends on time being integer to drop right-side digits
						when(s.active_start_time % 1000000)/10000 = 0 then 
								  '12'
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100)))
								+ rtrim(convert(char(2),(s.active_start_time % 10000)/100))
								+ ' AM'
						when (s.active_start_time % 1000000)/10000< 10 then
								convert(char(1),(s.active_start_time % 1000000)/10000) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_start_time % 10000)/100))
								+ ' AM'
						when (s.active_start_time % 1000000)/10000 < 12 then
								convert(char(2),(s.active_start_time % 1000000)/10000) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_start_time % 10000)/100)) 
								+ ' AM'
						when (s.active_start_time % 1000000)/10000< 22 then
								convert(char(1),((s.active_start_time % 1000000)/10000) - 12) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_start_time % 10000)/100)) 
								+ ' PM'
						else	convert(char(2),((s.active_start_time % 1000000)/10000) - 12)
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_start_time % 10000)/100))
								+ ' PM'
					end
					 + ' and '
					+ Case  -- Depends on time being integer to drop right-side digits
						when(s.active_end_time % 1000000)/10000 = 0 then 
								'12'
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100)))
								+ rtrim(convert(char(2),(s.active_end_time % 10000)/100))
								+ ' AM'
						when (s.active_end_time % 1000000)/10000< 10 then
								convert(char(1),(s.active_end_time % 1000000)/10000) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_end_time % 10000)/100))
								+ ' AM'
						when (s.active_end_time % 1000000)/10000 < 12 then
								convert(char(2),(s.active_end_time % 1000000)/10000) 
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_end_time % 10000)/100))
								+ ' AM'
						when (s.active_end_time % 1000000)/10000< 22 then
								convert(char(1),((s.active_end_time % 1000000)/10000) - 12)
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_end_time % 10000)/100)) 
								+ ' PM'
						else	convert(char(2),((s.active_end_time % 1000000)/10000) - 12)
								+ ':'  
								+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
								+ rtrim(convert(char(2),(s.active_end_time % 10000)/100)) 
								+ ' PM'
					end
			   ELSE ''
		   END as [Schedule]
			--, s.*
			--, j.*
			
		from msdb..sysjobs j
		join msdb..syscategories c
			on j.category_id = c.category_id
		join msdb..sysjobschedules js
			on j.job_id = js.job_id
		join msdb..sysschedules s
			on js.schedule_id = s.schedule_id	
		where c.[name] like '%syncronex%'
		and j.enabled = 1
		and (
			(@job_name_keyword is not null and j.name like '%' + @job_name_keyword + '%')
			or 
			(@job_name_keyword is null and 1=1)
			)
	)
	, cteJobCommand as (
			select j.job_id
				--, js.command
				, case when step_count = 1 then command
					else 'multiple steps (' + CAST(step_count as varchar) + ') configured for this job.'
					end as [command]
			from msdb..sysjobs j
			join msdb..sysjobsteps js
				on j.job_id = js.job_id
			join (
				select job_id, COUNT(*) as [step_count]
				from msdb..sysjobsteps	
				group by job_id
				--having COUNT(*) = 1
				) prelim
				on js.job_id = prelim.job_id
			join msdb..syscategories c
				on j.category_id = c.category_id
			where c.[name] like '%syncronex%'
			and j.enabled = 1
	)
	select j.job_name
		, j.next_run_datetime, j.Schedule
		--, j.NextRunDate, j.NextRunTime
		, jc.command
	from cteJobs j
	left join cteJobCommand	jc
		on j.job_id = jc.job_id
	where DATEDIFF(d, NextRunDate, GETDATE()) = 0
	and (
			( @job_step_keyword is not null and command like '%' + @job_step_keyword + '%' )
			or
			( @job_step_keyword is null and 1=1 )
		)
	order by next_run_datetime
	
END
GO	
