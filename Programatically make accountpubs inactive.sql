
begin tran

	set nocount on

	update support_AcctPubsToDeactivate
		set AccountId = a.AccountID
		, PublicationId = p.PublicationID
		, AccountPubId = ap.AccountPubID

	from support_AcctPubsToDeactivate tmp
	join scaccounts a
		on tmp.AcctCode = a.AcctCode
	join nsPublications p
		on tmp.PubCode = p.PubName
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
		and p.PublicationID = ap.PublicationId
		
		
	select *
	from support_AcctPubsToDeactivate	tmp
	join scManifestSequenceItems msi
		on tmp.AccountPubId = msi.AccountPubId
	where tmp.AccountPubId is not null
	
	delete msi
	from scManifestSequenceItems msi
	join support_AcctPubsToDeactivate tmp
		on msi.AccountPubId = tmp.AccountPubId
	print cast(@@rowcount as varchar) + ' records removed from scManifestSequenceItems'
	
	update scDefaultDraws
	set DrawAmount = 0
	from scDefaultDraws dd
	join support_AcctPubsToDeactivate tmp
		on dd.AccountID = tmp.AccountId
		and dd.PublicationID = tmp.PublicationId
	print 'Zeroed out ' + cast(@@rowcount as varchar) + ' default draw records'
	
	update scAccountsPubs 
	set Active = 0
		, APOwner = ( 
			select userid from Users where UserName = 'inactive@ajc.com' 
			)
	from scAccountsPubs ap
	join support_AcctPubsToDeactivate tmp
		on ap.AccountPubID = tmp.AccountPubId
	print 'Deactivated ' + cast(@@rowcount as varchar) + ' scAccountsPubs records'	
	
commit tran		