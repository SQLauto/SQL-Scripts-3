--|  Tables with AccountPubId column
select obj.[name], 'print ''Removing pub from [' + obj.[name] + ']...''', 1 as [order]
from sysobjects obj
join syscolumns col
	on col.id = obj.id 
where col.name in ('AccountPubId')
and obj.[type] = 'U'
union 
select obj.[name], 'delete from ' + obj.[name]/*+ ' where ' + col.name + ' = @' + col.name*/, 2 as [order]
from sysobjects obj
join syscolumns col
	on col.id = obj.id 
where col.name in ('AccountPubId')
and obj.[type] = 'U'
union
select obj.[name], 'where ' + col.name + ' = @' + col.name, 3 as [order]
from sysobjects obj
join syscolumns col
	on col.id = obj.id 
where col.name in ('AccountPubId')
and obj.[type] = 'U'
union
select obj.[name], '', 4 as [order]
from sysobjects obj
join syscolumns col
	on col.id = obj.id 
where col.name in ('AccountPubId')
and obj.[type] = 'U'

--|  Tables with Account and Publication columns
union
select obj.[name], 'print ''Removing pub from [' + obj.[name] + ']...''', 1 as [order]
from sysobjects obj
join syscolumns col1
	on col1.id = obj.id 
join syscolumns col2
	on col2.id = obj.id
where col1.name in ('AccountId')
and col2.name in ('PublicationId')
and obj.[type] = 'U'
union 
select obj.[name], 'delete from ' + obj.[name], 2 as [order]
from sysobjects obj
join syscolumns col1
	on col1.id = obj.id 
join syscolumns col2
	on col2.id = obj.id
where col1.name in ('AccountId')
and col2.name in ('PublicationId')
and obj.[type] = 'U'
union
select obj.[name], 'where ' + col1.name + ' = @' + col1.name + ' and ' + col2.name + ' = @' + col2.name, 3 as [order]
from sysobjects obj
join syscolumns col1
	on col1.id = obj.id 
join syscolumns col2
	on col2.id = obj.id
where col1.name in ('AccountId')
and col2.name in ('PublicationId')
and obj.[type] = 'U'
union
select obj.[name], 'and ' + col2.name + ' = @' + col2.name, 4 as [order]
from sysobjects obj
join syscolumns col1
	on col1.id = obj.id 
join syscolumns col2
	on col2.id = obj.id
where col1.name in ('AccountId')
and col2.name in ('PublicationId')
and obj.[type] = 'U'
union
select obj.[name], '', 5 as [order]
from sysobjects obj
join syscolumns col1
	on col1.id = obj.id 
join syscolumns col2
	on col2.id = obj.id
where col1.name in ('AccountId')
and col2.name in ('PublicationId')
and obj.[type] = 'U'

order by 1, 3
