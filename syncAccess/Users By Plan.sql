/*
	Users by Plan

	select *
	from sePlans
*/



declare @plancode nvarchar(20)
--declare @email nvarchar(512)

set @plancode = 'COMP'
--set @email = null

	select m.UserID, m.Email, p.Code
		, ph.PhoneNumber
		, sp.Active, p.Active
	from sePlans p
	join SubscriberPlans sp
		on p.PlanID = sp.PlanId
	join seMemberships m
		on sp.UserId = m.UserID
	left join PhoneNumbers ph
		on m.UserId = ph.UserId

	where p.Code = @plancode
	--and sp.active = 0
