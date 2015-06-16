BULK INSERT [dbo].[IISLogs] FROM 'S:\Customers\TRIB-CHI\u_ex130918.log'
WITH (
    FIELDTERMINATOR = ' ',
    ROWTERMINATOR = '\n'
)

delete from IISLogs
where date = '#Software:'
