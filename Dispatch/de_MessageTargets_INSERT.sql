begin tran

insert into demessagetarget (messagetargetdisplayname, syncronexusername)
select username, username
from sdmconfig..users
where username not in
	(
	select syncronexusername
	from demessagetarget
	)

select *
from demessagetarget

commit tran