
The following can be used to create a working "Archive Database" from a 2.7 database.  
The archive database can be added as an additional company in a multi-company environment, so the archived data can be accessed.

This process may need to be modified 
to archive from a 3.X database.

The process works as follows:

1)  Create a backup of the database you wish to archive.
2)  Drop all objects from the target "archive" database using the "Drop Objects" script.  The reason we do this is because we will recreate
	these tables by doing a "select * into ..." from the source database.
3)  Backup/Shrink the now empty archive database, you should be dealing with a much smaller database now that all of the historical data has been dropped.
4)  Install the stored procedure "syncDataCleanup" to the source database.
5)  Run the stored procedure "syncDataCleanup".  This will move data for a given date range into the archive database.  I recommend doing 
	a full year's worth of data.
6)  Add the indexes back to the Archive database using the "Add Indexes" script.
7)  Backup the archive database
8)  convert the database to 3.1
9)  Add a company to NSSESSION..nsSessionCompanies) for the archive db.