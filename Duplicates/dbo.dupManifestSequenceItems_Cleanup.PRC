if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[support_dupManifestSequenceItems_Cleanup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[support_dupManifestSequenceItems_Cleanup]
GO

create  procedure [dbo].[support_dupManifestSequenceItems_Cleanup]
as
/*=========================================================
    dbo.support_dupManifestSequenceItems_Cleanup.PRC
    
	$History:  $

==========================================================*/
begin
	set nocount on

	declare @msg nvarchar(1024)

	select @msg = 'support_dupManifestSequenceItems_Cleanup:  Procedure started...'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg


/*
	Removes Duplicate Manifest Sequence Items (Templates) 
	created by scManifestAccountMove
*/

insert into syncSystemLog ( 
	  LogMessage
	, SLTimeStamp
	, ModuleId
	, SeverityId
	, CompanyId
	, [Source]
	--, GroupId 
	)
select distinct
	 'Account/Pub ''' + a.AcctCode + '/' + p.PubShortName + ''' on Manifest/Sequence ''' + mt.MTCode + '/' + mst.Code
	  + ''' was duplicated.  (ManifestTemplates).'
		as [LogMessage]
	, getdate() as [SLTimeStamp]
	, 2 as [ModuleId]	--|2=SingleCopy
	, 1 as [SeverityId] --|1=Warning
	, 1 as [CompanyId]
	, N'' as [Source]   --|nvarchar(100)
	--, newid() as [GroupId]
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join (
		select ManifestSequenceTemplateId, AccountPubId
		from scManifestSequenceItems msi
		group by ManifestSequenceTemplateId, AccountPubId
		having count(*) > 1
	) as dups
	on mst.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
join scAccountsPubs ap
	on ap.AccountPubId = dups.AccountPubId
join scAccounts a
	on ap.AccountId = a.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
order by [LogMessage]

select msi.ManifestSequenceTemplateId, msi.AccountPubId, msi.ManifestSequenceItemId
into #dups
from scManifestSequenceItems msi
join 
	(
		select ManifestSequenceTemplateId, AccountPubId
		from scManifestSequenceItems msi
		group by ManifestSequenceTemplateId, AccountPubId
		having count(*) > 1
	) as dups
	on	msi.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	and msi.AccountPubId = dups.AccountPubId
join scManifestSequenceItems msi2
	on	msi2.ManifestSequenceTemplateId = dups.ManifestSequenceTemplateId
	and msi2.AccountPubId = dups.AccountPubId
where msi.ManifestSequenceItemId > msi2.ManifestSequenceItemId

delete scManifestSequenceItems
from scManifestSequenceItems ms
join #dups dups
	on ms.ManifestSequenceItemId = dups.ManifestSequenceItemId

set @msg = 'support_dupManifestSequenceItems_Cleanup: ' + cast(@@rowcount as varchar) + ' dulicate items removed.'
print @msg
exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg


--|  Cleanup
drop table #dups


	select @msg = 'support_dupManifestSequenceItems_Cleanup:  Procedure completed.'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg

end
GO

grant execute on [dbo].[support_dupManifestSequenceItems_Cleanup] to [nsuser]
GO
