-- Reimprimir cheque
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_che17;

CREATE PROCEDURE "informix".sp_che17(
a_compania		CHAR(3), 
a_agencia 		CHAR(3), 
a_cod_banco 	CHAR(3), 
a_cod_chequera	CHAR(3), 
a_no_requis 	CHAR(10) DEFAULT '*'
) 

DEFINE _origen_cheque CHAR(1);

 SELECT origen_cheque
   INTO _origen_cheque
   FROM chqchmae
  WHERE cod_compania   = a_compania
    AND cod_sucursal   = a_agencia
	AND autorizado     = 1
	AND pagado         = 1
	AND cod_banco      = a_cod_banco
	AND cod_chequera   = a_cod_chequera
	AND no_requis      MATCHES a_no_requis;

	if a_cod_chequera = "006" then
		UPDATE chqchmae
		   SET pagado          = 0
		 WHERE no_requis       = a_no_requis;
	else	 
		UPDATE chqchmae
		   SET pagado          = 0,	
			   autorizado	   = 0
		 WHERE no_requis       = a_no_requis;
	end if

	IF _origen_cheque = '3' THEN

	 DELETE FROM chqchcta
	  WHERE no_requis = a_no_requis;

	ELIF _origen_cheque = '2' THEN

	 DELETE
	   FROM chqchcta
	  WHERE no_requis   = a_no_requis
	    AND cuenta[1,3] = "122";
	END IF

END PROCEDURE;