--  Procedimiento para determinar si una poliza electronico aplica o no para el descuento de 5% 
-- Creado: 14/12/2011 - Autor: Armando Moreno M.

drop procedure sp_sis463;
create procedure sp_sis463(a_no_documento char(20), a_periodo CHAR(7))
returning	smallint,
			varchar(100);

define _error_desc			varchar(100);
define _nom_grupo			varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo_primer_pago	char(7);
define _periodo_pago		char(7);
define _cod_grupo			char(5);
define _cod_tipoprod		char(3);
define _cod_perpago			char(3);
define _cod_ramo			char(3);
define _prima_bruta			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _exigible			dec(16,2);
define _saldo				dec(16,2);
define _letra				dec(16,2);
define _tipo_produccion		smallint;
define _existe_end			smallint;
define _existe_rev			smallint;
define _fronting			smallint;
define _no_pagos			smallint;
define _aplica				smallint;
define _meses				smallint;
define _cant				smallint;
define _fecha_primer_pago	date;
define _fecha_ult_periodo	date;
define _fecha_suscripcion	date;
define _fecha_morosidad		date;
define _fecha_lim_pago		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _ult_pago			date;

set isolation to dirty read;

let _prima_bruta = 0;
let _no_pagos = 0;
let _cant = 0;

--set debug file to "sp_sis462.trc";
--trace on;

let _fecha_hoy = today;
let _fecha_morosidad = '01/04/2020';
let _fecha_ult_periodo = mdy(a_periodo[6,7],1,a_periodo[1,4]);

{foreach
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	 order by vigencia_final desc

	if _vigencia_inic <= _fecha_hoy then
		exit foreach;
	end if
end foreach
}

drop table if exists tmp_poliza;
create temp table tmp_poliza(
no_poliza	char(10),
aplica		smallint,
desc_aplica	varchar(100),
por_vencer	dec(16,2),
exigible	dec(16,2),
corriente	dec(16,2),
monto_30	dec(16,2),
monto_60	dec(16,2),
monto_90	dec(16,2),
saldo		dec(16,2),
primary key(no_poliza)) with no log;


foreach
	select mae.no_poliza,
		   vigencia_inic,
		   fecha_suscripcion,
		   cod_ramo,
		   no_pagos,
		   prima_bruta,
		   cod_tipoprod,
		   cod_perpago,
		   fronting,
		   cod_grupo,
		   fecha_primer_pago
	  into _no_poliza,
		   _vigencia_inic,
		   _fecha_suscripcion,
		   _cod_ramo,
		   _no_pagos,
		   _prima_bruta,
		   _cod_tipoprod,
		   _cod_perpago,
		   _fronting,   
		   _cod_grupo,
		   _fecha_primer_pago
	  from emipomae mae
	 where mae.vigencia_final >= _fecha_ult_periodo
	   and mae.estatus_poliza = 1
	   and mae.actualizado = 1
	   and mae.no_documento = a_no_documento
	 order by mae.vigencia_inic
	
	let _aplica = 1;

	call sp_cob33d('001','001',a_no_documento,a_periodo,_fecha_morosidad)
	returning	_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;

	if _cod_grupo in ('00087','124','125','1122','77850','1090','77960','78020') then  -- SD#3010 77960  11/04/2022 10:00  
		let _aplica = 0;
		
		select nombre
		  into _nom_grupo
		  from cligrupo
		 where cod_grupo = _cod_grupo;
		
		insert into tmp_poliza
		values(	_no_poliza,0,'NO APLICA PARA EL GRUPO ' || trim(_cod_grupo) || '- ' || trim(_nom_grupo),
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo);
		continue foreach;
	end if

	--Excepcion de Coaseguros
	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	if _tipo_produccion in (2,3) then
		insert into tmp_poliza
		values(	_no_poliza,0,"LA PÓLIZA ES COASEGURO.",
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo);
		continue foreach;
	end if

	--Excepcion Facultativos
	let _cant = 0;
	let _cant = sp_sis439(_no_poliza);

	if _cant = 1 then
		insert into tmp_poliza
		values(	_no_poliza,0,'FACULTATIVOS NO APLICAN',
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo);
		continue foreach;
	end if

	let _cant = 0;

	select count(*)
	  into _cant
	  from emipocob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_poliza = _no_poliza
	   and b.nombre like 'COLIS%'
	   and a.prima > 0.00;

	if _cant = 0 then
		insert into tmp_poliza
		values(	_no_poliza,0,'NO TIENE COBERTURA COMPLETA',
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo);
		continue foreach;
	end if

	let _cant = 0;

	select count(*)
	  into _cant
	  from emiauto
	 where no_poliza = _no_poliza
	   and uso_auto = 'P';

	if _cant = 0 then
		insert into tmp_poliza
		values(	_no_poliza,0,'EL USO DEL AUTO NO ES PARTICULAR',
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo);
		continue foreach;
	end if

	let _existe_end = 0;

	select count(*)
	  into _existe_end
	  from endedmae
	 where no_documento   = a_no_documento
	   and cod_endomov = "033"
	   and periodo = a_periodo
	   and actualizado = 1;	     --endoso de descuento covid 19

	let _existe_rev = 0;
	select count(*)
	  into _existe_rev
	  from endedmae
	 where no_documento   = a_no_documento
	   and cod_endomov = '034'		 --endoso de reversion de descuento covid19
	   and periodo = a_periodo
	   and actualizado = 1;

	if (_existe_end - _existe_rev) > 0 then
		insert into tmp_poliza
		values(	_no_poliza,0,'ENDOSO YA EXISTE PARA EL PERIODO ' || a_periodo,
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo);
		continue foreach;
	end if

	--Letra pactada
	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	begin
		on exception in (-1267)
		
			let _fecha_primer_pago = mdy(month(_fecha_primer_pago),28,year(_fecha_primer_pago));
			let _ult_pago = _fecha_primer_pago + ((_no_pagos - 1) * _meses ) units month;
		end exception
		let _ult_pago = _fecha_primer_pago + ((_no_pagos - 1) * _meses ) units month;
	end
	
	let _periodo_primer_pago = sp_sis39(_fecha_primer_pago);
	let _periodo_pago = sp_sis39(_ult_pago);

	if a_periodo > _periodo_pago or a_periodo < _periodo_primer_pago then
		insert into tmp_poliza
		values(	_no_poliza,
				0,
				'LA PÓLIZA NO TIENE PAGOS PACTADOS PARA EL PERIODO ' || a_periodo,
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo);
		continue foreach;
	end if

-- morosidad
if (_monto_60 + _monto_90) > 5 then
	insert into tmp_poliza
	values(	_no_poliza,
			0,
			'LOS PAGOS DE LA PÓLIZA NO ESTÁN AL DÍA. MOROSIDAD A 60+ DIAS: ' || _monto_60 + _monto_90,
			_por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_saldo
		  );
	continue foreach;
end if

if _vigencia_inic < _fecha_morosidad and _saldo <= 0 then
		insert into tmp_poliza
		values(	_no_poliza,
				0,
				'LA PÓLIZA NO TIENE SALDO AL PRINCIPIO DEL BENEFICIO.',
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo
			  );
	continue foreach;
end if

insert into tmp_poliza
values(	_no_poliza,
		1,
		'SI APLICA',
		_por_vencer,
		_exigible,
		_corriente,
		_monto_30,
		_monto_60,
		_monto_90,
		_saldo);

end foreach

return 0,'Actualizacion Exitosa';

end procedure;