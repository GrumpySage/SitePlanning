@AbapCatalog.sqlViewName: 'YSP_SF_OVERVIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supply Forecast Overview'
@UI: {
  headerInfo: {
    typeName: 'Supply Forecast',
    typeNamePlural: 'Supply Forecast',
    title: { type: #STANDARD, value: 'OrderNumber' } }
}
@ObjectModel.semanticKey: ['OrderNumber']
@ObjectModel.representativeKey: 'OrderNumber'
define view YSP_SUPPLY_FORECAST_OVERVIEW
  as select from YSP_SUPPLY_FORECAST_JOIN
{
      @UI.facet: [ {
        type: #FIELDGROUP_REFERENCE,
        position: 10,
        label: 'PO and STO detail page',
        targetQualifier: 'DetailPage'
      } ]

      @UI: {
        lineItem: [ { position: 10, importance: #HIGH } ],
        selectionField: [{position: 99 }]
      }
  key OrderNumber,

      @UI: {
        lineItem: [ { position: 20, importance: #HIGH } ],
        selectionField: [{position: 20 }],
        fieldGroup: [{qualifier: 'DetailPage', position: 10, importance: #HIGH }]
      }
      Material,

      @UI: {
        lineItem: [{ position: 30, label: 'Quantity difference', criticality: 'QuantityCriticality', importance: #HIGH }],
        selectionField: [{position: 30 }],
        dataPoint: {title: 'Quantity Difference', criticality: 'QuantityCriticality', criticalityRepresentation: #WITH_ICON }
      }
      QuantityDifference,


      @UI: {
        lineItem: [{ position: 40, label: 'Transport delay', criticality: 'DateCriticality', importance: #HIGH }],
        selectionField: [{position: 40 }],
        dataPoint: { criticality: 'DateCriticality', criticalityRepresentation: #WITH_ICON }
      }
      TransportDifference,

      @UI: {
        lineItem: [ { position: 50, importance: #HIGH } ],
        selectionField: [{position: 50 }],
        fieldGroup: [{qualifier: 'DetailPage', position: 20, importance: #HIGH }]
      }
      RequirementDate,

      @UI: {
        lineItem: [{ hidden: true }],
        fieldGroup: [{qualifier: 'DetailPage', label: 'Order Start Date', position: 30 }]
      }
      OrderStartDate,
      @UI: {
        lineItem: [{ hidden: true }],
        fieldGroup: [{qualifier: 'DetailPage', label: 'Order Finish Date', position: 40 }]
      }
      OrderFinishDate,

      @UI: {
        lineItem: [{ hidden: true }],
        fieldGroup: [{qualifier: 'DetailPage', label: 'PO Quantity', position: 50 }]
      }
      POQuantity,

      @UI: {
        lineItem: [{ hidden: true }],
        fieldGroup: [{qualifier: 'DetailPage', label: 'STO Quantity', position: 60 }]
      }
      STOQuantity,

      @UI: {
        lineItem: [{ hidden: true }],
        fieldGroup: [{qualifier: 'DetailPage', label: 'Supplying Plant', position: 70 }]
      }
      SupplyingPlant,

      @UI: {
        lineItem: [{ hidden: true }],
        fieldGroup: [{qualifier: 'DetailPage', label: 'Receiving Plant', position: 80 }]
      }
      ReceivingPlant,

// TODO: The below values should probably be put in a customizing table instead of being hardcoded.
      case
        when QuantityDifference < 0 then 1
        else 3
      end as QuantityCriticality,

      case
        when TransportDifference < 0 then 1
        when TransportDifference < 5 or TransportDifference > 30 then 2
        else 3
      end as DateCriticality

}
