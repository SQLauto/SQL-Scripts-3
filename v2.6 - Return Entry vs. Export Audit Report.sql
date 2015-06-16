

select mfstcode, a.acctcode
	, convert(varchar, d.drawdate, 101) as [DrawDate]
	--, convert(varchar, mh.mheffectivedate, 101) as [EffectiveDate]
	, d.drawamount, r.retamount
	, convert(varchar, retentrydate, 0) as [Return Entry Date]
	, convert(varchar, mhownerlastupdate, 0) as [Saved]
	, convert(varchar, mhownersubmitted, 0) as [Submitted]
	, convert(varchar, cast('2010-12-22 12:57:00.723' as datetime), 0) as [Exported]
	, username
from scaccounts a
join scaccountdrops ad
	on a.accountid = ad.accountid
join scmanifests m
	on ad.manifestid = m.manifestid
join scdraws d
	on a.accountid = d.accountid
join screturns r
	on d.drawid = r.drawid	
join screturnsaudit	ra
	on r.drawid = ra.drawid
	and r.returnid = ra.returnid
join users u
	on ra.retaudituserid = u.userid
join scmanifesthistory mh
	on m.manifestid = mh.manifestid	
	and d.drawdate = mh.mheffectivedate
where m.mfstcode in ('8611', '8606', '8605')
and d.drawdate between '12/13/2010' and '12/19/2010'
and r.retamount > 0
and r.retentrydate > '2010-12-22 12:57:00.723'--| datetime of the last export on 12/22
order by acctcode, d.drawdate