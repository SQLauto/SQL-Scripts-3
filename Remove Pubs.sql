--begin tran

set nocount on

declare @PubShortName varchar(5)
declare @PublicationId int


declare pub_cursor cursor
for
	select 'NSCR'
	union all select 'BDOG'
	union all select 'MKE'
	union all select 'BUYR'
	union all select 'PKRV'

open pub_cursor
fetch next from pub_cursor into @PubShortName

while @@fetch_status = 0
begin
	/*

		SELECT PUBSHORTNAME 
		FROM NSPUBLICATIONS
	*/
	select @PublicationId = publicationid from nspublications where pubshortname = @PubShortName

	print 'Removing pub from [scForecastAccountRules]...'
	delete from scForecastAccountRules
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scReturnsAudit]...'
	delete from scReturnsAudit
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scDrawAdjustmentsAudit]...'
	delete from scDrawAdjustmentsAudit
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scDrawHistory]...'
	delete from scDrawHistory
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scDrawForecasts]...'
	delete from scDrawForecasts
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scTemporaryDraws]...'
	delete from scTemporaryDraws
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scDraws]...'
	delete from scDraws
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scDeliveryReceipts]...'
	delete from scDeliveryReceipts
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scDefaultDrawHistory]...'
	delete from scDefaultDrawHistory
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scDefaultDraws]...'
	delete from scDefaultDraws
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scManifestSequenceItems]...'
	delete scManifestSequenceItems
	from scManifestSequenceItems msi
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubId
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scManifestSequences]...'
	delete scManifestSequences
	from scManifestSequences ms
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubId
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scAccountsPubs]...'
	delete from scAccountsPubs
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [scVariableDaysBack]...'
	delete from scVariableDaysBack
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print 'Removing pub from [nsPublications]...'
	delete from nsPublications
	where PublicationId = @PublicationId
	print cast(@@rowcount as varchar) + ' rows deleted'

	print '****************************************************'
	print 'Pub ''' + @PubShortName + ''' removed from database.'
	print '****************************************************'
	print ''

fetch next from pub_cursor into @PubShortName
end

close pub_cursor
deallocate pub_cursor

--rollback tran