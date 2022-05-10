FUNCTION Z_TA_05_EXERCICIO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(L_1) TYPE  INT4
*"     REFERENCE(L_2) TYPE  INT4
*"     REFERENCE(L_3) TYPE  INT4
*"  EXPORTING
*"     REFERENCE(RESULT) TYPE  CHAR10
*"----------------------------------------------------------------------
DATA: L2_L3, L1_L3, L1_L2,RETURN TYPE INT4.
L2_L3 = L_2 - L_3.
L1_L3 = L_1 - L_3.
L1_L2 = L_1 - L_2.

IF L2_L3 < L_1.
   RETURN =  L_2 + L_3.
ENDIF.



IF L_1 NE L_2 AND  L_2 NE L_3 AND L_1 NE L_3. "LADOS DIFERENTES
  RESULT = 'ESCALENO'.
ELSEIF L_1 EQ L_2 AND L_2 EQ L_3 AND L_1 EQ L_3. "LADOS IGUAIS
  RESULT = 'EQUILATERO'.
ELSEIF L_1 EQ L_2 OR L_2 EQ L_3 OR L_1 EQ L_3. " 2 LADOS IGUAIS
  RESULT = 'ISOCELES'.
ENDIF.

ENDFUNCTION.