-- Procedure que reversa un comprobante

-- Creado    : 04/09/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac66;

create procedure sp_sac66(
a_notrx integer
) returning integer,
            char(100);

define _noregistro		integer;

define _notrx			integer;
define _tipo			char(2);
define _comprobante		char(8);
define _fecha			date;
define _concepto		char(3);
define _ccosto			char(3);
define _descrip			char(50);
define _moneda      	char(2);
define _status      	char(1);
define _origen      	char(3);
define _usuario     	char(15);
define _fechacap    	datetime year to second;

define _debito      	dec(16,2);
define _credito     	dec(16,2);
define _cuenta			char(25);
define _linea			integer;

define _debito_aux     	dec(16,2);
define _credito_aux    	dec(16,2);
define _linea_aux		integer;
define _cod_auxiliar	char(5);

define _mayor_error		integer;
define _mayor_desc		char(150);

begin work;

let _fechacap 	= current;
let _status		= "I";

foreach
 select res_tipo_resumen,
        res_comprobante,
		res_fechatrx,
		res_tipcomp,
        res_ccosto,
		res_descripcion,
		res_moneda,
		res_usuariocap
   into _tipo,
		_comprobante,
		_fecha,
		_concepto,
		_ccosto,
		_descrip,
		_moneda,
		_usuario
   from cglresumen
  where res_notrx = a_notrx
	exit foreach;
end foreach

let _notrx = sp_sac10();

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
0.00,
_moneda,
0.00,
0.00,
_status,
"CGL",
_usuario,
_fechacap
);

-- Detalle del Comprobante

let _linea = 0;

foreach
 select res_cuenta,
        res_debito,
		res_credito,
		res_noregistro
   into _cuenta,
		_credito,
		_debito,
		_noregistro
   from cglresumen
  where res_notrx = a_notrx
  order by res_noregistro

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
	 select res1_auxiliar,
	        res1_debito,
		    res1_credito
	  into _cod_auxiliar,
		   _credito_aux,
	  	   _debito_aux
	  from cglresumen1
	 where res1_noregistro = _noregistro
	 order by res1_linea

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
		_debito_aux,
		_credito_aux,
		0
		);

	end foreach

end foreach


call sp_sac64("001", _notrx) returning _mayor_error, _mayor_desc;

if _mayor_error <> 0 then
	return _mayor_error, _mayor_desc;
end if

--rollback work;
commit work;

return 0, "Actualizacion Exitosa";

end procedure