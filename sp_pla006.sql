-- Actualizacion de la vacacion en insuser
-- Henry Giron 18/04/2010

drop procedure sp_pla006;

create procedure sp_pla006(a_usuario char(10), a_user char(10), a_fecha_ini date, a_fecha_fin date,a_cod_motivo char(3))
RETURNING SMALLINT, CHAR(30);

define _fecha datetime year to fraction(5);
DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);

BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

let _fecha = current;

update insuser
   set status  = "A",
	   fvac_out	  =	a_fecha_ini,
	   fvac_duein = a_fecha_fin,
	   cod_motivo = a_cod_motivo
 where usuario = a_usuario;

	 let a_fecha_ini = current;
	 let a_fecha_fin = current;
	 let a_cod_motivo = "999";


{if a_fecha_ini is null and a_fecha_fin is null and a_cod_motivo is null then
    -- Correcion de Error de Recurso Humanos se registrara el usuario que realizo la correccion y colocara la fecha en que se realizo en historico.
	update insuser
	   set status  = "A"
     where usuario = a_usuario;

	 let a_fecha_ini = current;
	 let a_fecha_fin = current;

else

	if a_fecha_ini <= _fecha then

		update insuser
		   set status  = "I"
	     where usuario = a_usuario;

	end if

	update insuser
	   set fvac_out	  =	a_fecha_ini,
		   fvac_duein = a_fecha_fin,
		   cod_motivo = a_cod_motivo
	 where usuario    = a_usuario;

end if }

insert into rrhvachi(
usuario,
date_added,
user_added,
fec_vac_ini,
fec_vac_fin,
cod_motivo)
values(
a_usuario,
_fecha,
a_user,
a_fecha_ini,
a_fecha_fin,
a_cod_motivo);


RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure