*&---------------------------------------------------------------------*
*& Report ZTA_05_BATCH_PRODUTOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTA_05_BATCH_PRODUTOS.

TABLES: t100.

DATA t_bdc TYPE TABLE OF bdcdata WITH HEADER LINE.
DATA t_mess LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA w_mess TYPE bdcmsgcoll.

* ler conteudo do arquivo (recebo tabela)



PERFORM bdc_dynpro USING    'SAPMZTA0005'  '9000'.
PERFORM bdc_field USING 'BDC_CURSOR' 'WA_PRODUTOS-COD_PROD'.
PERFORM bdc_field USING 'BDC_OKCODE'  '=NEW'.

PERFORM bdc_dynpro USING    'SAPMZTA0005'  '9000'.
PERFORM bdc_field USING 'BDC_CURSOR'  'WA_PRODUTOS-PRECO'.
PERFORM bdc_field USING 'BDC_OKCODE'  '=SAVE'.
PERFORM bdc_field USING 'WA_PRODUTOS-COD_PROD'  '15'.
PERFORM bdc_field USING 'WA_PRODUTOS-NOME_PRODUTO' 'TESTE'.
PERFORM bdc_field USING 'WA_PRODUTOS-PRECO' '99,99'.
PERFORM bdc_dynpro USING    'SAPMZTA0005'  '9000'.
PERFORM bdc_field USING 'BDC_CURSOR'  'WA_PRODUTOS-COD_PROD'.
PERFORM bdc_field USING 'BDC_OKCODE'  '=CANCEL'.


PERFORM call_transaction TABLES t_bdc USING 'ZTA05_ONLINE'.



****************************************************************
* Rotinas para criação da T_BDC
****************************************************************
FORM bdc_dynpro USING program dynpro.
  CLEAR t_bdc.
  t_bdc-program = program.
  t_bdc-dynpro = dynpro.
  t_bdc-dynbegin = 'X'.
  APPEND t_bdc.
ENDFORM.
****************************************************************
FORM bdc_field USING fnam fval.
  IF fval <> ''.
    CLEAR t_bdc.
    t_bdc-fnam = fnam.
*    CONDENSE fval NO-GAPS.
    WRITE fval TO t_bdc-fval.
*    t_bdc-fval = fval.
    APPEND t_bdc.
  ENDIF.
ENDFORM.

**********************************************************************
* FORM CALL_TRANSACTION
**********************************************************************
FORM call_transaction TABLES t_bdc_data USING w_tcode.
  CALL TRANSACTION w_tcode
  USING t_bdc_data MODE 'A' UPDATE 'S' MESSAGES INTO t_mess.
  IF sy-subrc NE 0.
    LOOP AT t_mess.
      PERFORM bdc_message.
      WRITE: / w_mess.
    ENDLOOP.
  ENDIF.
  CLEAR: t_mess, t_bdc.
  REFRESH: t_mess, t_bdc.
ENDFORM. " CALL_TRANSACTION

**********************************************************************
* FORM BDC_MESSAGE
**********************************************************************
FORM bdc_message.

  DATA straux4 TYPE text100.

  CLEAR w_mess.
  SELECT SINGLE * FROM t100
  WHERE sprsl = 'P'
    AND arbgb = t_mess-msgid
   AND msgnr = t_mess-msgnr.
  w_mess = t100-text.
  straux4 = t_mess-msgv1.
  REPLACE '&' WITH straux4 INTO w_mess.
  CONDENSE w_mess.
  straux4 = t_mess-msgv2.
  REPLACE '&' WITH straux4 INTO w_mess.
  CONDENSE w_mess.
  straux4 = t_mess-msgv3.
  REPLACE '&' WITH straux4 INTO w_mess.
  CONDENSE w_mess.
  straux4 = t_mess-msgv4.
  REPLACE '&' WITH straux4 INTO w_mess.
  CONDENSE w_mess.
ENDFORM.