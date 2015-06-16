use sdmconfig

begin tran

update t2k_attribute
set displayheight = 5
where attributedisplayid in 
	(
	select ta.attributedisplayid
	from t2k_attribute ta
	where displaytype = 20578
	and displayheight < 1
	)

select me.entityname, ta.attributeid, ta.attributedisplayid, ta.displayname, ta.displaytype, ta.displayheight, ta.isdefault 
from t2k_attribute ta
inner join merc_attribute ma
on ma.attributeid = ta.attributeid
inner join merc_entity me
on me.entityid = ma.entityid
where ta.attributeid in
	(
	select ma.attributeid
	from merc_attribute
	where entityid in 
		(
		select entityid 
		from merc_entity
		)
	)
and displaytype = 20578
order by 2,1

commit tran