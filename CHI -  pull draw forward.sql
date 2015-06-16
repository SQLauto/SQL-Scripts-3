begin tran

declare @sourceDate datetime
declare @targetDate datetime
declare @bkp_name nvarchar(50)
declare @sql nvarchar(4000)
declare @pub nvarchar(5)

set @targetDate = '3/24/2011'
set @sourceDate = '3/17/2011'
set @pub = 'USA'

		if exists (select * from sys.objects where object_id = OBJECT_ID(N'[dbo].[tmpAcctsMfsts]') AND type in (N'U'))
		begin
			drop table [dbo].[tmpAcctsMfsts]
		end
		
		create table tmpAcctsMfsts (
			  AccountId int
			, AcctCode nvarchar(20)
			, PublicationId int
			, PubShortName nvarchar(5)
			, MfstCode nvarchar(20)
			, ManifestTypeId int
			, ManifestTypeDescription nvarchar(128)
			, ManifestOwner int
			, Frequency int
			)
		
		insert into tmpAcctsMfsts (
			  AccountId
			, AcctCode 
			, PublicationId
			, PubShortName
			, MfstCode
			, ManifestTypeId
			, ManifestTypeDescription
			, ManifestOwner
			, Frequency
		)	
		select AccountId
			, AcctCode 
			, PublicationId
			, PubShortName
			, MfstCode
			, ManifestTypeId
			, ManifestTypeDescription
			, ManifestOwner
			, Frequency
		from dbo.listMfstsAccts('Delivery','83', null, -1, 16); 
		
select d.DrawId, d.AccountID, d.PublicationID, d.DrawDate, d.DrawWeekday, d.DrawAmount, d.DrawRate
into tmpBackup_scDraws_USA_03242011
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
where PubShortName = 'USA'
and d.DrawDate = @targetDate


;with cteSourceDraw as (
	select d.AccountID, d.PublicationID, d.DrawDate, d.DrawWeekday, d.DrawAmount, d.DrawRate
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where d.DrawDate = @sourceDate
	and p.PubShortName = @pub	
)
update scDraws
set DrawAmount = sd.DrawAmount
	, DrawRate = sd.DrawRate
from scDraws td
join cteSourceDraw sd
	on td.AccountID = sd.AccountID
	and td.PublicationID = sd.PublicationID
	and td.DrawWeekday = sd.DrawWeekday
join tmpAcctsMfsts m
	on td.AccountID = m.AccountId
	and td.PublicationID = m.PublicationId
where td.DrawDate = @targetDate
print cast(@@rowcount as varchar) + ' draw records updated'

select m.MfstCode, d.AccountID, a.AcctCode, d.PublicationID, p.PubShortName, d.DrawDate, tmp.DrawAmount as [Draw (before update)], d.DrawAmount as [Draw (after update)]
	, tmp.DrawRate as [Rate (before update)], d.DrawRate as [Rate (aftter update)]
from tmpBackup_scDraws_USA_03242011 tmp
join scDraws d
	on tmp.DrawId = d.DrawID
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
join tmpAcctsMfsts m
	on tmp.AccountID = m.AccountId
	and tmp.PublicationID = m.PublicationId
order by m.MfstCode, a.AcctCode

commit tran


