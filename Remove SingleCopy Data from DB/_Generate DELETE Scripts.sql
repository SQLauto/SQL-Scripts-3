/*
	This script will generate sql statements that can be used to delete SingleCopy v3.1 data
	Copy the results of Column 3 to a new query pane and execute the query
*/

--| Log informational message to Messages pane
select ObjectName, 'print ''deleting data from table [' + ObjectName + ']...''' as [SQL (Copy to New Query Pane)], DeleteOrder, 1 as [Group]
from adhoc..TablesWithCustomerData_v3_1
where ContainsCustomerData = 1
and DeleteOrder > 0

--| Generate Delete statement
union all select ObjectName
	, case ObjectName
		when 'dd_scAccountCategories' then 'delete from [' + ObjectName + '] where System <> 1'
		when 'dd_scAccountTypes' then 'delete from [' + ObjectName + '] where System <> 1'
		else 'delete from [' + ObjectName + ']'
		end
	, DeleteOrder
	, 2 as [Group]
from adhoc..TablesWithCustomerData_v3_1
where ContainsCustomerData = 1
and DeleteOrder > 0

--|
union all select ObjectName, 'print cast(@@rowcount as varchar) + '' rows deleted from [' + + ObjectName + ']...''', DeleteOrder, 3 as [Group]
from adhoc..TablesWithCustomerData_v3_1
where ContainsCustomerData = 1
and DeleteOrder > 0

union all select ObjectName, 'print ''''', DeleteOrder, 4 as [Group]
from adhoc..TablesWithCustomerData_v3_1
where ContainsCustomerData = 1
and DeleteOrder > 0
order by 3, 4
