
--|only in DNA
SELECT tmp.objectname, tmp.indexname as [DNA IndexName], ix.indexname as [NSDB IndexName], tmp.indexkeys as [DNA IndexKeys], ix.indexkeys as [NSDB IndexKeys]
FROM ADHOC..DNA_INDEXES tmp
left outer join nsdb..syncindexes ix
on tmp.objectname = ix.objectname
and tmp.indexname = ix.indexname
/*
and replace(tmp.indexdescription, ';', ',') = ix.indexdescription
and replace(tmp.indexkeys, ';', ',') = ix.indexkeys
*/
where tmp.indexname is not null
and ix.indexname is null

--|only in DEFAULT
SELECT ix.objectname, tmp.indexname as [DNA IndexName], ix.indexname as [NSDB IndexName], tmp.indexkeys as [DNA IndexKeys], ix.indexkeys as [NSDB IndexKeys]
FROM ADHOC..DNA_INDEXES tmp
right outer join nsdb..syncindexes ix
on tmp.objectname = ix.objectname
and tmp.indexname = ix.indexname
/*
and replace(tmp.indexdescription, ';', ',') = ix.indexdescription
and replace(tmp.indexkeys, ';', ',') = ix.indexkeys
*/
where ix.indexname is not null
and tmp.indexname is null

--|diferences
SELECT tmp.objectname, tmp.indexname as [DNA], ix.indexname as [NSDB], tmp.indexkeys as [DNA IndexKeys], ix.indexkeys as [NSDB IndexKeys]
FROM ADHOC..DNA_INDEXES tmp
right outer join nsdb..syncindexes ix
on tmp.objectname = ix.objectname
and tmp.indexname = ix.indexname
where replace(tmp.indexkeys, ';', ',') <> ix.indexkeys

