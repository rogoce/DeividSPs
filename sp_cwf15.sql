-- Procedimiento para buscar la segunda firma en el webservices
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

DROP PROCEDURE sp_cwf15;
CREATE PROCEDURE "informix".sp_cwf15(a_requis CHAR(10)) 
			RETURNING DEC(16,2), VARCHAR(20), CHAR(3), CHAR(3), CHAR(1);  

DEFINE _firma1 VARCHAR(20);
DEFINE _monto  DEC(16,2);
DEFINE _cod_banco    CHAR(3);
DEFINE _cod_chequera CHAR(3);
DEFINE _letra        CHAR(1);

SET ISOLATION TO DIRTY READ;


SELECT monto, 
       firma1,
	   cod_banco,
	   cod_chequera
  INTO _monto,
       _firma1,
	   _cod_banco,   
	   _cod_chequera
  FROM chqchmae 
WHERE no_requis = a_requis;

 IF _firma1 IS NULL THEN
	LET _firma1 = "";
 END IF

IF TRIM(_firma1) <> "" THEN
	SELECT tipo_firma
	  INTO _letra
	  FROM wf_firmas 
	WHERE windows_user = _firma1;

	IF _letra IS NULL THEN
		LET _letra = "";
	END IF
ELSE
	LET _letra = "";
END IF

 RETURN _monto, TRIM(_firma1), _cod_banco, _cod_chequera, _letra;
END PROCEDURE