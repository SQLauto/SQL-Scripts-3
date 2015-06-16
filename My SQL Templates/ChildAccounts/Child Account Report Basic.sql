
declare @acctCode nvarchar(25)
declare @rollupCode nvarchar(25)

set @acctCode = '10013'
set @rollupCode = null

select a.AcctCode as [Child Accouunt Code], r.RollupCode
from scAccounts a
join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID
join scRollups r
	on ca.AccountID = r.RollupID	
where (
	( 
		( @acctCode is null and a.AccountID > 0 )
		or
		( a.AcctCode = @acctCode 
	)	)
	and 
	( 
		( @rollupCode is null and r.RollupID > 0 )
		or
		( r.RollupCode = @rollupCode )
	 )
)		