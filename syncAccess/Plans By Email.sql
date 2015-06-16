

/*
	Plans by Email
*/

--select *
--from sePlans

declare @plancode nvarchar(20)
declare @email nvarchar(512)

set @plancode = 'PRINT'
set @email = null

select m.UserID, m.Email, p.Code, sp.Active, p.Active
from seMemberships m
join SubscriberPlans sp
	on m.UserID = sp.UserId
join sePlans p
	on sp.PlanId = p.PlanID
where p.Code = @plancode
and ( 
	( @email is null and m.UserID > 0 )
	or ( @email is not null and m.Email = @email )
	)
--and sp.active = 0