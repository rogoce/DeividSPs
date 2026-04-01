-- Llamado de las Remesas y Endoso que afectan a las pólizas en emiletra de manera cronologica.
-- Creado    : 01/12/2014 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro525d;

create procedure sp_pro525d()
returning	int,
			char(50);

define _error_desc		char(50);
define _documento		char(10);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _no_endoso		char(5);
define _tipo_doc		char(1);
define _renglon			smallint;
define _fecha_emision	date;
define _error_isam		integer;
define _error			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_documento) || trim(_error_desc);
	rollback work;
	return _error, _error_desc;
end exception

--set debug file to "sp_pro525d.trc";
--trace on;

create temp table tmp_movimiento (
documento	char(10),
renglon		smallint,
fecha		date,
tipo		char(1)) with no log;

foreach with hold
	select distinct l.no_poliza
	  into _no_poliza
	  from emiletra l, emipomae e
	 where l.no_poliza = e.no_poliza
	   and e.cod_ramo = '018'
	 order by l.no_poliza desc

	begin work;

	foreach
		select no_endoso,
			   fecha_emision
		  into _no_endoso,
			   _fecha_emision
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso <> '00000'
		   and activa = 1
		 order by fecha_emision

		insert into tmp_movimiento
		values(_no_endoso,0,_fecha_emision,'E');
	end foreach
	
	foreach
		select d.no_remesa,
			   d.renglon,
			   m.date_posteo
		  into _no_remesa,
			   _renglon,
			   _fecha_emision
		  from cobremae m, cobredet d
		 where m.no_remesa = d.no_remesa
		   and d.no_poliza = _no_poliza
		   and m.actualizado = 1
		   and m.tipo_remesa in ('A','M','C','J','H','T')
		 order by date_posteo
		
		insert into tmp_movimiento
		values(_no_remesa,_renglon,_fecha_emision,'C');
	end foreach
	
	foreach
		select documento,
			   renglon,
			   fecha,
			   tipo
		  into _documento,
			   _renglon,
			   _fecha_emision,
			   _tipo_doc
		  from tmp_movimiento
		 order by fecha

		if _tipo_doc = 'E' then
			
			select cod_endomov
			  into _cod_endomov
			  from endedmae
			 where no_poliza = _no_poliza
			   and no_endoso = _documento;

			if _cod_endomov <> '014' then
				call sp_pro541(_no_poliza,_documento) returning _error,_error_desc;
				
				if _error <> 0 then
					rollback work;
					return _error, _error_desc;
				end if
			else
				call sp_pro541b(_no_poliza,_documento) returning _error,_error_desc;
				
				if _error <> 0 then
					rollback work;
					return _error, _error_desc;
				end if
			end if
		elif _tipo_doc = 'C' then
			call sp_cob343a(_documento,_renglon) returning _error,_error_desc;
			
			if _error <> 0 then	
				rollback work;
				return _error, _error_desc;
			end if
		end if
	end foreach
	
	delete from tmp_movimiento;
	
	commit work;
end foreach
end

return 0, "Actualizacion Exitosa";
end procedure
