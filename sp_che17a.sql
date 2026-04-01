-- Reimprimir cheque
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_che17a;

CREATE PROCEDURE "informix".sp_che17a(
a_compania		CHAR(3), 
a_agencia 		CHAR(3), 
a_cod_banco 	CHAR(3), 
a_cod_chequera	CHAR(3), 
a_no_requis 	CHAR(10) DEFAULT '*',
a_no_requis2 	CHAR(10) DEFAULT '*'
) 


DEFINE _origen_cheque CHAR(1);
DEFINE _no_requis     CHAR(10);

foreach
 SELECT origen_cheque,
		no_requis
   INTO _origen_cheque,
		_no_requis
   FROM chqchmae
  WHERE cod_compania   = a_compania
    AND cod_sucursal   = a_agencia
	AND autorizado     = 1
	AND pagado         = 1
	AND cod_banco      = a_cod_banco
	AND cod_chequera   = a_cod_chequera
	AND no_requis      between a_no_requis and a_no_requis2

	UPDATE chqchmae
	   SET pagado          = 0,	
		   autorizado	   = 0
	 WHERE no_requis       = _no_requis;

	IF _origen_cheque = '2' THEN

	 DELETE FROM chqchcta
	  WHERE no_requis = _no_requis
	    AND cuenta    = "122-01-03";

	END IF
end foreach
END PROCEDURE;
