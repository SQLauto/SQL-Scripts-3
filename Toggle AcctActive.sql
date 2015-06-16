begin tran

declare @acctcode varchar(100)

set @acctcode = 'ac1004'

select acctactive, *
from scaccounts
where acctcode = @acctcode

update scaccounts
set acctactive = case acctactive
	when 1 then 0
	when 0 then 1
	end
where acctcode = @acctcode

select acctactive, *a
from scaccounts
where acctcode = @acctcode

commit tran