
begin tran

	use <database_name, sysinfo, co_po_env>

	declare @current_email nvarchar(50)
	declare @new_email nvarchar(50)

	set @current_email = '<current_email,sysinfo,a@b.com>'
	set @new_email = '<new_email,sysinfo,b@c.com>'

	select s.UserId, m.Email, u.UserName as [UserName (seUsers)], om.UserName as [UserName (oAutMembership)]
		, om.Provider, om.ProviderUserID
	from subscribers s
	left join seMemberships m
		on s.UserId = m.UserID
	left join seUsers u
		on s.UserId = u.userid
	left join OAuthMembership om
		on u.UserId = om.Id
	where m.Email in ( '<current_email,sysinfo,a@b.com>', '<new_email,sysinfo,b@c.com>' )


	update m
		set m.Email = '<new_email,sysinfo,b@c.com>'
	from subscribers s
	left join seMemberships m
		on s.UserId = m.UserID
	left join seUsers u
		on s.UserId = u.userid
	left join OAuthMembership om
		on u.UserId = om.Id
	where m.Email = '<current_email,sysinfo,a@b.com>'


	select s.UserId, m.Email, u.UserName as [UserName (seUsers)], om.UserName as [UserName (oAutMembership)]
		, om.Provider, om.ProviderUserID
	from subscribers s
	left join seMemberships m
		on s.UserId = m.UserID
	left join seUsers u
		on s.UserId = u.userid
	left join OAuthMembership om
		on u.UserId = om.Id
	where m.Email in ( '<current_email,sysinfo,a@b.com>', '<new_email,sysinfo,b@c.com>' )

rollback tran