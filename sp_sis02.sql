-- Seleccion del Codigo de la Compania Lider
-- 
-- Creado    : 07/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis02;

CREATE PROCEDURE "informix".sp_sis02(a_compania CHAR(3), a_agencia CHAR(3)) RETURNING CHAR(3);

DEFINE v_cod_coasegur CHAR(3);

LET v_cod_coasegur = NULL;

SELECT par_ase_lider
  INTO v_cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;

{
IF v_cod_coasegur IS NULL THEN
	LET v_cod_coasegur = "36";
END IF
}

RETURN v_cod_coasegur;

END PROCEDURE; 