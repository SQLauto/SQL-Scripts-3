begin tran


--|delete all non-city manifestsequence items
	
	--exec scManifestSequenceItemList_SELECT @ManifestSequenceTemplateId=11390,@OwnerId=0
	
	delete msi
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where mt.MTCode not like '83%'
	


	select MTCode, mt.ManifestTypeId, mst.Code, mst.Frequency, COUNT(msi.ManifestSequenceItemId)
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where mst.Frequency <> 127  --|Weekly sequences should have correct sequences regardless of what day we pulled them from
		and mt.MTCode not like '83%'
	group by MTCode, mt.ManifestTypeId, mst.Code, mst.Frequency
	order by 1, 4
	
	--exec scManifestSequenceItemList_SELECT @ManifestSequenceTemplateId=11390,@OwnerId=0

--|pull forward all non-city sequences from finalized manifests
	--|  Templates
	;with cteTemplates as (
		select mt.ManifestTemplateId, mt.MTCode, mt.ManifestTypeId
			, mst.ManifestSequenceTemplateId, mst.Frequency
			, msi.AccountPubId, msi.Sequence, msi.ManifestSequenceItemId
		from scManifestTemplates mt
		join scManifestSequenceTemplates mst
			on mt.ManifestTemplateId = mst.ManifestTemplateId
		join scManifestSequenceItems msi
			on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
		where mt.MTCode not like '83%'
	)	
	--| Source sequences for last week
	,  cteSource as (
		select m.ManifestTemplateId, m.MfstCode, m.ManifestTypeId
			, m.ManifestDate
			, mst.ManifestSequenceTemplateId
			, mst.Frequency
			, dbo.scGetDayFrequency(m.ManifestDate) as [FrequencyFromManifestDate]
			, ms.AccountPubId, ms.Sequence
		from scManifests m
		join scManifestSequences ms
			on m.ManifestID = ms.ManifestId
		--join scManifestTemplates mt
		--	on m.ManifestTemplateId = mt.ManifestTemplateId	
		join scManifestSequenceTemplates mst
			on ms.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
		where m.ManifestDate between '2/16/2015' and '2/22/2015'
		and m.MfstCode not like '83%'
	)
	insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
	select distinct src.ManifestSequenceTemplateId, src.AccountPubId, src.Sequence
	from cteSource src
	left join cteTemplates tem
		on src.ManifestTemplateId = tem.ManifestTemplateId
		and src.ManifestSequenceTemplateId = tem.ManifestSequenceTemplateId
		and src.Frequency & tem.Frequency > 0
		and src.AccountPubId = tem.AccountPubId
	where tem.ManifestSequenceItemId is null

	--exec scManifestSequenceItemList_SELECT @ManifestSequenceTemplateId=11390,@OwnerId=0
	
	

	select MTCode, mt.ManifestTypeId, mst.Code, mst.Frequency, COUNT(msi.ManifestSequenceItemId)
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where mst.Frequency <> 127  --|Weekly sequences should have correct sequences regardless of what day we pulled them from
		and mt.MTCode not like '83%'
	group by MTCode, mt.ManifestTypeId, mst.Code, mst.Frequency
	order by 1

commit tran