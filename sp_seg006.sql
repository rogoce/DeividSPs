--- Codigo: Adicion de Creacion de Usuario a INUSCO
--- Creado: Henry Giron 
--- Fecha:  25/08/2010

drop procedure sp_seg006;

create procedure "informix".sp_seg006(a_usuario CHAR(8), a_status CHAR(1), a_fecha_status date)
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);

DEFINE _fecha_status    DATE;
define _usuario			char(8);
define _status			char(1);

DEFINE _codigo_compania	CHAR(3);
define _codigo_agencia	CHAR(3);
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--SET DEBUG FILE TO "sp_seg006.trc"; 
--TRACE ON;
--Actualizacion de Usuarios en INUSCO	-- TODAY

FOREACH
 SELECT codigo_compania,	
 		codigo_agencia	
   INTO _codigo_compania,	
		_codigo_agencia	
   FROM insuser
  WHERE	usuario = a_usuario
    AND status  = a_status

	   if _codigo_compania is null then
		   let _codigo_compania = "001";
	   end if

	BEGIN
	ON EXCEPTION IN(-268)
		LET r_error       = 0;
		LET r_descripcion = 'Actualizacion Exitosa ...';	 
	END EXCEPTION

		INSERT INTO insusco(
		usuario,
		codigo_compania,
		codigo_agencia,
		password,
		status,
		fecha_status
		)
		VALUES(
		a_usuario,
		_codigo_compania,
		_codigo_agencia,	
		'12345678.com',
		'A',
		a_fecha_status 
		);

	END
END FOREACH


RETURN r_error, r_descripcion ;

END

end procedure;

    

  