-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac51;

create procedure sp_sac51(
a_periodo	char(7),
a_usuario	char(8),
a_origen	smallint
) returning integer,
            char(100);

define _notrx			integer;
define _tipo			char(2);
define _comprobante		char(8);
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
define _desc_ajuste		char(3);

--set debug file to "sp_sac06.trc";
--trace on;

set isolation to dirty read;

create temp table tmp_cuenta(
cuenta	    char(25),
debito	    dec(16,2),
credito	    dec(16,2)
) with no log;

let _periodo1   = "2006-12";
let _tipo		= "01";	 -- Comprobante Normal
let _fecha     	= sp_sis36(_periodo1);
let _ccosto		= "001";
let _descrip	= "";
let _monto   	= 0.00;
let _moneda		= "00";
let _status		= "R";
let _usuario    = a_usuario;
let _fechacap 	= current;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Registros Contables Normales

let _origen		= "PRO"; -- Produccion
let _tipo_comp2 = 0;
let _tipo_comp  = 1;

if a_periodo = "2006-10" then
	let _desc_ajuste = "AJ1";
elif a_periodo = "2006-11" then
	let _desc_ajuste = "AJ2";
elif a_periodo = "2006-12" then
	let _desc_ajuste = "AJ3";
end if

foreach
 select	e.no_poliza,
        e.no_endoso,
        a.cuenta,
        a.debito,
		a.credito
   into	_no_poliza,
        _no_endoso,
   		_cuenta,
		_debito_tab,
		_credito_tab
   from	endedmae e, endasien a, emipomae p
  where e.periodo      = a_periodo
    and e.no_poliza    = a.no_poliza
	and e.no_endoso    = a.no_endoso
	and e.actualizado  = 1
	and e.no_poliza    = p.no_poliza
	and p.cod_tipoprod = "002"
	and a.cuenta       like "131%"
	and a.tipo_comp    = 1
--	and e.no_poliza    = "202551"
--	and e.no_endoso    = "00007"

	let _credito = _debito_tab;
	let _debito  = _credito_tab * -1;

	insert into tmp_cuenta
	values (_cuenta, _debito, _credito);
	
	select cuenta
	  into _cuenta
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and tipo_comp = 1
	   and cuenta like "144%";

	let _debito  = _debito_tab;
	let _credito = _credito_tab * -1;

	insert into tmp_cuenta
	values (_cuenta, _debito, _credito);

end foreach

foreach
 select	cuenta,
        sum(debito),
		sum(credito)
   into	_cuenta,
		_debito_tab,
		_credito_tab
   from	tmp_cuenta
  group by cuenta
  order by cuenta

	-- Encabezado del Comprobante

	if _tipo_comp <> _tipo_comp2 then

		if _tipo_comp = 9 then
			let _concepto	= "014"; -- Consolidacion Companias
		else
			let _concepto	= "003"; -- Facturacion
		end if

		let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
		let _descrip     = _origen || " " || _periodo1 || " " || "AJUSTE COAS. MINORITARIO " || a_periodo;
		let _comprobante = _desc_ajuste || _periodo1[6,7] || _periodo1[3,4] || _tipo_comp;
		
		select count(*)
		  into _cantidad
		  from cgltrx1
		 where trx1_comprobante = _comprobante;
		 
		 if _cantidad <> 0 then
		 	return 1, "El Comprobante " || _comprobante || " Ya Fue Capturado";
		 end if 

		-- Contador de Comprobantes

		let _notrx = sp_sac10();

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
		_ccosto,
		_descrip,
		_monto,
		_moneda,
		0.00,
		0.00,
		_status,
		"CGL",
		_usuario,
		_fechacap
		);

		let _tipo_comp2 = _tipo_comp;
		let _linea		= 0;

	end if

	-- Detalle del Comprobante

	let _debito  = _debito_tab;
	let _credito = _credito_tab;
	let _linea   = _linea + 1;

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
	_ccosto,
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
		
end

drop table tmp_cuenta;

return 0, "Actualizacion Exitosa";

end procedure