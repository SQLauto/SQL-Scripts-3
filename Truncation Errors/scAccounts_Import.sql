
begin tran

exec scAccounts_Import

rollback tran

select distinct acctstateprovince
from scManifestLoad_View
where LEN(acctstateprovince) > 5

select ', max(len( ' + [name] + ') ) as [' + name + ']'
from syscolumns
where id = OBJECT_ID('scmanifestload_view')

select max(len( drawdate) ) as [drawdate]
, max(len( deliverydate) ) as [deliverydate]
, max(len( publication) ) as [publication]
, max(len( drawamount) ) as [drawamount]
, max(len( drawrate) ) as [drawrate]
, max(len( mfstname) ) as [mfstname]
, max(len( mfstcode) ) as [mfstcode]
, max(len( mfstdescription) ) as [mfstdescription]
, max(len( mfstnotes) ) as [mfstnotes]
, max(len( mfstcustom1) ) as [mfstcustom1]
, max(len( mfstcustom2) ) as [mfstcustom2]
, max(len( mfstcustom3) ) as [mfstcustom3]
, max(len( mfstowner) ) as [mfstowner]
, max(len( acctname) ) as [acctname]
, max(len( acctcode) ) as [acctcode]
, max(len( acctdescription) ) as [acctdescription]
, max(len( accttype) ) as [accttype]
, max(len( acctcategory) ) as [acctcategory]
, max(len( acctnotes) ) as [acctnotes]
, max(len( acctaddress) ) as [acctaddress]
, max(len( acctcity) ) as [acctcity]
, max(len( acctstateprovince) ) as [acctstateprovince]
, max(len( acctpostalcode) ) as [acctpostalcode]
, max(len( acctcountry) ) as [acctcountry]
, max(len( acctcustom1) ) as [acctcustom1]
, max(len( acctcustom2) ) as [acctcustom2]
, max(len( acctcustom3) ) as [acctcustom3]
, max(len( acctspecialinstructions) ) as [acctspecialinstructions]
, max(len( accthours) ) as [accthours]
, max(len( acctcontact) ) as [acctcontact]
, max(len( acctphone) ) as [acctphone]
, max(len( acctcreditcardonfile) ) as [acctcreditcardonfile]
, max(len( acctrollup) ) as [acctrollup]
, max(len( dropname) ) as [dropname]
, max(len( dropsequence) ) as [dropsequence]
, max(len( dropdescription) ) as [dropdescription]
, max(len( dropaddress) ) as [dropaddress]
, max(len( dropcity) ) as [dropcity]
, max(len( dropstateprovince) ) as [dropstateprovince]
, max(len( dropcountry) ) as [dropcountry]
, max(len( droppostalcode) ) as [droppostalcode]
, max(len( dropdeliveryinstructions) ) as [dropdeliveryinstructions]
, max(len( ParentAccount) ) as [ParentAccount]
, max(len( DeliveryStartDate) ) as [DeliveryStartDate]
, max(len( DeliveryStopDate) ) as [DeliveryStopDate]
, max(len( ForecastStartDate) ) as [ForecastStartDate]
, max(len( ForecastStopDate) ) as [ForecastStopDate]
, max(len( ExcludeFromBilling) ) as [ExcludeFromBilling]
, max(len( AcctPubActive) ) as [AcctPubActive]
, max(len( APCustom1) ) as [APCustom1]
, max(len( APCustom2) ) as [APCustom2]
, max(len( APCustom3) ) as [APCustom3]
, max(len( AllowForecasting) ) as [AllowForecasting]
, max(len( AllowReturns) ) as [AllowReturns]
, max(len( AllowAdjustments) ) as [AllowAdjustments]
, max(len( ForecastMinDraw) ) as [ForecastMinDraw]
, max(len( ForecastMaxDraw) ) as [ForecastMaxDraw]
, max(len( AcctCorporate) ) as [AcctCorporate]
from scManifestLoad_View