select mfstcode, PubShortName, AcctActive, SUM(drawamount), COUNT(*)
from scDraws d
join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
join scManifestSequences ms
	on ap.AccountPubID = ms.AccountPubId
join scmanifests m
	on ms.ManifestId = m.ManifestID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p
	on ap.PublicationID = p.PublicationID		
where d.DrawDate = '10/17/2011'		
and m.ManifestDate = '10/17/2011'
and m.MfstCode = '504'
and p.PubShortName = 'gz'
group by mfstcode, PubShortName, AcctActive
--order by DrawDate desc