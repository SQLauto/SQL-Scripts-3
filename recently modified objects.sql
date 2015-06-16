SELECT name, create_date, modify_date
FROM sys.objects
WHERE type = 'p'
--and datediff(d, modify_date, getdate()) < 90
order by 2 desc