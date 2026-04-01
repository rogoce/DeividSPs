-- Procedimiento para traer a los corredores
--
-- Creado    : 07/05/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 07/05/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_rec32a;

CREATE PROCEDURE "informix".sp_rec32a(a_reclamo CHAR(10))
  RETURNING   CHAR(100);

  DEFINE v_corredor  CHAR(100);
  DEFINE _no_poliza  CHAR(10);
  DEFINE _cod_agente CHAR(5);
  DEFINE _nombre     CHAR(50);
  DEFINE _cont       SMALLINT;

  SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec32a.trc"; 
--trace on;

  let a_reclamo = a_reclamo;

  SELECT no_poliza
    INTO _no_poliza
	FROM recrcmae 
   WHERE no_reclamo = a_reclamo;

  LET v_corredor = '';
  LET _cont = 0;

  FOREACH
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza

	SELECT nombre
	  INTO _nombre
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	LET _cont = _cont + 1;

	IF 	_cont =  1 THEN
		LET v_corredor = TRIM(_nombre);
	ELSE
    	LET v_corredor = TRIM(v_corredor)||" / "|| TRIM(_nombre);
	END IF
  END FOREACH

   				 
 RETURN trim(v_corredor);
END PROCEDURE
