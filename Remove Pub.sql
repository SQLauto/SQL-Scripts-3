begin tran

set nocount on

declare @PubShortName varchar(5)
declare @PublicationId int

set @PubShortName = 'DMN'

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

print 'Removing pub from [scProductLineItemDetails]...'
delete scProductLineItemDetails 
from scProductLineItemDetails plid
join scdraws d
	on d.DrawID = plid.DrawId
where d.PublicationID = @PublicationId
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

print 'Removing pub from [nsPublications]...'
delete from nspublications
where PublicationID = @PublicationId
print cast(@@rowcount as varchar) + ' rows deleted'

commit tran