*&---------------------------------------------------------------------*
*& Report ZTA_05_PDV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTA_05_PDV.
*"----------------------------------------------------------------------
*  DECLARAÇÕES
*"----------------------------------------------------------------------

DATA: it_venda     TYPE TABLE OF ZTA_05_VENDA,
      wa_venda     TYPE ZTA_05_VENDA,
      it_produto   TYPE TABLE OF ZTA_05_PRODUTOS,
      wa_produto   TYPE ZTA_05_PRODUTOS.

DATA: lv_ttotal TYPE Z_VALOR.
*"----------------------------------------------------------------------
*  PARAMETERS
*"----------------------------------------------------------------------
PARAMETERS: P_PEDIDO TYPE ZTA_05_VENDA-COD_VENDA OBLIGATORY.

*"----------------------------------------------------------------------
*  PEFORMS
*"----------------------------------------------------------------------
PERFORM: SELECTION,
         Exibir_Nota.
*"----------------------------------------------------------------------
START-OF-SELECTION.
*"----------------------------------------------------------------------
FORM: SELECTION.

SELECT *
  FROM ZTA_05_VENDA
  INTO TABLE it_venda
  WHERE ZTA_05_VENDA~cod_venda = P_PEDIDO.

  SELECT *
  FROM ZTA_05_PRODUTOS
  INTO TABLE it_produto
  WHERE COD_PROD = ZTA_05_PRODUTOS~COD_PROD.

 ENDFORM.

*"----------------------------------------------------------------------
*  FORMS
*"----------------------------------------------------------------------
FORM: Exibir_Nota.

LOOP AT it_venda INTO wa_venda WHERE cod_venda = p_pedido.
    WRITE:sy-vline,'--------------------------------------------------------------------------------------------------------------------',sy-vline,/
          sy-vline,'                                              ',wa_Venda-CNPJ,'                                                ',sy-vline,/
          sy-vline,'                                              ',wa_Venda-LOJA,'                            ',sy-vline,/.
    WRITE:sy-vline,'--------------------------------------------------------------------------------------------------------------------',sy-vline,/
          sy-vline,'                                      ',  'DATA',  sy-datum, 'HORA', sy-uzeit,/
          sy-vline,'--------------------------------------------------------------------------------------------------------------------',sy-vline,/
          sy-vline,'                                             ',    'CUMPOM DE COMPRA',/
          sy-vline,'--------------------------------------------------------------------------------------------------------------------',sy-vline,/
          sy-vline,'PEDIDO: ',P_PEDIDO,/.

   WRITE:sy-vline,3'ITEM',8 'COD',12'NOME DO PRODUTO',53'UN',74'PREÇO',94'TOTAL                    ',sy-vline,/.

  LOOP AT it_venda INTO wa_venda WHERE cod_venda = p_pedido.
      LOOP AT it_produto INTO wa_produto WHERE COD_PROD = wa_venda-COD_PROD.

    WRITE:sy-vline, wa_venda-COD_item,
                    wa_venda-COD_PROD,
                    wa_produto-NOME_PRODUTO,
                    wa_venda-QUANTIDADE,
                    wa_venda-PRECO,
                    wa_venda-TOTAL,'                  ',sy-vline,/.
                    lv_ttotal = lv_ttotal + wa_venda-TOTAL.

        endloop.
      endloop.
     WRITE:     sy-vline, '---------------------------------------------------------------------------------------------------------------', /.
     WRITE:'                                                TOTAL: R$', lv_ttotal.

  IF wa_venda-cod_venda eq p_pedido.
       stop.
  ENDIF.

endloop.

ENDFORM.