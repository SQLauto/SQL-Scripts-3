
declare @maxPrintSortOrder int
select @maxPrintSortOrder = max(PrintSortOrder)
from nsPublications

;with ctePrintSortOrder
as (
	select PubShortName, PrintSortOrder 
		, @maxPrintSortOrder + row_number() over ( order by PubShortName ) as [NewPrintSortOrder]
	from nsPublications
	where PrintSortOrder = 0
)
update nsPublications
	set PrintSortOrder = NewPrintSortOrder
from ctePrintSortOrder cte
join nsPublications p
	on cte.PubShortName = p.PubShortName
