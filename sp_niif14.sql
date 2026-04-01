-- Procedure de Detalle de Fianzas para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif012('2021-01','2021-12','001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif14;
create procedure sp_niif14(a_periodo char(7))
returning	integer			as error,
			integer			as error_isam,
			varchar(100)	as error_desc;

define _error_desc			varchar(100);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _subramo				varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_grupo			char(5);
define _no_unidad			char(5);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _cat_subramo			char(2);
define _cat_ramo			char(2);
define _cat1				char(2);
define _cat2				char(2);
define _cat3				char(2);
define _cat4				char(2);
define _cat5				char(2);
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _anio				smallint;
define _cnt_cob				integer;
define _error				integer;
define _error_isam			integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hasta			date;
define _porc_partic_suma	dec(9,6);
define _suma_aseg_facultativo	dec(16,2);
define _suma_aseg_retencion	dec(16,2);
define _suma_aseg_cesion	dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_asegurada		dec(16,2);
define _suma_contrato		dec(16,2);
define _porc_retencion		dec(9,6);
define _porc_fronting		dec(9,6);
define _porc_cedido			dec(9,6);
define _porc_coas			dec(7,4);


set isolation to dirty read;


let _categoria_contable = '';

begin 
on exception set _error, _error_isam, _error_desc
	if _no_poliza is null then
		let _no_poliza = '';
	end if

	
	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
	return _error,
		   _error_isam,
		   _error_desc;
end exception


--set debug file to "sp_niif013.trc";
--trace on;

let _fecha_hasta = sp_sis36(a_periodo);
let _anio = year(_fecha_hasta);

drop table if exists tmp_detalle_fianza;
create temp table tmp_detalle_fianza(
no_poliza				char(10),
no_documento			char(20),
vigencia_inic			date,
vigencia_final			date,
prima_suscrita			dec(16,2),
suma_asegurada			dec(16,2),
subramo					varchar(30),
enlace_contable			varchar(30),
suma_aseg_retencion		dec(16,2),
suma_aseg_facultativo	dec(16,2),
suma_aseg_cesion		dec(16,2),
anio					smallint,
primary key(no_poliza,vigencia_inic,anio)) with no log;

foreach
	select emi.no_poliza,
		   emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.prima_suscrita,
		   emi.suma_asegurada,
		   sub.nombre,
		   nif.clave_ramo||'-'||nif.clave_subramo||'-'||nif.cat1_n||'-'||nif.cat2_n
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_suscrita,
		   _suma_asegurada,
		   _subramo,
		   _categoria_contable
	  from emipomae emi
	 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	 inner join deivid_tmp:sc_niif17 nif on nif.codramo = emi.cod_ramo and nif.codsubramo = emi.cod_subramo
	 where emi.cod_ramo = '008'
	   and (emi.estatus_poliza in (1,3) or (emi.estatus_poliza in (2,4) and emi.fecha_cancelacion >= _fecha_hasta))
	   and emi.vigencia_inic <= _fecha_hasta and emi.vigencia_final >= _fecha_hasta
	   and emi.actualizado = 1

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	foreach
		select con.tipo_contrato,
			   rea.porc_partic_suma
		  into _tipo_contrato,
			   _porc_partic_suma
		  from emireaco rea
		 inner join reacomae con on con.cod_contrato = rea.cod_contrato
		 where rea.no_poliza = _no_poliza
		   and rea.no_cambio = _no_cambio

		let _suma_contrato = _suma_asegurada * (_porc_partic_suma/100);
		let _suma_aseg_retencion = 0;
		let _suma_aseg_facultativo = 0;
		let _suma_aseg_cesion = 0;
				
		if _tipo_contrato = 1 then
			let _suma_aseg_retencion = _suma_contrato;
		elif _tipo_contrato = 3 then
			let _suma_aseg_facultativo = _suma_contrato;
		else
			let _suma_aseg_cesion = _suma_contrato;
		end if

		BEGIN
		ON EXCEPTION IN(-239,-268)
			update tmp_detalle_fianza
			   set suma_aseg_retencion = suma_aseg_retencion + _suma_aseg_retencion,
				   suma_aseg_facultativo = suma_aseg_facultativo + _suma_aseg_facultativo,
				   suma_aseg_cesion = suma_aseg_cesion + _suma_aseg_cesion
			 where no_poliza = _no_poliza
			   and vigencia_inic = _vigencia_inic
			   and anio = _anio;
		END EXCEPTION
		
			insert into tmp_detalle_fianza(
					no_poliza,
					no_documento,
					vigencia_inic,
					vigencia_final,
					prima_suscrita,
					suma_asegurada,
					subramo,
					enlace_contable,
					suma_aseg_retencion,
					suma_aseg_facultativo,
					suma_aseg_cesion,
					anio)
			values(
					_no_poliza,
					_no_documento,
					_vigencia_inic,
					_vigencia_final,
					_prima_suscrita,
					_suma_asegurada,
					_subramo,
					_categoria_contable,
					_suma_aseg_retencion,
					_suma_aseg_facultativo,
					_suma_aseg_cesion,
					_anio
				   );
		end
	end foreach
end foreach

return 0,'','';
end
end procedure;