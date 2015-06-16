IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scManifestLoad_View]'))
DROP VIEW [dbo].[scManifestLoad_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[scManifestLoad_View]
as

select distinct RollupCode as [AcctCode]
	, RollupCode as [AcctName]--, N'' as [RollupDescription], N'' as [RollupAddress], N'' as [RollupCity], N'' as [RollupStateProvince], N'' as [RollupPostalCode], N'' as [RollupCountry], N'' as [RollupContact], N'' as [RollupPhone], N'' as [RollupHours], N'' as [RollupActive], N'' as [RollupSpecialInstructions], N'' as [RollupCustom1], N'' as [RollupCustom2], N'' as [RollupCustom3], N'' as [RollupNotes], N'' as [RollupImported], N'' as [RollupDefaultOwner]
        , N'' as [acctdescription]
        , N'' as [acctnotes]
        , N'' as [acctaddress]
        , N'' as [acctcity]
        , N'' as [acctstateprovince]
        , N'' as [acctpostalcode]
        , N'' as [acctcountry]
        , N'' as [acctcustom1]
        , N'' as [acctcustom2]
        , N'' as [acctcustom3]
        , N'' as [acctspecialinstructions]
        , N'' as [acctHours]
        , N'' as [acctContact]
        , N'' as [acctPhone]	
        , 1   as [acctrollup]
from (	
	select *
	from support_adhoc_import_load
	) prelim