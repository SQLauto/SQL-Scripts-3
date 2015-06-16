/*
	Remove accounts/pubs from sequences *ONLY* matching the target frequency
	
	
*/
begin tran

declare @targetFrequency int
set @targetFrequency = 62 --|  62 = MON, TUE, WED, THU, FRI


declare @bkp_name nvarchar(50)
declare @sql nvarchar(4000)

set @bkp_name = 'scManifestSequenceItems_Backup_'
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
			
exec(@sql)			

set @sql = 'select *
			from ' + @bkp_name
exec(@sql)	


select
		a.AcctCode, MTCode, MTName
		, mst.Code
		, typ.ManifestTypeDescription as [Type]
		, PubShortName 
		, mst.Frequency
		, dbo.support_DayNames_FromFrequency(mst.Frequency) as [FrequencyList]
		, case when mst.Frequency & 1 > 0 then ' X ' else ' - ' end as [sun]
		, case when mst.Frequency & 2 > 0 then ' X ' else ' - ' end as [mon]
		, case when mst.Frequency & 4 > 0 then ' X ' else ' - ' end as [tue]
		, case when mst.Frequency & 8 > 0 then ' X ' else ' - ' end as [wed]
		, case when mst.Frequency & 16 > 0 then ' X ' else ' - ' end as [thu]
		, case when mst.Frequency & 32 > 0 then ' X ' else ' - ' end as [fri]
		, case when mst.Frequency & 64 > 0 then ' X ' else ' - ' end as [sat]
		, ap.AccountPubID 
		, mst.ManifestSequenceTemplateId
		, ManifestSequenceItemId
		
	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join scAccounts a
		on ap.AccountId = a.AccountID	
	join dd_scManifestTypes typ
		on mt.ManifestTypeId = typ.ManifestTypeId	
	where p.PubShortName in ('lsun','ddbd','ldbd','ajcbd')
	and ( mst.Frequency & @targetFrequency > 0 )
	and ( mst.Frequency & (127-@targetFrequency) = 0 )

;with cteAcctPubsToRemove
as (
	select
		a.AcctCode, MTCode, MTName
		, mst.Code
		, typ.ManifestTypeDescription as [Type]
		, PubShortName 
		, mst.Frequency
		, dbo.support_DayNames_FromFrequency(mst.Frequency) as [FrequencyList]
		, case when mst.Frequency & 1 > 0 then ' X ' else ' - ' end as [sun]
		, case when mst.Frequency & 2 > 0 then ' X ' else ' - ' end as [mon]
		, case when mst.Frequency & 4 > 0 then ' X ' else ' - ' end as [tue]
		, case when mst.Frequency & 8 > 0 then ' X ' else ' - ' end as [wed]
		, case when mst.Frequency & 16 > 0 then ' X ' else ' - ' end as [thu]
		, case when mst.Frequency & 32 > 0 then ' X ' else ' - ' end as [fri]
		, case when mst.Frequency & 64 > 0 then ' X ' else ' - ' end as [sat]
		, ap.AccountPubID 
		, mst.ManifestSequenceTemplateId
		, ManifestSequenceItemId
		
	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join scAccounts a
		on ap.AccountId = a.AccountID	
	join dd_scManifestTypes typ
		on mt.ManifestTypeId = typ.ManifestTypeId	
	where p.PubShortName in ('lsun','ddbd','ldbd','ajcbd')
	and ( mst.Frequency & @targetFrequency > 0 )
	and ( mst.Frequency & (127-@targetFrequency) = 0 )
	--order by mst.Frequency
)
delete scManifestSequenceItems
from cteAcctPubsToRemove cte
join scManifestSequenceItems msi
	on cte.ManifestSequenceItemId = msi.ManifestSequenceItemId
print @@rowcount

--select msi.ManifestSequenceItemId
--	, cte.*
--from cteAcctPubsToRemove cte
--join scManifestSequenceItems msi
--	on cte.ManifestSequenceItemId = msi.ManifestSequenceItemId

commit tran