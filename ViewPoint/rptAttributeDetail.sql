use sdmconfig

select me.entityname, ma.attributealias, ta.displayname, li.displayvalue as [datatype], ma.attributelength
from t2k_attribute ta
inner join merc_attribute ma
on ta.attributeid = ma.attributeid
inner join merc_entity me
on ma.entityid = me.entityid
inner join listitem li
on cast(ma.datatype as varchar(5)) = li.keyvalue
where li.listid = '20153'
order by me.entityname, ta.displayname, ma.attributeid
