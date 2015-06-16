begin tran

select *
from NSSESSION..nsSessionCompanies

select *
from NSSESSION27..nsSessionCompanies

update NSSESSION27..nsSessionCompanies
set CoName = replace(CoName, ' *','')

select *
from NSSESSION27..nsSessionCompanies

--select *
--delete from NSSESSION27..nsSessionCompanies
--where CompanyID in (1, 16)

commit tran