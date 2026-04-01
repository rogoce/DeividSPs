-- Procedure que Genera el Asiento de Diario en el Mayor General del Modulo de Reaseguro

-- Creado    : 09/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac163;

create procedure sp_sac163(
a_usuario	char(8),
a_origen	smallint
) returning integer,
            char(100);

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
define _no_registro		char(10);
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
define _error_desc		char(50);
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

define _cheq_planilla	char(3);
define _cod_chequera	char(3);

--set debug file to "sp_sac163.trc";
--trace on;

set isolation to dirty read;

let _tipo		= "01";	 -- Comprobante Normal
let _ccosto		= "001";
let _descrip	= "";
let _monto   	= 0.00;
let _moneda		= "00";
let _status		= "I";
let _usuario    = a_usuario;
let _fechacap 	= current;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

create temp table tmp_prod(
no_registro	char(10)
) with no log;

foreach
 select	no_registro
   into	_no_registro
   from	sac999:reacomp
  where sac_asientos = 1

	insert into tmp_prod
	values (_no_registro);

	update sac999:reacomp
	   set sac_asientos = 2
	 where no_registro  = _no_registro;

end foreach

-- Registros Contables Normales

let _origen		   = "REA"; -- Reaseguro
let _concepto      = "003"; -- Facturacion
let _tipo_comp2    = 0;
let _periodo2      = "0";
let _centro_costo2 = "0";

let _fecha_impresion = MDY(1, 1, 1901);

foreach
 select	a.periodo,
        a.fecha,
        a.tipo_comp,
        a.cuenta,
		a.centro_costo,
        sum(a.debito),
		sum(a.credito)
   into	_periodo,
        _fecha_anulado,
        _tipo_comp,
        _cuenta,
		_centro_costo,
		_debito_tab,
		_credito_tab
   from	tmp_prod e, sac999:reacompasie a
  where e.no_registro = a.no_registro
  group by a.centro_costo, a.periodo, a.fecha, a.tipo_comp, a.cuenta
  order by a.centro_costo, a.periodo, a.fecha, a.tipo_comp, a.cuenta

	-- Encabezado del Comprobante

	if _tipo_comp     <> _tipo_comp2      or 
	   _periodo       <> _periodo2        or
	   _centro_costo  <> _centro_costo2   or
	   _fecha_anulado <> _fecha_impresion then

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
		_fecha_anulado,
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

		let _tipo_comp2      = _tipo_comp;
		let _linea		     = 0;
		let _periodo2        = _periodo;
		let _centro_costo2   = _centro_costo;
		let _fecha_impresion = _fecha_anulado;

	end if

	-- Trazabilidad con Reaseguro

	update sac999:reacompasie
	   set sac_notrx    = _notrx
	 where periodo      = _periodo
	   and tipo_comp    = _tipo_comp
	   and cuenta       = _cuenta
	   and centro_costo = _centro_costo
	   and fecha        = _fecha_anulado
	   and sac_notrx    is null;

	-- Detalle del Comprobante

	let _linea   = _linea + 1;
	let _debito  = _debito_tab;
	let _credito = _credito_tab;

	if _credito < 0.00 then
		let _credito = _credito * -1;
	end if

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

	-- Detalle del Auxiliar

	let _linea_aux = 0;

	foreach
	 select cod_auxiliar,
	        sum(debito),
		    sum(credito)
	  into _cod_auxiliar,
	  	   _debito_tab,
		   _credito_tab
	  from tmp_prod e, sac999:reacompasiau a
	 where a.no_registro  = e.no_registro
	   and a.cuenta       = _cuenta
	   and a.tipo_comp    = _tipo_comp
	   and a.periodo      = _periodo
	   and a.centro_costo = _centro_costo
	   and a.fecha        = _fecha_anulado
   	 group by cod_auxiliar

		select count(*)
		  into _cantidad
		  from cglauxiliar
		 where aux_cuenta  = _cuenta
		   and aux_tercero = _cod_auxiliar;

		if _cantidad = 0 then
			
			insert into cglauxiliar(
			aux_cuenta,
			aux_tercero,
			aux_pctreten,
			aux_saldoret,
			aux_corriente,
			aux_30dias,
			aux_60dias,
			aux_90dias,
			aux_120dias,
			aux_150dias,
			aux_ultimatrx,
			aux_ultimodcmto,
			aux_observacion
			)
			values(
			_cuenta,
			_cod_auxiliar,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			"",
			"",
			""
			);

		end if

		let _linea_aux = _linea_aux + 1;
		let _debito    = _debito_tab;
		let _credito   = _credito_tab;

		if _credito < 0.00 then
			let _credito = _credito * -1;
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

end foreach

drop table tmp_prod;

end 

return 0, "Actualizacion Exitosa";

end procedure