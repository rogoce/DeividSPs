-- Procedimiento para insertar emicartasal2
-- Creado    : 10/04/2014 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_end08;
CREATE PROCEDURE "informix".sp_end08(a_poliza CHAR(10),_cod_producto_ant  varchar(10))
			RETURNING   SMALLINT, varchar(20);  -- _error
						

DEFINE _error		        INTEGER;
define _no_documento        varchar(15);
define _prima_ant           dec(16,2);
define _periodo_ant         varchar(7);
define _cantidad            smallint;
define _descripcion         varchar(20);
define _error_int           smallint;

BEGIN

	ON EXCEPTION SET _error,_error_int,_descripcion 
		RETURN _error, _descripcion ;         
	END EXCEPTION

SET ISOLATION TO DIRTY READ;
	--SET DEBUG FILE TO "sp_end08.trc";      
	--TRACE ON;  
	SELECT no_documento, 
		   prima, 
		   periodo
	  into _no_documento,
		   _prima_ant,
		   _periodo_ant
	  FROM emipomae
	 WHERE no_poliza = a_poliza;
	 	   
		select count(*)
		  into _cantidad
		  from emicartasal2
		 where no_documento = _no_documento;
	
	if _cantidad = 0 then 
		INSERT INTO emicartasal2 (no_documento,
								  nombre_cliente,
								  fecha_aniv,
								  nombre_agente, 
								  cod_grupo,
								  cod_producto_ant,   
								  prima_ant,   
								  periodo_ant )  
						VALUES ( _no_documento,
						         " ",
								 " 01/01/2000",
								 " ",
								 " ",
								 _cod_producto_ant,   
								 _prima_ant,   
								 _periodo_ant);
	else
		update emicartasal2
		   set nombre_cliente        = " ",   
			   fecha_aniv            = " 01/01/2000",
			   nombre_agente         = " ", 
			   cod_grupo             = " ",
			   cod_producto_ant      = _cod_producto_ant,
			   prima_ant             = _prima_ant,   
			   periodo_ant           = _periodo_ant
		 where no_documento          = _no_documento;
	end if
RETURN 0," exito";
END
END PROCEDURE;