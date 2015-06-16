
/*
select messagetargetid, syncronexusername
from demessagetarget
where  syncronexusername in (
	'gavrov@njmg.com'
	,'kfennelly@njmg.com'
	,'kmezzetti@njmg.com'
	,'jsamra@njmg.com'
	,'jelejalde@njmg.com'
	)
order by 2
*/
begin tran

select distinct sdm_district, syncronexusername
from descheduledetail sd
join demessagetarget mt
	on sd.sdm_messagetargetid = mt.messagetargetid
where sdm_district like 'sc%'
and sdm_scheduleid in ( select scheduleid from deschedule where scheduledisplayname like 'single copy%' )

update descheduledetail
set sdm_messagetargetid = 
	case sdm_district 
		when 'sc30' then 58
		when 'sc32' then 62
		when 'sc33' then 65
		when 'sc40' then 82
		when 'sc42' then 60
		when 'sc43' then 82
		else sdm_messagetargetid
	end
where sdm_scheduleid in ( select scheduleid from deschedule where scheduledisplayname like 'single copy%' )


select distinct sdm_district, syncronexusername
from descheduledetail sd
join demessagetarget mt
	on sd.sdm_messagetargetid = mt.messagetargetid
where sdm_district like 'sc%'
and sdm_scheduleid in ( select scheduleid from deschedule where scheduledisplayname like 'single copy%' )

commit tran