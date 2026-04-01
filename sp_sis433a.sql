----------------------------------------------------------
--Proceso que genera la prima suscrita en un rango de periodos especifico y la prima cobrada de las mismas pólizas de la prima suscrita
--Creado    : 21/08/2015 - Autor: Román Gordón
----------------------------------------------------------

drop procedure sp_sis433a;
create procedure sp_sis433a(a_no_poliza char(10), a_no_endoso char(5), a_saldo dec(16,2), a_prima_bruta dec(16,2))
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define v_filtros2			varchar(255);
define v_filtros			varchar(255);
define _desc_ramo			varchar(50);
define _tipo_vigencia		varchar(20);
define _factor_impuesto		dec(9,6);
define _suma_asegurada		dec(16,2);
define _sum_prima_reas		dec(16,2);
define _prima_salud			dec(16,2);
define _prima_reas			dec(16,2);
define _prima				dec(16,2);
define _porc_partic_prima	dec(9,6); 
define _porc_partic_reas	dec(9,6); 
define _porc_partic_suma	dec(9,6); 
define _factor				dec(9,6);
define _proc_partic_coas	dec(7,4);
define _porc_comis_fac		dec(7,4);
define _porc_impuesto		dec(5,2);
define _no_poliza			char(10);
define _no_cesion			char(10);
define _dummy				char(10);
define _periodo_end			char(7);
define _periodo_cob			char(7);
define _ult_no_endoso		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _fase				char(1);
define _tipo				char(1);
define _tipo_produccion		smallint;
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _ramo_sis			smallint;
define _impreso				smallint;
define _orden2				smallint;
define _orden				smallint;
define _cnt					smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _fecha_impresion		date;
define _vigencia_inic		date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || ' no_poliza: ' || trim (a_no_poliza);
	return _error,_error_desc;
end exception

--set debug file to "sp_sis433.trc";
--trace on;

drop table if exists prueba;

delete from dep_emifacon
 where no_poliza = a_no_poliza;
   --and no_endoso = a_no_endoso;

delete from dep_emifafac
 where no_poliza = a_no_poliza;
   --and no_endoso = a_no_endoso;

select cod_ramo,
	   cod_tipoprod
  into _cod_ramo,
	   _cod_tipoprod
  from emipomae
 where no_poliza = a_no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

{if _ramo_sis = 5 then
	
	select sum(y.factor_impuesto) 
	  into _factor_impuesto
	  from emipolim x, prdimpue y
	 where x.no_poliza    = a_no_poliza
	   and x.cod_impuesto = y.cod_impuesto
	   and y.pagado_por   = "C";

	let _factor_impuesto = _factor_impuesto + 100;
	let _prima_salud = a_saldo / (_factor_impuesto / 100);
	let _factor = 1;
else}
--let _factor = a_saldo/a_prima_bruta;
--end if

let _sum_prima_reas = 0.00;

drop table if exists tmp_emipouni;

if _ramo_sis = 5 then
	select no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	   and activo = 1
	  into temp tmp_emipouni;
else
	select no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	  into temp tmp_emipouni;
end if

foreach
	select no_unidad
	  Into _no_unidad
	  from tmp_emipouni

	-- Cargar Reaseguros Individuales
	create temp table prueba(
	no_poliza			char(10),
	no_endoso			char(5),
	no_unidad			char(5),
	cod_cober_reas		char(3),
	orden				smallint,
	cod_contrato		char(5),
	cod_ruta			char(5),
	porc_partic_suma	dec(9,6),
	porc_partic_prima	dec(9,6),
	suma_asegurada		dec(16,2) default 0,
	prima				dec(16,2) default 0) with no log;

	select max(no_cambio)
	  into _no_cambio
	  from emireama
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	insert into prueba(
			no_poliza,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima)
    select no_poliza,
		   no_unidad,
		   cod_cober_reas,
		   orden,
		   cod_contrato,
		   porc_partic_suma,
		   porc_partic_prima
	  from emireaco
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad
	   and no_cambio = _no_cambio;

	update prueba
	   set no_endoso = a_no_endoso
	 Where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	insert into dep_emifacon(
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
		prima)
	select no_poliza,        
		   no_endoso,
		   no_unidad,
		   cod_cober_reas,
		   orden,
		   cod_contrato,
		   cod_ruta,
		   porc_partic_suma,
		   porc_partic_prima,
		   suma_asegurada,
		   prima			
	  from prueba
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	drop table prueba;

	if _ramo_sis = 5 then
		select max(r.no_endoso)
		  into _ult_no_endoso
		  from emifacon r, endedmae e
		 where r.no_poliza = e.no_poliza
		   and r.no_endoso = e.no_endoso
		   and r.no_poliza = a_no_poliza
		   and r.no_unidad = _no_unidad
		   and e.cod_endomov in ('011','014')
		   and e.actualizado = 1;

		foreach
			select cod_cober_reas,
				   orden,
				   suma_asegurada,
				   prima
			  into _cod_cober_reas,
				   _orden,
				   _suma_asegurada,
				   _prima_reas
			  from emifacon
			 where no_poliza = a_no_poliza
			   and no_endoso = _ult_no_endoso
			   and no_unidad = _no_unidad

			update dep_emifacon
			   set prima = _prima_reas,
				   suma_asegurada = _suma_asegurada
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso
			   and no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and orden = _orden;

			if _prima_reas is null then
				let _prima_reas = 0.00;
			end if

			let _sum_prima_reas = _sum_prima_reas + _prima_reas;
		end foreach
	else
		foreach
			execute procedure sp_pro356(a_no_poliza,_no_unidad)
			into	_no_poliza,
					_no_unidad,
					_cod_cober_reas,
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima,
					_suma_asegurada,
					_prima_reas,
					_cnt,
					_orden

			{let _suma_asegurada = _suma_asegurada * _factor;
			let _prima_reas = _prima_reas * _factor;}
			
			
			if _prima_reas is null then
				let _prima_reas = 0.00;
			end if

			update dep_emifacon
			   set porc_partic_prima = _porc_partic_prima,
				   porc_partic_suma = _porc_partic_suma,
				   suma_asegurada = _suma_asegurada,
				   prima = _prima_reas
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso
			   and no_unidad = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and orden = _orden;

			let _sum_prima_reas = _sum_prima_reas + _prima_reas;

			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			if _tipo_contrato = 3 then
				foreach
					execute procedure sp_pro356a(a_no_poliza,_no_unidad,_cod_cober_reas, _cod_contrato)
					into	_no_poliza,
							_dummy,
							_no_unidad,
							_cod_cober_reas,
							_orden2,
							_cod_contrato,
							_cod_coasegur,
							_porc_partic_reas,
							_porc_comis_fac,
							_porc_impuesto,
							_suma_asegurada,
							_prima,
							_impreso,
							_fecha_impresion,
							_no_cesion

					if _impreso is null then
						let _impreso = 0;
					end if

					if _fecha_impresion is null then
						let _fecha_impresion = today;
					end if

					insert into dep_emifafac(
							no_poliza,
							no_endoso,
							no_unidad,
							cod_cober_reas,
							orden,
							cod_contrato,
							cod_coasegur,
							porc_partic_reas,
							porc_comis_fac,
							porc_impuesto,
							suma_asegurada,
							prima,
							impreso,
							fecha_impresion,
							no_cesion,
							subir_bo,
							monto_comision,
							monto_impuesto)
					values(	a_no_poliza,
							a_no_endoso,
							_no_unidad,
							_cod_cober_reas,
							_orden2,
							_cod_contrato,
							_cod_coasegur,
							_porc_partic_reas,
							_porc_comis_fac,
							_porc_impuesto,
							_suma_asegurada,
							_prima,
							_impreso,
							_fecha_impresion,
							_no_cesion,
							0,
							0.00,
							0.00);
				end foreach
			end if
		end foreach
	end if
end foreach;

let _factor = 1;

if abs(_sum_prima_reas) > 1 then
	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	select sum(y.factor_impuesto) 
	  into _factor_impuesto
	  from emipolim x, prdimpue y
	 where x.no_poliza    = a_no_poliza
	   and x.cod_impuesto = y.cod_impuesto
	   and y.pagado_por   = "C";

	if _factor_impuesto is null then
		let _factor_impuesto = 0.00;
	end if

	let _sum_prima_reas = _sum_prima_reas * (1 + (_factor_impuesto / 100));

	if _tipo_produccion = 2 then
		select porc_partic_coas
		  into _proc_partic_coas
		  from emicoama 
		 where no_poliza = a_no_poliza
		   and cod_coasegur = '036';

		let _sum_prima_reas = _sum_prima_reas / (_proc_partic_coas / 100);
	end if

	let _factor = a_saldo/_sum_prima_reas;
end if

update dep_emifacon
   set suma_asegurada = suma_asegurada * _factor,
	   prima = prima * _factor
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

return 0,'Generación de registros existosa.';
end
end procedure;