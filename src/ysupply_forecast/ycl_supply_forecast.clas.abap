**********************************************************************
* This class is the main class for updating supply forecasting.
* It handles two pieces of information: Production Orders (PO) and Stock Transport Orders (STO). These are
* used to show a view comparing the two, plus it performs a calculation to see whether previous
* production orders can help fulfill future Stock Transport Orders.
* The intention is to schedule this class to run once an hour.
* Developer: DKJONEPE
* Date:      13/01-2023
**********************************************************************
CLASS ycl_supply_forecast DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.

    TYPES:
      tt_production_order      TYPE TABLE OF ysp_prod_order WITH DEFAULT KEY,
      tt_stock_transport_order TYPE TABLE OF ysp_sto WITH DEFAULT KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mo_out TYPE REF TO if_oo_adt_classrun_out.

    METHODS:
      get_and_update_po
        IMPORTING io_po_data_provider TYPE REF TO ycl_sp_data_provider,
      get_and_convert_po_json
        IMPORTING io_po_data_provider         TYPE REF TO ycl_sp_data_provider
        RETURNING VALUE(rt_production_orders) TYPE tt_production_order,
      update_production_orders
        IMPORTING it_production_orders TYPE tt_production_order,

      get_and_update_sto
        IMPORTING io_sto_data_provider TYPE REF TO ycl_sp_data_provider,
      get_and_convert_sto_json
        IMPORTING io_sto_data_provider             TYPE REF TO ycl_sp_data_provider
        RETURNING VALUE(rt_stock_transport_orders) TYPE tt_stock_transport_order,
      update_stock_transport_orders
        IMPORTING it_stock_transport_orders TYPE tt_stock_transport_order,

      calculate_supply_forecast.
ENDCLASS.

CLASS ycl_supply_forecast IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    mo_out = out.

    " We have to create the data provider instances here, so we can more easily write unit tests
    " for all methods of this class.
    " Fetch and update PO
    DATA(lo_po_data_provider) = ycl_sp_data_provider=>get_instance(
      iv_datatype = ycl_sp_data_provider=>production_orders ).
    get_and_update_po( lo_po_data_provider ).

    " Fetch and update STO
    DATA(lo_sto_data_provider) = ycl_sp_data_provider=>get_instance(
      iv_datatype = ycl_sp_data_provider=>stock_transport_orders ).
    get_and_update_sto( lo_sto_data_provider ).

    " Calculates whether a previous PO can help fulfill future STOs.
    calculate_supply_forecast( ).

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    out->write( 'All done!' ).

  ENDMETHOD.

  METHOD get_and_update_po.
    update_production_orders( get_and_convert_po_json( io_po_data_provider ) ).
  ENDMETHOD.

  METHOD get_and_convert_po_json.
    TRY.
        DATA(lv_po_json) = io_po_data_provider->read_data( ).

        NEW /ui2/cl_json( )->deserialize(
          EXPORTING
            json             = lv_po_json
            pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING
            data             = rt_production_orders ).
        " May want to raise the exceptions instead.
      CATCH cx_sy_move_cast_error.
        MESSAGE e101(ysp_supply_forecast) WITH 'PO' INTO DATA(lv_err_msg).
        mo_out->write( lv_err_msg ).
      CATCH ycx_sp_data_provider INTO DATA(lx_data_provider).
        mo_out->write( lx_data_provider->mv_error_message ).
      CATCH cx_static_check INTO DATA(lx_static).
        mo_out->write( lx_static->get_longtext( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD update_production_orders.
    IF it_production_orders IS INITIAL.
      MESSAGE e100(ysp_supply_forecast) WITH 'PO' INTO DATA(lv_err_msg).
      mo_out->write( |{ lv_err_msg }| ).
      RETURN.
    ENDIF.

    DELETE FROM ysp_prod_order.
    INSERT ysp_prod_order FROM TABLE @it_production_orders.

    mo_out->write( |Updated PO table with { lines( it_production_orders ) } rows.| ).
  ENDMETHOD.

  METHOD get_and_update_sto.
    update_stock_transport_orders( get_and_convert_sto_json( io_sto_data_provider ) ).
  ENDMETHOD.

  METHOD get_and_convert_sto_json.
    TRY.
        DATA(lv_sto_json) = io_sto_data_provider->read_data( ).

        NEW /ui2/cl_json( )->deserialize(
          EXPORTING
            json             = lv_sto_json
            pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING
            data             = rt_stock_transport_orders ).
        " May want to raise the exceptions instead.
      CATCH cx_sy_move_cast_error.
        MESSAGE e101(ysp_supply_forecast) WITH 'STO' INTO DATA(lv_err_msg).
        mo_out->write( lv_err_msg ).
      CATCH ycx_sp_data_provider INTO DATA(lx_data_provider).
        mo_out->write( lx_data_provider->mv_error_message ).
      CATCH cx_static_check INTO DATA(lx_static).
        mo_out->write( lx_static->get_longtext( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD update_stock_transport_orders.

    IF it_stock_transport_orders IS INITIAL.
      MESSAGE e100(ysp_supply_forecast) WITH 'STO' INTO DATA(lv_err_msg).
      mo_out->write( |{ lv_err_msg }| ).
      RETURN.
    ENDIF.

    DELETE FROM ysp_sto.
    INSERT ysp_sto FROM TABLE @it_stock_transport_orders.

    mo_out->write( |Updated STO table with { lines( it_stock_transport_orders ) } rows.| ).
  ENDMETHOD.

  METHOD calculate_supply_forecast.

    TYPES: tt_supply_forecast TYPE TABLE OF ysp_sup_forecast WITH DEFAULT KEY.
    CONSTANTS: lc_outgoing TYPE ysp_direction VALUE 'Outgoing',
               lc_incoming TYPE ysp_direction VALUE 'Incoming'.

    SELECT * FROM ysp_supply_forecast_join INTO TABLE @DATA(lt_orders).

    " For each joined entry, split back into 2 rows with the relevant fields for the PO and STO, respectively.
    DATA(lt_quantity_changes) = VALUE tt_supply_forecast( FOR order IN lt_orders (
      order_number = order-OrderNumber
      direction = lc_incoming
      material = order-material
      supplying_plant = order-SupplyingPlant
      quantity = order-poQuantity
      orderDate = order-OrderFinishDate )
     (
      order_number = order-OrderNumber
      direction = lc_outgoing
      material = order-material
      supplying_plant = order-SupplyingPlant
      quantity = order-stoQuantity * -1
      orderDate = order-RequirementDate
     ) ).

    " We want to process by finish/requirement date, then by quantity (so PO's that come in the
    " same day as they are needed are counted).
    SORT lt_quantity_changes BY orderDate ASCENDING quantity DESCENDING.

    " The logic below uses a table to keep a running tally of the quantity of a certain material
    " at a certain location, in order to determine whether an STO can be fulfilled at the required date.
    DATA: lt_plant_quantity TYPE TABLE OF ysp_plant_quantity WITH DEFAULT KEY.
    LOOP AT lt_quantity_changes ASSIGNING FIELD-SYMBOL(<quantity_change>).
      SELECT SINGLE * FROM @lt_plant_quantity AS plantQty
        WHERE Material EQ @<quantity_change>-material
          AND SupplyingPlant EQ @<quantity_change>-supplying_plant
        INTO @DATA(ls_plant_quantity).
      IF sy-subrc NE 0.
        " If we do not already have this material/plant combination, add it to the list.
        CLEAR ls_plant_quantity.
        ls_plant_quantity = VALUE #(
          Material = <quantity_change>-material
          SupplyingPlant = <quantity_change>-supplying_plant
          Quantity = 0 ).
        APPEND ls_plant_quantity TO lt_plant_quantity.
      ENDIF.

      " Modify the running tally of the quantity.
      ls_plant_quantity-quantity = ls_plant_quantity-quantity + <quantity_change>-quantity.
      MODIFY TABLE lt_plant_quantity FROM ls_plant_quantity.

      " If this is an STO and there is not enough quantity, set the criticality.
      IF <quantity_change>-direction EQ lc_outgoing AND ls_plant_quantity-quantity < 0.
        <quantity_change>-quantity_criticality = 1.
      ENDIF.

    ENDLOOP.

    " We recalculate everything, so clear the table, then insert the new calculation.
    DELETE FROM ysp_sup_forecast.
    INSERT ysp_sup_forecast FROM TABLE @lt_quantity_changes.

  ENDMETHOD.

ENDCLASS.
