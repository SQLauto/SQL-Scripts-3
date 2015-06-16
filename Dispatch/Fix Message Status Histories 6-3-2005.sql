begin tran

select msh1.sdm_messageid as [messageid], msh1.sdm_messagetargetid as [messagetargetid]--, msh2.sdm_messagetargetid
into #tmp
from demessagestatushistory msh1
--join demessagestatushistory msh2
--on msh1.sdm_messageid = msh2.sdm_messageid
where msh1.sdm_messagestatusid = 0
--and msh2.sdm_messagestatusid = 5
order by 1

select msh1.sdm_messageid, msh1.sdm_messagetargetid, msh2.sdm_messagetargetid
from demessagestatushistory msh1
join demessagestatushistory msh2
on msh1.sdm_messageid = msh2.sdm_messageid
where msh1.sdm_messagestatusid = 0
and msh2.sdm_messagestatusid = 5
order by 1

update demessagestatushistory
set demessagestatushistory.sdm_messagetargetid = tmp.messagetargetid 
from #tmp tmp
where demessagestatushistory.sdm_messagestatusid = 5
and demessagestatushistory.sdm_messageid = tmp.messageid

select msh1.sdm_messageid, msh1.sdm_messagetargetid, msh2.sdm_messagetargetid
from demessagestatushistory msh1
join demessagestatushistory msh2
on msh1.sdm_messageid = msh2.sdm_messageid
where msh1.sdm_messagestatusid = 0
and msh2.sdm_messagestatusid = 5
order by 1

commit tran