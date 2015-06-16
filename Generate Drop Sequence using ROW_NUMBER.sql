	select 
		ROW_NUMBER() over (partition by MfstCode order by AcctCode) as [DropSequence]
		, AcctCode, AcctCity, AcctAddress
	from scManifestLoad
