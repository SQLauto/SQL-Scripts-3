	
select substring(
    (
	select ', ''' + name + ''' as [' + name + ']'
	from syscolumns
	where id = OBJECT_ID('scAccounts')
	and name not like '%id'
	order by colid
     for xml path('')
    )
    , 2, 200000) as csv

	
select substring(
    (
	select ', ' + name
	from syscolumns
	where id = OBJECT_ID('scAccounts')
	and name not like '%id'
	order by colid
     for xml path('')
    )
    , 2, 200000) as csv
