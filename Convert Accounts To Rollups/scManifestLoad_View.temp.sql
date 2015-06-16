IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[scManifestLoad_View]'))
DROP VIEW [dbo].[scManifestLoad_View]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[scManifestLoad_View]
as

select distinct AcctCode as [AcctCode]
	, AcctName as [AcctName]--, [RollupDescription], [RollupAddress], [RollupCity], [RollupStateProvince], [RollupPostalCode], [RollupCountry], [RollupContact], [RollupPhone], [RollupHours], [RollupActive], [RollupSpecialInstructions], [RollupCustom1], [RollupCustom2], [RollupCustom3], [RollupNotes], [RollupImported], [RollupDefaultOwner]
        , [acctdescription]
        , [acctnotes]
        , [acctaddress]
        , [acctcity]
        , [acctstateprovince]
        , [acctpostalcode]
        , [acctcountry]
        , [acctcustom1]
        , [acctcustom2]
        , [acctcustom3]
        , [acctspecialinstructions]
        , [acctHours]
        , [acctContact]
        , [acctPhone]	
        , 1   as [acctrollup]
from (	
		select a.*
		from support_AcctsToRollup a

	) prelim