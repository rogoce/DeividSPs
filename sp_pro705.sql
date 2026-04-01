-- Inserta Marca Ducruet
-- Creado    : 10/10/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro705;
CREATE PROCEDURE "informix".sp_pro705(a_cod_marca integer,a_nombre_marca char(30),a_cod_modelo integer,a_nombre_modelo char(30),a_cod_marca_ancon char(5))
       RETURNING  int,char(100);

DEFINE _error         integer;
DEFINE _error_2       integer;
DEFINE _error_desc    char(50);
DEFINE _mensaje       char(100);


-- Adicionar marca sin validacion

SET ISOLATION TO DIRTY READ;
set debug file to "sp_pro705.trc";
trace on;

BEGIN

ON EXCEPTION SET _error, _error_2, _error_desc 
 	RETURN _error, _error_desc;
END EXCEPTION

	if trim(a_cod_marca_ancon) = '' or a_cod_marca_ancon is null then
		LET _mensaje = "Debe seleccionar la marca relacionada a Ancon";
		return 1,_mensaje;
	end if 


	BEGIN
	  ON EXCEPTION IN(-239,-268)

		 update modelos_ducruet
			set nombre_marca  = a_nombre_marca, nombre_modelo  = a_nombre_modelo, cod_marca_ancon = a_cod_marca_ancon
		  where cod_marca = a_cod_marca and cod_modelo = a_cod_modelo;

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
			   a_cod_modelo,   
			   a_nombre_modelo,   
			   a_cod_marca_ancon,   
			   null,   
			   null,   
			   null )  ;   
       END			   

LET _mensaje = "Actualizacion Exitosa ...";

return 0,_mensaje;

END
END PROCEDURE