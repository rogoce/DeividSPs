-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac67;

create procedure sp_sac67(
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
define _periodo			char(7);
define _no_tranrec		char(10);

define _mayor_error		integer;
define _mayor_desc		char(150);

--set debug file to "sp_sac06.trc";
--trace on;

begin work;

set isolation to dirty read;

create temp table tmp_cuenta(
cuenta	char(25),
debito	dec(16,2),
credito	dec(16,2)
) with no log;

create temp table tmp_posteo(
notrx integer
) with no log;

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

if a_origen = 1 then -- Produccion

	create temp table tmp_prod(
	no_poliza	char(10),
	no_endoso	char(5),
	periodo		char(7)
	) with no log;

	foreach
	 select	no_poliza,
	        no_endoso,
			periodo
	   into	_no_poliza,
	        _no_endoso,
			_periodo
	   from	endedmae
	  where no_factura in ("01-526296", "01-527581", "02-25160", "02-25161", "02-25164")

		insert into tmp_prod
		values (_no_poliza, _no_endoso, _periodo);

		update endedmae
		   set sac_asientos = 2
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso;

		update endasien
		   set periodo      = _periodo
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso;

	end foreach

	-- Registros Contables Normales

	let _origen		= "PRO"; -- Produccion
	let _tipo_comp2 = 0;
	let _periodo2   = "0";
	let _periodo    = "2007-07";

	foreach
	 select	a.tipo_comp,
	        a.cuenta,
	        sum(a.debito),
			sum(a.credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	tmp_prod e, endasien a
	  where e.no_poliza   = a.no_poliza
		and e.no_endoso   = a.no_endoso
	  group by a.tipo_comp, a.cuenta
	  order by a.tipo_comp, a.cuenta

		let _fecha = sp_sac62(_periodo);

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 or 
		   _periodo   <> _periodo2   then

			if _tipo_comp = 9 then
				let _concepto	= "014"; -- Consolidacion Companias
			else
				let _concepto	= "003"; -- Facturacion
			end if

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
			let _periodo2   = _periodo;

		end if

		-- Trazabilidad con Produccion

		update endasien
		   set sac_notrx = _notrx
		 where periodo   = _periodo
		   and tipo_comp = _tipo_comp
		   and cuenta    = _cuenta;

		-- Detalle del Comprobante

		let _debito  = _debito_tab;
		let _credito = _credito_tab * -1;
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

		-- Detalle del Auxiliar

		let _linea_aux = 0;

		foreach
		 select cod_auxiliar,
		        sum(debito),
			    sum(credito)
		  into _cod_auxiliar,
		  	   _debito_tab,
			   _credito_tab
		  from tmp_prod e, endasiau a
		 where e.no_poliza   = a.no_poliza
		   and e.no_endoso   = a.no_endoso
		   and a.cuenta      = _cuenta
 		 group by cod_auxiliar

			let _debito    = _debito_tab;
			let _credito   = _credito_tab * -1;
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

	end foreach

	drop table tmp_prod;

end if

drop table tmp_cuenta;

-- Mayorizacion

foreach
 select notrx
   into _notrx
   from tmp_posteo

	call sp_sac64("001", _notrx) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then

		rollback work;
		return _mayor_error, _mayor_desc;

	end if

end foreach

drop table tmp_posteo;

end

--rollback work;
commit work;

return 0, "Actualizacion Exitosa";

end procedure