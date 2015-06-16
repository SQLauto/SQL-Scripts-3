

select m.MfstCode, a.AcctCode, p.PubShortName, seq1.Sequence as [seq1 sequence], ms.Sequence as [seq2 sequence]
from scManifests m
join scManifestSequences ms
	on m.ManifestID = ms.ManifestId
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p
	on ap.PublicationId = p.PublicationID
left join (
	select m.MfstCode, m.ManifestDate, a.AcctCode, p.PubShortName, ms.Sequence
	from scManifests m
	join scManifestSequences ms
		on m.ManifestID = ms.ManifestId
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	where m.MfstCode = '8338'
	and m.ManifestDate = '1/5/2011'
	) as seq1
	on seq1.AcctCode = a.AcctCode
	and seq1.PubShortName = p.PubShortName	
where m.MfstCode = '8338'
and m.ManifestDate = '1/7/2011'
order by seq1.Sequence 