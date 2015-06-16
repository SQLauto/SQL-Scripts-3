

;WITH CTE_ExampleData as (
    select s.UserId
		, m.email
		, m.createddate
		, s.firstname, s.lastname
	from subscribers s
	join sememberships m
		on s.userid = m.userid
	where datediff(d, createddate, getdate()) = 0
	and m.createddate > '2015-04-08 18:48:00.000'
)
 select 
    createddate = dateadd(mi,datediff(mi,0,createddate) + 1,0),
    rows = count(1)
 from CTE_ExampleData
 group by dateadd(minute,datediff(mi,0,createddate)+1,0)
 order by createddate desc

     select count(*)
	from subscribers s
	join sememberships m
		on s.userid = m.userid
	where datediff(d, createddate, getdate()) = 0
	and m.createddate > '2015-04-08 18:48:00.000'
