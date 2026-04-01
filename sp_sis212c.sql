-- 
drop procedure sp_sis212c;
create procedure "informix".sp_sis212c(a_periodo_desde char(7),a_periodo_hasta char(7), a_codramo varchar(100))
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _filtros				varchar(250);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_requis			char(10);
define _periodo_corte		char(7);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
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
define _no_cambio			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _fecha_corte			date;

set isolation to dirty read;

--set debug file to "sp_sis212a.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
	rollback work;
 	return _error, _error_desc;         
end exception

if a_periodo_desde < '2015-09' then
	return 1, 'El Periodo no Aplica';
end if

foreach with hold
	select d.no_poliza,
		   d.no_requis,
		   d.no_documento
	  into _no_poliza,
		   _no_requis,
		   _no_documento
	  from chqchpol d, chqchmae m, emipomae e
	 where m.no_requis = d.no_requis
	   and d.no_poliza = e.no_poliza
	   and e.cod_ramo in ('002','020','023')
	   and m.periodo >= a_periodo_desde
	   and m.pagado = 1
	   and m.origen_cheque = 6

	begin work;

	select vigencia_inic,
		   cod_ramo
	  into _vigencia_inic,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cnt_existe
	  from chqreaco_transf
	 where no_requis = _no_requis
	   and no_poliza = _no_poliza;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe <> 0 then
		commit work;
		continue foreach;
	end if

	insert into chqreaco_transf
	select *
	  from chqreaco
	 where no_requis = _no_requis
	   and no_poliza = _no_poliza;

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and cod_ruta >= '00595'
	   and _vigencia_inic between vig_inic and vig_final;

	if _cod_ruta is null then
		rollback work;
		return 1,'No se encontro Ruta para el no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' || trim(_no_endoso);
	end if

	select count(*)
	  into _cnt_facultativo
	  from chqreaco e, reacomae c
	 where c.cod_contrato = e.cod_contrato
	   and e.no_requis = _no_requis
	   and e.no_poliza = _no_poliza
	   and c.tipo_contrato = 3;

	if _cnt_facultativo is null then
		let _cnt_facultativo = 0;
	end if

	if _cnt_facultativo > 0 then
		commit work;
		continue foreach;
	end if

	{call sp_sis122(_no_poliza,_no_endoso)  returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		let _error_desc = trim(_error_desc) || 'Distribución de Reaseguro. no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' || trim(_no_endoso);
		return _error,_error_desc;
	end if}

	delete from chqreaco
	 where no_requis = _no_requis
	   and no_poliza = _no_poliza
	   and cod_contrato not in (select cod_contrato from chqreafa where no_requis = _no_requis and no_poliza = _no_poliza);

	drop table if exists tmp_dist_rea;
	call sp_sis188(_no_poliza) returning _error,_error_desc;

	if _error <> 0 then
		rollback work;
		let _error_desc = trim(_error_desc) || 'Proporción de Coberturas. no_poliza: ' || trim(_no_poliza) || ' no_requis: ' || trim(_no_requis);
		return _error,_error_desc;
	end if
	
	select periodo
	  into _periodo
	  from chqchmae 
	 where no_requis = _no_requis;

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

		insert into chqreaco(
				no_requis,
				no_poliza,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima,
				subir_bo,
				cod_cober_reas,
				porc_proporcion)
		values(	_no_requis,
				_no_poliza,
				_orden,
				_cod_contrato,
				_porc_partic_suma,
				_porc_partic_prima,
				1,
				_cod_cober_reas,
				_porc_proporcion);
	end foreach
	
	delete from chqreaco
	 where no_requis         = _no_requis
	   and porc_partic_suma  = 0.00
	   and porc_partic_prima = 0.00;
	
	foreach
		select sum(porc_partic_prima)
		  into _porcentaje
		  from chqreaco
		 where no_requis = _no_requis
		 group by no_requis,no_poliza,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _error_desc = 'Distribucion de Reaseguro de Prima No Suma 100% en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (_no_requis) || ', Por Favor Verifique ...';
			return 1, _error_desc with resume;
			rollback work;
			continue foreach;
		end if
	end foreach


	foreach
		select sum(porc_partic_suma)
		  into _porcentaje
		  from chqreaco
		 where no_requis = _no_requis
		 group by no_requis,no_poliza,cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0;
		end if

		if _porcentaje <> 100 then
			let _error_desc = 'Distribucion de Reaseguro de Suma No Suma 100% en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (_no_requis) || ', Por Favor Verifique ...';
			return 1, _error_desc  with resume;
			rollback work;
			continue foreach;
		end if
	end foreach

	-- Verificacion para el Facultativo
	{select count(*)
	  into _contador_ret 
	  from chqreaco c, reacomae r
	 where c.no_requis     = _no_requis
	   and c.cod_contrato  = r.cod_contrato
	   and r.tipo_contrato = 3; 
	 
	if _contador_ret is null then
		let _contador_ret = 0;
	end if 

	if _contador_ret <> 0 then
		select count(*)
		  into _contador_ret
		  from chqreafa
		 where no_requis = _no_requis;

		if _contador_ret is null then
			let _contador_ret = 0; 
		end if

		if _contador_ret = 0 then
			let _error_desc = 'No Existe Distribucion de Facultativos en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (_no_requis) || ', Por Favor Verifique ...';
			return 1, _error_desc; -- with resume;
		end if

		foreach
			select sum(porc_partic_reas)
			  into _porcentaje
			  from chqreafa
			 where no_requis = _no_requis
			 group by no_requis,no_poliza

			if _porcentaje is null then
				let _porcentaje = 0;
			end if

			if _porcentaje <> 100 then
				let _error_desc = _no_poliza || ' Distribucion de Reaseguro de Facultativos No Suma 100% en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (_no_requis) || ', Por Favor Verifique ...';
				return 1, _error_desc; -- with resume;
			end if
	   end foreach
	end if}

	-- verificacion de varias retenciones
	foreach
		select count(*) 
		  into _contador_ret 
		  from chqreaco c, reacomae r
		 where c.no_requis     = _no_requis
		   and c.cod_contrato  = r.cod_contrato
		   and r.tipo_contrato = 1
		 group by c.no_requis,c.no_poliza,c.cod_cober_reas	    
		 
		if _contador_ret is null then
			let _contador_ret = 0;
		end if 
		 
		if _contador_ret > 1 then
			let _error_desc = 'Existe Mas de Una Retencion  en la Póliza: ' || trim(_no_documento) || ' en la Requisicion: ' || trim (_no_requis) || ', Por Favor Verifique ...';
			return 1, _error_desc with resume;
			rollback work;
			continue foreach;
		end if
	end foreach
	
	if _periodo >= '2016-01' then
		update sac999:reacomp
		   set sac_asientos = 0
		 where no_remesa = _no_requis
		   and no_poliza = _no_poliza
		   and tipo_registro in (4,5)
		   and periodo >= '2016-01';--_periodo;
	end if

	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;