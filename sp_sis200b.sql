
drop procedure sp_sis200b;

create procedure "informix".sp_sis200b()--, a_no_unidad char(5))
returning integer, char(250);

define _mensaje			char(250);
define _no_poliza		char(10);
define _no_remesa		char(10);
define _no_unidad		char(5);
define _cod_cober_cambio	char(3);
define _cod_cober_reas	char(3);
define _porc_proporcion	dec(16,2);
define _error_isam		integer;
define _renglon			integer;
define _error			integer;
define _no_cambio		smallint;
define _cnt				smallint;

set isolation to dirty read;

--set debug file to "sp_sis200.trc";
--trace on;

begin

on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

foreach
	select no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from tmp_ttco_dist
	 
	select no_poliza 
	  into _no_poliza
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon = _renglon;

	let _no_cambio = null;

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	if _no_cambio is null then
		let _mensaje = 'No Existe Distribucion de Reaseguro para Esta Poliza, Por Favor Verifique ...';
		return 1, _mensaje;
	end if

	select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
	
	call sp_sis188(_no_poliza) returning _error,_mensaje;
	
	if _error <> 0 then
		--let _mensaje = trim(_mensaje) || ' la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (a_no_requis) || ', Por Favor Verifique ...';
		return _error,_mensaje;
	end if
	
	foreach
		select cod_cober_reas
		  into _cod_cober_reas
		  from tmp_dist_rea
		
		let _cnt = 0;
		
		select count(*)
		  into _cnt
		  from emireaco
		  where no_poliza      = _no_poliza
			and no_unidad      = _no_unidad
			and no_cambio      = _no_cambio
			and cod_cober_reas = _cod_cober_reas;

		if _cnt is null then
			let _cnt = 0;
		end if
		
		if _cnt = 0 then
			let _cod_cober_cambio = '';
			
			if _cod_cober_reas = '033' then
				let _cod_cober_cambio = '002';
			elif _cod_cober_reas = '034' then
				let _cod_cober_cambio = '031';
			end if
			
			if _cod_cober_cambio <> '' then
				
				insert into emireama
				select no_poliza,no_unidad,no_cambio,_cod_cober_reas,vigencia_inic,vigencia_final
				  from emireama
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cober_cambio;
				
				update emireaco
				   set cod_cober_reas = _cod_cober_reas
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cober_cambio;
				
				delete emireama
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cober_cambio;
			
				{insert into emireaco
				select no_poliza,no_unidad,no_cambio,_cod_cober_reas,orden,cod_contrato,porc_partic_suma,porc_partic_prima
				  from emireaco
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cober_cambio;
				
				update emireama
				   set cod_cober_reas = _cod_cober_reas
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cober_cambio;
				
				delete emireaco
				 where no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   and no_cambio      = _no_cambio
				   and cod_cober_reas = _cod_cober_cambio;}
				
			end if
		end if
	end foreach
	
	drop table tmp_dist_rea;
end foreach

end
end procedure;