--execute procedure sp_sis212a('2017-01','2017-01','002,020,023;')
drop procedure sp_sis212a;
create procedure "informix".sp_sis212a(a_periodo_desde char(7),a_periodo_hasta char(7), a_codramo varchar(100))
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _filtros				varchar(250);
define _no_documento		char(20);
define _no_poliza			char(10);
define _emi_periodo			char(7);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_sin_fac		dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_aseg_fac		dec(16,2);
define _suma_sin_fac		dec(16,2);
define _suma_aseg			dec(16,2);
define _prima_rea			dec(16,2);
define _cnt_facultativo		smallint;
define _ult_no_cambio		smallint;
define _cnt_existe			smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_corte			date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
	rollback work;
 	return _error, _error_desc;         
end exception

if a_periodo_desde < '2015-09' then
	return 1, 'El Periodo no Aplica';
end if

drop table if exists temp_det;
call sp_pro34('001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*',a_codramo,'*') returning _filtros;

update temp_det
   set seleccionado = 0
 where vigencia_inic < '01/07/2017';

--set debug file to "sp_sis212a.trc";
--trace on;

select emi_periodo
  into _emi_periodo
  from parparam;

foreach with hold
	select no_poliza,																	 
		   no_endoso																		 
	  into _no_poliza,
		   _no_endoso
	  from temp_det
	 where seleccionado = 1
	  -- and no_factura in ('01-1811607')
	 group by 1, 2

	begin work;

	select vigencia_inic,
		   vigencia_final,
		   cod_ramo
	  into _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _periodo = '';

	select periodo,
		   cod_endomov
	  into _periodo,
		   _cod_endomov
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	{if _cod_endomov not in ('011','004') then
		commit work;
		continue foreach;
	end if}

	select count(*)
	  into _cnt_existe
	  from emifacon_transf
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if

	if _cnt_existe = 0 then
		return 1,'No Existe en emifacon_transf no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' || trim(_no_endoso) with resume;
		commit work;
		continue foreach;
	end if

	delete from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	   --and cod_contrato not in (select cod_contrato from emifafac where no_poliza = _no_poliza and no_endoso = _no_endoso);

	insert into emifacon
	select *
	  from emifacon_transf
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	{foreach
		select distinct no_unidad
		  into _no_unidad
		  from tmp_reas

		drop table if exists tmp_dist_rea;
		call sp_sis188b(_no_poliza,_no_endoso,_no_unidad) returning _error,_error_desc;

		if _error <> 0 then
			rollback work;
			let _error_desc = trim(_error_desc) || 'Proporción de Coberturas. no_poliza: ' || trim(_no_poliza) || ' no_endoso: ' || trim(_no_endoso);
			return _error,_error_desc;
		end if

		select suma_asegurada
		  into _suma_asegurada
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		foreach
			select cod_cober_reas,
				   sum(prima_rea)
			  into _cod_cober_reas,
				   _prima_rea
			  from tmp_reas
			 where no_unidad = _no_unidad
			 group by 1

			foreach
				select orden,
					   cod_contrato,
					   porc_partic_prima,
					   porc_partic_suma
				  into _orden,
					   _cod_contrato,
					   _porc_partic_prima,
					   _porc_partic_suma
				  from rearucon
				 where cod_ruta = _cod_ruta
				   and cod_cober_reas = _cod_cober_reas
				 order by orden

				select porc_cober_reas
				  into _porc_proporcion
				  from tmp_dist_rea
				 where cod_cober_reas = _cod_cober_reas;

				select sum(suma_asegurada)
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
				
				if _prima_suscrita = 0.00 then
					continue foreach;
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
						1);

				select nvl(max(no_cambio),0)
				  into _no_cambio
				  from emireaco
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;
				{delete from emireaco
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;

				let _no_cambio = _no_cambio + 1;

				insert into emireama(
						no_poliza,
						no_unidad,
						no_cambio,
						cod_cober_reas,
						vigencia_inic,
						vigencia_final)
				values(	_no_poliza,
						_no_unidad,
						_no_cambio,
						_cod_cober_reas,
						_vigencia_inic,
						_vigencia_final);

				INSERT INTO emireaco(
				no_poliza,
				no_unidad,
				no_cambio,
				cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima
				)
				SELECT 
				_no_poliza, 
				no_unidad,
				_no_cambio,
				_cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima
				FROM emifacon
				WHERE no_poliza = _no_poliza
				  AND no_endoso = _no_endoso
				  and no_unidad = _no_unidad
				  and cod_cober_reas = _cod_cober_reas;
						
			end foreach
		end foreach
	end foreach

	if _periodo >= _emi_periodo then
		update endedmae
		   set sac_asientos = 0
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		update sac999:reacomp
		   set sac_asientos = 0
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and tipo_registro = 1;
	end if}

	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;