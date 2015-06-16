--|Use this script to remove manifests that don't have any active drops

begin tran

delete from scaccountdrops
where accountid not in (
	select accountid
	from scaccounts
	where acctactive = 1
	)

delete from scdrophistory
where manifestid not in (
	select manifestid
	from scaccountdrops ad
	join scaccounts a
	on ad.accountid = a.accountid
	where a.acctactive = 1
	group by manifestid
	)

delete from scdrops
where manifestid not in (
	select manifestid
	from scaccountdrops ad
	join scaccounts a
	on ad.accountid = a.accountid
	where a.acctactive = 1
	group by manifestid
	)

delete from scmanifestuploaddata
where manifestid not in (
	select manifestid
	from scaccountdrops ad
	join scaccounts a
	on ad.accountid = a.accountid
	where a.acctactive = 1
	group by manifestid
	)


delete from scmanifesthistory
where manifestid not in (
	select manifestid
	from scaccountdrops ad
	join scaccounts a
	on ad.accountid = a.accountid
	where a.acctactive = 1
	group by manifestid
	)

delete from scmanifests
where manifestid not in (
	select manifestid
	from scaccountdrops ad
	join scaccounts a
	on ad.accountid = a.accountid
	where a.acctactive = 1
	group by manifestid
	)


select *
from scmanifests
where manifestid not in (
	select manifestid
	from scaccountdrops ad
	join scaccounts a
	on ad.accountid = a.accountid
	where a.acctactive = 1
	group by manifestid
	)

--rollback tran
commit tran