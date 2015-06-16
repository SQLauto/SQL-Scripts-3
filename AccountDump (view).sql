IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CustomExport_AccountInfo_View]'))
DROP VIEW [dbo].[CustomExport_AccountInfo_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CustomExport_AccountInfo_View]
AS
	with cteManifests 
	as (
		select distinct ap.AccountId, mt.MTCode
		from scManifestTemplates mt
		join scManifestSequenceTemplates mst
			on mt.ManifestTemplateId = mst.ManifestTemplateId
		join scManifestSequenceItems msi
			on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
		join scAccountsPubs ap
			on ap.AccountPubID = msi.AccountPubId
	)
	, cteDefaultDraw
	as (
		select 1 as dw
			, dd.AccountID, dd.PublicationID
			, CASE DrawWeekday when 1 then dd.DrawAmount
				else null end as [SUN]
			, CASE DrawWeekday when 2  then dd.DrawAmount
				else null end as [MON]
			, CASE DrawWeekday when 3  then dd.DrawAmount
				else null end as [TUE]	
			, CASE DrawWeekday when 4  then dd.DrawAmount
				else null end as [WED]
			, CASE DrawWeekday when 5  then dd.DrawAmount
				else null end as [THU]
			, CASE DrawWeekday when 6  then dd.DrawAmount
				else null end as [FRI]
			, CASE DrawWeekday when 7  then dd.DrawAmount
				else null end as [SAT]
		from scDefaultDraws dd
		--join scAccountsPubs ap
		--	on dd.AccountId = ap.AccountID
		--	and dd.PublicationID = ap.PublicationId
		--join scAccounts a
		--	on ap.AccountId = a.AccountID
		--join nsPublications p
		--	on ap.PublicationId = p.PublicationID
		where dd.DrawWeekday = 1
		union all
		select dw + 1
			, dd.AccountID, dd.PublicationID
			, CASE DrawWeekday when 1 then dd.DrawAmount
				else null end as [SUN]
			, CASE DrawWeekday when 2  then dd.DrawAmount
				else null end as [MON]
			, CASE DrawWeekday when 3  then dd.DrawAmount
				else null end as [TUE]	
			, CASE DrawWeekday when 4  then dd.DrawAmount
				else null end as [WED]
			, CASE DrawWeekday when 5  then dd.DrawAmount
				else null end as [THU]
			, CASE DrawWeekday when 6  then dd.DrawAmount
				else null end as [FRI]
			, CASE DrawWeekday when 7  then dd.DrawAmount
				else null end as [SAT]
		from scDefaultDraws dd
		--join scAccounts a
		--	on dd.AccountId = a.AccountID
		--join nsPublications p
		--	on dd.PublicationId = p.PublicationID
		join cteDefaultDraw cte
			on cte.AccountID = dd.AccountID
			and cte.PublicationID = dd.PublicationID
		where dd.DrawWeekday = dw + 1
		and dw + 1 <= 7
	)
	select
		'AcctCode' as [AcctCode], 'AcctName' as [AcctName], 'AcctAddress' as [AcctAddress], 'AcctCity' as [AcctCity]
		, 'AcctStateProvince' as [AcctStateProvince], 'AcctPostalCode' as [AcctPostalCode], 'SyncAccountType' as [SyncAccountType], 'RollupCode' as [RollupCode], 'MTCode' as [MTCode], 'PubShortName' as [PubShortName]
		, 'SUN' as [SUN], 'MON' as [MON], 'TUE' as [TUE], 'WED' as [WED], 'THU' as [THU], 'FRI' as [FRI], 'SAT' as [SAT]
	union all select 
		a.AcctCode, AcctName, AcctAddress, AcctCity, AcctStateProvince, AcctPostalCode, [SyncAccountType], RollupCode, MTCode
		, dd.PubShortName, dd.SUN, dd.MON, dd.TUE, dd.WED, dd.THU, dd.FRI, dd.SAT
	from ( 
		select  AcctCode, PubShortName
			, cast(MAX(SUN) as varchar) as SUN
			, cast(MAX(MON) as varchar) as MON
			, cast(MAX(TUE) as varchar) as TUE
			, cast(MAX(WED) as varchar) as WED
			, cast(MAX(THU) as varchar) as THU
			, cast(MAX(FRI) as varchar) as FRI
			, cast(MAX(SAT) as varchar) as SAT
		from cteDefaultDraw cte
		join scAccounts a
			on cte.AccountID = a.AccountID
		join nsPublications p
			on cte.PublicationID = p.PublicationID	
		group by AcctCode, PubShortName
		) as dd
	join (	
		select AcctCode, AcctName, AcctAddress, AcctCity, AcctStateProvince, AcctPostalCode, 'Child Account' as [SyncAccountType], RollupCode, m.MTCode
		from scAccounts a
		join scChildAccounts ca
			on a.AccountID = ca.ChildAccountID
		join scRollups r
			on ca.AccountID = r.RollupID
		left join cteManifests m
			on a.AccountID = m.AccountId		
		--left join cteDefaultDraw dd
		--	on 	dd.AccountID = a.AccountID
		where a.AcctActive = 1
		union all 
		select AcctCode, AcctName, AcctAddress, AcctCity, AcctStateProvince, AcctPostalCode, 'Stand-Alone' as [SyncAccountType], null, MTCode
		from scAccounts a
		left join scChildAccounts ca
			on a.AccountID = ca.ChildAccountID
		left join cteManifests m
			on a.AccountID = m.AccountId
		--left join cteDefaultDraw dd
		--	on dd.AccountID = a.AccountID	
		where a.AcctActive = 1
		and ca.AccountID is null
		) as a
	on dd.AcctCode = a.AcctCode
GO


