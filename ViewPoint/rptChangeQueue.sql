use sdmconfig

select cqh.changequeueheaderid, cqd.attributename, cqd.oldvalue, cqd.newvalue, cqk.attributename + ' = ' + cqk.attributevalue as [Key], *
from changequeueheader cqh
inner join changequeueentity cqe
on cqh.changequeueheaderid = cqe.changequeueheaderid
inner join changequeueentitydetail cqd
on cqe.changequeueentityid = cqd.changequeueentityid
inner join changequeueentitykey cqk
on cqe.changequeueentityid = cqk.changequeueentityid
where statusid in (20603, 20607)

select cqh.archivechangequeueheaderid, cqd.attributename, cqd.oldvalue, cqd.newvalue, cqk.attributename + ' = ' + cqk.attributevalue as [Key], [action], statusid
from archivechangequeueheader cqh
inner join archivechangequeueentity cqe
on cqh.archivechangequeueheaderid = cqe.archivechangequeueheaderid
inner join archivechangequeueentitydetail cqd
on cqe.archivechangequeueentityid = cqd.archivechangequeueentityid
inner join archivechangequeueentitykey cqk
on cqe.archivechangequeueentityid = cqk.archivechangequeueentityid
where cqk.attributename = 'SDM_CustName' 
and cqk.attributevalue like 'Hawaii Department of Education%'

--|Action
-----------------
--|Create = 20600
--|update = 20601

--|Status
-----------------
--|Requested = 20603
--|Pending = 20607
--|Complete = 20604