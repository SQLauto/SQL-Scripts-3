
begin tran

select ad1.*
from scaccountdrops ad1
join (
	
	select ad.*
	from scaccountdrops ad
	join (
		select ad.manifestid, ad.accountid
		from scmanifests m
		join users u
			on m.mfstowner = u.username
		join scaccountdrops ad
			on m.manifestid = ad.manifestid
		where username = 'stcloudtimes@startribune.com'
		group by ad.manifestid, ad.accountid
		having count(*) > 1
		) dups
	on ad.manifestid = dups.manifestid
	and ad.accountid = dups.accountid
 ) ad2
on ad1.accountid = ad2.accountid
and ad1.manifestid = ad2.manifestid
where ad1.dropid > ad2.dropid

delete scaccountdrops
from scaccountdrops ad1
join (
	
	select ad.*
	from scaccountdrops ad
	join (
		select ad.manifestid, ad.accountid
		from scmanifests m
		join users u
			on m.mfstowner = u.username
		join scaccountdrops ad
			on m.manifestid = ad.manifestid
		where username = 'stcloudtimes@startribune.com'
		group by ad.manifestid, ad.accountid
		having count(*) > 1
		) dups
	on ad.manifestid = dups.manifestid
	and ad.accountid = dups.accountid
 ) ad2
on ad1.accountid = ad2.accountid
and ad1.manifestid = ad2.manifestid
where ad1.dropid > ad2.dropid


select ad1.*
from scaccountdrops ad1
join (
	
	select ad.*
	from scaccountdrops ad
	join (
		select ad.manifestid, ad.accountid
		from scmanifests m
		join users u
			on m.mfstowner = u.username
		join scaccountdrops ad
			on m.manifestid = ad.manifestid
		where username = 'stcloudtimes@startribune.com'
		group by ad.manifestid, ad.accountid
		having count(*) > 1
		) dups
	on ad.manifestid = dups.manifestid
	and ad.accountid = dups.accountid
 ) ad2
on ad1.accountid = ad2.accountid
and ad1.manifestid = ad2.manifestid

commit tran