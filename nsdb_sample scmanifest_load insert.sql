begin tran

insert into scmanifestload (
AcctAddress
, AcctCity
, AcctCode
, AcctName
, AcctState
, AcctZip
, Date
, Draw
, LocationCat
, LocationSeq
, LocationType
, MfstCode
, PubShortName
, RollupAcct
, TruckName
)
select  distinct AcctAddress
, AcctCity
, AcctCode
, AcctName
, AcctState
, AcctZip
, Date
, Draw
, LocationCat
, LocationSeq
, LocationType
, 'aaa'
, 'zzzzz'
, RollupAcct
, TruckName
from scmanifestload
where mfstcode = 'mfst1'

select *
from scmanifestload

delete from scmanifestload
where pubshortname <> 'zzzzz'

select *
from scmanifestload

exec scmanifest_data_load

commit tran