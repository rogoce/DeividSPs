-- Verifica si la ruta aplica para la Distribución de Reaseguro por plenos.
-- Creado    : 13/01/2012 - Autor: Roman Gordon
-- SIS v.2.0 - - DEIVID, S.A.


drop procedure sp_pro218_esp;

create procedure sp_pro218_esp()
returning char(10)	as nro_poliza,
		  char(10)	as nro_endoso,
		  char(10)	as nro_factura,
		  char(5)	as unidad,
		  integer	as _error;

define _no_factura			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_ramo			char(4);
define _cod_cober_reas		char(3);
define _par_ase_lider		char(3);
define _cod_tipoprod		char(3);
define _cod_endomov			char(3);
define _ase_lider			char(3);
define _cod_ruta			char(5);
define _tipo_mov			char(1);
define _prima_neta_emifacon	dec(16,2);
define _suma_aseg_emifacon	dec(16,2);
define _porc_partic_prima	dec(16,2);
define _sum_aseg_emifacon	dec(16,2);
define _porc_partic_coas	dec(16,2);
define _porc_partic_suma	dec(16,2);
define _suma_asegurada		dec(16,2);
define _prima_neta			dec(16,2);
define _porc_partic_reas	dec(9,6);
define _mult_plenos			dec(8,2);
define _signo				dec(8,2);
define _cnt_emigloco		smallint;
define _actualizado			smallint;
define _no_cambio			smallint;
define _tipo_prod			smallint;
define _tipopro				smallint;
define _return				smallint;
define _serie				smallint;
define _orden				smallint;
define _fila				smallint;
define _cont				smallint;
define _row					smallint;
define _vigencia_final		date; 
define _vigencia_inic		date; 

--set debug file to "sp_pro218_esp.trc";
--trace on;

set isolation to dirty read;

foreach
	select mae.periodo,
		   mae.no_factura,
		   mae.no_poliza,
		   mae.no_endoso,
		   uni.no_unidad,
		   mae.vigencia_inic_pol,
		   mae.vigencia_final_pol,
		   prd.cod_cober_reas,
		   uni.suma_asegurada,
		   sum(cob.prima_neta) as prima,
		   rea.porc_partic_prima
	  into _periodo,
		   _no_factura,
		   _no_poliza,
		   _no_endoso,
		   _no_unidad,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_cober_reas,
		   _suma_asegurada,
		   _prima_neta,
		   _porc_partic_reas
	  from endedmae mae
	 inner join emipomae emi on emi.no_poliza = mae.no_poliza
	 inner join endeduni uni on uni.no_poliza = mae.no_poliza and uni.no_endoso = mae.no_endoso
	 inner join endedcob cob on cob.no_poliza = uni.no_poliza and cob.no_endoso = uni.no_endoso and cob.no_unidad = uni.no_unidad
	 inner join prdcober prd on prd.cod_cobertura = cob.cod_cobertura
	  left join emifacon rea on rea.no_poliza = mae.no_poliza and rea.no_endoso = mae.no_endoso and rea.no_unidad = uni.no_unidad
	  left join reacomae con on con.cod_contrato = rea.cod_contrato
	 where emi.cod_ramo in ('002','020','023')
	   and mae.periodo between '2024-10' and '2024-10'
	   and mae.actualizado = 1
	   and rea.cod_contrato is null
	   and uni.prima_suscrita != 0
	 group by mae.periodo,mae.no_factura,mae.no_poliza,mae.no_endoso,uni.no_unidad,prd.cod_cober_reas,rea.porc_partic_prima,mae.vigencia_inic_pol,mae.vigencia_final_pol,uni.suma_asegurada
	 order by 1,3,4,5,6

	foreach
		select cod_ruta,
			   cod_contrato,
			   porc_partic_prima,
			   orden
		  into _cod_ruta,
			   _cod_contrato,
			   _porc_partic_prima,
			   _orden
		  from rearucon 
		 where cod_ruta in ('00841','00842','00843')
		   and cod_cober_reas = _cod_cober_reas

		let _prima_neta_emifacon = 0.00;
		let _suma_aseg_emifacon = 0.00;
		
		let _prima_neta_emifacon = _prima_neta * (_porc_partic_prima/100);
		let _suma_aseg_emifacon = _suma_asegurada * (_porc_partic_prima/100);
		
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
		values(
			_no_poliza,
			_no_endoso,
			_no_unidad,
			_cod_cober_reas,
			_orden,
			_cod_contrato,
			_cod_ruta,
			_porc_partic_prima,
			_porc_partic_prima,
			_suma_aseg_emifacon,
			_prima_neta_emifacon,
			0,
			0);

		select max(no_cambio)
		  into _no_cambio
		  from emireama
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cober_reas = _cod_cober_reas;

		/*if _no_cambio is null then
			let _no_cambio = 0;
		else
			let _no_cambio = _no_cambio + 1;
		end if
		
		insert into emireama
		values(
				_no_poliza,
				_no_unidad,
				_no_cambio,
				_cod_cober_reas,
				_vigencia_inic,
				_vigencia_final
				);

		insert into emireaco
		values(
				_no_poliza,
				_no_unidad,
				_no_cambio,
				_cod_cober_reas,
				_orden,
				_cod_contrato,
				_porc_partic_prima,
				_porc_partic_prima
				);
		*/
	end foreach
	
	return _no_poliza, _no_endoso,_no_factura,_no_unidad,0 with resume;
end foreach

end procedure;