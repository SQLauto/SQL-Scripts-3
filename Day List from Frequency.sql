
declare @frequency int
declare @dayList nvarchar(33)
set @frequency = 127
set @dayList = null

select @dayList = 
	case 
		when @frequency & 1 > 0 then 'SUN'
		else ''
	end
	 + 
	case 
		when @frequency & 2 > 0 then 
									case 
										when @frequency & 1 > 0 then ', MON'
										else 'MON'
									end								
		else ''										
	end
	 + 
	case 
		when @frequency & 4 > 0 then 
									case 
										when ( @frequency & 1 > 0 )
											 OR ( @frequency & 2 > 0 )
											 then ', TUE'
										else 'TUE'
									end
		else ''															
	end	
	 + 
	case 
		when @frequency & 8 > 0 then 
									case 
										when ( @frequency & 1 > 0 )
											 OR ( @frequency & 2 > 0 )
											 OR ( @frequency & 4 > 0 )
											 then ', WED'
										else 'WED'
									end	
		else ''														
	end	
	 + 
	case 
		when @frequency & 16 > 0 then 
									case 
										when ( @frequency & 1 > 0 )
											 OR ( @frequency & 2 > 0 )
											 OR ( @frequency & 4 > 0 )
											 OR ( @frequency & 8 > 0 )
											 then ', THU'
										else 'THU'
									end	
		else ''														
	end			
	 + 
	case 
		when @frequency & 32 > 0 then 
									case 
										when ( @frequency & 1 > 0 )
											 OR ( @frequency & 2 > 0 )
											 OR ( @frequency & 4 > 0 )
											 OR ( @frequency & 8 > 0 )
											 OR ( @frequency & 16 > 0 )
											 then ', FRI'
										else 'FRI'
									end	
		else ''														
	end
	 + 
	case 
		when @frequency & 64 > 0 then 
									case 
										when ( @frequency & 1 > 0 )
											 OR ( @frequency & 2 > 0 )
											 OR ( @frequency & 4 > 0 )
											 OR ( @frequency & 8 > 0 )
											 OR ( @frequency & 16 > 0 )
											 OR ( @frequency & 32 > 0 )
											 then ', SAT'
										else 'SAT'
									end	
		else ''														
	end
	
print @dayList	