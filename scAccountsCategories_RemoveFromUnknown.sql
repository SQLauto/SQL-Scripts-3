--|Remove accounts from the 'Unknown' account category if they also belong to another non-unknown category

begin tran

delete from scaccountscategories
where categoryid = ( select categoryid from dd_scaccountcategories where catname = 'NONE' )
and accountid in ( 
	select accountid
	from scaccountscategories
	group by accountid
	having count(*) > 1
	)

commit tran