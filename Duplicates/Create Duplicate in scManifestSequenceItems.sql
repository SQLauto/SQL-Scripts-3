begin tran

insert into scmanifestsequenceitems (
	AccountPubId
	,ManifestSequenceTemplateId
	,Sequence
)
select AccountPubId
	,ManifestSequenceTemplateId
	,Sequence
from scmanifestsequenceitems 
where manifestsequenceitemid = 570


commit tran
