-- Procedure que carga los registros de tiempos para los bloques/asignaciones de salud

-- Creado:	19/09/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_bo034;
create procedure sp_bo034()
returning integer,
          char(50);

define _fecha_atc 			datetime year to minute;
define _fecha_pre  			datetime year to minute;
define _fecha_scan			datetime year to minute;
define _fecha_imcs			datetime year to minute;
define _fecha_ancon			datetime year to minute;
define _fecha_ajus 			datetime year to minute;
define _fecha_asig			datetime year to minute;
define _fecha_susp_rem		datetime year to minute;

define _tiempo_atc_pre		dec(16,2);
define _tiempo_pre_scan		dec(16,2);
define _tiempo_scan_imcs	dec(16,2);
define _tiempo_imcs_ancon	dec(16,2);
define _tiempo_ancon_ajus	dec(16,2);
define _tiempo_scan_ajus	dec(16,2);
define _tiempo_asig_ajus	dec(16,2);
define _tiempo_total		dec(16,2);
	
define _imcs_enviado		smallint;
define _imcs_regreso		smallint;
define _cod_asignacion		char(10);
define _cod_entrada			char(10);
define _completado			smallint;
define _escaneado			smallint;
define _pendiente_asignar	smallint;
define _pendiente_imcs		smallint;
define _ajustador_asignar	smallint;
define _monto_completado	dec(16,2);
define _monto				dec(16,2);
define _bloque_completo		smallint;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

--set debug file to "sp_bo034.trc";

set isolation to dirty read;

begin 
on exception set _error
	return _error, _error_desc;
end exception

foreach
 select cod_entrada,
        fecha,
		completado
   into _cod_entrada,
   	    _fecha_atc,
		_bloque_completo
   from atcdocma
  where bo_ok = 0

   foreach
	select date_added,
		   fecha_scan,
		   imcs_fecha_enviado,
		   imcs_fecha_regreso,
		   fecha_completado,
		   imcs_asignar,
		   cod_asignacion,
		   ajustador_fecha,
		   completado,
		   date_susp_rem,
		   ajustador_asignar,
		   monto,
		   escaneado,
		   imcs_regreso	
	  into _fecha_pre,
	       _fecha_scan,
		   _fecha_imcs,
		   _fecha_ancon,
		   _fecha_ajus,
		   _imcs_enviado,
		   _cod_asignacion,
		   _fecha_asig,
		   _completado,
		   _fecha_susp_rem,
		   _ajustador_asignar,
		   _monto,
		   _escaneado,
		   _imcs_regreso
	  from atcdocde
	 where cod_entrada = _cod_entrada
	 
		let _error_desc = "Procesando Asignacion " || _cod_asignacion;
		{if _cod_asignacion = '400199' then  --'398129'
			trace on;
		end if	}
	
		delete from atcdocme
		 where cod_asignacion = _cod_asignacion;

		let _pendiente_asignar = 0;
		let _monto_completado  = 0;

		if _ajustador_asignar = 1 and
		   _escaneado         = 1 and
		   _completado        = 0 then
			let _pendiente_asignar = 1;
		end if

		if _completado = 0 then
			let _fecha_ajus = current;
		else
			if _fecha_susp_rem is not null then
				let _fecha_asig = _fecha_susp_rem;
			end if
			let _monto_completado  = _monto;
		end if

		let _tiempo_atc_pre    = sp_bo033(_fecha_atc,   _fecha_pre);
		let _tiempo_pre_scan   = sp_bo033(_fecha_pre,   _fecha_scan);
		let _tiempo_scan_imcs  = sp_bo033(_fecha_scan,  _fecha_imcs);
		let _tiempo_imcs_ancon = sp_bo033(_fecha_imcs,  _fecha_ancon);
		let _tiempo_ancon_ajus = sp_bo033(_fecha_ancon, _fecha_ajus);
		let _tiempo_scan_ajus  = sp_bo033(_fecha_scan,  _fecha_ajus);
		let _tiempo_asig_ajus  = sp_bo036(_fecha_asig,  _fecha_ajus); -- Minutos
		let _tiempo_total      = sp_bo033(_fecha_atc,   _fecha_ajus);

		if _completado = 1 then

			if day(_fecha_asig) <> day(_fecha_ajus) then
				let _tiempo_asig_ajus  = _tiempo_asig_ajus - (15 * 60);
			end if

		end if

		let _pendiente_imcs = 0;
		 
		if _imcs_enviado = 0 then
			let _tiempo_scan_imcs  = 0;
			let _tiempo_imcs_ancon = 0;
			let _tiempo_ancon_ajus = 0;
		else
			if _imcs_regreso = 0 then
				let _pendiente_imcs = 1;
			end if
		end if	

		insert into atcdocme
		values(
		_cod_asignacion,
		_tiempo_atc_pre,
		_tiempo_pre_scan,
		_tiempo_scan_imcs,
		_tiempo_imcs_ancon,
		_tiempo_ancon_ajus,
		_tiempo_scan_ajus,
		_tiempo_total,
		_tiempo_asig_ajus,
		_pendiente_asignar,
		_monto_completado,
		_pendiente_imcs
		);
	end foreach
	if _bloque_completo = 1 then

		update atcdocma
		   set bo_ok       = 1
		 where cod_entrada = _cod_entrada;

	end if
end foreach
end
return 0, "Actualizacion Exitosa";

end procedure
