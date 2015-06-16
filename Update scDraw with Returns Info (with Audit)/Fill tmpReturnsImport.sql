

insert into tmpReturnsImport (AcctCode, Pub, DrawDate, DrawAmount, RetAmount, DrawRate )
select OUTLET_NUM, PUB_CODE, CALENDAR_DT, DRAW, [RETURN], 
from tmpReturnsImport_CSV


delete from tmpReturnsImport

insert into tmpReturnsImport (AcctCode, Pub, DrawDate, DrawAmount, RetAmount, DrawRate )
select OUTLET_NUM, PUB_CODE, CALENDAR_DT, replace(DRAW,'"',''), replace([RETURN],'"',''), PUB_COST
from tmpReturnsImport_Combined

