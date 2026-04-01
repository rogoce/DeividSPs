-- Actualizando los valores de las cartas de Salud en emicartasal
-- Creado    : 12/12/2011 - Autor: Henry Giron.
-- Modificado: 12/12/2011 - Autor: Henry Giron	  copia de sp_pro500
-- SIS v.2.0 -  - DEIVID, S.A.
DROP PROCEDURE sp_pro4942a;
CREATE PROCEDURE sp_pro4942a()
RETURNING smallint, char(25);

DEFINE _error 				smallint; 
DEFINE _no_documento	CHAR(20); 
DEFINE _cod_producto_ant   	CHAR(5);
DEFINE _prima_ant	     DEC(16,2); 
DEFINE _periodo_ant     CHAR(7);


--set debug file to "sp_pro4942.trc";
set lock mode to wait;
BEGIN
ON EXCEPTION SET _error 
 	RETURN _error, "Error al Actualizar"; 
END EXCEPTION 

FOREACH
	select  no_documento,
  			cod_producto_ant,
  			prima_ant,
  			periodo_ant
  into 		_no_documento,	
			_cod_producto_ant,
			_prima_ant,	    
			_periodo_ant     
from emicartasal2_copy

 
UPDATE emicartasal2 
   SET cod_producto_ant = _cod_producto_ant    , 
       prima_ant        = _prima_ant           , 
	   periodo_ant      = _periodo_ant     
 WHERE no_documento  = trim(_no_documento); 

end foreach
END 
RETURN 0,"Proceso Exitoso"; 
END PROCEDURE; 