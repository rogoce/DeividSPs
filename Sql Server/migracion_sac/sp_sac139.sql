-- Procedure que Genera el Asiento de Diario en el Mayor General del modulo de suministros

-- Creado    : 27/11/2009 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac139;

create procedure sp_sac139(
a_usuario	char(8),
a_origen	smallint
) returning integer,
            char(100);

define _no_requis		char(10);
define _fecha			date;
define _cantidad		integer;
define _concepto		char(3);
define _origen      	char(3);
define _tipo_comp		smallint;
define _linea			integer;
define _centro_costo2	char(3);
define _cuenta			char(25);
define _debito      	dec(16,2);
define _credito     	dec(16,2);
define _fecha_impresion	date;
define _periodo			char(7);
define _tipo_compd		char(50);
define _descrip			char(50);
define _comprobante		char(8);
define _notrx			integer;
define _tipo			char(2);
define _moneda      	char(2);
define _status      	char(1);
define _usuario     	char(15);
define _fechacap    	datetime year to second;
define _monto			dec(16,2);	
define _centro_costo	char(3);
					 
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--SET DEBUG FILE TO "sp_sac139.trc"; 
--trace on;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _tipo		= "01";	 -- Comprobante Normal
let _moneda		= "00";
let _status		= "I";
let _usuario    = a_usuario;
let _fechacap 	= current;
let _monto   	= 0.00;

create temp table tmp_che(
no_requis	char(10),
fecha		date
) with no log;

-- Entrada de Suministros

foreach
 select	cod_entrada,
        fecha_ent
   into _no_requis,
        _fecha
   from psuminentm
  where actualizado  = 1
    and sac_asientos = 1

	insert into tmp_che
	values (_no_requis, _fecha);

	update psuminentm
	   set sac_asientos = 2
	 where cod_entrada  = _no_requis;

end foreach

select count(*)
  into _cantidad
  from tmp_che;

if _cantidad <> 0 then

	let _concepto	   = "002"; -- Inventario
	let _origen		   = "SOC"; -- Suministros
	let _tipo_comp     = 2;
	let _linea		   = 0;
	let _centro_costo2 = "0";

	let _fecha_impresion = MDY(1, 1, 1901);

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
	   from	socentcta x, tmp_che y
	  where x.cod_entrada = y.no_requis
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

			--insert into tmp_posteo
			--values (_notrx);

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

		-- Trazabilidad con Entrada de Suministro

		update socentcta
		   set sac_notrx    = _notrx
		 where tipo         = _tipo_comp
		   and fecha        = _fecha
		   and centro_costo = _centro_costo
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

	end foreach

end if

-- Salida de Suministro

delete from tmp_che;

foreach
 select	cod_salida,
        fecha
   into _no_requis,
        _fecha
   from socsalm
  where sac_asientos = 1

	insert into tmp_che
	values (_no_requis, _fecha);

	update socsalm
	   set sac_asientos = 2
	 where cod_salida  = _no_requis;

end foreach

select count(*)
  into _cantidad
  from tmp_che;

if _cantidad <> 0 then

	let _concepto	   = "002"; -- Inventario
	let _origen		   = "SOC"; -- Suministros
	let _tipo_comp     = 1;
	let _linea		   = 0;
	let _centro_costo2 = "0";

	let _fecha_impresion = MDY(1, 1, 1901);

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
	   from	socsalcta x, tmp_che y
	  where x.cod_salida = y.no_requis
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

			--insert into tmp_posteo
			--values (_notrx);

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

		-- Trazabilidad con Entrada de Suministro

		update socsalcta
		   set sac_notrx    = _notrx
		 where tipo         = _tipo_comp
		   and fecha        = _fecha
		   and centro_costo = _centro_costo
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

	end foreach

end if

drop table tmp_che;

end

return 0, "Actualizacion Exitosa";

end procedure