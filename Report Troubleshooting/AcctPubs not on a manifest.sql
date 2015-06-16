/*
	report troubleshooting
*/
;with cteDraw
as (
	select ap.AccountPubID, ap.AccountId, ap.PublicationId, d.DrawAmount
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	join scAccounts a
		on d.AccountID = a.AccountID
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
		and p.PublicationID = ap.PublicationId	
	join Users u
		on a.AcctOwner = u.UserID
	where UserName not in ('admin@singlecopy.compy', 'nie@ajc.com' )
	and PubShortName = 'spw'
	and DrawDate = '8/15/2012'
),
cteManifest
as (
	select ms.AccountPubId, m.MfstCode
	from scmanifests m
	join scManifestSequences ms
		on m.ManifestId = ms.ManifestId
	where m.ManifestDate = '8/15/2012'
	and m.ManifestTypeId = 1
	)

select d.AccountPubID, m.AccountPubId
from cteDraw d
left join cteManifest m
	on d.AccountPubId = m.AccountPubId 
where m.AccountPubId is null