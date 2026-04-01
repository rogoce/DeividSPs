-- Procedure que Valida que se Genere en la tabla de reaseguros los registros
-- con la nueva distribucion de reaseguro para auto

-- Creado    : 01/10/2013 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_rea056;

create procedure "informix".sp_rea056() 
returning integer,
		  char(100);

define _no_endoso		char(5);

define _periodo			char(7);

define _no_registro		char(10);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _no_requis		char(10);

define _no_documento	char(20);

define _fecha			date;

define _renglon			smallint;
define _cantidad		smallint;
define _tipo_registro	smallint;
define _sac_asientos	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_rea056.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, trim(_error_desc) || " " || _no_poliza;
end exception

foreach
 select	tipo_registro,
        fecha,
		periodo,
        no_remesa,
		renglon,
		no_tranrec,
		no_requis,
		no_poliza
   into	_tipo_registro,
        _fecha,
		_periodo,
        _no_remesa,
		_renglon,
		_no_tranrec,
		_no_requis,
		_no_poliza
   from sac999:reacamaut
  where tipo_registro = 4
	and no_requis     = "513094"
--    and no_tranrec    = "1209691"

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _tipo_registro = 2 then -- Cobros

		select count(*)
		  into _cantidad
		  from sac999:reacomp
		 where no_remesa = _no_remesa
		   and renglon   = _renglon;

		if _cantidad = 1 then 

			select sac_asientos
			  into _sac_asientos
			  from sac999:reacomp
			 where no_remesa = _no_remesa
			   and renglon   = _renglon;

			if _sac_asientos = 0 then

				return 1, "No Hay Asientos Para: " || " Remesa " || _no_remesa || " Renglon " || _renglon with resume;  

			else

--				let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');
		
--				insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
--				values(_no_registro, _tipo_registro, _no_poliza, null, _no_remesa, _renglon, null, _no_documento, 0, _fecha, _periodo);	
		
			end if
	
		elif _cantidad = 2 then  

			return 1, "Ya Hay Registro Nuevo Para: " || " Remesa " || _no_remesa || " Renglon " || _renglon with resume;  

		else

			return 1, "No Hay Registro Inicial Para: " || " Remesa " || _no_remesa || " Renglon " || _renglon with resume;  

		end if

	elif _tipo_registro = 3 then -- Reclamos

		select count(*)
		  into _cantidad
		  from sac999:reacomp
		 where no_tranrec = _no_tranrec;

		if _cantidad = 1 then 

			select sac_asientos
			  into _sac_asientos
		      from sac999:reacomp
		     where no_tranrec = _no_tranrec;

			if _sac_asientos = 0 then

				return 1, "No Hay Asientos Para: " || " No Trenrec " || _no_tranrec with resume;  

			else

				let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');

				insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
				values(_no_registro, _tipo_registro, _no_poliza, null, null, null, _no_tranrec, _no_documento, 0, _fecha, _periodo);	

			end if

		elif _cantidad = 2 then  

			return 1, "Ya Hay Registro Nuevo Para: " || " No Trenrec " || _no_tranrec with resume;  

		else

			return 1, "No Hay Registro Inicial Para: " || " No Trenrec " || _no_tranrec with resume;  

		end if

	elif _tipo_registro in (4, 5) then -- Cheques Pagados/Anulados - Devolucion de Primas

		let _tipo_registro = 5;

		select count(*)
		  into _cantidad
		  from sac999:reacomp
		 where no_remesa     = _no_requis
		   and no_poliza     = _no_poliza
		   and tipo_registro = _tipo_registro;

		if _cantidad = 1 then 

			select sac_asientos
			  into _sac_asientos
			  from sac999:reacomp
			 where no_remesa     = _no_requis
			   and no_poliza     = _no_poliza
			   and tipo_registro = _tipo_registro;

			if _sac_asientos = 0 then

				return 1, "No Hay Asientos Para: " || " Requisicion " || _no_requis || " No. Poliza " || _no_poliza with resume;  

			else

				let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');
			
				insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
				values(_no_registro, _tipo_registro, _no_poliza, null, _no_requis, null, null, _no_documento, 0, _fecha, _periodo);	

			end if
					
		elif _cantidad = 2 then  

			return 1, "Ya Hay Registro Para: " || " Requisicion " || _no_requis || " No. Poliza " || _no_poliza with resume;  

		else

			return 1, "No Hay Registro Inicial Para: " || " Requisicion " || _no_requis || " No. Poliza " || _no_poliza with resume;  

		end if

	end if
	
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure