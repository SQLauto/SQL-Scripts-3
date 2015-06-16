
begin tran

set nocount on

insert into dd_scAccountTypes (ATName, ATDescription, [System])
select distinct AcctType as [ATName], AcctType as [ATDescription], 0 as [System]
from scManifestLoad_View v
left join dd_scAccountTypes typ
	on v.AcctType = typ.ATName
where typ.AccountTypeId is null
print cast(@@rowcount as nvarchar) + ' Account Types Added'

rollback tran