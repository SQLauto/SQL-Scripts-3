select a.AcctCode, p.PubShortName, d.DrawDate, d.RetAmount, ra.RetAuditDate, m.MfstCode, v.DeviceCode
	, ManifestOwner
	, a.AcctOwner
	, ap.APOwner
	, ra.RetAuditUserId
	, m.ManifestID
	, m.ManifestDate
from scReturnsAudit ra
join scDraws d 
	on ra.DrawId = d.DrawID
join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
join scManifestSequences ms
	on ap.AccountPubID = ms.AccountPubId
join scmanifests m
	on m.ManifestID = ms.ManifestId
	and m.ManifestDate = d.DrawDate
join nsDevices v
	on m.DeviceId = v.deviceid	
join scAccounts a
	on a.AccountID = d.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
where RetAuditUserId = 6
order by RetAuditDate desc
