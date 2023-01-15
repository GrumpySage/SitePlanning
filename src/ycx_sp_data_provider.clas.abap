CLASS ycx_sp_data_provider DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: mv_error_message TYPE string.

    METHODS:
      constructor
        IMPORTING iv_error_message TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ycx_sp_data_provider IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( ).
    mv_error_message = iv_error_message.

  ENDMETHOD.

ENDCLASS.
