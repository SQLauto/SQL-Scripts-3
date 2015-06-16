
/*
	Sequences with a frequency that includes multipe days.  e.g. Mon, Tue
*/

select *
from scManifestSequenceTemplates mst
join scManifestTemplates mt
	on mst.ManifestTemplateId = mt.ManifestTemplateId
where Frequency <> 1
	and Frequency <> 2
	and Frequency <> 4
	and Frequency <> 8
	and Frequency <> 16
	and Frequency <> 32
	and Frequency <> 64
and ManifestTypeId = 1