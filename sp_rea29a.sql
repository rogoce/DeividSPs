--Reporte para el Cuadre de las cuentas de Reaseguro Cedido
--Creado    : 28/12/2015 - Autor: Román Gordón
--execute procedure sp_rea29a(today)

drop procedure sp_rea29a;
create procedure "informix".sp_rea29a(a_fecha date)
returning	char(20)	as poliza,
			char(10)	as remesa,
			integer		as renglon,
			date		as vigencia_inic,
			date		as vigencia_final,
			varchar(50)	as contratante,
			dec(16,2)	as suma_asegurada,
			dec(16,2)	as prima,
			dec(16,2)	as saldo_pxc,
			char(5)		as unidad,
			dec(16,2)	as suma_asegurada_uni,			
			dec(16,2)	as prima_unidad,
			dec(16,2)	as saldo_pxc_unidad,
			char(3)		as cod_cober_reas,
			varchar(50)	as contrato,
			smallint	as tipo_contrato,
			varchar(30)	as coasegurador,
			dec(9,6)	as porc_partic_prima,
			smallint	as serie,
			dec(16,2)	as suma_asegurada_reas,			
			dec(16,2)	as prima_reas,
			dec(16,2)	as saldo_pxc_reas,
			dec(16,2)	as suma_asegurada_xl,
			dec(16,2)	as prima_xl,
			dec(16,2)	as suma_aseg_xl_prorrata,
			dec(16,2)	as prima_xl_prorrata,
			dec(16,2)	as prima_pxc_xl,
			dec(16,2)	as prima_pxc_xl_prorrata;

begin

define _nom_contrato			varchar(50);
define _contratante				varchar(50);
define _error_desc				varchar(50);
define _nom_compania			varchar(30);
define _nom_coasegur			varchar(30);
define _no_documento			char(20);
define _no_remesa				char(10);
define _no_poliza				char(10);
define _no_unidad				char(5);
define _cod_cober_reas			char(3);
define _cod_tipoprod			char(3);
define _cod_ramo				char(3);
define _suma_aseg_xl_prorrata	dec(16,2);
define _saldo_pxc_xl_prorrata	dec(16,2);
define _prima_xl_prorrata		dec(16,2);
define _suma_aseg_reas			dec(16,2);
define _saldo_pxc_reas			dec(16,2);
define _prima_acum_uni			dec(16,2);
define _prima_neta_uni			dec(16,2);
define _suma_aseg_pol			dec(16,2);
define _suma_aseg_uni			dec(16,2);
define _saldo_pxc_uni			dec(16,2);
define _suma_aseg_xl			dec(16,2);
define _saldo_pxc_xl			dec(16,2);
define _prima_neta				dec(16,2);
define _prima_reas				dec(16,2);
define _saldo_pxc				dec(16,2);
define _prima_xl				dec(16,2);
define _porc_partic_coas		dec(7,4);
define _porc_partic_prima		dec(9,6);
define _porc_cont_partic		dec(9,6);
define _prorrata_uni			dec(9,6);
define _prorrata				dec(9,6);
define _porc_partic_reas		dec(9,6);
define _dias_vigencia			smallint;
define _dias_contrato			smallint;
define _tipo_contrato			smallint;
define _contrato_xl				smallint;
define _no_cambio				smallint;
define _serie					smallint;
define _renglon					integer;
define _error					integer;
define _vigencia_final			date;
define _vigencia_inic			date;
define _fecha_desde				date;


set isolation to dirty read;

--set debug file to "sp_rea29a.trc"; 
--trace on;

let _fecha_desde = a_fecha - 1 units year;

select nombre
  into _nom_compania
  from emicoase
 where cod_coasegur = '036';

foreach with hold
	select e.no_documento,
		   e.no_poliza,
		   e.vigencia_inic,
		   e.vigencia_final,
		   e.suma_asegurada,
		   e.cod_tipoprod,
		   e.prima_neta,
		   c.nombre,
		   d.no_remesa,
		   d.renglon,
		   d.prima_neta
	  into _no_documento,
		   _no_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _suma_aseg_pol,
		   _cod_tipoprod,
		   _prima_neta,
		   _contratante,
		   _no_remesa,
		   _renglon,
		   _saldo_pxc
	  from emipomae e, cliclien c,cobredet d
	 where e.cod_pagador = c.cod_cliente
	   and e.no_poliza = d.no_poliza
	   and e.vigencia_final >= a_fecha
	   and e.vigencia_inic < a_fecha
	   and d.fecha < a_fecha
	   and e.vigencia_inic >= _fecha_desde
	   and e.cod_ramo in ('001','003')
	   and e.estatus_poliza = 1
	   and e.actualizado = 1
	   and d.tipo_mov in ('P','N')
	   and d.actualizado = 1
	   --and no_documento = '0112-00066-01'

	let _dias_vigencia = _vigencia_final - _vigencia_inic;
	let _dias_contrato = _vigencia_final - a_fecha;
	let _prorrata = _dias_contrato / _dias_vigencia;
	let _porc_partic_coas = 100;

	if _cod_tipoprod = '001' then --Coas. Mayoritario
		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza = _no_poliza
		   and cod_coasegur = '036'; --Ancon
	end if

	{select saldo_pxc
	  into _saldo_pxc
	  from cobmoros
	 where no_documento = _no_documento;

	if _saldo_pxc is null then
		let _saldo_pxc = 0.00;
	end if}

	let _suma_aseg_pol = _suma_aseg_pol * (_porc_partic_coas/100);
	let _prima_neta = _prima_neta * (_porc_partic_coas/100);
	let _saldo_pxc = _saldo_pxc * (_porc_partic_coas/100);

	select sum(prima_neta)
	  into _prima_acum_uni
	  from emipouni
	 where no_poliza = _no_poliza;

	foreach
		select no_unidad,
			   prima_neta
		  into _no_unidad,
			   _prima_neta_uni
		  from emipouni
		 where no_poliza = _no_poliza

		let _prorrata_uni = _prima_neta_uni/_prima_acum_uni;
		let _prima_neta_uni = _prima_neta * _prorrata_uni;
		let _suma_aseg_uni = _suma_aseg_pol * _prorrata_uni;
		let _saldo_pxc_uni = _saldo_pxc * _prorrata_uni;

		foreach
			select distinct e.cod_cober_reas,
				   e.porc_partic_prima,
				   r.serie,
				   r.nombre,
				   r.tipo_contrato,
				   s.nombre,
				   c.porc_cont_partic,
				   c.contrato_xl,
				   e.porc_proporcion
			  into _cod_cober_reas,
				   _porc_partic_prima,
				   _serie,
				   _nom_contrato,
				   _tipo_contrato,
				   _nom_coasegur,
				   _porc_cont_partic,
				   _contrato_xl,
				   _porc_partic_reas
			  from cobreaco e
			  left join reacomae r on e.cod_contrato = r.cod_contrato
			  left join reacoase c on e.cod_cober_reas = c.cod_cober_reas and e.cod_contrato = c.cod_contrato
			  left join emicoase s on s.cod_coasegur = c.cod_coasegur
			 where e.no_remesa = _no_remesa
			   and e.renglon = _renglon

			if _tipo_contrato = 1 then
				let _nom_coasegur = _nom_compania;
				let _porc_cont_partic = 100;
			elif _tipo_contrato = 3 then
				let _nom_coasegur = 'FACULTATIVO';
				let _porc_cont_partic = 100;
			end if

			{let _porc_partic_reas = 0;

			if _cod_cober_reas = '001' then
				let _porc_partic_reas = 70;
			elif _cod_cober_reas = '021' then
				let _porc_partic_reas = 30;
			elif _cod_cober_reas = '003' then
				let _porc_partic_reas = 90;
			elif _cod_cober_reas = '022' then
				let _porc_partic_reas = 10;
			end if}

			let _prima_reas = _prima_neta_uni * (_porc_partic_reas/100) * (_porc_partic_prima/100)* (_porc_cont_partic/100);
			let _suma_aseg_reas = _suma_aseg_uni * (_porc_partic_prima/100)*(_porc_cont_partic/100);
			let _saldo_pxc_reas = _saldo_pxc_uni* (_porc_partic_reas/100) * (_porc_partic_prima/100)*(_porc_cont_partic/100);

			let _saldo_pxc_xl_prorrata = 0.00;
			let _suma_aseg_xl_prorrata = 0.00;
			let _prima_xl_prorrata = 0.00;
			let _suma_aseg_xl = 0.00;
			let _saldo_pxc_xl = 0.00;
			let _prima_xl = 0.00;

			if _contrato_xl = 1 then
				let _prima_xl = _prima_reas;
				let _suma_aseg_xl = _suma_aseg_reas;
				
				let _prima_xl_prorrata = _prima_xl * _prorrata;
				
				--let _saldo_pxc_xl = _saldo_pxc_reas;
				--let _saldo_pxc_xl_prorrata = _saldo_pxc_xl * _prorrata;
			end if
			
			let _saldo_pxc_xl_prorrata = _saldo_pxc_reas * _prorrata;

			return  _no_documento,
					_no_remesa,
					_renglon,
					_vigencia_inic,
					_vigencia_final,
					_contratante,
					_suma_aseg_pol,
					_prima_neta,
					_saldo_pxc,
					_no_unidad,
					_suma_aseg_uni,
					_prima_neta_uni,
					_saldo_pxc_uni,
					_cod_cober_reas,
					_nom_contrato,
					_tipo_contrato,
					_nom_coasegur,
					_porc_partic_prima,
					_serie,
					_suma_aseg_reas,
					_prima_reas,
					_saldo_pxc_reas,
					_suma_aseg_xl,
					_prima_xl,
					_suma_aseg_xl_prorrata,
					_prima_xl_prorrata,
					_saldo_pxc_xl,
					_saldo_pxc_xl_prorrata					
					with resume;
		end foreach
	end foreach
end foreach

drop table if exists temp_det;
end

end procedure;