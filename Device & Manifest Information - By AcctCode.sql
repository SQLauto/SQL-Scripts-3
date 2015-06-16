

select DrawDate, DrawAmount, RetAmount, RetExportLastAmt, RetExpDateTime
	, ra.RetAuditDate, ra.RetAuditField
	, u.UserID, u.UserName
from scdraws d
join scaccounts a
	on d.AccountID = a.AccountID
join scReturnsAudit ra
	on d.DrawID = ra.DrawId
join users u	
	on ra.RetAuditUserId = u.UserID
where a.AcctCode in ( 'g4934', 'g4944' )
order by DrawDate desc


select d.DeviceCode, m.MfstCode , m.ManifestDate, MfstUploadFinished
	, d.*
from scManifestTransfers mt
join scmanifests m
	on m.ManifestID = mt.ManifestID
join scManifestSequences ms
	on m.ManifestID = ms.ManifestId
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubID
join scAccounts a
	on ap.AccountId = a.AccountID
join nsDevices d
	on m.DeviceId = d.DeviceId	
left join nsDevicesUsers du
	on d.DeviceId = du.DeviceID

where a.AcctCode in ( 'g4934', 'g4944' )	
and MfstDate = '8/25/2011'
	