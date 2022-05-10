*&---------------------------------------------------------------------*
*& Report Z_TA05_MATRICULAS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT Z_TA05_MATRICULAS.

*-------------------------------------------------------------*
* Declarações
*-------------------------------------------------------------*

TYPES: BEGIN OF ty_Matricula,
         disciplina TYPE ZDISCIPLINA,
         curso TYPE ZNAMECURSO,
         semestre TYPE ZSEMESTRE,
       END OF ty_Matricula.
DATA: gt_matriculas TYPE TABLE OF ty_Matricula,
      wa_matriculas TYPE ty_Matricula.

*-------------------------------------------------------------*
* PARAMETERS AND PERFORMS
*-------------------------------------------------------------*

PARAMETERS: p_search TYPE char40.
PERFORM: SELECIONA_DADOS,  PREENCHIMENTO_TABELA.

*-------------------------------------------------------------*
* FORM seleciona_dados
*-------------------------------------------------------------*

FORM SELECIONA_DADOS.
SELECT A~NAMEDISCIPLINA B~NAMECURSO B~SEMESTRE
  INTO TABLE gt_matriculas
  FROM ZTA05_GRADE AS G
  INNER JOIN ZTA05_CURSO AS B ON G~FK_CURSO = B~CODCURSO
  INNER JOIN ZTA05_DISCIPLINA AS A ON G~FK_DISCIPLINA = A~CODDISCI
  WHERE NAMECURSO = p_search.
ENDFORM.

*-------------------------------------------------------------*
* FORM PREENCHIMENTO_TABELA.
*-------------------------------------------------------------*

FORM PREENCHIMENTO_TABELA.
  LOOP AT gt_matriculas INTO wa_matriculas.
  CHECK wa_matriculas CS p_search.
  WRITE: wa_matriculas-disciplina,
         wa_matriculas-curso,
         wa_matriculas-semestre,
         /.
  ENDLOOP.
ENDFORM.