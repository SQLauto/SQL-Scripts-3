
begin tran

declare @mfstcode nvarchar(25)
declare @mfstdate datetime
declare @newOwner nvarchar(25)
declare @newDevice nvarchar(25)

set @mfstcode = 'mfst10'
set @mfstdate = convert(varchar, getdate(), 1)

set @newOwner = 'user@syncronex.com'
set @newDevice = null

select manifestid, mfstcode, mfstname, mfstimported, mfstactive
	, m.deviceid, d.devicecode
	, m.manifestowner, u.username
from scmanifests m
left join nsdevices d
	on m.deviceid = d.deviceid
left join users u
	on m.manifestowner = u.userid
where datediff(d, manifestdate, @mfstdate) = 0
and mfstcode = @mfstcode

if exists ( select 1 from users where username = @newOwner )
begin
	update scmanifests
	set manifestowner = ( select userid from users where username = @newOwner )
	from scmanifests m
	left join nsdevices d
		on m.deviceid = d.deviceid
	left join users u
		on m.manifestowner = u.userid
	where datediff(d, manifestdate, @mfstdate) = 0
	and mfstcode = @mfstcode
end

if exists ( select 1 from nsdevices where devicecode = @newDevice )
begin
	update scmanifests
	set deviceid = ( select deviceid from nsdevices where devicecode = @newDevice )
	from scmanifests m
	left join nsdevices d
		on m.deviceid = d.deviceid
	left join users u
		on m.manifestowner = u.userid
	where datediff(d, manifestdate, @mfstdate) = 0
	and mfstcode = @mfstcode
end

select manifestid, mfstcode, mfstname, mfstimported, mfstactive
	, m.deviceid, d.devicecode
	, m.manifestowner, u.username
from scmanifests m
left join nsdevices d
	on m.deviceid = d.deviceid
left join users u
	on m.manifestowner = u.userid
where datediff(d, manifestdate, @mfstdate) = 0
and mfstcode = @mfstcode

commit tran