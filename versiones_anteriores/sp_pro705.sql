-- Inserta Marca Ducruet
-- Creado    : 10/10/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro705;
CREATE PROCEDURE "informix".sp_pro705(a_cod_marca integer,a_nombre_marca char(30))
       RETURNING  int,char(100);

DEFINE _error         integer;
DEFINE _error_2       integer;
DEFINE _error_desc    char(50);
DEFINE _mensaje       char(100);

LET _cod_cliente  = null;
LET _cod_cobrador = null;
let _fecha_hoy    = current;

-- Adicionar marca sin validacion

SET ISOLATION TO DIRTY READ;
BEGIN

ON EXCEPTION SET _error, _error_2, _error_desc 
 	RETURN _error, _error_desc;
END EXCEPTION



	BEGIN
	  ON EXCEPTION IN(-239,-268)

		 update modelos_ducruet
			set nombre_marca  = a_nombre_marca
		  where cod_marca = a_cod_marca;

	  END EXCEPTION

	  INSERT INTO modelos_ducruet  
			 ( cod_marca,   
			   nombre_marca,   
			   cod_modelo,   
			   nombre_modelo,   
			   cod_marca_ancon,   
			   nombre_marca_ancon,   
			   cod_modelo_ancon,   
			   nombre_modelo_ancon )  
	  VALUES ( a_cod_marca,   
			   a_nombre_marca,   
			   null,   
			   null,   
			   null,   
			   null,   
			   null,   
			   null )  ;   
       END			   

LET _mensaje = "Actualizacion Exitosa ...";

return 0,_mensaje;

END
END PROCEDURE