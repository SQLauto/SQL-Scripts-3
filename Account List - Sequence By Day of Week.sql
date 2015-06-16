

declare @startDate datetime
declare @endDate datetime
declare @selectedDate datetime
declare @manifest nvarchar(25)

set @startDate = '1/16/2012'
set @endDate = '1/22/2012'
set @selectedDate = '1/17/2012'

set @manifest = '501'
;with cte
as (
	select @startDate as dt
		, m.MfstCode, m.ManifestDate, a.AcctCode, p.PubShortName, ms.Sequence
		, CASE datename(dw, m.ManifestDate) when 'Sunday' then ms.Sequence 
			else null end as [SEQ1]
		, CASE datename(dw, m.ManifestDate) when 'Monday' then ms.Sequence 
			else null end as [SEQ2]
		, CASE datename(dw, m.ManifestDate) when 'Tuesday' then ms.Sequence 
			else null end as [SEQ3]	
		, CASE datename(dw, m.ManifestDate) when 'Wednesday' then ms.Sequence 
			else null end as [SEQ4]
		, CASE datename(dw, m.ManifestDate) when 'Thursday' then ms.Sequence 
			else null end as [SEQ5]
		, CASE datename(dw, m.ManifestDate) when 'Friday' then ms.Sequence 
			else null end as [SEQ6]
		, CASE datename(dw, m.ManifestDate) when 'Saturday' then ms.Sequence 
			else null end as [SEQ7]				
	from scManifests m
	join scManifestSequences ms
		on m.ManifestID = ms.ManifestId
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	where m.MfstCode = @manifest
	and m.ManifestDate = @startDate
	union all
	select dt + 1
		, m.MfstCode, m.ManifestDate, a.AcctCode, p.PubShortName, ms.Sequence
		, CASE datename(dw, m.ManifestDate) when 'Sunday' then ms.Sequence 
			else null end as [SEQ1]
		, CASE datename(dw, m.ManifestDate) when 'Monday' then ms.Sequence 
			else null end as [SEQ2]
		, CASE datename(dw, m.ManifestDate) when 'Tuesday' then ms.Sequence 
			else null end as [SEQ3]	
		, CASE datename(dw, m.ManifestDate) when 'Wednesday' then ms.Sequence 
			else null end as [SEQ4]
		, CASE datename(dw, m.ManifestDate) when 'Thursday' then ms.Sequence 
			else null end as [SEQ5]
		, CASE datename(dw, m.ManifestDate) when 'Friday' then ms.Sequence 
			else null end as [SEQ6]
		, CASE datename(dw, m.ManifestDate) when 'Saturday' then ms.Sequence 
			else null end as [SEQ7]				
	from scManifests m
	join scManifestSequences ms
		on m.ManifestID = ms.ManifestId
	join scAccountsPubs ap
		on ms.AccountPubId = ap.AccountPubID
	join scAccounts a
		on ap.AccountId = a.AccountID
	join nsPublications p
		on ap.PublicationId = p.PublicationID
	join cte
		on cte.MfstCode = m.MfstCode
		and cte.AcctCode = a.AcctCode
		and cte.PubShortName = p.PubShortName
	where m.MfstCode = @manifest
	and m.ManifestDate = dt + 1
	and dt + 1 <= @endDate
)
select MfstCode, AcctCode, PubShortName
		, MAX(SEQ1) as [SEQ1]
		, MAX(SEQ2) as [SEQ2]
		, MAX(SEQ3) as [SEQ3]
		, MAX(SEQ4) as [SEQ4]
		, MAX(SEQ5) as [SEQ5]
		, MAX(SEQ6) as [SEQ6]
		, MAX(SEQ7) as [SEQ7]
into #unsorted
from cte
group by MfstCode, AcctCode, PubShortName
order by AcctCode


if DATEDIFF(d, @startDate, @selectedDate) = 0
	select *
	from #unsorted
	order by [SEQ1], PubShortName
if DATEDIFF(d, @startDate, @selectedDate) = 1
	select *
	from #unsorted
	order by [SEQ2]	
if DATEDIFF(d, @startDate, @selectedDate) = 2
	select *
	from #unsorted
	order by [SEQ3]
if DATEDIFF(d, @startDate, @selectedDate) = 3
	select *
	from #unsorted
	order by [SEQ4]
if DATEDIFF(d, @startDate, @selectedDate) = 4
	select *
	from #unsorted
	order by [SEQ5]			
if DATEDIFF(d, @startDate, @selectedDate) = 5
	select *
	from #unsorted
	order by [SEQ6]	
if DATEDIFF(d, @startDate, @selectedDate) = 6
	select *
	from #unsorted
	order by [SEQ7]	