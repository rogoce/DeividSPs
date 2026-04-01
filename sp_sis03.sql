-- Seleccion del Contrato de Retencion
-- 
-- Creado    : 07/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis03;

CREATE PROCEDURE "informix".sp_sis03(a_compania CHAR(3), a_agencia CHAR(3)) RETURNING CHAR(5);

DEFINE v_contrato CHAR(5);

LET v_contrato = NULL;

{
SELECT valor_parametro
  INTO _contrato
  FROM inspaag
 WHERE codigo_compania = a_compania
   AND codigo_agencia  = a_agencia
   AND cod_aplicacion  = "PAR"
   AND cod_version     = "02"
   AND codigo_parametro = "contrato_rentencion";
}

IF v_contrato IS NULL THEN
	LET v_contrato = "7";
END IF

RETURN v_contrato;

END PROCEDURE; 