OSQL -S snapper -U nsadmin -P nsadmin -d nsdb -Q "exec scUpdate_Demo_Data"
OSQL -S snapper -U dmconfig -P dmconfig -d SDMData -Q "exec deUpdate_Demo_Data"