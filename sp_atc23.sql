-- Ingreso a parmailsend para ser enviado por correo --> CON ANCON SIEMPRE GANAS

-- Amado Perez 25/10/2012


drop procedure sp_atc23;

create procedure sp_atc23(a_no_boleto CHAR(10))
RETURNING integer, VARCHAR(100);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
define _cod_cliente     char(10);
define v_nombre     	varchar(100);


BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set lock mode to wait 60;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_che124.trc"; 
--trace on;

UPDATE atcacbdd	  
   SET ganador = 1
 where no_boleto = a_no_boleto;

RETURN r_error, r_descripcion;

END
end procedure