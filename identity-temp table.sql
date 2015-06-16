

select ident_current=identity(int,1,1)
into #tmp
from supportManifestLoad

drop table #tmp

ALTER TABLE supportManifestLoad drop column ID int identity(1,1)


