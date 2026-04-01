-- Procedure que verifica que cuadre SAC Vs Deivid en Produccion

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac79;

create procedure sp_sac79()
returning smallint,
          char(50);

define _monto1		dec(16,2);
define _monto2		dec(16,2);
define _monto		dec(16,2);
define _debito		dec(16,2);
define _credito		dec(16,2);

define _mes			smallint;
define _ano			smallint;
define _periodo		char(7);
define _fecha		date;

define _periodo2	char(7);
define _cuenta		char(25);
define _fechatrx	date;
define _auxiliar	char(1);

define _notrx		integer;
define _linea		integer;
define _fecha_trx	date;
define _origen		char(3);
define _concepto	char(3);
define _tipo_comp	smallint;
define _tipo_compd	char(50);
define _descrip		char(50);
define _comprobante	char(8);
define _cod_auxiliar char(5);

set isolation to dirty read;

create temp table tmp_asientos(
periodo		char(7),
cuenta		char(25),
monto1		dec(16,2),
monto2		dec(16,2)
) with no log;

select par_mesfiscal,
       par_anofiscal
  into _mes,
       _ano
  from cglparam;

let _mes = 7;

if _mes < 10 then
	let _periodo = _ano || "-0" || _mes;
else
	let _periodo = _ano || "-" || _mes;
end if

let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);

foreach
 select res_fechatrx,
		res_cuenta,
		sum(res_debito - res_credito)
   into _fechatrx,
		_cuenta,
		_monto1
   from cglresumen
  where year(res_fechatrx)   = year(_fecha)
	and res_comprobante[1,3] = "PRO"
    and month(res_fechatrx)  <> 12
	and res_fechatrx         >= _fecha

	and	(res_cuenta       like ("131%") or
	     res_cuenta       like ("144%") or
	     res_cuenta       like ("213%") or
	     res_cuenta       like ("214%") or
	     res_cuenta       like ("231%") or
	     res_cuenta       like ("240%") or
	     res_cuenta       like ("264%") or
	     res_cuenta       like ("265%") or
	     res_cuenta       like ("411%") or
	     res_cuenta       like ("413%") or
	     res_cuenta       like ("422%") or
	     res_cuenta       like ("511%") or
	     res_cuenta       like ("521%") or
	     res_cuenta       like ("531%") or
	     res_cuenta       like ("562%") or
	     res_cuenta       like ("563%"))

--	  and res_cuenta           like ("411%")
--    and res_notrx not in (1991, 1968, 1971)
--    and month(res_fechatrx)  = month(_fecha)

  group by 1, 2

	let _periodo2 = sp_sis39(_fechatrx);

	insert into tmp_asientos
	values ("2007-12", _cuenta, _monto1, 0.00);

end foreach

foreach
 select e.periodo,
		a.cuenta,
        sum(a.debito + a.credito)
   into _periodo2,
		_cuenta,
        _monto2
   from endasien a, endedmae e
  where a.no_poliza    = e.no_poliza
    and a.no_endoso    = e.no_endoso
    and e.periodo[1,4] = _periodo[1,4]
	and e.periodo[6,7] <> "12"
	and e.periodo      >= _periodo
--	and a.cuenta       like ("411%")

	and	(a.cuenta       like ("131%") or
	     a.cuenta       like ("144%") or
	     a.cuenta       like ("213%") or
	     a.cuenta       like ("214%") or
	     a.cuenta       like ("231%") or
	     a.cuenta       like ("240%") or
	     a.cuenta       like ("264%") or
	     a.cuenta       like ("265%") or
	     a.cuenta       like ("411%") or
	     a.cuenta       like ("413%") or
	     a.cuenta       like ("422%") or
	     a.cuenta       like ("511%") or
	     a.cuenta       like ("521%") or
	     a.cuenta       like ("531%") or
	     a.cuenta       like ("562%") or
	     a.cuenta       like ("563%"))

  group by 1, 2

	insert into tmp_asientos
	values ("2007-12", _cuenta, 0.00, _monto2);

end foreach

let _periodo     = "2007-12";
let _origen	     = "PRO"; -- Produccion
let _fecha_trx   = sp_sac62("2007-12");
let _concepto    = "003"; -- Facturacion
let _tipo_comp   = 1;

let _tipo_compd  = sp_sac11(1, _tipo_comp);
let _descrip     = _origen || " " || _periodo || " " || trim(_tipo_compd);
let _comprobante = _origen || _periodo[6,7] || _periodo[3,4] || _tipo_comp;
	
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
"01",
_comprobante,
_fecha_trx,
_concepto,
"001",
_descrip,
0.00,
"00",
0.00,
0.00,
"I",
"CGL",
"informix",
today
);

let _linea = 0;

foreach
 select periodo,
		cuenta,
        sum(monto1),
        sum(monto2)
   into _periodo2,
		_cuenta,
        _monto1,
        _monto2
   from tmp_asientos
  group by 1, 2
  order by 1, 2
                           
	if _monto1 <> _monto2 then

		let _debito  = 0.00;
		let _credito = 0.00;

		let _monto   = _monto2 - _monto1;
					 
		if _monto > 0 then
			let _debito  = _monto;
		else
			let _credito = _monto * -1;
		end if

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
		"01",
		_linea,
		_cuenta,
		"001",
		_debito,
		_credito,
		0
		);
	
		update cgltrx1
		   set trx1_debito  = trx1_debito  + _debito,
		       trx1_credito = trx1_credito + _credito,
			   trx1_monto   = trx1_monto   + _debito
		 where trx1_notrx   = _notrx;

		select cta_auxiliar
		  into _auxiliar
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _auxiliar = "S" then


			foreach
			 select aux_tercero
			   into _cod_auxiliar
			   from cglauxiliar
			  where aux_cuenta = _cuenta
				exit foreach;
			end foreach

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
			"01",
			_linea,
			1,
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito,
			0
			);

		end if

	end if

end foreach

drop table tmp_asientos;

return "0",
	   "Actualizacion Exitosa - Notrx " || _notrx;	

end procedure