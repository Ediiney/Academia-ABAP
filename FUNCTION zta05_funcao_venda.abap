FUNCTION zta05_funcao_venda.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VENDA) TYPE  ZTA05_VENDA_TB
*"  EXPORTING
*"     REFERENCE(E_RETORNO) TYPE  SYST_SUBRC
*"     REFERENCE(E_N_PEDIDO) TYPE  NUMC10
*"----------------------------------------------------------------------
*  DECLARAÇÃO
*"----------------------------------------------------------------------
  TABLES: zta_05_venda,
          zta_05_produtos.

  DATA:
    it_compra TYPE zta05_pdv_tb,
    wa_venda  TYPE zta_05_venda,
    lv_total  TYPE z_valor.

  DATA: gt_venda TYPE zta05_pdv_tb.

*"----------------------------------------------------------------------
*  SELEÇÃO
*"----------------------------------------------------------------------
  IF i_venda[] IS NOT INITIAL.
    SELECT *
        FROM zta_05_produtos
        INTO  TABLE @DATA(it_produto)
        FOR ALL ENTRIES IN @i_venda
        WHERE cod_prod = @i_venda-cod_prod.
  ENDIF.

   SELECT SINGLE MAX( cod_venda )
       INTO @DATA(lv_new_cod_venda)
       FROM zta_05_venda.
       ADD 1 TO lv_new_cod_venda.
"----------------------------------------------------------------------
* LOOP
*"----------------------------------------------------------------------

  SORT it_produto by COD_PROD.

  LOOP  AT i_venda ASSIGNING FIELD-SYMBOL(<lfs_i_venda>).
    MOVE: lv_new_cod_venda TO wa_venda-cod_venda,
          sy-tabix         TO wa_venda-cod_item.
    READ TABLE it_produto ASSIGNING FIELD-SYMBOL(<lfs_it_produto>) WITH KEY cod_prod = <lfs_i_venda>-cod_prod. "binary search
    IF sy-subrc = 0.
      MOVE:  <lfs_it_produto>-cod_prod TO wa_venda-cod_prod,
             <lfs_it_produto>-preco    TO wa_venda-preco,
             <lfs_i_venda>-quantidade  TO wa_venda-quantidade,
             <lfs_i_venda>-cnpj        TO wa_venda-cnpj,
             <lfs_i_venda>-loja        TO wa_venda-loja,
             sy-datum                  TO wa_venda-data,
             sy-uzeit                  TO wa_venda-hora.
      wa_venda-total = <lfs_it_produto>-preco * <lfs_i_venda>-quantidade.

      e_n_pedido = wa_venda-cod_venda.

      e_retorno = sy-subrc.
*      WAIT UP TO 1 SECONDS.

      INSERT INTO zta_05_venda VALUES wa_venda .
    ENDIF.
  ENDLOOP.





ENDFUNCTION.