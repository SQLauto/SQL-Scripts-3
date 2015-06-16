
;with cteDraw
as (
	select DrawDate, PubShortName, SUM(drawamount) as [Draw]
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where d.DrawDate = '5/11/2012'
	group by DrawDate, PubShortName
)
select d.DrawDate, d.PubShortName, d.Draw as [Draw (scDraws)], v.draw as [Draw (scManifestLoad_View)]
from cteDraw d
left join ( 
	select drawdate, publication, SUM(cast(drawamount as int)) as [Draw]
	from scManifestLoad_View v
	group by drawdate, publication
) as v
	on d.DrawDate = v.drawdate
	and d.PubShortName = v.publication
order by PubShortName