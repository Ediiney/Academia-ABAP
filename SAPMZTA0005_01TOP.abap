*&---------------------------------------------------------------------*
*& Include SAPMZTA0005_01TOP                        - Module Pool      SAPMZTA0005
*&---------------------------------------------------------------------*
PROGRAM sapmzta0005.

MODULE cadastro_produtos OUTPUT.
DATA: wa_produtos TYPE zta_05_produtos,
      gv_okcode   TYPE sy-ucomm,
      wa_prod     TYPE zta_05_produtos,
      it_produtos TYPE TABLE OF zta_05_produtos.
DATA : RESPOSTA TYPE c.
ENDMODULE.