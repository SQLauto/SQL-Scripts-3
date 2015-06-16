begin tran 
set nocount on

declare @agency int
declare @username nvarchar(100)

set @agency = 5
set @username = 'sgwin@ajc.com'

--|confirm the address
select a.AgencyId, a.AgencyCode, a.AgencyName
	, aa.AddressId
	, adr.*
from scAgencies a
join scAgenciesAddresses aa
	on a.AgencyId = aa.AgencyId
join scAddresses adr
	on aa.AddressId = adr.AddressId
where a.AgencyId = @agency

select UserName, aa.AgencyId, COUNT(*)
from (
	select *
	from scaccounts	a
	join Users u
		on a.AcctOwner = u.UserID
	where u.UserName = @username
	) a
join scAccountsAgencies aa
		on aa.AccountId = a.AccountID
group by UserName, aa.AgencyId


update scAccountsAgencies	
set AgencyId = @agency
from (
	select *
	from scaccounts	a
	join Users u
		on a.AcctOwner = u.UserID
	where u.UserName = @username
	) a
join scAccountsAgencies aa
		on aa.AccountId = a.AccountID
where AgencyId <> @agency
print 'Updated AgencyId for ' + cast(@@rowcount as varchar) + ' accounts'

insert into scAccountsAgencies
select a.AccountID, @agency
from (
	select *
	from scaccounts	a
	join Users u
		on a.AcctOwner = u.UserID
	where u.UserName = @username
	) a
left join scAccountsAgencies aa
		on aa.AccountId = a.AccountID
where aa.AgencyId is null
print 'Inserted AgencyId for ' + cast(@@rowcount as varchar) + ' accounts'


select UserName, aa.AgencyId, COUNT(*)
from (
	select *
	from scaccounts	a
	join Users u
		on a.AcctOwner = u.UserID
	where u.UserName = @username
	) a
join scAccountsAgencies aa
		on aa.AccountId = a.AccountID
group by UserName, aa.AgencyId

rollback tran