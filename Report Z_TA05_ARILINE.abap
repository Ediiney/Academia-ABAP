
*&---------------------------------------------------------------------*
*& Report Z_TA05_ARILINE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT z_ta05_ariline.

*-------------------------------------------------------------*
* Declarações Structure: zbapisfldat, bapiret2
*-------------------------------------------------------------*

TABLES: bapisflkey, bapisfldra.

DATA: gt_flight_list TYPE TABLE OF zbapisfldat,
      wa_flight_list TYPE zbapisfldat,

      gt_flight_det  TYPE TABLE OF bapisfladd,
      wa_flight_det  TYPE bapisfladd,

      gt_return      TYPE TABLE OF bapiret2,
      wa_return      TYPE bapiret2,

      gt_details TYPE TABLE OF ZTA05_FLIGH_DETAIL_ST,
      wa_details     TYPE ZTA05_FLIGH_DETAIL_ST.





*-------------------------------------------------------------*
* SELECT-OPTIONS  SCREEN 1
*-------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK screen1 WITH FRAME.
PARAMETERS: p_id TYPE bapisflkey-airlineid .

SELECT-OPTIONS s_date FOR bapisfldra-low MODIF ID s1.

SELECTION-SCREEN END OF BLOCK screen1.

*-------------------------------------------------------------*
* SELECT-OPTIONS  radio
*-------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK screen2 WITH FRAME.

PARAMETERS: lista    RADIOBUTTON GROUP rad
            USER-COMMAND invisible DEFAULT 'X',
            detalhes RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK screen2.

*-------------------------------------------------------------*
* PERFORMS
*-------------------------------------------------------------*


*-------------------------------------------------------------*
START-OF-SELECTION.
*-------------------------------------------------------------*
  PERFORM: select_dados,
           get_detail,
           exibir_details_alv.

*-------------------------------------------------------------*
END-OF-SELECTION.
*-------------------------------------------------------------*
  PERFORM:  exibe_lista_alv.

*-------------------------------------------------------------*
* PERFORMS Visible  and invisible
*-------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  PERFORM visible_invisible.

FORM visible_invisible .

  LOOP AT SCREEN.
    IF lista = 'X'.

      IF screen-group1 = 'S2'.
        screen-invisible = 1.
        screen-input     = 0.
        screen-active    = 0.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.

      IF screen-group1 = 'S1'.
        screen-invisible = 0.
        screen-input     = 1.
        screen-active    = 1.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.

    ELSE.

      IF screen-group1 = 'S1'.
        screen-invisible = 1.
        screen-input     = 0.
        screen-active    = 0.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.


      IF screen-group1 = 'S2'.
        screen-invisible = 0.
        screen-input     = 1.
        screen-active    = 1.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

*-------------------------------------------------------------*
* FORM SELECT_DADOS.
*-------------------------------------------------------------*
FORM select_dados.
  CALL FUNCTION 'BAPI_FLIGHT_GETLIST'
    EXPORTING
      airline     = p_id
    TABLES
      date_range  = s_date
      flight_list = gt_flight_list
      return      = gt_return.

ENDFORM.

*-------------------------------------------------------------*
* FORM GET_DETAIL
*-------------------------------------------------------------*
FORM get_detail.

  DATA wa_additional_info TYPE bapisfladd.



  CHECK detalhes = 'X'.

  LOOP AT gt_flight_list INTO wa_flight_list.

    CALL FUNCTION 'BAPI_FLIGHT_GETDETAIL'
      EXPORTING
        airlineid       = wa_flight_list-airlineid
        connectionid    = wa_flight_list-connectid
        flightdate      = wa_flight_list-flightdate
      IMPORTING
*       FLIGHT_DATA     =
        additional_info = wa_additional_info.
*       AVAILIBILITY    =
* TABLES
*     EXTENSION_IN    =
*     EXTENSION_OUT   =
*     RETURN          =

*--->


  Move:wa_flight_list-airlineid             to wa_details-airlineid.
  Move:wa_flight_list-connectid             to wa_details-connectionid.
  Move:wa_flight_list-flightdate            to wa_details-flightate.
  Move-CORRESPONDING wa_additional_info to wa_details.
  Append wa_details to gt_details.

  ENDLOOP.
ENDFORM.

*-------------------------------------------------------------*
* FORM exibe_lista_alv
*-------------------------------------------------------------*
FORM exibe_lista_alv.

  CONSTANTS c_estrutura TYPE dd02l-tabname VALUE 'BAPISFLDAT'.
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        wa_layout   TYPE lvc_s_layo,
        wa_fieldcat TYPE LINE OF lvc_t_fcat.

*Ajusta layout
  wa_layout-zebra      = 'X'.
*  wa_layout-edit       = 'X'.
  wa_layout-no_hgridln = 'X'.
  wa_layout-sel_mode   = 'C'.
  wa_layout-box_fname  = 'BOX'.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = c_estrutura
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

* Exibe report
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     i_callback_program       = sy-repid
      is_layout_lvc   = wa_layout
*     i_callback_pf_status_set = 'F_SET_PF_STATUS'
*     i_callback_user_command  = 'F_USER_COMMAND'
      it_fieldcat_lvc = lt_fieldcat
    TABLES
      t_outtab        = gt_flight_list
    EXCEPTIONS
      program_error   = 1
      OTHERS          = 2.
ENDFORM.

*-------------------------------------------------------------*
*FORM DETAIL_alv.
*-------------------------------------------------------------*

Form exibir_details_alv.
  CONSTANTS c_table2 TYPE dd02l-tabname VALUE 'ZTA05_FLIGH_DETAIL_ST'.

  DATA: lt_fieldcat TYPE lvc_t_fcat, " lvc_t_fcat : Um tipo tabela de uma estrutura"
        wa_layout   TYPE lvc_s_layo, " Jogando os componentes standard  da estrutura em uma work area para podermos modificar o layout da nossa alv "
        wa_fieldcat TYPE LINE OF lvc_t_fcat. " a work area fieldcat do tipo linha da tabela (pega a estrutura) "
*Read table gt_details ASSIGNING FIELD-SYMBOL(<lfs_details>) index 1.

*    Ajusta layout
  wa_layout-zebra      = 'X'. " Definindo um layout zebra na nossa alv, com a wa que definimos logo acima "
*  wa_layout-edit       = 'X'.
*  wa_layout-no_hgridln = 'X'.
*
*  wa_layout-sel_mode   = 'C'.
*  wa_layout-box_fname  = 'BOX'.

* Obtém estrutura do report
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE' " Chamando a função "
    EXPORTING
      i_structure_name       = c_table2 " Estou exportando essa estrutura com os dados da c_table para a função"
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
*    PERFORM ajusta_fieldcat TABLES lt_fieldcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     i_callback_program       = sy-repid
      is_layout_lvc   = wa_layout
*     i_callback_pf_status_set = 'F_SET_PF_STATUS'
*     i_callback_user_command  = 'F_USER_COMMAND'
      it_fieldcat_lvc = lt_fieldcat " lt_fieldcat : Estrutura do relatório como se fosse o esqueleto e o gt_flight_list é o corpo"
    TABLES
      t_outtab        = gt_details " gt_flight_list Dados do relatório"
    EXCEPTIONS
      program_error   = 1
      OTHERS          = 2.

IF sy-subrc = 0.
ENDIF.



  ENDFORM.
"-------------------------------------------------------------*

*-------------------------------------------------------------*
* FORM LIST_AIRLINE.
*-------------------------------------------------------------*

FORM list_airline.

  DATA: lv_total    TYPE bapisfldat-price,
        lv_id       TYPE bapisfldat-airline,
        lv_subtotal TYPE bapisfldat-price.

  WRITE:/
              sy-vline, 2 'ID',
           7   sy-vline, 9 'Line',
          20  sy-vline, 22'ConID',
          27  sy-vline, 28 'Flightdate',
          40  sy-vline, 42 'ArP',
          46  sy-vline, 52 'CityFrom',
          69  sy-vline, 70 'ArP',
           75  sy-vline, 76 'CityTo',
          98  sy-vline, 99 'DepTime',
          109 sy-vline, 110 'ArTime',
           120 sy-vline, 121'ArDate',
          133 sy-vline, 134 'Price',
          166 sy-vline, 167 'Curr',
           174 sy-vline, 175 'Curr', sy-vline,
          sy-uline.

  LOOP AT gt_flight_list INTO wa_flight_list.

    lv_total = lv_total + wa_flight_list-price.

    WRITE:/  sy-vline, wa_flight_list-airlineid,
              sy-vline, wa_flight_list-airline(10),
              sy-vline, wa_flight_list-connectid,
              sy-vline, wa_flight_list-flightdate,
              sy-vline, wa_flight_list-airportfr,
              sy-vline, wa_flight_list-cityfrom,
              sy-vline, wa_flight_list-airportto,
              sy-vline, wa_flight_list-cityto,
              sy-vline, wa_flight_list-deptime,
              sy-vline, wa_flight_list-arrtime,
              sy-vline, wa_flight_list-arrdate,
              sy-vline, wa_flight_list-price,
              sy-vline, wa_flight_list-curr,
              sy-vline, wa_flight_list-curr_iso,
             sy-vline.

  ENDLOOP.

  WRITE: sy-uline(55), sy-vline, 'Total:', lv_total, sy-vline, sy-uline(55).

ENDFORM.