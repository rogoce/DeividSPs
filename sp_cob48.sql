-- Procedimiento que Genera los Tarjeta Habientes

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob48;

CREATE PROCEDURE "informix".sp_cob48()

DEFINE _no_tarjeta       CHAR(19); 
DEFINE _cod_cliente      CHAR(10); 

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob48.trc"; 
--TRACE ON;                                                                

DELETE FROM cobtahab;

-- Procesa Todas las Tarjetas de Credito

FOREACH
 SELECT no_tarjeta,
		cod_cliente
   INTO _no_tarjeta,
		_cod_cliente
   FROM cobtacre
 GROUP BY no_tarjeta, cod_cliente	

	INSERT INTO cobtahab
	VALUES(
	_no_tarjeta,
	_cod_cliente
	);   		   	
END FOREACH

END PROCEDURE;
