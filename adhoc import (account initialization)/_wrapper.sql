begin tran

exec nsPublications_Import

if exists ( 
	select mfstcode
	from scManifestLoad_View
	where mfstcode is not null
)
begin
	exec scManifest_Data_Load
end
else
begin
	exec scAccounts_Import
	exec scAccountsPubs_Import
	exec scDefaultDraws_Import
end
rollback tran