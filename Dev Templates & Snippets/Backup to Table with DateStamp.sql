declare @bkp_name nvarchar(50)
declare @sql nvarchar(4000)

set @bkp_name = 'tmpBackup_scManifestSequenceItems_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)

set @sql = 'select *
			into ' + @bkp_name + '
			from scManifestSequenceItems'
--exec(@sql)			
print @sql

--set @sql = 'select *
--			from ' + @bkp_name
--exec(@sql)			

--GO

--declare @bkp_name nvarchar(50)
--declare @sql nvarchar(4000)

set @bkp_name = 'tmpBackup_scManifestSequenceItems_'
+ right('00' + cast(datepart(mm, getdate()) as varchar),2)
+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
+ '_'
+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)
set @sql = 'select *
			into ' + @bkp_name + '
			from scManifestSequenceItems'
print @sql
--exec(@sql)			

--set @sql = 'select *
--			from ' + @bkp_name
--exec(@sql)			
