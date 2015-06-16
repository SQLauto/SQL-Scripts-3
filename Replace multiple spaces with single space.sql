 SELECT REPLACE(
            REPLACE(
                REPLACE(
                    LTRIM(RTRIM( <column_name> ))
                ,'  ',' '+CHAR(7))  --Changes 2 spaces to the OX model
            ,CHAR(7)+' ','')        --Changes the XO model to nothing
        ,CHAR(7),'') AS [CleanString] --Changes the remaining X's to nothing
   FROM <table_name>
  WHERE CHARINDEX('  ', <column_name> ) > 0