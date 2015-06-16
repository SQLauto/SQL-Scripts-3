begin tran

--set nocount off

declare @startdate datetime
declare @enddate datetime
declare @mfstcode varchar(25)

set @mfstcode = 'a0140'
set @startdate = '11/25/2012'
set @enddate = '12/4/2012'

;with cteTemplates
as (
	select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, Frequency, ap.AccountPubId, msi.Sequence  
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubId
	where ( 
				( @mfstcode is null and mt.ManifestTemplateId > 0 )
				or
				( @mfstcode is not null and mt.MTCode = @mfstcode )
			)
)			
select m.MfstCode, m.ManifestDate, ms.ManifestSequenceId, ms.AccountPubId, ms.Sequence, cte.Sequence as [Sequence_Template]
into support_ManifestSequences_12042012
from scManifests m
join scManifestSequences ms
	on m.ManifestId = ms.ManifestId
join cteTemplates cte
	on ms.ManifestSequenceTemplateId = cte.ManifestSequenceTemplateId
	and ms.AccountPubId = cte.AccountPubId
	and m.ManifestTemplateId = cte.ManifestTemplateId
	and dbo.scGetDayFrequency( m.ManifestDate ) & cte.Frequency > 0
where m.ManifestDate between @startdate and @enddate
and (ms.Sequence = 0
	and ms.Sequence <> cte.Sequence)

update scManifestSequences
set Sequence = Sequence_Template
from scManifestSequences ms
join support_ManifestSequences_12042012 tmp
	on ms.ManifestSequenceId = tmp.ManifestSequenceId
--print @@rowcount

commit tran