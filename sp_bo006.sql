-- Procedure que Cambia el Estatus de los Periodos Abiertos a Cerrados

drop procedure sp_bo006;

create procedure sp_bo006()
returning integer,
          char(50);

define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado	smallint;
define _par_periodo_ant		char(7);
define _par_fecha_ant		date;

select emi_periodo_cerrado,
       cob_periodo_cerrado,
	   par_periodo_act
  into _emi_periodo_cerrado,
       _cob_periodo_cerrado,
	   _par_periodo_ant
  from parparam;

if _emi_periodo_cerrado = 1 and
   _cob_periodo_cerrado = 1 then

	let _par_fecha_ant = sp_sis36(_par_periodo_ant);
	let _par_fecha_ant = _par_fecha_ant - 60;

	update parparam
	   set emi_periodo_cerrado = 0,
	       cob_periodo_cerrado = 0,
	       fecha_cierre        = today,
	       par_periodo_act     = emi_periodo,
	       par_periodo_ant     = _par_periodo_ant,
	       par_fecha_ant       = _par_fecha_ant;

	return 0, "Actualizacion Exitosa";

else

	return 1, "Actualizacion Exitosa";

end if

end procedure