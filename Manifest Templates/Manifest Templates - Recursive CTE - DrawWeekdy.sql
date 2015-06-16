begin tran

	delete from scManifestSequenceItems 
	where ManifestSequenceItemId in (
		2383328
	)	

declare @firstday int

set @firstday = 1

set @firstday = @firstday - 1

;with cte
as (
	select @firstday as firstday
		, @firstday + 1 as [Weekday]
		, mt.MTCode
		, msi.AccountPubId
		--, mst.Frequency 
		--, power(2,@firstday) as [power], mst.Frequency & power(2,@firstday) as [and]
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where MTCode in ( '0787' )
	and AccountPubId = 41559
	and mst.Frequency & power(2,@firstday)> 0
	union all
	select firstday + 1
		, (firstday + 1) + 1 as [Weekday]
		, mt.MTCode
		, msi.AccountPubId
		--, mst.Frequency 
		--, power(2,firstday + 1), mst.Frequency & power(2,firstday + 1)				
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	join cte
		on cte.MTCode = mt.MTCode
		and cte.AccountPubId = msi.AccountPubId
	where mst.Frequency & power(2,firstday + 1) > 0
	and firstday + 1 <= 9
)
select *
from cte

rollback tran