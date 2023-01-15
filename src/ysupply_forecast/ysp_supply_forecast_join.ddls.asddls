@AbapCatalog.sqlViewName: 'YSP_SF_JOIN'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supply Forecast Join'

define view YSP_SUPPLY_FORECAST_JOIN
  as select from    ysp_prod_order
    left outer join ysp_sto on ysp_prod_order.order_number = ysp_sto.sto_number
{

  key ysp_prod_order.order_number                                                   as OrderNumber,
      ysp_prod_order.material                                                       as Material,
      ysp_prod_order.order_start_date                                               as OrderStartDate,
      ysp_prod_order.order_finish_date                                              as OrderFinishDate,
      ysp_prod_order.quantity                                                       as POQuantity,
      ysp_sto.quantity                                                              as STOQuantity,
      ysp_sto.requirement_date                                                      as RequirementDate,
      ysp_sto.supplying_plant                                                       as SupplyingPlant,
      ysp_sto.receiving_plant                                                       as ReceivingPlant,
      datn_days_between(ysp_prod_order.order_finish_date, ysp_sto.requirement_date) as TransportDifference,
      ysp_prod_order.quantity - ysp_sto.quantity                                    as QuantityDifference

}
