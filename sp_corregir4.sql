-- Procedure que carga las polizas perdida total para su cancalacion

-- Creado: 16/01/2009 - Autor: Demetrio Hurtado Almanza

drop procedure sp_corregir4;

create procedure sp_corregir4()
returning integer,
          char(50);

define _no_reclamo		char(10);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _fecha_perdida	date;
define _no_documento	char(20);
define _cantidad		smallint;
define _user_added		char(10);
define _cod_ramo 		char(3);
define _ramo_sis		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
	select no_reclamo,
	       fecha,
		   user_added
	  into _no_reclamo,
	       _fecha_perdida,
		   _user_added
	  from rectrmae
	 where actualizado = 1
	   and perd_total  = 1
	   and periodo[1,4] = "2009"

	select no_poliza,
	       no_unidad
	  into _no_poliza,
	  	   _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	  
	select no_documento,
	       cod_ramo
	  into _no_documento,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 1 then -- Automovil

		select count(*)
		  into _cantidad
		  from recpolpe
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _cantidad = 0 then

			insert into recpolpe(
			no_poliza,
			no_unidad,
			no_documento,
			procesada,
			cancelada,
			motivo,
			fecha_perdida,
			fecha_cancelada,
			fecha_procesada,
			user_added,
			no_factura
			)
			values(
			_no_poliza,
			_no_unidad,
			_no_documento,
			0,
			0,
			"",
			_fecha_perdida,
			null,
			null,
			_user_added,
			null
			);

		else

		   {	update recpolpe
			   set no_documento    = _no_documento,
			       procesada       = 0,
			       cancelada       = 0,
				   motivo          = "",
				   fecha_perdida   = _fecha_perdida,
				   fecha_cancelada = null,
				   fecha_procesada = null,
				   user_added      = _user_added,
				   no_factura	   = null
		     where no_poliza       = _no_poliza
		       and no_unidad       = _no_unidad;}

		end if

	end if
end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure


