-- Lectura del Nombre de la Compania
-- 
-- Creado    : 03/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 03/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis01;

CREATE PROCEDURE "informix".sp_sis01(a_compania CHAR(3)) RETURNING CHAR(50);

DEFINE v_compania_nombre CHAR(50);

LET v_compania_nombre = NULL;

SET ISOLATION TO DIRTY READ;

SELECT descr_compania
  INTO v_compania_nombre		
  FROM inscias
 WHERE codigo_compania = a_compania;

IF v_compania_nombre IS NULL THEN
	LET v_compania_nombre = 'Compañia no Definida';
END IF

RETURN TRIM(v_compania_nombre);

END PROCEDURE; 