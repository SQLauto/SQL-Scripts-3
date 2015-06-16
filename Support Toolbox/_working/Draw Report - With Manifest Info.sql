declare @day int
set @day = 0

;with cteManifests 
as (
		select @day as dt 
			, MTCode, mst.Frequency, AcctCode, PubShortName, msi.Sequence
		from scManifestTemplates mt
		join scManifestSequenceTemplates mst
			on mt.ManifestTemplateId = mst.ManifestTemplateId
		join scManifestSequenceItems msi
			on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
		join scAccountsPubs ap
			on msi.AccountPubId = ap.AccountPubID
		join scAccounts a
			on ap.AccountId = a.AccountID
		join nsPublications p
			on ap.PublicationId = p.PublicationID
		where mst.Frequency & power(2, @day ) = 1
		and mt.ManifestTypeId = 1
		union all
		select  dt + 1
			, mt.MTCode, mst.Frequency, a.AcctCode, p.PubShortName, msi.Sequence
		from scManifestTemplates mt
		join scManifestSequenceTemplates mst
			on mt.ManifestTemplateId = mst.ManifestTemplateId
		join scManifestSequenceItems msi
			on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
		join scAccountsPubs ap
			on msi.AccountPubId = ap.AccountPubID
		join scAccounts a
			on ap.AccountId = a.AccountID
		join nsPublications p
			on ap.PublicationId = p.PublicationID
		join cteManifests cte
			on cte.MTCode = mt.MTCode
			and cte.AcctCode = a.AcctCode
			and cte.PubShortName = p.PubShortName
		where mst.Frequency & power(2, dt + 1 ) = power(2, dt + 1 )
		and power(2, dt + 1 ) <= 127
		and mt.ManifestTypeId = 1
	)
	, cteDraw 
	as (
		select AcctCode, p.PubShortName, d.DrawDate, d.DrawAmount, d.RetAmount, d.RetExpDateTime, d.RetExportLastAmt
		from scDraws d
		join scAccounts a
			on d.AccountID = a.AccountID
		join nsPublications p
			on d.PublicationID = p.PublicationID
		where p.PubShortName = 'ppga'
		and RetAmount > 0
	)
	select distinct MTCode, d.*
	from cteManifests m
	join cteDraw d
		on m.AcctCode = d.AcctCode
		and m.PubShortName = d.PubShortName
		and Frequency & datepart(dw, drawdate) > 1
	order by AcctCode, PubShortName

