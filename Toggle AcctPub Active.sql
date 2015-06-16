begin tran

declare @acctcode varchar(100)

set @acctcode = 'ac1004'

select a.accountid, acctactive, ap.active, p.publicationid, pubshortname
from scaccounts a
join scaccountspubs ap
	on a.accountid = ap.accountid
join nspublications p
	on ap.publicationid = p.publicationid
where acctcode = @acctcode

update scaccountspubs
set active = case active
	when 0 then 1
	else 1
	end
from scaccounts a
join scaccountspubs ap
	on a.accountid = ap.accountid
join nspublications p
	on ap.publicationid = p.publicationid
where acctcode = @acctcode

select a.accountid, acctactive, ap.active, p.publicationid, pubshortname
from scaccounts a
join scaccountspubs ap
	on a.accountid = ap.accountid
join nspublications p
	on ap.publicationid = p.publicationid
where acctcode = @acctcode

commit tran