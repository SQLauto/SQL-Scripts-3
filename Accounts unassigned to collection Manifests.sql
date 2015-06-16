
select acctcode, dd.drawamount
from scaccounts a
left join (
    select accountid
    from scmanifestsequenceitems msi
    join scmanifestsequencetemplates mst
        on mst.manifestsequencetemplateid = msi.manifestsequencetemplateid
    join scmanifesttemplates mt
        on mst.manifesttemplateid = mt.manifesttemplateid
    join scaccountspubs ap
        on msi.accountpubid = ap.accountpubid
    where mt.manifesttypeid = ( 
        select manifesttypeid from dd_scManifestTypes where manifesttypedescription = 'collection'
        )
    ) tmp
    on a.AccountId = tmp.AccountId
join (
    select AccountId, sum(DrawAmount) as [DrawAmount]
    from scDraws
	where drawdate > dateadd(d, -30, convert(varchar, getdate(), 1))
    group by AccountId
    --having sum(DrawAmount) > 0
    ) dd  
    on a.AccountId = dd.AccountId
where tmp.AccountId is null

--select datediff(d, '5/11/2015', '5/12/2015')
--select datediff(d, '5/12/2015', '5/11/2015')
--select dateadd(d, -30, convert(varchar, getdate(), 1))