-- Reporte Detallado de Pólizas en Adelanto de Comisión
-- Creado    : 18/09/2014 - Autor: Román Gordón
-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_che146;
create procedure sp_che146(a_cod_agente char(5))
returning	varchar(50) 	as Corredor,
			smallint		as numero_maximo_pagos,
			char(20)		as Poliza,
			dec(5,2)		as porc_partic_agt,
			dec(5,2)		as porc_comis_agt,
			dec(16,2)		as Prima_neta,
			dec(16,2)		as Prima_acumulada,
			dec(16,2)		as monto_cobrado,
			dec(16,2)		as prima_neta_cob,
			dec(16,2)		as comision_pagada,
			dec(16,2)		as comis_devengada,
			dec(16,2)		as comis_saldo

define _nom_agente			varchar(50);
define _error_desc			varchar(50);
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

set isolation to dirty read;

--set debug file to "sp_che146.trc";	 																						 
--trace on;

call sp_che145b(a_cod_agente) returning _error,_error_desc;

if _error <> 0 then
	return _error_desc,_error,'',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00;
end if

let _no_doc_verif = '';
let _comis_saldo = 0.00;

foreach
	select distinct no_documento
	  into _no_documento
	  from tmp_det
	  
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
			   tipo_mov
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
			   _tipo_mov
		  from tmp_det
		 where no_documento = _no_documento
		 --group by no_documento,nom_agente,no_pagos,no_documento,
		 order by date_added

		let _flag = 0;

		if _no_documento <> _no_doc_verif then
			let _no_doc_verif = _no_documento;
			let _comis_saldo = 0;
		end if

		if _tipo_mov = 'P' and _comis_saldo < 0 then 
			delete from tmp_det
			 where no_documento = _no_documento
			   and no_recibo = _no_recibo
			   and date_added = _fecha_cobro;

			continue foreach;
		elif _tipo_mov = 'P' and _comis_saldo > 0 then
			let _flag = 1;
		end if
		
		let _comis_saldo = _comis_saldo + _comision_pagada - _comis_devengada;
	end foreach
end foreach

foreach
	select nom_agente,
		   no_pagos,
		   no_documento,
		   porc_partic_agt,
		   porc_comis_agt,
		   prima_neta,
		   prima_neta_h,
		   sum(prima_bruta),
		   sum(prima_neta_cob),
		   sum(comis_pagada),
		   sum(comis_devengada),
		   sum(comis_pagada)- sum(comis_devengada)
	  into _nom_agente,
		   _max_no_pagos,
		   _no_documento,
		   _porc_partic_agt,
		   _porc_comis_agt,
		   _prima_neta,
		   _prima_neta_h,
		   _monto_cobrado,
		   _prima_neta_cob,
		   _comision_pagada,
		   _comis_devengada,
		   _comis_saldo
	  from tmp_det
	 group by nom_agente,no_pagos,no_documento,porc_partic_agt,porc_comis_agt,prima_neta,prima_neta_h
	 order by no_documento
	
	return	_nom_agente,
			_max_no_pagos,
			_no_documento,
			_porc_partic_agt,
			_porc_comis_agt,
			_prima_neta,
			_prima_neta_h,
			_monto_cobrado,
			_prima_neta_cob,
			_comision_pagada,
			_comis_devengada,
			_comis_saldo
	with resume;
end foreach

drop table tmp_det;
end procedure;