
--|  Use this script to drop the objects containing historical data
--|  Objects will be recreated and populated during the archive process

  --------------------------
--|	scDrawAdjustmentsAudit |--
  --------------------------
	drop table scDrawAdjustmentsAudit

  -----------------------
--|	scDrawAdjustments	|--
  -----------------------
	drop table scDrawAdjustments

  -----------------------
--|	scReturnsAudit		|--
  -----------------------
	drop table scReturnsAudit

  -----------------------
--|	scReturnsAudit		|--
  -----------------------
	drop table scReturns

  ------------------------
--|	scDraws              |--
  ------------------------
	drop table scDraws

  -----------------------
--|	scTemporaryDraws	|--
  -----------------------
	drop table scTemporaryDraws

  ------------------------
--| scDefaultDrawHistory |
  ------------------------
	drop table scDefaultDrawHistory

  -----------------------
--| scDrawForecasts		|
  -----------------------
	drop table scDrawForecasts

  ------------------------
--| scManifestUploadData |
  ------------------------
	drop table scManifestUploadData

  ------------------------
--| scManifestHistory    |
  ------------------------
	drop table scManifestHistory

  -----------------------------------
--| scManifestDownloadCancellations |
  -----------------------------------
	if exists (select name from sysobjects where name = N'scManifestDownloadCancellations' and type = 'U' )
	drop table scManifestDownloadCancellations

  ------------------------
--| scManifestDownladTrx |
  ------------------------
	if exists (select name from sysobjects where name = N'scManifestDownloadTrx' and type = 'U' )
	drop table scManifestDownloadTrx

  ---------------------------
--| scManifestTransferDrops |
  ---------------------------
	if exists (select name from sysobjects where name = N'scManifestTransferDrops' and type = 'U' )
	drop table scManifestTransferDrops

  ------------------------
--| scManifestTransfers  |
  ------------------------
	if exists (select name from sysobjects where name = N'scManifestTransfers' and type = 'U' )
	drop table scManifestTransfers

  ---------------------------
--| scConditionHistory      |
  ---------------------------
	--drop table scConditionHistory

  ---------------------------
--| syncSystemLog           |
  ---------------------------
	drop table syncSystemLog
