begin tran

select *
from merc_controlpanel

update merc_controlpanel
set attributevalue = 'GRamsdell@buffnews.com'
where attributename = 'DefaultSysAdminEmail'

update merc_controlpanel
set attributevalue = 'buffnews.com'
where attributename = 'EmailDomain'

update merc_controlpanel
set attributevalue = 'dispatch.buffnews.com'
where attributename = 'Dispatch Server'

select *
from merc_controlpanel

--rollback tran
commit tran