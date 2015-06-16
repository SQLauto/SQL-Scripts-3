


/*
	delete data
		historical
			table driven "list" of tables to delete data. issue is writing the joins with the appropriate manifest/draw tables
			
				by SingleCopy Version
	
			loop through big tables deleting "chunks", shrinking log file as we go
		
	shrink log file
	shrink database		



	wrapper - 
		list of tables 
		calls procedure to delete table data
			calls procedure to shrink log file
			
	reporting sp_spaceUsed
*/

