

*&---------------------------------------------------------------------*
*& Report Z_TA05_RANGE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ta05_range.

*-------------------------------------------------------------*
* Declarações
*-------------------------------------------------------------*

RANGES: ra_airlineid FOR zta05_fligh_detail_st-airlineid,
             ra_data FOR zta05_fligh_detail_st-flightdate.


TYPES: BEGIN OF tb_airline,
         carrid   TYPE scarr-carrid,
         carrname TYPE scarr-carrname,
       END OF tb_airline.

TYPES: BEGIN OF tb_spf,
         carrid    TYPE scarr-carrid,
         connid    TYPE spfli-connid,
         countryfr TYPE sgeocity-country,
         cityfrom  TYPE spfli-cityfrom,
         airpfrom  TYPE spfli-airpfrom,
         countryto TYPE sgeocity-country,
         cityto    TYPE sgeocity-city,
         airpto    TYPE sairport-id,
         fltime    TYPE spfli-fltime,
         deptime   TYPE spfli-deptime,
         arrtime   TYPE spfli-arrtime,
         distance  TYPE spfli-distance,
         distid    TYPE spfli-distid,
         fltype    TYPE spfli-fltype,
       END OF tb_spf.

 TYPES: BEGIN OF tb_sfl,
        carrid     TYPE scarr-carrid,
        connid     TYPE spfli-connid,
        FLDATE     TYPE SFLIGHT-FLDATE,
        PRICE      TYPE SFLIGHT-PRICE,
        CURRENCY   TYPE SFLIGHT-CURRENCY,
        PLANETYPE  TYPE SFLIGHT-PLANETYPE,
        SEATSMAX   TYPE SFLIGHT-SEATSMAX,
        SEATSOCC   TYPE SFLIGHT-SEATSOCC,
        PAYMENTSUM TYPE SFLIGHT-PAYMENTSUM,
        SEATSMAX_B TYPE SFLIGHT-SEATSMAX_B,
        SEATSOCC_B TYPE SFLIGHT-SEATSOCC_B,
        SEATSMAX_F TYPE SFLIGHT-SEATSMAX_F,
        SEATSOCC_F TYPE SFLIGHT-SEATSOCC_F,
    END OF tb_sfl.
DATA: w_airlineid  LIKE LINE OF ra_airlineid,
      wa_airlineid TYPE zta05_fligh_detail_st-airlineid,

      w_data       LIKE LINE OF ra_data,
      wa_data      TYPE zta05_fligh_detail_st-flightdate.

DATA: it_spf TYPE TABLE OF tb_spf,
      wa_spf TYPE tb_spf.

DATA: it_airline TYPE TABLE OF tb_airline,
      wa_airline TYPE tb_airline.

DATA: it_sfl TYPE TABLE OF tb_sfl,
      wa_sfl TYPE tb_sfl.

DATA: gl_airline TYPE TABLE OF zta05_airline_st,
      wa_air     TYPE zta05_airline_st.


w_airlineid-sign    = 'I'.
w_airlineid-option  = 'BT'.
w_airlineid-low     = 'AA'.
w_airlineid-high    = 'LH'.
APPEND w_airlineid TO ra_airlineid.

w_data-sign    = 'I'.
w_data-option  = 'BT'.
w_data-low     = '20220501'.
w_data-high    = '20200501'.
APPEND w_data TO ra_data.
*-------------------------------------------------------------*
* PEFORMS
*-------------------------------------------------------------*
START-OF-SELECTION.

PERFORM: select_airline.

END-OF-SELECTION.
PERFORM:      loop_airline.

*------------------------------------------------------------*
* SELECT AND INNER JOIN AND FOR ALL ENTRIES
*-------------------------------------------------------------*


FORM select_airline.
  SELECT carrid
         carrname
    INTO TABLE it_airline
    FROM scarr
    WHERE carrid IN ra_airlineid.

  IF it_airline[] IS NOT INITIAL.

    SELECT  carrid
         connid
         countryfr
         cityfrom
         airpfrom
         countryto
         cityto
         airpto
         fltime
         deptime
         arrtime
         distance
         distid
         fltype
      INTO TABLE it_spf
           FROM spfli
           FOR ALL ENTRIES IN it_airline
      WHERE carrid = it_airline-carrid.

  ENDIF.

SELECT CARRID
       CONNID
       FLDATE
       PRICE
       CURRENCY
       PLANETYPE
       SEATSMAX
       SEATSOCC
       PAYMENTSUM
       SEATSMAX_B
       SEATSOCC_B
       SEATSMAX_F
       SEATSOCC_F
  INTO TABLE it_sfl
  FROM SFLIGHT
  FOR ALL ENTRIES IN it_SPF
  WHERE carrid = it_spf-carrid
  AND CONNID = it_spf-connid.

*SELECT CARRID
*  INTO TABLE tb_airline
*  FROM SFLIGHT
*  FOR ALL ENTRIES IN tb_airline
*  WHERE FLDATE = tb_airline-FLDATE.
ENDFORM.
*SELECT SCAR~CARRID
*       SCAR~CARRNAME
*       SPF~connid
*       SFL~FLDATE
*  INTO TABLE tb_airline
*FROM SCARR AS SCAR
*  INNER JOIN SPFLI AS SPF  ON SPF~carrid     = SCAR~carrid
*  INNER JOIN SFLIGHT AS SFL ON SFL~CARRID    = SCAR~CARRID
*                              AND SFL~connid = SPF~connid
*  where SFL~FLDATE in ra_data.

*SELECT * FROM sflights2
*         INTO TABLE tb_airline
*         WHERE carrid    IN ra_airlineid
*           AND fldate    IN ra_data.

*------------------------------------------------------------*
* LOOP
*-------------------------------------------------------------*
FORM loop_airline.


  LOOP AT it_airline INTO wa_airline.

    LOOP AT it_spf INTO wa_spf WHERE CARRID EQ wa_airline-CARRID.

      LOOP AT it_sfl INTO wa_sfl WHERE CARRID EQ wa_spf-CARRID
                                   AND CONNID EQ wa_spf-CONNID.

    IF sy-subrc EQ 0.
*      BREAK F-ABAP05.
         wa_air-carrid   = wa_airline-carrid.
         wa_air-carrname = wa_airline-carrname.
         wa_air-connid    =  wa_spf-connid.
         wa_air-fldate    =  wa_sfl-fldate.
         wa_air-countryfr =  wa_spf-countryfr.
         wa_air-cityfrom  =  wa_spf-cityfrom.
         wa_air-airpfrom  =  wa_spf-airpfrom.
         wa_air-countryto =  wa_spf-countryto.
         wa_air-cityto    =  wa_spf-cityto.
         wa_air-airpto    =  wa_spf-airpto.
         wa_air-fltime    =  wa_spf-fltime.
         wa_air-deptime   =  wa_spf-deptime.
         wa_air-deptime   =  wa_spf-arrtime.
         wa_air-distance  =  wa_spf-distance.
         wa_air-distid    =  wa_spf-distid.
        wa_air-fltype    =  wa_spf-fltype.


    ENDIF.

    WRITE: / wa_air-carrid,
             wa_air-carrname,
             wa_air-connid,
             wa_air-fldate,
             wa_air-countryfr,
             wa_air-cityfrom,
             wa_air-airpfrom,
             wa_air-countryto,
             wa_air-cityto,
             wa_air-airpto,
             wa_air-fltime,
             wa_air-deptime,
             wa_air-deptime,
             wa_air-distance,
             wa_air-distid,
             wa_air-fltype.
     ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.

*------------------------------------------------------------*
* ALV AIRLINE
*-------------------------------------------------------------*
*
*
*  DATA: lt_fieldcat TYPE lvc_t_fcat,
*        wa_layout   TYPE lvc_s_layo,
*        wa_fieldcat TYPE LINE OF lvc_t_fcat.
*
*  wa_layout-zebra      = 'X'.
*  wa_layout-no_hgridln = 'X'.
*  wa_layout-sel_mode   = 'C'.
*  wa_layout-box_fname  = 'BOX'.
*
*  CONSTANTS c_estrutura TYPE dd02l-tabname VALUE 'ZTA05_AIRLINE_TB'.
*
*  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*    EXPORTING
*     I_BUFFER_ACTIVE  =
*      i_structure_name = c_estrutura
*     I_CLIENT_NEVER_DISPLAY       = 'X'
*     I_BYPASSING_BUFFER           =
*     I_INTERNAL_TABNAME           =
*    CHANGING
*      ct_fieldcat      = lt_fieldcat
*   EXCEPTIONS
*     INCONSISTENT_INTERFACE       = 1
*     PROGRAM_ERROR    = 2
*     OTHERS           = 3
*    .
*  IF sy-subrc <> 0.
* Implement suitable error handling here
*  ENDIF.
*
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
*    EXPORTING
*      is_layout_lvc   = wa_layout
*      it_fieldcat_lvc = lt_fieldcat
*    TABLES
*      t_outtab        = gl_airline
*   EXCEPTIONS
*     PROGRAM_ERROR   = 1
*     OTHERS          = 2
*    .
*  IF sy-subrc <> 0.
* Implement suitable error handling here
*  ENDIF.