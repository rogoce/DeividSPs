-- Procedure que carga la tabla pivote para validacion

-- Creado    : 01/10/2013 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_rea057;

create procedure "informix".sp_rea057()
returning integer,
          char(50);

define _no_poliza	char(10);
define _no_remesa	char(10);
define _renglon		smallint;
define _no_tranrec	char(10);
define _no_requis	char(10);

define _periodo		char(7);
define _fecha		date;
define _cantidad	smallint;
define _procesados	smallint;

define _periodo_act	char(7);
define _fecha_act	date;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_rea057.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, trim(_error_desc) || " " || _no_poliza;
end exception

delete from sac999:reacamaut;
		
let _procesados = 0;

--{
foreach
 select no_requis,
        no_poliza
   into	_no_requis,
        _no_poliza
   from camchqreaco

	let _procesados = _procesados + 1;

	select fecha_impresion
	  into _fecha
	  from chqchmae
	 where no_requis = _no_requis;

	let _periodo = sp_sis39(_fecha);

	if _periodo > "2013-09" then

		let _periodo_act = _periodo;
		let _fecha_act   = _fecha;

	else

		let _periodo_act = "2013-09";
		let _fecha_act   = "30/09/2013";

	end if

	select count(*)
	  into _cantidad
	  from sac999:reacamaut
	 where no_requis     = _no_requis
	   and no_poliza     = _no_poliza
	   and tipo_registro = 4;

	if _cantidad = 0 then

		select max(secuencia)
		  into _cantidad
		  from sac999:reacamaut
		 where no_poliza = _no_poliza;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		let _cantidad = _cantidad + 1;

		insert into sac999:reacamaut (no_poliza, secuencia, no_remesa, renglon, no_tranrec, no_requis, tipo_registro, fecha, periodo)
		values (_no_poliza, _cantidad, null, null, null, _no_requis, 4, _fecha_act, _periodo_act);

	end if

end foreach
--}

{
foreach
 select no_tranrec,
        no_poliza
   into	_no_tranrec,
        _no_poliza
   from camrecreaco
  where no_tranrec is not null

	let _procesados = _procesados + 1;

	select periodo,
	       fecha
	  into _periodo,
	       _fecha
	  from rectrmae
	 where no_tranrec = _no_tranrec;

	if _periodo > "2013-09" then

		let _periodo_act = _periodo;
		let _fecha_act   = _fecha;

	else

		let _periodo_act = "2013-09";
		let _fecha_act   = "30/09/2013";

	end if

	select count(*)
	  into _cantidad
	  from sac999:reacamaut
	 where no_tranrec = _no_tranrec;

	if _cantidad = 0 then

		select max(secuencia)
		  into _cantidad
		  from sac999:reacamaut
		 where no_poliza = _no_poliza;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		let _cantidad = _cantidad + 1;

		insert into sac999:reacamaut (no_poliza, secuencia, no_remesa, renglon, no_tranrec, no_requis, tipo_registro, fecha, periodo)
		values (_no_poliza, _cantidad, null, null, _no_tranrec, null, 3, _fecha_act, _periodo_act);

	end if

--	if _procesados >= 250 then
--		exit foreach;
--	end if

end foreach
--}

{ 	 
foreach 
 select no_poliza,
        no_remesa,
		renglon
   into _no_poliza,
        _no_remesa,
		_renglon
   from camcobreaco

	let _procesados = _procesados + 1;

	select periodo,
	       fecha
	  into _periodo,
	       _fecha
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _periodo > "2013-09" then

		let _periodo_act = _periodo;
		let _fecha_act   = _fecha;

	else

		let _periodo_act = "2013-09";
		let _fecha_act   = "30/09/2013";

	end if
	
	select count(*)
	  into _cantidad
	  from sac999:reacamaut
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _cantidad = 0 then

		select max(secuencia)
		  into _cantidad
		  from sac999:reacamaut
		 where no_poliza = _no_poliza;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		let _cantidad = _cantidad + 1;

		insert into sac999:reacamaut (no_poliza, secuencia, no_remesa, renglon, no_tranrec, no_requis, tipo_registro, fecha, periodo)
		values (_no_poliza, _cantidad, _no_remesa, _renglon, null, null, 2, _fecha_act, _periodo_act);

	end if

end foreach
}

--{

	{
	foreach
	 select c.no_requis
	   into	_no_requis
	   from chqchmae c, chqchpol p
	  where c.no_requis        = p.no_requis
	    and p.no_poliza        = _no_poliza
        and c.origen_cheque    = "6"
		and c.fecha_anulado   >= _fecha
		and c.pagado           = 1
		and c.anulado          = 1

		select count(*)
		  into _cantidad
		  from sac999:reacamaut
		 where no_requis     = _no_requis
		   and no_poliza     = _no_poliza
		   and tipo_registro = 5;

		if _cantidad = 0 then

			select max(secuencia)
			  into _cantidad
			  from sac999:reacamaut
			 where no_poliza = _no_poliza;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			let _cantidad = _cantidad + 1;

			insert into sac999:reacamaut (no_poliza, secuencia, no_remesa, renglon, no_tranrec, no_requis, tipo_registro, fecha, periodo)
			values (_no_poliza, _cantidad, null, null, null, _no_requis, 5, _fecha_act, _periodo_act);

		end if

	end foreach
	}


end

return _procesados, " Registros Procesados, Actualizacion Exitosa";

end procedure
