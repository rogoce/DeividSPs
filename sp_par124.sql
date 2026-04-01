-- Procedimiento que Graba el Asiento de la Factura

-- Creado    : 25/10/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/10/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par124;		

CREATE PROCEDURE "informix".sp_par124(
a_no_documento	CHAR(20), 
a_cuenta    	CHAR(25), 
a_debito    	DEC(16,2),
a_credito   	DEC(16,2),
a_tipo_comp		SMALLINT
)

BEGIN
ON EXCEPTION IN(-268)

	UPDATE cobincas
	   SET debito 	    = debito  + a_debito,
	       credito 	    = credito + a_credito
	 WHERE no_documento = a_no_documento
	   AND cod_cuenta 	= a_cuenta;

END EXCEPTION

	INSERT INTO cobincas(
	no_documento,
	cod_cuenta,
	debito,
	credito,
	tipo_comp
	)
	VALUES(
	a_no_documento,
	a_cuenta,
	a_debito,
	a_credito,
	a_tipo_comp
	);

END 

END PROCEDURE;
