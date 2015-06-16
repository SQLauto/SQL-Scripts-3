
declare @str varchar(1000)
set @str ='HARIA|123|MALE|STUDENT|HOUSEWIFE'

--Creating a number table
;with numcte as( 
select 1 as rn union all select rn+1 from numcte where rn<LEN(@str)),
--Get the position of the "|" charecters
GetDelimitedCharPos as(
select ROW_NUMBER() over(order by getdate()) seq, rn,delimitedcharpos
from numcte 
cross apply(select SUBSTRING(@str,rn,1)delimitedcharpos) X where delimitedcharpos = '|')

--Applying the formula SUBSTRING(@str,startseq + 1,endseq-startseq + 1)
-- i.e. SUBSTRING(@str,11,15-11) in this case

select top 1 SUBSTRING(
    @str
    ,(select top 1 rn+1 from GetDelimitedCharPos where seq =2)
    ,(select top 1 rn from GetDelimitedCharPos where seq =3) - 
    (select top 1 rn+1 from GetDelimitedCharPos where seq =2)
    ) DesiredResult
from GetDelimitedCharPos