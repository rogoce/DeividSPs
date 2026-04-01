-- Procedure que Carga los registros para generar el asiento de reaseguro

-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_rea008;

create procedure sp_rea008(
a_tipo		smallint default 99,
a_valor1	char(10) default null,
a_valor2	char(10) default null
) returning integer,
		    char(100);

define _no_endoso		char(5);

define _periodo			char(7);

define _no_registro		char(10);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _no_tranrec		char(10);
define _no_reclamo		char(10);

define _no_documento	char(20);

define _fecha			date;

define _renglon			smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_rea008.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc||" "||_no_registro;
end exception

if a_tipo = 1 then -- Produccion

	let _no_poliza = a_valor1;
	let _no_endoso = a_valor2;

	select count(*)
	  into _cantidad
	  from sac999:reacomp
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cantidad = 0 then 

		select fecha_emision,
		       periodo
		  into _fecha,
		       _periodo
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		select no_documento
		  into _no_documento
		  from emipomae
		 where no_poliza = _no_poliza;

		let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');

		insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
		values(_no_registro, a_tipo, _no_poliza, _no_endoso, null, null, null, _no_documento, 0, _fecha, _periodo);	

	end if

elif a_tipo = 2 then -- Cobros

	let _no_remesa = a_valor1;

	foreach
	 select renglon,
	        no_poliza,
			doc_remesa,
			fecha,
			periodo
	   into _renglon,
	        _no_poliza,
			_no_documento,
			_fecha,
			_periodo
	   from cobredet
	  where no_remesa = _no_remesa
	    and tipo_mov  in ("P", "N")

		select count(*)
		  into _cantidad
		  from sac999:reacomp
		 where no_remesa = _no_remesa
		   and renglon   = _renglon;

		if _cantidad = 0 then 

			let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');
		
			insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
			values(_no_registro, a_tipo, _no_poliza, null, _no_remesa, _renglon, null, _no_documento, 0, _fecha, _periodo);	

		end if

	end foreach

elif a_tipo = 3 then -- Reclamos

	let _no_tranrec = a_valor1;

	select count(*)
	  into _cantidad
	  from sac999:reacomp
	 where no_tranrec = _no_tranrec;

	if _cantidad = 0 then 

		select no_reclamo,
		       fecha,
			   periodo
		  into _no_reclamo,
		       _fecha,
			   _periodo
		  from rectrmae
		 where no_tranrec = _no_tranrec;

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo;
		 
		 select no_documento
		   into _no_documento
		   from emipomae
		  where no_poliza = _no_poliza;

		let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');

		insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
		values(_no_registro, a_tipo, _no_poliza, null, null, null, _no_tranrec, _no_documento, 0, _fecha, _periodo);	
	
	end if

elif a_tipo in (4, 5) then -- Cheques Pagados/Anulados - Devolucion de Primas

	let _no_remesa = a_valor1;
	
	if a_tipo = 4 then 

		select fecha_impresion
		  into _fecha
		  from chqchmae
		 where no_requis = _no_remesa;

	else

		select fecha_anulado
		  into _fecha
		  from chqchmae
		 where no_requis = _no_remesa;
		
		if _fecha is null then
			let _fecha = today;
		end if
	
	end if

	if _fecha < "01/09/2013" then
		let _fecha = "01/09/2013";
	end if

	let _periodo = sp_sis39(_fecha);

	foreach
	 select	no_poliza,
	        no_documento
	   into _no_poliza,
	        _no_documento
       from chqchpol
      where no_requis = _no_remesa

		select count(*)
		  into _cantidad
		  from sac999:reacomp
		 where no_remesa     = _no_remesa
		   and no_poliza     = _no_poliza
		   and tipo_registro = a_tipo;

		if _cantidad = 0 then 
			let _no_registro = sp_sis13("001", 'REA', '02', 'rea_no_registro');
		
			insert into sac999:reacomp(no_registro, tipo_registro, no_poliza, no_endoso, no_remesa, renglon, no_tranrec, no_documento, sac_asientos, fecha, periodo)
			values(_no_registro, a_tipo, _no_poliza, null, _no_remesa, null, null, _no_documento, 0, _fecha, _periodo);	
		end if
	end foreach
end if

end

return 0, "Actualizacion Exitosa";

end procedure