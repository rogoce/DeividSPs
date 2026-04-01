-- Reporte Detallado de Pólizas en Adelanto de Comisión
-- Creado    : 18/09/2014 - Autor: Román Gordón
-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_che180;
create procedure sp_che180(a_compania char(3), a_cod_agente char(5))
returning	varchar(50) 	as Corredor,
			smallint		as numero_maximo_pagos,
			char(20)		as Poliza,
			dec(16,2)		as Prima_neta,
			dec(16,2)		as Prima_acumulada,
			varchar(10)		as No_Recibo,
			date			as Fecha_Pago,
			dec(16,2)		as monto_cobrado,
			dec(16,2)		as prima_neta_cob,
			dec(5,2)		as porc_partic_agt,
			dec(5,2)		as porc_comis_agt,
			dec(16,2)		as comision_pagada,
			dec(16,2)		as comis_devengada,
			dec(16,2)		as comis_saldo,
			smallint		as flag,
			varchar(50)		as Cliente,
			varchar(50)		as Compania,
			dec(16,2)       as comis_devengada_2;

define _nom_cliente			varchar(50);
define _nombre_cia			varchar(50);
define _error_desc			varchar(50);
define _nom_agente			varchar(50);
define _no_recibo			varchar(10);
define _no_doc_verif		char(20);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_tipoprod		char(3);
define _tipo_mov			char(1);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _comision_adelanto	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_pagada		dec(16,2);
define _comis_devengada		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_suscrita		dec(16,2);
define _comision_saldo		dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_neta_h		dec(16,2);
define _comis_saldo			dec(16,2);
define _prima_neta			dec(16,2);
define _adelanto_comis		smallint;
define _cnt_cobadeco		smallint;
define _max_no_pagos		smallint;
define _error				smallint;
define _flag				smallint;
define _fecha_adelanto		date;
define _fecha_inicio		date;
define _fecha_cobro			date;
define _saldo_comis         dec(16,2);
define _comis_devengada2    dec(16,2);

set isolation to dirty read;

--set debug file to "sp_che145.trc";	 																						 
--trace on;
call sp_che180b(a_cod_agente) returning _error,_error_desc;

if _error <> 0 then
	return _error_desc,_error,'',0.00,0.00,'','01/01/1900',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0,'','',0;
end if

let _no_doc_verif = '';
let _comis_saldo = 0.00;


let _nombre_cia = trim(sp_sis01(a_compania));

foreach
	select nom_agente,
		   no_pagos,
		   no_documento,
		   prima_neta,
		   prima_neta_h,
		   no_recibo,
		   date_added,
		   prima_bruta,
		   prima_neta_cob,
		   porc_partic_agt,
		   porc_comis_agt,
		   comis_pagada,
		   comis_devengada,
		   tipo_mov,
		   nom_cliente,
		   saldo_comis
	  into _nom_agente,
		   _max_no_pagos,
		   _no_documento,
		   _prima_neta,
		   _prima_neta_h,
		   _no_recibo,
		   _fecha_cobro,
		   _monto_cobrado,
		   _prima_neta_cob,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _comision_pagada,
		   _comis_devengada,
		   _tipo_mov,
		   _nom_cliente,
		   _saldo_comis
	  from tmp_det
	 order by no_documento,date_added

	let _flag = 0;
	
	{if a_cod_agente = '00226' and _no_recibo in ('1034240','VC300914') then
		continue foreach;
	end if}
	
	if _no_documento <> _no_doc_verif then
		let _no_doc_verif = _no_documento;
		let _comis_saldo = 0;
	end if

	if _tipo_mov = 'P' and _comis_saldo <= 0 then 
		--let _comision_pagada = 0.00;
		--let _comis_devengada = 0.00;
		continue foreach;
	elif _tipo_mov = 'P' and _comis_saldo  > 0 then
		let _flag = 1;
	end if
    
 	let _comis_saldo = _comis_saldo + _comision_pagada - _comis_devengada;
	--let _comis_devengada2 = _comis_devengada;
	
	return	_nom_agente,
			_max_no_pagos,
			_no_documento,
			_prima_neta,
			_prima_neta_h,
			_no_recibo,
			_fecha_cobro,
			_monto_cobrado,
			_prima_neta_cob,
			_porc_partic_agt,
			_porc_comis_agt,
			_comision_pagada,
			_comis_devengada,
			_comis_saldo,
			_flag,
			_nom_cliente,
			_nombre_cia,
			_saldo_comis
	with resume;
end foreach

drop table tmp_det;
end procedure;