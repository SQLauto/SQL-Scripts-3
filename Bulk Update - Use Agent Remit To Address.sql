

begin tran

select COUNT(*)
from scAccounts
where UseAgentRemitToAddress = 1

select u.UserName, COUNT(*) as [Accts]
from Users u
join UsersAddresses ua
	on u.UserID = ua.UserId
--join scAddresses ad
--	on ua.AddressId = ad.AddressId	
join scAccounts a
	on u.UserID = a.AcctOwner
where a.UseAgentRemitToAddress = 0
group by u.UserName
order by u.UserName

update scAccounts
set UseAgentRemitToAddress = 1
from Users u
join UsersAddresses ua
	on u.UserID = ua.UserId
join scAccounts a
	on u.UserID = a.AcctOwner
where a.UseAgentRemitToAddress = 0


select COUNT(*)
from scAccounts
where UseAgentRemitToAddress = 1

commit tran	
	