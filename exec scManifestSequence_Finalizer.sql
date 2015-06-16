declare @date datetime

set @date = dateadd(d, 1, convert( varchar, getdate(), 1) )

exec scManifestSequence_Finalizer @date