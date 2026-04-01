-- Procedure que Genera el Asiento de Diario en el Mayor General del modulo de planilla

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac135;

create procedure sp_sac135(
a_usuario	char(8),
a_origen	smallint
) returning integer,
			integer,
            char(100);
 
define _cheq_planilla	char(3);
define _notrx			integer;
define _tipo			char(2);
define _comprobante		char(15);
define _fecha			date;
define _concepto		char(3);
define _ccosto			char(3);
define _descrip			char(50);
define _monto			dec(16,2);						 
define _moneda      	char(2);
define _debito      	dec(16,2);
define _credito     	dec(16,2);
define _status      	char(1);
define _origen      	char(3);
define _usuario     	char(15);
define _fechacap    	datetime year to second;

define _no_remesa		char(10);
define _tipo_remesa		char(1);
define _renglon			smallint;
define _tipo_mov		char(1);

define _tipo_comp		smallint;
define _tipo_comp2		smallint;
define _tipo_compd		char(50);
define _debito_tab		dec(16,2);
define _credito_tab		dec(16,2);
define _debito_tab2		dec(16,2);
define _credito_tab2	dec(16,2);

define _debito_rea		dec(16,2);
define _credito_rea		dec(16,2);
define _monto_rea		dec(16,2);

define _cuenta			char(25);
define _linea			integer;
define _linea_aux		integer;
define _cantidad		integer;

define _no_requis		char(10);
define _fecha_impresion	date;
define _fecha_anulado	date;
define _periodo1		char(7);
define _periodo2		char(7);
define _cod_auxiliar	char(5);

define _error			integer;
define _error_isam		integer;
define _cta_auxiliar	char(5);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _no_tranrec		char(10);
define _no_reclamo		char(10);

define _mayor_error		integer;
define _mayor_desc		char(150);

define _centro_costo	char(3);
define _centro_costo2	char(3);

define _cod_chequera	char(3);

define _error_code		integer;
define _error_desc		char(100);
define _cnt_reg			integer;
define _cnt_reg_acum	integer;

on exception set _error_code,_error_isam,_error_desc 
 	return _error_code,_error_isam, _error_desc;
end exception

--set debug file to "sp_sac135.trc";
--trace on;

set isolation to dirty read; 

let _cheq_planilla = "013";

create temp table tmp_che(
no_requis	char(10),
fecha		date
) with no log;

drop table if exists tmp_posteo;
create temp table tmp_posteo(
notrx integer
) with no log;


let _tipo			= "01";	 -- Comprobante Normal
let _descrip		= "";
let _monto			= 0.00;
let _moneda			= "00";
let _status			= "I";
let _usuario		= a_usuario;
let _fechacap		= current;
let _cnt_reg_acum = 0;


-- Cheques Pagados

foreach
 select	no_requis,
        fecha_impresion,
		centro_costo
   into _no_requis,
        _fecha,
		_centro_costo
   from chqchmae
  where pagado       = 1
    and sac_asientos = 0
	and tipo_requis  = "C"
	and cod_chequera = _cheq_planilla

	if _centro_costo is null then

		call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

		if _error <> 0 then
			return _error,0, _error_desc;
		end if

	end if

	insert into tmp_che
	values (_no_requis, _fecha);

	update chqchmae
	   set sac_asientos = 2
	 where no_requis    = _no_requis;

	let _periodo = sp_sis39(_fecha);

	update chqchcta
	   set fecha        = _fecha,
	       periodo      = _periodo,
		   tipo_requis  = "C"
	 where no_requis    = _no_requis
	   and tipo         = 1;

	update chqchcta
	   set centro_costo = _centro_costo
	 where no_requis    = _no_requis
	   and tipo         = 1
	   and centro_costo is null;

	foreach
	 select renglon
	   into _renglon
	   from chqchcta
	  where no_requis = _no_requis
	    and tipo      = 1 		

		update chqctaux
		   set tipo         = 1,
		       fecha        = _fecha
		 where no_requis    = _no_requis
		   and renglon      = _renglon;

		update chqctaux
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and renglon      = _renglon
	   	   and centro_costo is null;

	end foreach

end foreach

select count(*)
  into _cantidad
  from tmp_che;

if _cantidad <> 0 then

	let _concepto	   = "004"; -- Planilla
	let _origen		   = "PLA"; -- Planilla
	let _tipo_comp     = 1;
	let _linea		   = 0;
	let _centro_costo2 = "0";

	let _fecha_impresion = MDY(1, 1, 1901);
	foreach
		select x.centro_costo,
			   y.fecha,
			   x.cuenta,
			   sum(x.debito),
			   sum(x.credito)
		  into _centro_costo,
		  	   _fecha,
		  	   _cuenta,
		  	   _debito,
		  	   _credito
		  from chqchcta x, tmp_che y
		 where x.no_requis = y.no_requis
		   and x.tipo      = 1
		 group by x.centro_costo, y.fecha, x.cuenta
		
		let _cnt_reg_acum = _cnt_reg_acum + 1;
	end foreach

	foreach
		select x.centro_costo,
			   y.fecha,
			   x.cuenta,
			   sum(x.debito),
			   sum(x.credito)
		  into _centro_costo,
		  	   _fecha,
		  	   _cuenta,
		  	   _debito,
		  	   _credito
		  from chqchcta x, tmp_che y
		 where x.no_requis = y.no_requis
		   and x.tipo      = 1
		 group by x.centro_costo, y.fecha, x.cuenta
		 order by x.centro_costo, y.fecha, x.cuenta

		if _fecha_impresion <> _fecha         or
		   _centro_costo    <> _centro_costo2 then

			let _periodo     = sp_sis39(_fecha);
			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || _periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || _periodo[6,7] || _periodo[3,4] || _tipo_comp;

			-- Contador de Comprobantes

			let _notrx = sp_sac10();

			insert into tmp_posteo
			values (_notrx);

			-- Insercion de Comprobantes

			insert into cgltrx1(
			trx1_notrx,
			trx1_tipo,
			trx1_comprobante,
			trx1_fecha,
			trx1_concepto,
			trx1_ccosto,
			trx1_descrip,
			trx1_monto,
			trx1_moneda,
			trx1_debito,
			trx1_credito,
			trx1_status,
			trx1_origen,
			trx1_usuario,
			trx1_fechacap
			)
			values(
			_notrx,
			_tipo,
			_comprobante,
			_fecha,
			_concepto,
			_centro_costo,
			_descrip,
			_monto,
			_moneda,
			0.00,
			0.00,
			_status,
			_origen,
			_usuario,
			_fechacap
			);

			let _fecha_impresion = _fecha;
			let _linea           = 0;
			let _centro_costo2   = _centro_costo;

		end if

		-- Trazabilidad con Cheques

		update chqchcta
		   set sac_notrx    = _notrx
		 where tipo         = 1
		   and fecha        = _fecha
		   and centro_costo = _centro_costo
		   and tipo_requis  = "C"
		   and sac_notrx    is null;

		-- Detalle del Comprobante

		let _linea = _linea + 1;

		insert into cgltrx2(
		trx2_notrx,
		trx2_tipo,
		trx2_linea,
		trx2_cuenta,
		trx2_ccosto,
		trx2_debito,
		trx2_credito,
		trx2_actlzdo
		)
		values(
		_notrx,
		_tipo,
		_linea,
		_cuenta,
		_centro_costo,
		_debito,
		_credito,
		0
		);

		update cgltrx1
		   set trx1_debito  = trx1_debito  + _debito,
		       trx1_credito = trx1_credito + _credito,
			   trx1_monto   = trx1_monto   + _debito
		 where trx1_notrx   = _notrx;

		-- Auxiliar por Programa

		let _linea_aux = 0;

		foreach
		 select x.cod_auxiliar,
		 		sum(x.debito),
		        sum(x.credito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqctaux x, tmp_che y
		  where x.no_requis    = y.no_requis
			and x.tipo         = 1
			and x.fecha        = _fecha
			and x.centro_costo = _centro_costo
		    and x.cuenta       = _cuenta
 		  group by x.cod_auxiliar

			let _linea_aux = _linea_aux + 1;

			call sp_sac136(_cuenta, _cod_auxiliar) returning _error, _error_desc;

			if _error <> 0 then
				return _error,0, _error_desc;
			end if

			insert into cgltrx3(
			trx3_notrx,
			trx3_tipo,
			trx3_lineatrx2,
			trx3_linea,
			trx3_cuenta,
			trx3_auxiliar,
			trx3_debito,
			trx3_credito,
			trx3_actlzdo
			)
			values(
			_notrx,
			_tipo,
			_linea,
			_linea_aux,
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito,
			0
			);

		end foreach
	return 1,_cnt_reg_acum,'' with resume;
	end foreach

end if

-- Cheques Anulados

delete from tmp_che;

foreach
 select	no_requis,
        fecha_anulado,
		centro_costo
   into _no_requis,
        _fecha,
		_centro_costo
   from chqchmae
  where pagado       = 1
    and anulado      = 1
    and sac_anulados = 0
	and tipo_requis  = "C"
	and cod_chequera = _cheq_planilla

	if _centro_costo is null then

		call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

		if _error <> 0 then
			return _error,0, _error_desc;
		end if

	end if

	insert into tmp_che
	values (_no_requis, _fecha);

	update chqchmae
	   set sac_anulados = 2
	 where no_requis    = _no_requis;

	let _periodo = sp_sis39(_fecha);

	update chqchcta
	   set fecha        = _fecha,
	       periodo      = _periodo,
		   tipo_requis  = "C"
	 where no_requis    = _no_requis
	   and tipo         = 2;

	update chqchcta
	   set centro_costo = _centro_costo
	 where no_requis    = _no_requis
	   and tipo         = 2
	   and centro_costo is null;

	foreach
	 select renglon
	   into _renglon
	   from chqchcta
	  where no_requis = _no_requis
	    and tipo      = 2 		

		update chqctaux
		   set tipo         = 2,
		       fecha        = _fecha
		 where no_requis    = _no_requis
		   and renglon      = _renglon;

		update chqctaux
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and renglon      = _renglon
	       and centro_costo is null;

	end foreach

end foreach

select count(*)
  into _cantidad
  from tmp_che;

if _cantidad <> 0 then

	let _concepto	   = "004"; -- Planilla
	let _origen		   = "PLA"; -- Planilla
	let _tipo_comp     = 2;
	let _linea		   = 0;
	let _centro_costo2 = "0";

	let _fecha_impresion = MDY(1, 1, 1901);
	foreach
		select x.centro_costo,
			   y.fecha,
			   x.cuenta,
			   sum(x.debito),
			   sum(x.credito)
		  into _centro_costo,
		  	   _fecha,
		  	   _cuenta,
		  	   _debito,
		  	   _credito
		  from chqchcta x, tmp_che y
		 where x.no_requis = y.no_requis
		   and x.tipo      = 2
		 group by x.centro_costo, y.fecha, x.cuenta

		let _cnt_reg_acum = _cnt_reg_acum + 1;
	end foreach

	foreach
	 select	x.centro_costo,
	        y.fecha,
	        x.cuenta,
	 		sum(x.debito),
			sum(x.credito)
	   into	_centro_costo,
	        _fecha,
	        _cuenta,
	   		_debito,
			_credito
	   from	chqchcta x, tmp_che y
	  where x.no_requis = y.no_requis
	    and x.tipo      = 2
	  group by x.centro_costo, y.fecha, x.cuenta
	  order by x.centro_costo, y.fecha, x.cuenta

		if _fecha_impresion <> _fecha         or
		   _centro_costo    <> _centro_costo2 then

			let _periodo     = sp_sis39(_fecha);
			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || _periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || _periodo[6,7] || _periodo[3,4] || _tipo_comp;

			-- Contador de Comprobantes

			let _notrx = sp_sac10();

			insert into tmp_posteo
			values (_notrx);

			-- Insercion de Comprobantes

			insert into cgltrx1(
			trx1_notrx,
			trx1_tipo,
			trx1_comprobante,
			trx1_fecha,
			trx1_concepto,
			trx1_ccosto,
			trx1_descrip,
			trx1_monto,
			trx1_moneda,
			trx1_debito,
			trx1_credito,
			trx1_status,
			trx1_origen,
			trx1_usuario,
			trx1_fechacap
			)
			values(
			_notrx,
			_tipo,
			_comprobante,
			_fecha,
			_concepto,
			_centro_costo,
			_descrip,
			_monto,
			_moneda,
			0.00,
			0.00,
			_status,
			_origen,
			_usuario,
			_fechacap
			);

			let _fecha_impresion = _fecha;
			let _linea           = 0;
			let _centro_costo2   = _centro_costo;

		end if

		-- Trazabilidad con Cheques

		update chqchcta
		   set sac_notrx    = _notrx
		 where tipo         = 2
		   and fecha        = _fecha
		   and centro_costo = _centro_costo
		   and tipo_requis  = "C"
		   and sac_notrx    is null;

		-- Detalle del Comprobante

		let _linea = _linea + 1;

		insert into cgltrx2(
		trx2_notrx,
		trx2_tipo,
		trx2_linea,
		trx2_cuenta,
		trx2_ccosto,
		trx2_debito,
		trx2_credito,
		trx2_actlzdo
		)
		values(
		_notrx,
		_tipo,
		_linea,
		_cuenta,
		_centro_costo,
		_debito,
		_credito,
		0
		);

		update cgltrx1
		   set trx1_debito  = trx1_debito  + _debito,
		       trx1_credito = trx1_credito + _credito,
			   trx1_monto   = trx1_monto   + _debito
		 where trx1_notrx   = _notrx;

		-- Auxiliar por Programa

		let _linea_aux = 0;

		foreach
		 select x.cod_auxiliar,
		 		sum(x.debito),
		        sum(x.credito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqctaux x, tmp_che y
		  where x.no_requis    = y.no_requis
			and x.tipo         = 2
			and x.fecha        = _fecha
			and x.centro_costo = _centro_costo
		    and x.cuenta       = _cuenta
 		  group by x.cod_auxiliar
			
			call sp_sac136(_cuenta, _cod_auxiliar) returning _error, _error_desc;

			if _error <> 0 then
				return _error,0, _error_desc;
			end if

			let _linea_aux = _linea_aux + 1;

			insert into cgltrx3(
			trx3_notrx,
			trx3_tipo,
			trx3_lineatrx2,
			trx3_linea,
			trx3_cuenta,
			trx3_auxiliar,
			trx3_debito,
			trx3_credito,
			trx3_actlzdo
			)
			values(
			_notrx,
			_tipo,
			_linea,
			_linea_aux,
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito,
			0
			);

		end foreach

		return 1,_cnt_reg_acum,'' with resume;

	end foreach

end if

-- ACH Pagados

delete from tmp_che;

foreach
 select	no_requis,
        fecha_impresion,
		centro_costo
   into _no_requis,
        _fecha,
		_centro_costo
   from chqchmae
  where pagado       = 1
    and sac_asientos = 0
	and tipo_requis  = "A"
	and cod_chequera = _cheq_planilla
	
	if _centro_costo is null then

		call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

		if _error <> 0 then
			return _error,0, _error_desc;
		end if

	end if

	insert into tmp_che
	values (_no_requis, _fecha);

	update chqchmae
	   set sac_asientos = 2
	 where no_requis    = _no_requis;

	let _periodo = sp_sis39(_fecha);

	update chqchcta
	   set fecha        = _fecha,
	       periodo      = _periodo,
		   tipo_requis  = "A"
	 where no_requis    = _no_requis
	   and tipo         = 1;

	update chqchcta
	   set centro_costo = _centro_costo
	 where no_requis    = _no_requis
	   and tipo         = 1
	   and centro_costo is null;

	foreach
	 select renglon
	   into _renglon
	   from chqchcta
	  where no_requis = _no_requis
	    and tipo      = 1 		

		update chqctaux
		   set tipo         = 1,
		       fecha        = _fecha
		 where no_requis    = _no_requis
		   and renglon      = _renglon;

		update chqctaux
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and renglon      = _renglon
	   	   and centro_costo is null;

	end foreach

end foreach

select count(*)
  into _cantidad
  from tmp_che;

if _cantidad <> 0 then

	let _concepto	   = "004"; -- Planilla
	let _origen		   = "PLA"; -- Planilla
	let _tipo_comp     = 3;
	let _linea		   = 0;
	let _centro_costo2 = "0";

	let _fecha_impresion = MDY(1, 1, 1901);

	foreach
		select x.centro_costo,
			   y.fecha,
			   x.cuenta,
			   sum(x.debito),
			   sum(x.credito)
		  into _centro_costo,
		  	   _fecha,
		  	   _cuenta,
		  	   _debito,
		  	   _credito
		  from chqchcta x, tmp_che y
		 where x.no_requis = y.no_requis
		   and x.tipo      = 1
		 group by x.centro_costo, y.fecha, x.cuenta
		 	
		let _cnt_reg_acum = _cnt_reg_acum + 1;
	end foreach

	foreach
	 select	x.centro_costo,
	        y.fecha,
	        x.cuenta,
	 		sum(x.debito),
			sum(x.credito)
	   into	_centro_costo,
	        _fecha,
	        _cuenta,
	   		_debito,
			_credito
	   from	chqchcta x, tmp_che y
	  where x.no_requis = y.no_requis
	    and x.tipo      = 1
	  group by x.centro_costo, y.fecha, x.cuenta
	  order by x.centro_costo, y.fecha, x.cuenta

		if _fecha_impresion <> _fecha         or
		   _centro_costo    <> _centro_costo2 then

			let _periodo     = sp_sis39(_fecha);
			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || _periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || _periodo[6,7] || _periodo[3,4] || _tipo_comp;

			-- Contador de Comprobantes

			let _notrx = sp_sac10();

			insert into tmp_posteo
			values (_notrx);

			-- Insercion de Comprobantes

			insert into cgltrx1(
			trx1_notrx,
			trx1_tipo,
			trx1_comprobante,
			trx1_fecha,
			trx1_concepto,
			trx1_ccosto,
			trx1_descrip,
			trx1_monto,
			trx1_moneda,
			trx1_debito,
			trx1_credito,
			trx1_status,
			trx1_origen,
			trx1_usuario,
			trx1_fechacap
			)
			values(
			_notrx,
			_tipo,
			_comprobante,
			_fecha,
			_concepto,
			_centro_costo,
			_descrip,
			_monto,
			_moneda,
			0.00,
			0.00,
			_status,
			_origen,
			_usuario,
			_fechacap
			);

			let _fecha_impresion = _fecha;
			let _linea           = 0;
			let _centro_costo2   = _centro_costo;

		end if

		-- Trazabilidad con Cheques

		update chqchcta
		   set sac_notrx    = _notrx
		 where tipo         = 1
		   and fecha        = _fecha
		   and centro_costo = _centro_costo
		   and tipo_requis  = "A"
		   and sac_notrx    is null;

		-- Detalle del Comprobante

		let _linea = _linea + 1;

		insert into cgltrx2(
		trx2_notrx,
		trx2_tipo,
		trx2_linea,
		trx2_cuenta,
		trx2_ccosto,
		trx2_debito,
		trx2_credito,
		trx2_actlzdo
		)
		values(
		_notrx,
		_tipo,
		_linea,
		_cuenta,
		_centro_costo,
		_debito,
		_credito,
		0
		);

		update cgltrx1
		   set trx1_debito  = trx1_debito  + _debito,
		       trx1_credito = trx1_credito + _credito,
			   trx1_monto   = trx1_monto   + _debito
		 where trx1_notrx   = _notrx;

		-- Auxiliar por Programa

		let _linea_aux = 0;

		foreach
		 select x.cod_auxiliar,
		 		sum(x.debito),
		        sum(x.credito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqctaux x, tmp_che y
		  where x.no_requis    = y.no_requis
			and x.tipo         = 1
			and x.fecha        = _fecha
			and x.centro_costo = _centro_costo
		    and x.cuenta       = _cuenta
 		  group by x.cod_auxiliar

			let _linea_aux = _linea_aux + 1;

			call sp_sac136(_cuenta, _cod_auxiliar) returning _error, _error_desc;

			if _error <> 0 then
				return _error,0, _error_desc;
			end if

			insert into cgltrx3(
			trx3_notrx,
			trx3_tipo,
			trx3_lineatrx2,
			trx3_linea,
			trx3_cuenta,
			trx3_auxiliar,
			trx3_debito,
			trx3_credito,
			trx3_actlzdo
			)
			values(
			_notrx,
			_tipo,
			_linea,
			_linea_aux,
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito,
			0
			);

		end foreach
		return 1,_cnt_reg_acum,'' with resume;
	end foreach

end if

-- ACH Anulados

delete from tmp_che;

foreach
 select	no_requis,
        fecha_anulado,
		centro_costo
   into _no_requis,
        _fecha,
		_centro_costo
   from chqchmae
  where pagado       = 1
    and anulado      = 1
    and sac_anulados = 0
	and tipo_requis  = "A"
	and cod_chequera = _cheq_planilla

	if _centro_costo is null then

		call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

		if _error <> 0 then
			return _error,0, _error_desc;
		end if

	end if

	insert into tmp_che
	values (_no_requis, _fecha);

	update chqchmae
	   set sac_anulados = 2
	 where no_requis    = _no_requis;

	let _periodo = sp_sis39(_fecha);

	update chqchcta
	   set fecha        = _fecha,
	       periodo      = _periodo,
		   tipo_requis  = "A"
	 where no_requis    = _no_requis
	   and tipo         = 2;

	update chqchcta
	   set centro_costo = _centro_costo
	 where no_requis    = _no_requis
	   and tipo         = 2
	   and centro_costo is null;

	foreach
	 select renglon
	   into _renglon
	   from chqchcta
	  where no_requis = _no_requis
	    and tipo      = 2 		

		update chqctaux
		   set tipo         = 2,
		       fecha        = _fecha
		 where no_requis    = _no_requis
		   and renglon      = _renglon;

		update chqctaux
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and renglon      = _renglon
	       and centro_costo is null;

	end foreach

end foreach

select count(*)
  into _cantidad
  from tmp_che;

if _cantidad <> 0 then

	let _concepto	   = "004"; -- Planilla
	let _origen		   = "PLA"; -- Planilla
	let _tipo_comp     = 4;
	let _linea		   = 0;
	let _centro_costo2 = "0";

	let _fecha_impresion = MDY(1, 1, 1901);

	foreach
		select x.centro_costo,
			   y.fecha,
			   x.cuenta,
			   sum(x.debito),
			   sum(x.credito)
		  into _centro_costo,
		  	   _fecha,
		  	   _cuenta,
		  	   _debito,
		  	   _credito
		  from chqchcta x, tmp_che y
		 where x.no_requis = y.no_requis
		   and x.tipo      = 2
		 group by x.centro_costo, y.fecha, x.cuenta

		let _cnt_reg_acum = _cnt_reg_acum + 1;
	end foreach

	foreach
	 select	x.centro_costo,
	        y.fecha,
	        x.cuenta,
	 		sum(x.debito),
			sum(x.credito)
	   into	_centro_costo,
	        _fecha,
	        _cuenta,
	   		_debito,
			_credito
	   from	chqchcta x, tmp_che y
	  where x.no_requis = y.no_requis
	    and x.tipo      = 2
	  group by x.centro_costo, y.fecha, x.cuenta
	  order by x.centro_costo, y.fecha, x.cuenta

		if _fecha_impresion <> _fecha         or
		   _centro_costo    <> _centro_costo2 then

			let _periodo     = sp_sis39(_fecha);
			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || _periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || _periodo[6,7] || _periodo[3,4] || _tipo_comp;

			-- Contador de Comprobantes

			let _notrx = sp_sac10();

			insert into tmp_posteo
			values (_notrx);

			-- Insercion de Comprobantes

			insert into cgltrx1(
			trx1_notrx,
			trx1_tipo,
			trx1_comprobante,
			trx1_fecha,
			trx1_concepto,
			trx1_ccosto,
			trx1_descrip,
			trx1_monto,
			trx1_moneda,
			trx1_debito,
			trx1_credito,
			trx1_status,
			trx1_origen,
			trx1_usuario,
			trx1_fechacap
			)
			values(
			_notrx,
			_tipo,
			_comprobante,
			_fecha,
			_concepto,
			_centro_costo,
			_descrip,
			_monto,
			_moneda,
			0.00,
			0.00,
			_status,
			_origen,
			_usuario,
			_fechacap
			);

			let _fecha_impresion = _fecha;
			let _linea           = 0;
			let _centro_costo2   = _centro_costo;

		end if

		-- Trazabilidad con Cheques

		update chqchcta
		   set sac_notrx    = _notrx
		 where tipo         = 2
		   and fecha        = _fecha
		   and centro_costo = _centro_costo
		   and tipo_requis  = "A"
		   and sac_notrx    is null;

		-- Detalle del Comprobante

		let _linea = _linea + 1;

		insert into cgltrx2(
		trx2_notrx,
		trx2_tipo,
		trx2_linea,
		trx2_cuenta,
		trx2_ccosto,
		trx2_debito,
		trx2_credito,
		trx2_actlzdo
		)
		values(
		_notrx,
		_tipo,
		_linea,
		_cuenta,
		_centro_costo,
		_debito,
		_credito,
		0
		);

		update cgltrx1
		   set trx1_debito  = trx1_debito  + _debito,
		       trx1_credito = trx1_credito + _credito,
			   trx1_monto   = trx1_monto   + _debito
		 where trx1_notrx   = _notrx;

		-- Auxiliar por Programa

		let _linea_aux = 0;

		foreach
		 select x.cod_auxiliar,
		 		sum(x.debito),
		        sum(x.credito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqctaux x, tmp_che y
		  where x.no_requis    = y.no_requis
			and x.tipo         = 2
			and x.fecha        = _fecha
			and x.centro_costo = _centro_costo
		    and x.cuenta       = _cuenta
 		  group by x.cod_auxiliar

			let _linea_aux = _linea_aux + 1;

			call sp_sac136(_cuenta, _cod_auxiliar) returning _error, _error_desc;

			if _error <> 0 then
				return _error,0, _error_desc;
			end if

			insert into cgltrx3(
			trx3_notrx,
			trx3_tipo,
			trx3_lineatrx2,
			trx3_linea,
			trx3_cuenta,
			trx3_auxiliar,
			trx3_debito,
			trx3_credito,
			trx3_actlzdo
			)
			values(
			_notrx,
			_tipo,
			_linea,
			_linea_aux,
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito,
			0
			);

		end foreach
		return 1,_cnt_reg_acum,'' with resume;
	end foreach

end if

-- Mayorizacion
select count(*)
  into _cnt_reg
  from tmp_posteo;

let _cnt_reg_acum = _cnt_reg_acum + _cnt_reg;


foreach
 select notrx
   into _notrx
   from tmp_posteo

	call sp_sac64("001", _notrx, a_usuario) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then

		if _mayor_desc is null then
			let _mayor_desc = "Error en sp_sac64";
		end if

		return _mayor_error,0, _mayor_desc;

	end if

	return 1,_cnt_reg_acum,'' with resume;

end foreach	 

drop table tmp_che;
drop table tmp_posteo;

return 0,0,'Mayorizacion Exitosa';
end procedure
