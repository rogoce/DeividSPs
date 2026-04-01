-- Procedimiento para traer inf. de endbenef
-- 
-- creado: 14/01/2004 - Autor: Armando Moreno Montenegro.

DROP PROCEDURE sp_pro137;
CREATE PROCEDURE "informix".sp_pro137(a_no_poliza CHAR(10),a_no_endoso CHAR(5),a_no_unidad CHAR(5),a_cod_cliente CHAR(10))
RETURNING DEC(5,2),
		  char(10),
		  char(5),
		  char(10),
		  char(3),
		  date,
		  char(5),
		  smallint,
		  char(50);

define _porc_partic_ben dec(5,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_endoso		char(5);
define _cod_cliente		char(10);
define _nombre			char(50);
define _cod_parentesco	char(3);
define _benef_desde		date;
define _opcion          smallint;

foreach
 SELECT no_poliza,
		no_endoso,
		no_unidad,
		cod_cliente,
		cod_parentesco,
		benef_desde,
		porc_partic_ben,
		opcion,
		nombre
   INTO _no_poliza,
		_no_endoso,
		_no_unidad,
		_cod_cliente,
		_cod_parentesco,
		_benef_desde,
		_porc_partic_ben,
		_opcion,
		_nombre
   FROM endbenef
  WHERE no_poliza   = a_no_poliza
	AND no_endoso   = a_no_endoso
    AND no_unidad   = a_no_unidad
    AND cod_cliente = a_cod_cliente

	RETURN _porc_partic_ben,
		   _no_poliza,
		   _no_unidad,
		   _cod_cliente,
		   _cod_parentesco,
		   _benef_desde,
		   _no_endoso,
		   _opcion,
		   _nombre
	  WITH RESUME;   	
end foreach
END PROCEDURE