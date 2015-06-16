/*
	Define acctTableType Table parameter
*/
	IF  EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'acctTableType' AND ss.name = N'dbo')
	DROP TYPE [dbo].[acctTableType]
	GO

	CREATE TYPE [dbo].[acctTableType] AS TABLE(
		[AccountId] [int] NULL
	)
	GO


declare @acctsToDelete as acctTableType

insert into @acctsToDelete
select a.AccountID
from scAccounts a
join (
	select
		v.acctcode as [AcctCode_View], a.AcctCode as [AcctCode_scAccounts]
		--, map.CircSystemIdentifier, map.MappedIdentifier
	from scManifestLoad_View v
	join scAccounts a
		on SUBSTRING(v.AcctCode, 1, 3) + SUBSTRING(v.AcctCode, 5, 4) = SUBSTRING(a.AcctCode, 1, 3) + SUBSTRING(a.AcctCode, 5, 4)
	left join scAccountMappings map
		on v.acctcode = map.MappedIdentifier
	where v.edition = 'EarlySun'
	and map.MappedIdentifier is null	
	group by v.acctcode, a.AcctCode
	having COUNT(*) = 2
	--order by v.acctcode
	) prelim
	on prelim.AcctCode_View = a.AcctCode
where prelim.AcctCode_View = prelim.AcctCode_scAccounts

exec support_BulkDeleteAccounts @acctsToDelete