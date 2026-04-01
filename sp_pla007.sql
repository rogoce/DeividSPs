-- Eliminar usuario de INSUSER
-- Henry Giron 04/05/2010
-- NO SE PUEDE ELIMINAR REGISTRO DE INSUSER...SOLICITUD: SR. DEMETRIO 05/05/2011

drop procedure sp_pla007;

create procedure sp_pla007(a_usuario char(10), a_user char(10), a_fecha date)
RETURNING SMALLINT, CHAR(30);

define _fecha datetime year to fraction(5);
DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _encontro        SMALLINT;

BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

--set debug file to "sp_pla007.trc";
--trace on;

return 1,'NO UTILIZAR' WITH RESUME;

LET _encontro     = 0;
LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

let _fecha = current;
let a_fecha = current;

insert into hisdeluser (usuario,fecha_delete,usuario_delete)
values (a_user,a_fecha,a_usuario);

select count(*) into _encontro from deivid:hisuser where usuario = a_usuario;
if _encontro > 0 then
	Delete from deivid:hisuser where usuario = a_usuario;
end if

select count(*) into _encontro from deivid:cambio_user where usuario = a_usuario;
if _encontro > 0 then
	Delete from deivid:cambio_user where usuario = a_usuario;
end if

select count(*) into _encontro from segv05:insusco where usuario = a_usuario;
if _encontro > 0 then
	Delete from segv05:insusco where usuario = a_usuario;
end if

select count(*) into _encontro from segv05:insuser where usuario = a_usuario;
if _encontro > 0 then
	Delete from segv05:insuser where usuario = a_usuario;
end if

RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure