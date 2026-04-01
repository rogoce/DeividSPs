-- Procedimiento para traer inf. de emibenef
-- 
-- creado: 14/01/2004 - Autor: Armando Moreno Montenegro.

DROP PROCEDURE sp_pro136;
CREATE PROCEDURE "informix".sp_pro136(a_no_poliza CHAR(10),a_no_unidad CHAR(5))
RETURNING DEC(5,2),
		  char(10),
		  char(5),
		  char(10),
		  char(3),
		  date,
		  char(50);

define _porc_partic_ben dec(5,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _cod_cliente		char(10);
define _nombre			char(50);
define _cod_parentesco	char(3);
define _benef_desde		date;

foreach
 SELECT porc_partic_ben,
		no_poliza,
		no_unidad,
		cod_cliente,
		cod_parentesco,
		benef_desde,
		nombre
   INTO _porc_partic_ben,
		_no_poliza,
		_no_unidad,
		_cod_cliente,
		_cod_parentesco,
		_benef_desde,
		_nombre
   FROM emibenef
  WHERE no_poliza = a_no_poliza
    AND no_unidad = a_no_unidad


	RETURN _porc_partic_ben,
		   _no_poliza,
		   _no_unidad,
		   _cod_cliente,
		   _cod_parentesco,
		   _benef_desde,
		   _nombre
	  WITH RESUME;   	
end foreach
END PROCEDURE