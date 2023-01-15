@AbapCatalog.sqlViewName: 'YSP_SF_SUM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggregated supply forecast overview'

@UI: {
  headerInfo: {
    typeName: 'Summed Supply Forecast',
    typeNamePlural: 'Summed Supply Forecast',
  title: { type: #STANDARD, value: 'OrderNumber' }
  }
}
@ObjectModel.semanticKey: ['OrderNumber']
@ObjectModel.representativeKey: 'OrderNumber'
define view YSP_SUPPLY_FORECAST_SUM
  as select from ysp_sup_forecast
{

      @UI.lineItem: [ { position: 10 } ]
  key order_number as OrderNumber,

      @UI.lineItem: [ { position: 20 } ]
  key direction,

      @UI: {
        lineItem: [ { position: 30, importance: #HIGH } ],
        selectionField: [{position: 10 }]
      }
      material,

      @UI.lineItem: [{ hidden: true }]
      quantity_criticality,

      @UI: {
        lineItem: [{ position: 30, criticality: 'quantity_criticality', importance: #HIGH }],
        selectionField: [{position: 20 }],
        dataPoint: {title: 'Quan', criticality: 'Quantity_Criticality', criticalityRepresentation: #WITH_ICON }
      }
      quantity,

      @UI.lineItem: [ { position: 50, importance: #HIGH } ]
      @EndUserText.label: 'Finish or Req. Date'
      orderdate,

      @UI.lineItem: [ { position: 60 } ]
      supplying_plant
}
