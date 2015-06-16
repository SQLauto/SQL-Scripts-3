begin tran
	insert into descheduledetail
	(
	sdm_company
	,sdm_dayofweek
	,sdm_distributioncenter
	,sdm_zone
	,sdm_district
	,sdm_hourbegin
	,sdm_hourend
	,sdm_isactive
	,sdm_lastupdated
	,sdm_messagetargetid
	,sdm_minutebegin
	,sdm_minuteend
	,sdm_scheduleid
	)
	select distinct c.sdm_company, dow.daynumber, dc.sdm_distributioncenter, z.sdm_zone, d.sdm_district, 0, 23, 1, getdate()
		, mt.messagetargetid, 0, 45, 2
	from nscompany c
	inner join dedistributioncenter dc
		on c.sdm_company = dc.sdm_company
	inner join dezone z
		on dc.sdm_distributioncenter = z.sdm_distributioncenter
	inner join dedistrict d
		on z.sdm_zone = d.sdm_zone
	inner join dd_nsdayofweek dow
		on 1 = 1
	inner join tmpusers tmp
		on d.sdm_district = tmp.district
	inner join demessagetarget mt
		on tmp.[last name] = mt.extensionattribute2
		and tmp.[first name] = mt.extensionattribute1

	select *
	from descheduledetail
	order by 5
	
commit tran
