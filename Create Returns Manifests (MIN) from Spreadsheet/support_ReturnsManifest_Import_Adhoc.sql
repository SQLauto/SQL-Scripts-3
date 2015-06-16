IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ReturnsManifests_Import_Adhoc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ReturnsManifests_Import_Adhoc]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_ReturnsManifests_Import_Adhoc]
	  @param1 nvarchar(20) = null
	, @param2 int = null
	, @param3 datetime = null
AS
/*
	[dbo].[support_ReturnsManifests_Import_Adhoc]
	
	depends on procedure exec support_AddManifestSequenceTemplates @consolidated=1
	
	$History:  $
*/
BEGIN
/*
	
*/

set nocount on

	--|  Import Manifests
	create table #tempManifests (
		mfstcode varchar(20)
		, mfstname varchar(50)
		, mfsttype varchar(80)
		, mfstowner varchar(50)
		, frequency int
	)

	insert into #tempManifests (mfstcode, mfstname, mfsttype, mfstowner, frequency)
	select distinct ManifestCode, ManifestName, 4, 1, 127
	from support_ReturnsManifest_Import

	-- Insert the new manifests.
	insert dbo.scManifestTemplates (
		 MTCode
		,MTName
		,MTOwner
		,ManifestTypeId
	--	,MTDescription
		,MTNotes
		,MTImported
	--	,MTCustom1
	--	,MTCustom2
	--	,MTCustom3
		,MTDeleted

	)
	select mfstcode
		, mfstname
		, tmp.mfstowner as [MTOwner]
		, tmp.mfsttype as [ManifestTypeId]
		, 'Adhoc Import ' + convert(varchar, getdate(), 1)
		, 0 as [MTImported]
		, 0 as [MTDeleted]
	from #tempManifests tmp
	left join scManifestTemplates mt on ( tmp.mfstcode = mt.MTCode )
	where MTCode is null
	order by mfsttype, mfstcode
	print 'Inserted ' + cast(@@rowcount as varchar) + ' into scManifestTemplates.'

	exec support_AddManifestSequenceTemplates @consolidated=1


	insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
	select mst.ManifestSequenceTemplateId, ap.AccountPubID, tmp.SequenceNumber
	from support_ReturnsManifest_Import tmp
	join scAccounts a
		on tmp.AccountCode = a.AcctCode
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join scManifestTemplates mt
		on tmp.ManifestCode = mt.MTCode
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	order by 1, 2, 3
	print 'Inserted ' + cast(@@rowcount as varchar) + ' into scManifestSequenceItems.'
END
GO	
