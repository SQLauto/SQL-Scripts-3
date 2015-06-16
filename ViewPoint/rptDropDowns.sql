use sdmconfig

select entityname, attributealias, displayname, domainentity, domainkey, domainexpression, domaincondition
from t2k_attribute ta
inner join merc_attribute ma
on ta.attributeid = ma.attributeid
inner join merc_entity me
on me.entityid = ma.entityid
where domainentity <> ''
order by domainentity, domainexpression, entityname, attributename
