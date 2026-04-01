-- Procedimiento para crear en PRDSALBIT modo: Insertar
-- Creado    : 10/05/2012 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe67;
CREATE PROCEDURE "informix".sp_proe67(a_poliza char(10),a_unidad char(5),a_prod_new CHAR(5),a_prod_old CHAR(5), a_usuario CHAR(8))
RETURNING SMALLINT, CHAR(50); 
 
define _username	    char(32);
define _no_documento	char(20);
define _fecha_actual	date;
DEFINE _error       	SMALLINT;


let _username = sp_sis84();
let _fecha_actual	= sp_sis26();
-- SET DEBUG FILE TO "sp_proe67.trc";      
-- TRACE ON;   
begin
	select trim(no_documento)
	  into _no_documento
	  from emipomae 
	 where trim(no_poliza) = a_poliza;

	BEGIN
	ON EXCEPTION SET _error 
	 	RETURN _error, "Error al insertar bitacora";         
	END EXCEPTION 
  INSERT INTO prdsalbit  
         ( no_poliza,   
           no_unidad,   
           no_documento,   
           user_added,   
           date_added,   
           producto_actual,   
           product_anterior )  
  VALUES ( a_poliza,   
           a_unidad,   
		   _no_documento,
		   a_usuario,
		   _fecha_actual,
           a_prod_new,
           a_prod_old )  ;
	END
END

RETURN 0, "Actualizacion Exitosa";

END PROCEDURE
