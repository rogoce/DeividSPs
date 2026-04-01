----------------------------------------------------------
--Proceso que genera la prima suscrita en un rango de periodos especifico y la prima cobrada de las mismas pólizas de la prima suscrita
--Creado    : 21/08/2015 - Autor: Román Gordón
----------------------------------------------------------

drop procedure sp_sis433;
create procedure sp_sis433(a_no_poliza char(10), a_no_endoso char(5), a_saldo dec(16,2), a_prima_bruta dec(16,2))
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define v_filtros2			varchar(255);
define v_filtros			varchar(255);
define _desc_ramo			varchar(50);
define _tipo_vigencia		varchar(20);
define _factor_impuesto		dec(20,8);
define _prima_coberturas	dec(16,2);
define _prima_salud			dec(16,2);
define _prima_reas			dec(16,2);
define _porc_partic_prima	dec(9,6); 
define _factor				dec(9,6);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo_end			char(7);
define _periodo_cob			char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _fase				char(1);
define _tipo				char(1);
define _no_cambio			smallint;
define _ramo_sis			smallint;
define _error_isam			integer;
define _renglon				integer;
define _error				integer;
define _vigencia_inic		date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

--set debug file to "sp_sis433.trc";
--trace on;

drop table if exists tmp_emifacon;
drop table if exists prueba;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis = 5 then
	
	select sum(y.factor_impuesto) 
	  into _factor_impuesto
	  from emipolim x, prdimpue y
	 where x.no_poliza    = a_no_poliza
	   and x.cod_impuesto = y.cod_impuesto
	   and y.pagado_por   = "C";

	let _factor_impuesto = _factor_impuesto + 100;
	let _prima_salud = a_saldo / (_factor_impuesto / 100);
	let _factor = 1;
else
	let _factor = a_saldo/a_prima_bruta;
end if

select *
  from emifacon
 where 1=2
  into temp tmp_emifacon;

foreach
	select no_unidad
	  Into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza

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

--	IF _no_cambio IS NULL THEN
--	   LET _no_cambio = 0;
--	END IF

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

	insert into tmp_emifacon(
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

	foreach
		select cod_cober_reas,
			   cod_contrato,
			   porc_partic_prima
		  into _cod_cober_reas,
			   _cod_contrato,
			   _porc_partic_prima
		  from tmp_emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and no_unidad = _no_unidad

		let _prima_coberturas = 0.00;

		select sum(prima_neta * _factor)
		  into _prima_coberturas
		  from emipocob e, prdcober c
		 where e.cod_cobertura = c.cod_cobertura
		   and no_poliza = a_no_poliza
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas;

		if _prima_coberturas is null then
			let _prima_coberturas = 0.00;
		end if

		if _ramo_sis = 5 and _prima_coberturas <> 0 then
			let _prima_coberturas = _prima_salud * _factor;
		end if

		let _prima_reas = _prima_coberturas * (_porc_partic_prima/100);

		update tmp_emifacon
		   set prima = _prima_reas
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato = _cod_contrato;
	end foreach
end foreach;

return 0,'Generación de registros existosa.';
end
end procedure;