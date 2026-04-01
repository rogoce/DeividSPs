
drop procedure ap_inserta_fecha;
create procedure "informix".ap_inserta_fecha()
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error,i       	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _no_remesa, _recibo_old, _recibo_new   CHAR(10);
DEFINE _fecha           date;  

BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';


let _fecha = current;

for i = 1 to 700

   insert into cobfectar
   values(_fecha,0);

   let _fecha = _fecha + 1;

end for

RETURN r_error, r_descripcion ;

END

end procedure;
