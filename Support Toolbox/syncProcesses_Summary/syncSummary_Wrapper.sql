
declare @startDate datetime
declare @stopDate datetime
set @startDate = '3/26/2012'
set @stopDate = '4/2/2012'


select *
from syncSummary_Import( @startDate, @stopDate )
union all
select *
from syncSummary_Forecast( @startDate, @stopDate )
union all
select *
from syncSummary_IndexMaint( @startDate, @stopDate )
union all
select *
from syncSummary_DataEntry( @startDate, @stopDate )

order by 2 desc
