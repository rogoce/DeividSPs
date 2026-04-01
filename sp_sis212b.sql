--execute procedure sp_sis212b('2016-02','2016-02','002,020,023;') 
drop procedure sp_sis212b;
create procedure "informix".sp_sis212b(a_periodo_desde char(7),a_periodo_hasta char(7), a_codramo varchar(100))
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _filtros				varchar(250);
define _no_documento		char(20);
define _no_registro			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo_corte		char(7);
define _cob_periodo			char(7);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_prima_prop		dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_sin_fac		dec(9,6);
define _porcentaje			dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_aseg_fac		dec(16,2);
define _suma_sin_fac		dec(16,2);
define _suma_aseg			dec(16,2);
define _prima_rea			dec(16,2);
define _cnt_facultativo		smallint;
define _ult_no_cambio		smallint;
define _contador_ret		smallint;
define _cnt_existe			smallint;
define _cnt_notrx			smallint;
define _no_cambio			smallint;
define _renglon				smallint;
define _orden				smallint;
define _error_isam			integer;
define _notrx				integer;
define _error				integer;
define _vigencia_inic		date;
define _fecha_corte			date;

set isolation to dirty read;

--set debug file to "sp_sis212a.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
	--rollback work;
 	return _error, _error_desc;         
end exception

select cob_periodo
  into _cob_periodo
  from parparam;

if a_periodo_desde < _cob_periodo then
	return 1, 'El Periodo no Aplica';
end if

drop table if exists temp_det;
call sp_pro307(	'001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*',a_codramo,'*') returning _filtros;

--set debug file to "sp_sis212a.trc";
--trace on;

foreach with hold
	select distinct t.no_poliza,																	 
		   t.no_endoso,
		   t.no_remesa,
		   t.renglon
	  into _no_poliza,
		   _no_endoso,
		   _no_remesa,
		   _renglon
	  from temp_det t, cobreaco r, reacomae c,emipomae e
	 where t.no_remesa = r.no_remesa
	   and t.renglon = r.renglon
	   and r.cod_contrato = c.cod_contrato
	   and t.no_poliza = e.no_poliza
	  -- and e.vigencia_inic >= '01/01/2018'
	   and c.tipo_contrato = 1
	   and r.porc_partic_prima <> 5
	   and seleccionado = 1

	{begin
		on exception in(-535)

		end exception 	
		begin work;
	end}

	select vigencia_inic,
		   cod_ramo
	  into _vigencia_inic,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cnt_existe
	  from cobreaco_transf
	 where no_remesa = _no_remesa
	   and renglon = _renglon;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe <> 0 then
		--commit work;
		continue foreach;
	end if

	insert into cobreaco_transf
	select *
	  from cobreaco
	 where no_remesa = _no_remesa
	   and renglon = _renglon;

	let _periodo = '';

	select periodo
	  into _periodo
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon = _renglon;

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and cod_ruta >= '00595'
	   and _vigencia_inic between vig_inic and vig_final
	   and activo = 1;

	if _cod_ruta is null then
		--rollback work;
		return 1,'No se encontro Ruta para el no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' || trim(_no_endoso) with resume;
		continue foreach;
	end if

	select count(*)
	  into _cnt_facultativo
	  from cobreaco e, reacomae c
	 where c.cod_contrato = e.cod_contrato
	   and e.no_remesa = _no_remesa
	   and e.renglon = _renglon
	   and c.tipo_contrato = 3;

	if _cnt_facultativo is null then
		let _cnt_facultativo = 0;
	end if

	if _cnt_facultativo > 0 then
		--commit work;
		continue foreach;
	end if

	{call sp_sis122(_no_poliza,_no_endoso)  returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		let _error_desc = trim(_error_desc) || 'Distribución de Reaseguro. no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' || trim(_no_endoso);
		return _error,_error_desc;
	end if}

	delete from cobreaco
	 where no_remesa = _no_remesa
	   and renglon = _renglon
	   and cod_contrato not in (select cod_contrato from cobreafa where no_remesa = _no_remesa and renglon = _renglon);

	drop table if exists tmp_dist_rea;
	call sp_sis188(_no_poliza) returning _error,_error_desc;

	if _error <> 0 then
		--rollback work;
		let _error_desc = trim(_error_desc) || 'Proporción de Coberturas. no_poliza: ' || trim(_no_poliza) || ' no_remesa: ' || trim(_no_remesa);
		return _error,_error_desc;
	end if

	foreach
		select orden,
			   cod_cober_reas,
			   cod_contrato,
			   porc_partic_prima,
			   porc_partic_suma
		  into _orden,
			   _cod_cober_reas,
			   _cod_contrato,
			   _porc_partic_prima,
			   _porc_partic_suma
		  from rearucon
		 where cod_ruta = _cod_ruta
		 order by orden

		select porc_cober_reas
		  into _porc_proporcion
		  from tmp_dist_rea
		 where cod_cober_reas = _cod_cober_reas;

		if _porc_proporcion is null then
			--let _porc_proporcion = 0;	--Lo puse en comentario Armando, 13/12/2013
			continue foreach;
		end if

		{select sum(suma_asegurada)
		  into _suma_aseg_fac
		  from emifacon e, reacomae c
		 where e.cod_contrato = c.cod_contrato
		   and c.tipo_contrato = 3
		   and no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas;

		if _suma_aseg_fac is null then
			let _suma_aseg_fac = 0;
		end if
		
		if _suma_aseg_fac = 0 then
			let _suma_sin_fac = _suma_asegurada;
			let _porc_sin_fac = 100;			
		else
			let _suma_sin_fac = _suma_asegurada - _suma_aseg_fac;
			let _porc_sin_fac =  _suma_sin_fac/_suma_asegurada;
			let _porc_partic_prima = _porc_partic_prima * _porc_sin_fac;
		end if

		let _suma_aseg = (_suma_sin_fac * _porc_partic_suma / 100) * _porc_proporcion / 100;
		
		if _suma_aseg is null then
			let _suma_aseg = 0.00;
		end if
		
		let _prima_suscrita = (_prima_rea * _porc_partic_prima) / 100;
		
		if _prima_suscrita is null then
			let _prima_suscrita = 0;
		end if

		insert into emifacon(
				no_poliza,
				no_endoso,
				no_unidad,
				cod_cober_reas,
				orden,
				cod_contrato,
				cod_ruta,
				porc_partic_suma,
				porc_partic_prima,
				suma_asegurada,
				prima,
				ajustar,
				subir_bo)
		values(	_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_cober_reas,
				_orden,
				_cod_contrato,
				_cod_ruta,
				_porc_partic_suma,
				_porc_partic_prima,
				_suma_aseg,
				_prima_suscrita,
				0,
				1);}

		insert into cobreaco(
				no_remesa,
				renglon,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima,
				subir_bo,
				cod_cober_reas,
				porc_proporcion)
		values(	_no_remesa,
				_renglon,
				_orden,
				_cod_contrato,
				_porc_partic_suma,
				_porc_partic_prima,
				1,
				_cod_cober_reas,
				_porc_proporcion);
	end foreach
	
	foreach
		select sum(porc_partic_prima)
		  into _porcentaje
		  from cobreaco
		 where no_remesa = _no_remesa
		 group by no_remesa,renglon,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _error_desc = 'Distribucion de Reaseguro de Prima No Suma 100%, Por Favor Verifique ...';
			return 1, _error_desc with resume;
		end if
	end foreach

	foreach
		select sum(porc_partic_suma)
		  into _porcentaje
		  from cobreaco
		 where no_remesa = _no_remesa
		 group by no_remesa,renglon,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _error_desc = 'Distribucion de Reaseguro de Suma No Suma 100%, Por Favor Verifique ...';
			return 1, _error_desc with resume;
		end if
	end foreach

	-- Verificacion para el Facultativo
	{select count(*)
	  into _contador_ret 
	  from cobreaco c, reacomae r
	 where c .no_remesa     = _no_remesa
	   and c.cod_contrato  = r.cod_contrato
	   and r.tipo_contrato = 3; 
	 
	if _contador_ret is null then
		let _contador_ret = 0;
	end if 

	if _contador_ret <> 0 then

		select count(*)
		  into _contador_ret
		  from cobreafa
		 where no_remesa = _no_remesa;

		if _contador_ret is null then
			let _contador_ret = 0; 
		end if

		if _contador_ret = 0 then
			let _error_desc = 'No Existe Distribucion de Facultativos, Por Favor Verifique ...';
			return 1, _error_desc;
		end if

		foreach
			select sum(porc_partic_reas)
			  into _porcentaje
			  from cobreafa
			 where no_remesa = _no_remesa
			 group by no_remesa,renglon

			if _porcentaje is null then
				let _porcentaje = 0;
			end if

			if _porcentaje <> 100 then
				let _error_desc = _no_poliza || ' Distribucion de Reaseguro de Facultativos No Suma 100%, Por Favor Verifique ...';
				return 1, _error_desc;
			end if
	   end foreach
	end if}

	-- Verificacion de Varias Retenciones
	foreach
		select count(*) 
		  into _contador_ret 
		  from cobreaco c, reacomae r
		 where c.no_remesa     = _no_remesa
		   and c.cod_contrato  = r.cod_contrato
		   and r.tipo_contrato = 1
		 group by no_remesa,renglon,cod_cober_reas	    
		 
		if _contador_ret is null then
			let _contador_ret = 0;
		end if 
		 
		if _contador_ret > 1 then
			let _error_desc = 'Existe Mas de Una Retencion ...';
			return 1, _error_desc with resume;
		end if
	end foreach	
	
	--commit work;
	
	if _periodo >= _cob_periodo then
		foreach
			select sac_notrx
			  into _notrx
			  from cobasien
			 where no_remesa = _no_remesa
			   and renglon = _renglon

			call sp_sac77(_notrx) returning _error,_error_desc;
		end foreach

		foreach
			select no_registro
			  into _no_registro
			  from sac999:reacomp
			 where no_remesa = _no_remesa
			   and renglon = _renglon
			   and tipo_registro = 2

			select count(*)
			  into _cnt_notrx
			  from sac999:reacompasie
			 where no_registro = _no_registro;

			if _cnt_notrx is null then
				let _cnt_notrx = 0;
			end if

			if _cnt_notrx = 0 then
				update sac999:reacomp
				   set sac_asientos = 0
				 where no_registro = _no_registro;
			else
				foreach
					select distinct sac_notrx
					  into _notrx
					  from sac999:reacompasie
					 where no_registro = _no_registro

					call sp_sac77(_notrx) returning _error,_error_desc;
				end foreach
			end if
		end foreach
	end if

	{begin
		on exception in(-535)

		end exception 	
		begin work;
	end}
	
	let _porc_prima_prop = 0.00;

	select sum(porc_proporcion * porc_partic_prima / 100)
	  into _porc_prima_prop
      from cobreaco
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _porc_prima_prop is null then
		let _porc_prima_prop = 0.00;
	end if

	if _porc_prima_prop <> 100.00 then
		return 1, "% Proporcion No Suma 100% Remesa: " || _no_remesa || "  " || _renglon || " " with resume;
	end if
	--commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;