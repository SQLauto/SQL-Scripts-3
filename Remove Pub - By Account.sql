declare @AcctCode varchar(20)
declare @PubName varchar(5)

set @AcctCode = ''
set @PubName = ''

set nocount on

declare @AccountId int
declare @PublicationId int
declare @AccountPubId int
select @AccountId = accountid from scaccounts where acctcode = @AcctCode
select @PublicationId = publicationid from nspublications where pubshortname = @PubName
select @AccountPubId = accountpubid from scaccountspubs where accountid = @AccountId and publicationid = @PublicationId

select distinct dd.accountid, a.acctcode, a.acctname, pubshortname
from scdefaultdraws dd
join scaccounts a
on dd.accountid = a.accountid
join nspublications p
on dd.publicationid = p.publicationid
where dd.accountid = @AccountId

print 'Removing pub from [scForecastAccountRules]...'
delete from scForecastAccountRules
where AccountID = @AccountID
and PublicationId = @PublicationId
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scReturnsAudit]...'
delete from scReturnsAudit
where AccountID = @AccountID
and PublicationId = @PublicationId
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scDrawAdjustmentsAudit]...'
delete from scDrawAdjustmentsAudit
where AccountID = @AccountID
and PublicationId = @PublicationId
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scDrawHistory]...'
delete from scDrawHistory
where AccountID = @AccountID
and publicationid = @publicationid
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scDrawForecasts]...'
delete from scDrawForecasts
where AccountID = @AccountID
and PublicationID = @PublicationID
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scTemporaryDraws]...'
delete from scTemporaryDraws
where AccountID = @AccountID
and PublicationID = @PublicationID
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scDraws]...'
delete from scDraws
where AccountID = @AccountID
and PublicationID = @PublicationID
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scDeliveryReceipts]...'
delete from scDeliveryReceipts
where AccountID = @AccountID
and PublicationID = @PublicationID
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scDefaultDrawHistory]...'
delete from scDefaultDrawHistory
where AccountID = @AccountID
and PublicationID = @PublicationID
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scDefaultDraws]...'
delete from scDefaultDraws
where AccountID = @AccountID
and PublicationID = @PublicationID
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scManifestSequenceItems]...'
delete from scManifestSequenceItems
where AccountPubId = @AccountPubId
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scManifestSequences]...'
delete from scManifestSequences
where AccountPubId = @AccountPubId
print cast(@@rowcount as varchar) + ' rows deleted'

print 'Removing pub from [scAccountsPubs]...'
delete from scAccountsPubs
where AccountPubID = @AccountPubID
print cast(@@rowcount as varchar) + ' rows deleted'

select distinct dd.accountid, a.acctcode, a.acctname, pubshortname
from scdefaultdraws dd
join scaccounts a
	on dd.accountid = a.accountid
join nspublications p
	on dd.publicationid = p.publicationid
where dd.accountid = @AccountId
