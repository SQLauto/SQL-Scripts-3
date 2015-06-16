begin tran
set nocount on

declare @pubCode nvarchar(5)
declare @drawDate datetime
declare @deliveryDate datetime
declare @incorrectRate decimal(8,5)
declare @correctRate decimal(8,5)

/*-------------------------------------------------
	Update the following parameters as necessary	
-------------------------------------------------*/
set @pubCode = 'IBD2'				
set @drawDate = '11/26/2010'
set @deliveryDate = '11/25/2010'
set @incorrectRate = 0.00000
set @correctRate = 0.65000

select d.DrawID, a.AcctCode , p.PubShortName, d.DrawDate, d.DeliveryDate, d.DrawRate
into #tmpDraws
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccounts a
	on d.AccountID = a.AccountID	
where DATEDIFF(d, DrawDate, @drawDate) = 0
and DATEDIFF(D, DeliveryDate, @deliveryDate) = 0
and p.PubShortName = @pubCode
and d.DrawRate = @incorrectRate

update scDraws
set DrawRate = @correctRate
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
where DATEDIFF(d, DrawDate, @drawDate) = 0
and DATEDIFF(D, DeliveryDate, @deliveryDate) = 0
and p.PubShortName = @pubCode
and d.DrawRate = @incorrectRate
select cast(@@rowcount as nvarchar) + ' records updated with correct rate'

select tmp.AcctCode, tmp.PubShortName, d.DrawDate, d.DeliveryDate, tmp.DrawRate as [Old Rate], d.DrawRate as [New Rate]
from #tmpDraws tmp
join scDraws d
	on tmp.DrawId = d.DrawID

drop table #tmpDraws

rollback tran

