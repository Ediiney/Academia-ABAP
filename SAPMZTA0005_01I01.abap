*&---------------------------------------------------------------------*
*& Include          SAPMZTA0005_01I01
*&---------------------------------------------------------------------*
MODULE user_command_9000.

  CASE gv_okcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.

    WHEN 'NEW'.
      CLEAR wa_produtos.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZTA05R'
        IMPORTING
          number      = wa_produtos-cod_prod.
*&---------------------------------------------------------------------*
*& TABLE
*&---------------------------------------------------------------------*
      WHEN 'TABLE'.
         PERFORM ALV_PRODUTOS.
*&---------------------------------------------------------------------*
*& DELETE
*&---------------------------------------------------------------------*
    WHEN 'DELETE'.
      CLEAR RESPOSTA.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR              = 'Confirmar'
            TEXT_QUESTION         = 'Deseja confirmar a alteração?'
            TEXT_BUTTON_1         = 'Sim'
            TEXT_BUTTON_2         = 'Não'
            DEFAULT_BUTTON        = '2'
            DISPLAY_CANCEL_BUTTON = ' '
          IMPORTING
            ANSWER                = RESPOSTA
          EXCEPTIONS
            TEXT_NOT_FOUND        = 1
            OTHERS                = 2.
          IF RESPOSTA = '2'.
           EXIT.
           ENDIF.
       IF WA_PRODUTOS-COD_PROD EQ WA_PRODUTOS-COD_PROD.
        DELETE FROM ZTA_05_PRODUTOS WHERE COD_PROD = WA_PRODUTOS-COD_PROD.
        MESSAGE 'PRODUTO EXCLUIDO COM SUCESSO' TYPE 'I'.
       ELSE.
        MESSAGE 'PRODUTO NÃO EXISTENTE' TYPE 'E'.
       ENDIF.
      CLEAR wa_produtos.
*&---------------------------------------------------------------------*
*& SEARCH
*&---------------------------------------------------------------------*
     WHEN 'SEARCH'.
*       PERFORM SELECIONA_DADOS.
*       IF SY-SUBRC = 0.
*       ELSE.
*         MESSAGE 'PRODUTO NÃO CADASTRADO' TYPE 'W'.
*       ENDIF.
      LEAVE TO SCREEN 9001.
*&---------------------------------------------------------------------*
*& EDIT
*&---------------------------------------------------------------------*
     WHEN 'EDIT'.
      MODIFY ZTA_05_PRODUTOS FROM WA_PRODUTOS.
      IF SY-SUBRC = 0.
      MESSAGE 'PRODUTO ALTERADO COM SUCESSO!' TYPE 'I'.
      ENDIF.
      CLEAR wa_produtos.
*&---------------------------------------------------------------------*
*& SAVE
*&---------------------------------------------------------------------*
     WHEN 'SAVE'.
      INSERT zta_05_produtos FROM  wa_produtos.
      MESSAGE i007(zdev).
      IF SY-SUBRC = 0.
        CLEAR WA_PRODUTOS.
      ENDIF.
  ENDCASE.

ENDMODULE.

MODULE user_command_9001.
  CASE gv_okcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 9000.

    WHEN 'NEW'.
      CLEAR wa_produtos.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZTA05R'
        IMPORTING
          number      = wa_produtos-cod_prod.
*&---------------------------------------------------------------------*
*& TABLE
*&---------------------------------------------------------------------*
      WHEN 'TABLE'.
         PERFORM ALV_PRODUTOS.
*&---------------------------------------------------------------------*
*& SEARCH
*&---------------------------------------------------------------------*
      WHEN 'SEARCH'.
         PERFORM SELECIONA_DADOS.
         IF SY-SUBRC = 0.
           ELSE.
              MESSAGE 'PRODUTO NÃO CADASTRADO' TYPE 'W'.
          ENDIF.
 ENDCASE.
ENDMODULE.