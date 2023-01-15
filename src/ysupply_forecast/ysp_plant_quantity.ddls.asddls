@AbapCatalog.sqlViewName: 'YSP_PLANT_QTY'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant quantity'
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view YSP_PLANT_QUANTITY
  as select from ysp_sup_forecast
{
  key material        as Material,
  key supplying_plant as SupplyingPlant,
      quantity        as Quantity
}
