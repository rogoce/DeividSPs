-- Reporte de los Siniestros por Causa

-- Creado    : 03/07/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec213;

create procedure "informix".sp_rec213(a_ano char(4)) 
returning smallint,
          char(50);

define _periodo		char(7);
define _periodo_ant	char(7);
define _mes			smallint;

define _error		smallint;
define _error_desc	char(50);

select rec_periodo_ant
  into _periodo_ant
  from parparam;

for _mes = 1 to 12

	if _mes < 10 then

		let _periodo = a_ano || "-0" || _mes;
					   
	else

		let _periodo = a_ano || "-" || _mes;

	end if

	delete from recsincau where periodo = _periodo;

	if _periodo <= _periodo_ant then

		call sp_rec208(_periodo) returning _error, _error_desc;
		 
		if _error <> 0 then

			return _error, _error_desc;

		else

			return 1, " Periodo " || _periodo with resume;

		end if

	end if

end for

return 0, "Actualizacion Exitosa";

end procedure