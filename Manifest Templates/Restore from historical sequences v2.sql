begin tran


	declare @restore table ( manifestTemplateId int )

	insert into @restore ( manifestTemplateId )
	select mt.ManifestTemplateId
	from scManifestTemplates mt
	where mtcode in (
		  'SFHAWKER'
		, 'SGW01'
		, 'SGW02'
		, 'SGW04'
		, 'SGW06'
		, 'STOPACCTS'
		, 'ZGWINACTIVE'
		, 'ZINACTIVE'
		, 'S329EM6TRIP1'
		, 'T315EM6TRIP1'
		, 'W297EM6TRIP1'
		, 'WW36EM6TRIP1'
		, 'X045EM6TRIP1'
		, 'Y040EM6TRIP1'
		, 'Z060EM6TRIP1'
	)

	delete msi
	from @restore tmp
	join scManifestSequenceTemplates mst
		on tmp.manifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	

	;with cte as (
	select m.ManifestTemplateId, tmp.Frequency
		, ms.AccountPubId
		, Sequence
		--, AccountId
	from scManifests m
	join (	
		select mt.ManifestTemplateId, mst.Frequency, MAX(ManifestDate) as [ManifestDate]
		from @restore tmp
		join scManifestTemplates mt
			on tmp.manifestTemplateId = mt.ManifestTemplateId
		left join scManifestSequenceTemplates mst
			on mt.ManifestTemplateId = mst.ManifestTemplateId
		join scManifests m
			on m.ManifestTemplateId = mt.ManifestTemplateId
			and dbo.scGetDayFrequency(m.ManifestDate) & mst.Frequency > 0
		where m.ManifestDate between '5/7/2015' and '5/13/2015'
		group by mt.ManifestTemplateId, mst.Frequency
		) tmp
		on m.ManifestTemplateId = tmp.ManifestTemplateId
		and m.ManifestDate = tmp.ManifestDate	
	join scManifestSequences ms
		on m.ManifestID = ms.ManifestId	
	--join scAccountsPubs ap
	--	on ms.AccountPubId = ap.AccountPubID
	--order by m.ManifestTemplateId, tmp.Frequency, ms.Sequence	
	)
	insert into scManifestSequenceItems ( ManifestSequenceTemplateId, AccountPubId, Sequence )
	select mst.ManifestSequenceTemplateId, AccountPubId, Sequence
	--select mt.ManifestTemplateId, mt.MTCode
	--	, mst.ManifestSequenceTemplateId, mst.Frequency
	--	, cte.Sequence, cte.AccountPubId
	from cte
	join scManifestTemplates mt
		on cte.ManifestTemplateId = mt.ManifestTemplateId
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
		and cte.Frequency & mst.Frequency > 0

	--order by 2, 3, 4
	
rollback tran	