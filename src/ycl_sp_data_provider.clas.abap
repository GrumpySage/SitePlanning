**********************************************************************
* This class handles communication with external APIs, getting Production Orders and Stock
* Transport Orders.
* Developer: DKJONEPE
* Date:      13/01-2023
**********************************************************************
CLASS ycl_sp_data_provider DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    " For a bigger solution, consider adding an interface:
*    INTERFACES yif_sp_data_provider.

    TYPES:
      BEGIN OF ENUM enum_datatype,
        production_orders,
        stock_transport_orders,
      END OF ENUM enum_datatype.

    CLASS-METHODS:
      get_instance
        IMPORTING iv_datatype        TYPE enum_datatype
        RETURNING VALUE(ro_instance) TYPE REF TO ycl_sp_data_provider.

    METHODS:
      read_data
        RETURNING VALUE(rv_json) TYPE string
        RAISING
          ycx_sp_data_provider
          cx_static_check.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mv_datatype TYPE enum_datatype.

    METHODS:
      create_client_and_fetch
        IMPORTING url                TYPE string
        RETURNING VALUE(rv_response) TYPE string
        RAISING   cx_static_check,
      mocked_po_data
        RETURNING
          VALUE(rt_po_mock) TYPE string,
      mocked_sto_data
        RETURNING
          VALUE(rt_sto_mock) TYPE string.

    CONSTANTS: lc_po_endpoint  TYPE string VALUE 'http://sap.com/TODO_PO_ENDPOINT',
               lc_sto_endpoint TYPE string VALUE 'http://sap.com/TODO_STO_ENDPOINT'.

ENDCLASS.

CLASS ycl_sp_data_provider IMPLEMENTATION.

  METHOD get_instance.
    ro_instance = NEW #( ).
    ro_instance->mv_datatype = iv_datatype.
  ENDMETHOD.

  METHOD read_data.
    " TODO in actual solution: Instead of having constants with URL's, put them in a customizing table
    rv_json = SWITCH #( mv_datatype
      WHEN production_orders THEN create_client_and_fetch( lc_po_endpoint )
      WHEN stock_transport_orders THEN create_client_and_fetch( lc_sto_endpoint )
      ELSE THROW ycx_sp_data_provider( |Unknown type of data: { mv_datatype }| ) ).
  ENDMETHOD.

  METHOD create_client_and_fetch.
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    DATA(client) = cl_web_http_client_manager=>create_by_http_destination( dest ).
*    Commented out as we do not have the actual endpoints. When we do, add in this line and remove the SWITCH statement.
*    DATA(response) = client->execute( if_web_http_client=>get )->get_text(  ).
    rv_response = SWITCH #( url
      WHEN lc_po_endpoint THEN mocked_po_data( )
      WHEN lc_sto_endpoint THEN mocked_sto_data( )
      ELSE '' ).
    client->close(  ).

  ENDMETHOD.

  METHOD mocked_po_data.
    rt_po_mock = '[ ' &&
'{ "orderNumber": 12345679, "material": "FG8888", "quantity": 6400, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&
'{ "orderNumber": 12345680, "material": "FG9999", "quantity": 6400, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&
'{ "orderNumber": 12345681, "material": "FG0000", "quantity": 6400, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&
'{ "orderNumber": 12345682, "material": "FG1111", "quantity": 6400, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&

'{ "orderNumber": 12345683, "material": "FG2222", "quantity": 640, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&
'{ "orderNumber": 12345684, "material": "FG3333", "quantity": 640, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&
'{ "orderNumber": 12345685, "material": "FG4444", "quantity": 640, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&
'{ "orderNumber": 12345686, "material": "FG5555", "quantity": 640, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-02" },' &&

'{ "orderNumber": 12345687, "material": "FG6666", "quantity": 5400, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-11" },' &&

'{ "orderNumber": 12345688, "material": "FG2222", "quantity": 1000, "orderStartDate": "2022-09-01", "orderFinishDate": "2022-09-04" },' &&
'{ "orderNumber": 12345689, "material": "FG0000", "quantity": 6400, "orderStartDate": "2022-08-01", "orderFinishDate": "2022-08-02" },' &&
' ]'.
  ENDMETHOD.

  METHOD mocked_sto_data.
    rt_sto_mock = '[ ' &&
'{ "stoNumber": 12345679, "material": "FG8888", "quantity": 6200, "requirementDate": "2022-09-05", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
'{ "stoNumber": 12345680, "material": "FG9999", "quantity": 6200, "requirementDate": "2022-09-10", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
'{ "stoNumber": 12345681, "material": "FG0000", "quantity": 6200, "requirementDate": "2022-08-26", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
'{ "stoNumber": 12345682, "material": "FG1111", "quantity": 6200, "requirementDate": "2022-10-26", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&

'{ "stoNumber": 12345683, "material": "FG2222", "quantity": 700, "requirementDate": "2022-09-05", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
'{ "stoNumber": 12345684, "material": "FG3333", "quantity": 700, "requirementDate": "2022-09-10", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
'{ "stoNumber": 12345685, "material": "FG4444", "quantity": 700, "requirementDate": "2022-08-26", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
'{ "stoNumber": 12345686, "material": "FG5555", "quantity": 700, "requirementDate": "2022-10-26", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&

'{ "stoNumber": 12345687, "material": "FG6666", "quantity": 5400, "requirementDate": "2022-09-11", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&

'{ "stoNumber": 12345688, "material": "FG2222", "quantity": 400, "requirementDate": "2022-09-06", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
'{ "stoNumber": 12345689, "material": "FG0000", "quantity": 200, "requirementDate": "2022-08-27", "supplyingPlant": "F100", "receivingPlant": "DC01" },' &&
' ]'.
  ENDMETHOD.

ENDCLASS.

