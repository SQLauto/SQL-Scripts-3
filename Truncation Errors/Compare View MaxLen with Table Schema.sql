select a.ColumnName, a.ColumnLength, b.Length
from (
		  select 'acctaddress' as [ColumnName], max(len( acctaddress) ) as [ColumnLength] from scManifestLoad_View
union all select 'acctcategory' as [ColumnName], max(len( acctcategory) ) as [acctcategory] from scManifestLoad_View
union all select 'acctcity' as [ColumnName], max(len( acctcity) ) as [acctcity] from scManifestLoad_View
union all select 'acctcode' as [ColumnName], max(len( acctcode) ) as [acctcode] from scManifestLoad_View
union all select 'AcctContact' as [ColumnName], max(len( AcctContact) ) as [AcctContact] from scManifestLoad_View
union all select 'acctcountry' as [ColumnName], max(len( acctcountry) ) as [acctcountry] from scManifestLoad_View
union all select 'AcctCreditCardOnFile' as [ColumnName], max(len( AcctCreditCardOnFile) ) as [AcctCreditCardOnFile] from scManifestLoad_View
union all select 'acctcustom1' as [ColumnName], max(len( acctcustom1) ) as [acctcustom1] from scManifestLoad_View
union all select 'acctcustom2' as [ColumnName], max(len( acctcustom2) ) as [acctcustom2] from scManifestLoad_View
union all select 'acctcustom3' as [ColumnName], max(len( acctcustom3) ) as [acctcustom3] from scManifestLoad_View
union all select 'acctdescription' as [ColumnName], max(len( acctdescription) ) as [acctdescription] from scManifestLoad_View
union all select 'AcctHours' as [ColumnName], max(len( AcctHours) ) as [AcctHours] from scManifestLoad_View
union all select 'acctname' as [ColumnName], max(len( acctname) ) as [acctname] from scManifestLoad_View
union all select 'acctnotes' as [ColumnName], max(len( acctnotes) ) as [acctnotes] from scManifestLoad_View
union all select 'AcctPhone' as [ColumnName], max(len( AcctPhone) ) as [AcctPhone] from scManifestLoad_View
union all select 'acctpostalcode' as [ColumnName], max(len( acctpostalcode) ) as [acctpostalcode] from scManifestLoad_View
union all select 'AcctPubActive' as [ColumnName], max(len( AcctPubActive) ) as [AcctPubActive] from scManifestLoad_View
union all select 'acctrollup' as [ColumnName], max(len( acctrollup) ) as [acctrollup] from scManifestLoad_View
union all select 'acctspecialinstructions' as [ColumnName], max(len( acctspecialinstructions) ) as [acctspecialinstructions] from scManifestLoad_View
union all select 'acctstateprovince' as [ColumnName], max(len( acctstateprovince) ) as [acctstateprovince] from scManifestLoad_View
union all select 'accttype' as [ColumnName], max(len( accttype) ) as [accttype] from scManifestLoad_View
union all select 'AllowAdjustments' as [ColumnName], max(len( AllowAdjustments) ) as [AllowAdjustments] from scManifestLoad_View
union all select 'AllowForecasting' as [ColumnName], max(len( AllowForecasting) ) as [AllowForecasting] from scManifestLoad_View
union all select 'AllowReturns' as [ColumnName], max(len( AllowReturns) ) as [AllowReturns] from scManifestLoad_View
union all select 'APCustom1' as [ColumnName], max(len( APCustom1) ) as [APCustom1] from scManifestLoad_View
union all select 'APCustom2' as [ColumnName], max(len( APCustom2) ) as [APCustom2] from scManifestLoad_View
union all select 'APCustom3' as [ColumnName], max(len( APCustom3) ) as [APCustom3] from scManifestLoad_View
union all select 'deliverydate' as [ColumnName], max(len( deliverydate) ) as [deliverydate] from scManifestLoad_View
union all select 'DeliveryStartDate' as [ColumnName], max(len( DeliveryStartDate) ) as [DeliveryStartDate] from scManifestLoad_View
union all select 'DeliveryStopDate' as [ColumnName], max(len( DeliveryStopDate) ) as [DeliveryStopDate] from scManifestLoad_View
union all select 'drawamount' as [ColumnName], max(len( drawamount) ) as [drawamount] from scManifestLoad_View
union all select 'drawdate' as [ColumnName], max(len( drawdate) ) as [drawdate] from scManifestLoad_View
union all select 'drawrate' as [ColumnName], max(len( drawrate) ) as [drawrate] from scManifestLoad_View
union all select 'dropaddress' as [ColumnName], max(len( dropaddress) ) as [dropaddress] from scManifestLoad_View
union all select 'dropcity' as [ColumnName], max(len( dropcity) ) as [dropcity] from scManifestLoad_View
union all select 'dropcountry' as [ColumnName], max(len( dropcountry) ) as [dropcountry] from scManifestLoad_View
union all select 'dropdeliveryinstructions' as [ColumnName], max(len( dropdeliveryinstructions) ) as [dropdeliveryinstructions] from scManifestLoad_View
union all select 'dropdescription' as [ColumnName], max(len( dropdescription) ) as [dropdescription] from scManifestLoad_View
union all select 'dropname' as [ColumnName], max(len( dropname) ) as [dropname] from scManifestLoad_View
union all select 'droppostalcode' as [ColumnName], max(len( droppostalcode) ) as [droppostalcode] from scManifestLoad_View
union all select 'dropsequence' as [ColumnName], max(len( dropsequence) ) as [dropsequence] from scManifestLoad_View
union all select 'dropstateprovince' as [ColumnName], max(len( dropstateprovince) ) as [dropstateprovince] from scManifestLoad_View
union all select 'ExcludeFromBilling' as [ColumnName], max(len( ExcludeFromBilling) ) as [ExcludeFromBilling] from scManifestLoad_View
union all select 'ForecastMaxDraw' as [ColumnName], max(len( ForecastMaxDraw) ) as [ForecastMaxDraw] from scManifestLoad_View
union all select 'ForecastMinDraw' as [ColumnName], max(len( ForecastMinDraw) ) as [ForecastMinDraw] from scManifestLoad_View
union all select 'ForecastStartDate' as [ColumnName], max(len( ForecastStartDate) ) as [ForecastStartDate] from scManifestLoad_View
union all select 'ForecastStopDate' as [ColumnName], max(len( ForecastStopDate) ) as [ForecastStopDate] from scManifestLoad_View
union all select 'mfstcode' as [ColumnName], max(len( mfstcode) ) as [mfstcode] from scManifestLoad_View
union all select 'mfstcustom1' as [ColumnName], max(len( mfstcustom1) ) as [mfstcustom1] from scManifestLoad_View
union all select 'mfstcustom2' as [ColumnName], max(len( mfstcustom2) ) as [mfstcustom2] from scManifestLoad_View
union all select 'mfstcustom3' as [ColumnName], max(len( mfstcustom3) ) as [mfstcustom3] from scManifestLoad_View
union all select 'mfstdescription' as [ColumnName], max(len( mfstdescription) ) as [mfstdescription] from scManifestLoad_View
union all select 'mfstname' as [ColumnName], max(len( mfstname) ) as [mfstname] from scManifestLoad_View
union all select 'mfstnotes' as [ColumnName], max(len( mfstnotes) ) as [mfstnotes] from scManifestLoad_View
union all select 'mfstowner' as [ColumnName], max(len( mfstowner) ) as [mfstowner] from scManifestLoad_View
union all select 'publication' as [ColumnName], max(len( publication) ) as [publication] from scManifestLoad_View
) a
	join (
	select name, prec as [length]
	from syscolumns
	where id = object_id('scAccounts')
) b
 on a.columnName = b.name
where a.ColumnLength = b.Length
