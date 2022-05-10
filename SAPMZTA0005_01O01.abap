*&---------------------------------------------------------------------*
*& Include          SAPMZTA0005_01O01
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& PERFORM
*&---------------------------------------------------------------------*
MODULE PERFORM_SELECT_DADOS OUTPUT.
PERFORM SELECIONA_DADOS.
ENDMODULE.

MODULE ALV_PRODUTOS OUTPUT.
  PERFORM ALV_PRODUTOS.
ENDMODULE.
*&---------------------------------------------------------------------*
*& CHAIN
*&---------------------------------------------------------------------*
MODULE validacao_preenchimento INPUT.
  IF wa_produtos-nome_produto = ''.
    MESSAGE 'Preencha todos os campos Obrigatórios!' TYPE 'E'.
  ELSEIF  wa_produtos-preco < 1.
    MESSAGE 'O valor não pode ser menor que 0,90!' TYPE 'E'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& FORM
*&---------------------------------------------------------------------*
FORM: SELECIONA_DADOS.
IF WA_PRODUTOS-COD_PROD IS INITIAL.
  SELECT *
    FROM ZTA_05_PRODUTOS
    INTO TABLE IT_PRODUTOS.
ELSE.
SELECT SINGLE *
      FROM ZTA_05_PRODUTOS
      INTO  WA_PRODUTOS
      WHERE COD_PROD = WA_PRODUTOS-COD_PROD.
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ALV_PRODUTOS
*&---------------------------------------------------------------------*

FORM ALV_PRODUTOS.

  CONSTANTS c_estrutura TYPE dd02l-tabname VALUE 'ZTA_05_PRODUTOS'.
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        wa_layout   TYPE lvc_s_layo,
        wa_fieldcat TYPE LINE OF lvc_t_fcat.

*Ajusta layout
  wa_layout-zebra      = 'X'.
*  wa_layout-edit       = 'X'.
  wa_layout-no_hgridln = 'X'.
*  wa_layout-sel_mode   = 'C'.
*  wa_layout-box_fname  = 'BOX'.

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
      t_outtab        = it_produtos
    EXCEPTIONS
      program_error   = 1
      OTHERS          = 2.
ENDFORM.