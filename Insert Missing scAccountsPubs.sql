--/*	
insert scAccountsPubs (
		 companyid
		,distributioncenterid
		,accountid
		,publicationid
		,deliverystartdate
		,deliverystopdate
		,forecaststartdate
		,forecaststopdate
		,excludefrombilling
		,active
		,apcustom1
		,apcustom2
		,apcustom3
		,apowner
	)
	select
		 1
		,1
		,i.accountid
		,i.publicationid
		,null
		,null
		,null
		,null
		,0
		,1
		,null
		,null
		,null
		,1
--	*/
	from (
		select d.AccountID, d.PublicationID
		from scAccountsPubs ap
		right join ( 
			select distinct AccountId, PublicationId
			from scDraws
		) d		
		on ap.AccountId = d.AccountID
		and ap.PublicationId = d.PublicationID
		where ap.AccountPubID is null
	) as i	
	
	