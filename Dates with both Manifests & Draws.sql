;with cteManifests
as (
	select distinct ManifestDate
	from scManifests
	)
,cteDraws
as (
	select distinct DrawDate
	from scDraws
)
select ManifestDate, DrawDate
from cteManifests m
full join cteDraws d
	on m.ManifestDate = d.DrawDate
order by 1 desc	