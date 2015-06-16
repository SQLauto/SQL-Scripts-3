	
select substring(
    (
		select ',' + cast(<Column_Name, sysname, column_name> as nvarchar)
		from  <Table_Name, sysname, table_name>
		--where t.y = z
		order by <Column_Name, sysname, column_name>
     for xml path('')
    )
    , 2, 200000) as csv