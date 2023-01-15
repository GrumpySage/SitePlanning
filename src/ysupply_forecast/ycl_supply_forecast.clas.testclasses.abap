*"* use this source file for your ABAP unit test classes
CLASS ltc_supply_forecast DEFINITION DEFERRED.

CLASS ycl_supply_forecast DEFINITION
  LOCAL FRIENDS ltc_supply_forecast.

CLASS ltc_supply_forecast DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS:
      empty_po_data FOR TESTING RAISING cx_static_check.
      " TODO: add more unit tests here.

    DATA: test_double TYPE REF TO ycl_sp_data_provider,
          cut         TYPE REF TO ycl_supply_forecast.
ENDCLASS.

CLASS ltc_supply_forecast IMPLEMENTATION.

  METHOD empty_po_data.

    DATA: lo_data_provider_stub TYPE REF TO ycl_sp_data_provider.

    "create test double object
    lo_data_provider_stub ?= cl_abap_testdouble=>create( 'ycl_sp_data_provider' ).

    cl_abap_testdouble=>configure_call( lo_data_provider_stub )->returning( '' ).

    lo_data_provider_stub->read_data( ).

    cut = NEW #( ).

    DATA(lt_result) = cut->get_and_convert_po_json( lo_data_provider_stub ).

    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act = lines( lt_result )
        exp = 0
    ).

  ENDMETHOD.

ENDCLASS.
