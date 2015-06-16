begin tran

insert into dsimessageload (
trans_num
,account
,publication
)
select 
	30054900
	,11303884051
	,100

rollback tran
