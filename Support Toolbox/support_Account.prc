IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'support_Account' 
)
   DROP PROCEDURE dbo.support_Account
GO

CREATE PROCEDURE [dbo].[support_Account]
	@account nvarchar(20)
	, @pubshortname nvarchar(5) = null
	, @frequency int = 127
	, @manifesttype nvarchar(10) = null
AS
/*
	Returns relevant account information for a given AccountId or AcctCode
*/
	declare @accountId int
	declare @acctCode nvarchar(20)
	
	if ( isnumeric(@account) = 1 )
	begin
		select @accountId = AccountID
		from scAccounts
		where AccountID = @account
	end
	
	if @accountId is null
	begin
		select @acctCode = @account
	end
	
	select
		a.AcctCode, MTCode, MTName
		, mst.Code
		, typ.ManifestTypeDescription as [Type]
		, PubShortName 
		, mst.Frequency
		--, dbo.support_DayNames_FromFrequency(mst.Frequency) as [FrequencyList]
		, case when mst.Frequency & 1 > 0 then ' X ' else ' - ' end as [sun]
		, case when mst.Frequency & 2 > 0 then ' X ' else ' - ' end as [mon]
		, case when mst.Frequency & 4 > 0 then ' X ' else ' - ' end as [tue]
		, case when mst.Frequency & 8 > 0 then ' X ' else ' - ' end as [wed]
		, case when mst.Frequency & 16 > 0 then ' X ' else ' - ' end as [thu]
		, case when mst.Frequency & 32 > 0 then ' X ' else ' - ' end as [fri]
		, case when mst.Frequency & 64 > 0 then ' X ' else ' - ' end as [sat]
		, a.AcctActive
		, ap.Active
		, ap.AccountPubID 
		, ap.AccountId
		, ap.PublicationId
		, mt.ManifestTemplateId
		, mst.ManifestSequenceTemplateId
		, ManifestSequenceItemId
		, d.DeviceCode
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
	left join nsDevices d
		on mt.DeviceId = d.DeviceId		
	where 
		ap.AccountId = coalesce(@accountId, ap.AccountId)
		and a.AcctCode = coalesce(@acctCode, AcctCode)
		--(@accountId is not null and ap.AccountId = @accountId )
		--or AcctCode = @account
	and (
		@pubshortname is null and p.PublicationID > 0
		or
		@pubshortname is not null and PubShortName = @pubshortname
	)
	and (
		mst.Frequency & @frequency > 0
	)
	and (
		@manifesttype is null and typ.ManifestTypeId > 0
		or 
		@manifesttype is not null and typ.ManifestTypeDescription = @manifesttype
	)	
	order by AcctCode, Frequency	

GO

-- =============================================
-- Example to execute the stored procedure
-- =============================================
EXECUTE dbo.support_Account @account='00033251', @pubshortname='ajc', @frequency=126, @manifesttype=null
GO

EXECUTE dbo.support_Account @account=94
GO
