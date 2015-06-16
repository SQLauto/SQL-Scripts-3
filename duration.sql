     -- "DT" is an abbreviation for "DATETIME", not "DATE"
DECLARE  @StartDT DATETIME
        ,@EndDT   DATETIME
;
 SELECT @StartDT = '2000-01-01 10:30:50.780'
        ,@EndDT  = '2000-01-02 12:34:56.789'
;
--===== Display the dates and the desired format for duration
 SELECT  StartDT  = @StartDT
        ,EndDT    = @EndDT
        ,Duration = STUFF(CONVERT(VARCHAR(20),@EndDT-@StartDT,114),1,2,DATEDIFF(hh,0,@EndDT-@StartDT))