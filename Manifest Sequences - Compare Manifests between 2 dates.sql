

	select a.AcctCode, ap.PublicationId
		, d.*
	from scManifests m
	join scManifestSequences ms
		on m.ManifestId = ms.ManifestId
	join scAccountsPubs ap
		on ms.accountPubId = ap.AccountPubId
	join scAccounts a
		on ap.AccountId = a.AccountId
	join scDraws d
		on a.AccountId = d.AccountId
		and ap.PublicationId = d.PublicationId
		and d.DrawDate = m.ManifestDate
	where m.ManifestDate = '1/26/2011'
	and m.MfstCode = 'A0308' 	
	and ms.AccountPubId not in (
		select ms.AccountPubId
		from scManifests m
		join scManifestSequences ms
			on m.ManifestId = ms.ManifestId
		where m.ManifestDate = '1/25/2011'	
		and m.MfstCode = 'A0308'
	)
	