--|  STUFF ( character_expression , start , length , replaceWith_expression )
--|  Stuff( result of the query listed above, 1, 1, '')

/*
	<group_by_table, sysname, categories>
	<group_by_column, sysname, category>
	<csv_source_table, sysname, subcategories>
	<csv_source_column, sysname, subcategory>
	<csv_column_header, sysname, [csv]>
	<join_column, sysname, join_column>
	
	select t1.category
			, [csv] = 
				stuff((
					select ',' + csv.subcategory as [text()]
					from subcategories csv
					where csv.join_column = t1.join_column
					for xml path('')

					), 1, 1, '')

	from categories t1

*/

select t1.<group_by_column, sysname, category>
		, <csv_column_header, sysname, [csv]> = 
			stuff((
				select ',' + csv.<csv_source_column, sysname, subcategory> as [text()]
				from <csv_source_table, sysname, subcategories> csv
				where csv.<join_column, sysname, join_column> = t1.<join_column, sysname, join_column>
				for xml path('')

				), 1, 1, '')

from <group_by_table, sysname, categories> t1