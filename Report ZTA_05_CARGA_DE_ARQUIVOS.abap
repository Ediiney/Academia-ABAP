*&---------------------------------------------------------------------*
*& Report ZTA_05_CARGA_DE_ARQUIVOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTA_05_CARGA_DE_ARQUIVOS.
TABLES : zta_05_produtos.
*--------------------------------------------------------------------*
*VARIÁVEIS PARA O POPUP DE SEEÇÃO DE ARQUIVOS
DATA it_files TYPE filetable.
DATA wa_files TYPE file_table.
DATA v_rc     TYPE i.
DATA: it_bdc TYPE TABLE OF bdcdata,
      it_msg TYPE TABLE OF bdcmsgcoll,
      v_modo TYPE c VALUE 'N',
      wa_bdc LIKE LINE OF it_bdc.
*--------------------------------------------------------------------*
*VARIÁVEIS PARA O GUI UPLOAD
DATA lv_file  TYPE string.

*--------------------------------------------------------------------*
*TABELA E WA PARA O GUI UPLOAD
TYPES:BEGIN OF ty_arquivo,
        linha TYPE c LENGTH 2000,
      END OF ty_arquivo,
      BEGIN OF ty_zproduto,
        mandt      TYPE zta_05_produtos-mandt,
        cod_prod TYPE zta_05_produtos-cod_prod,
        nome_produto    TYPE zta_05_produtos-nome_produto,
        preco      TYPE zta_05_produtos-preco,
      END OF ty_zproduto.

DATA: gr_table     TYPE REF TO cl_salv_table.
DATA: gr_functions TYPE REF TO cl_salv_functions_list.
DATA: gr_columns   TYPE REF TO cl_salv_columns_table.
DATA: gr_column    TYPE REF TO cl_salv_column_table.
DATA: gr_select    TYPE REF TO cl_salv_selections.
DATA: gr_events    TYPE REF TO cl_salv_events_table.
DATA: it_saida TYPE TABLE OF ty_zproduto.
DATA: wa_saida TYPE  ty_zproduto.
DATA it_outdata TYPE STANDARD TABLE OF ty_arquivo WITH HEADER LINE.
DATA wa_outdata TYPE ty_arquivo.

*--------------------------------------------------------------------*
*Definição de parametro de seleção
PARAMETERS p_file(1024) TYPE c.

*--------------------------------------------------------------------*
* Evento para ativaro matchcode
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file .

*--------------------------------------------------------------------*
*metodo para exibir o popup de seleção de arquivos
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Abrir...'
      default_extension       = '*.txt|*.csv|*.*'
      file_filter             = ' TXT (*.txt)|*.txt| CSV(*.csv)|*.csv| Todas(*.*)|*.* '
      multiselection          = space
    CHANGING
      file_table              = it_files
      rc                      = v_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
*--------------------------------------------------------------------*
* identifica o arquivo selecionado e joga para o parametro de seleção
    READ TABLE it_files INTO wa_files INDEX 1.
    p_file = wa_files-filename.
  ENDIF.


START-OF-SELECTION.

**Função para fazer upload e jogar para tabela Interna. Neste
*caso o tipo ASC é para arquivos TXT e excel.
*o tipo BIN é para word, pdf.
  lv_file = p_file.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_file
      filetype                = 'ASC'
    TABLES
      data_tab                = it_outdata
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno

        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

END-OF-SELECTION.


  LOOP AT it_outdata INTO wa_outdata.
    FREE :it_bdc.
    DATA: lv_cod TYPE string,
          lv_produto TYPE string,
          lv_valor   TYPE string.
    CLEAR: lv_cod, lv_produto, lv_valor.
*--------------------------------------------------------------------*
*SEPARANDO O TEXTO

    SPLIT wa_outdata AT ';' INTO  lv_cod
                                  lv_produto
                                  lv_valor .

    PERFORM dynpro USING :
          'X' 'SAPMZTA0005'  '9000',
          ' ' 'BDC_CURSOR'  'WA_PRODUTOS-PRECO',
          ' ' 'BDC_OKCODE'  '=NEW',
          'X' 'SAPMZTA0005'  '9000',
          ' ' 'BDC_CURSOR'  'WA_PRODUTOS-PRECO',
          ' ' 'BDC_OKCODE'  '=SAVE',
          ' ' 'WA_PRODUTOS-COD_PROD'  '39',
          ' ' 'WA_PRODUTOS-NOME_PRODUTO' lv_produto,
          ' ' 'WA_PRODUTOS-PRECO'  lv_valor,
          'X' 'SAPMZTA0005'  '9000',
          ' ' 'BDC_CURSOR'  'WA_PRODUTOS-COD_PROD',
          ' ' 'BDC_OKCODE'  '=CANCEL'.


    CALL TRANSACTION 'ZTA05_ONLINE' USING it_bdc
                                  MODE v_modo
                                  MESSAGES INTO it_msg.

    IF sy-subrc EQ 0.
      MESSAGE s010(zdev).
    ELSE.
      MESSAGE e011(zdev).
    ENDIF.
  ENDLOOP.

  PERFORM zseleciona.

FORM dynpro USING p_screen
                  p_field
                  p_value.

  CLEAR wa_bdc.
  IF NOT p_screen IS INITIAL.
    wa_bdc-dynbegin = 'X'.
    wa_bdc-program  = p_field.
    wa_bdc-dynpro   = p_value.
  ELSE.
    wa_bdc-fnam = p_field.
    wa_bdc-fval = p_value.
  ENDIF.
  APPEND wa_bdc TO it_bdc.

ENDFORM.

FORM zseleciona.

  SELECT *
    FROM zta_05_produtos
    INTO TABLE @DATA(it_zproduto).

  LOOP AT it_zproduto ASSIGNING FIELD-SYMBOL(<lfs_zproduto>) .
    MOVE-CORRESPONDING <lfs_zproduto> TO wa_saida.
    APPEND wa_saida TO it_saida.
  ENDLOOP.

*§3 create an ALV table - default is grid display ...
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = gr_table
        CHANGING
          t_table      = it_saida ).

*Events
      gr_events = gr_table->get_event( ).
    CATCH cx_salv_msg.
  ENDTRY.
  TRY.
      gr_columns  = gr_table->get_columns( ).
      gr_columns->set_optimize( abap_true ).
      gr_column   ?= gr_columns->get_column( 'MANDT' ).
      gr_column->set_visible( abap_false ).

    CATCH cx_salv_not_found.

  ENDTRY.

*§4 offer the default set of ALV generic funtions
  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).
  gr_select = gr_table->get_selections( ).
  gr_select->set_selection_mode( 3 ).


*... and display the table
  gr_table->display( ).


ENDFORM.