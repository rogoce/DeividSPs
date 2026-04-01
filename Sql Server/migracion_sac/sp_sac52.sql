-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac52;

create procedure sp_sac52(
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
define _periodo3		char(7);
define _cod_auxiliar	char(5);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _cta_auxiliar	char(5);

define _no_poliza		char(10);
define _desc_ajuste		char(3);

define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _no_documento	char(20);
define _suma_impuesto	dec(16,2);
define _cant_impuestos	integer;
define _cod_impuesto	char(3);
define _cuenta_inc	   	char(25);
define _cuenta_dan	   	char(25);
define _factor_impuesto	dec(5,2);
define _cod_ramo	   	char(3);

--set debug file to "sp_sac06.trc";
--trace on;

set isolation to dirty read;

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

let _concepto	= "004"; -- Cheques
let _origen		= "CHE"; -- Cheques
let _tipo_comp2 = 0;
let _tipo_comp  = 1;
let _linea		= 0;

if a_periodo = "2006-10" then
	let _desc_ajuste = "AJ4";
elif a_periodo = "2006-11" then
	let _desc_ajuste = "AJ5";
elif a_periodo = "2006-12" then
	let _desc_ajuste = "AJ6";
end if

let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
let _descrip     = _origen || " " || _periodo1 || " " || "AJUSTE CHEQUE DEV. PRIMA " || a_periodo;
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

foreach	
 select p.no_documento,
        p.no_poliza,
        p.monto,
		p.prima_neta,
		m.fecha_impresion,
		m.fecha_anulado
   into _no_documento,
        _no_poliza,
		_prima_bruta,
		_prima_neta,
		_fecha_impresion,
		_fecha_anulado
   from chqchmae m, chqchpol p
  where m.no_requis = p.no_requis
    and m.periodo = a_periodo
    and m.pagado = 1

	let _periodo2 = sp_sis39(_fecha_impresion);
	let _periodo3 = sp_sis39(_fecha_anulado);

	if _periodo2 = _periodo3 then
		continue foreach;
	end if

	let _impuesto = _prima_bruta - _prima_neta;

	if _impuesto <> 0.00 then

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		-- Rebajar las Primas por Cobrar
		
		LET _cuenta  = sp_sis15('PAPXCSD', '01', _no_poliza); -- Produccion Directa
		let _debito  = 0.00;
		let _credito = _impuesto;
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

		-- Afectar el Impuesto

		let _suma_impuesto = 0.00;

		 select count(*)
		   into _cant_impuestos
		   from emipolim
		  where no_poliza = _no_poliza;

		foreach	
		 select cod_impuesto
		   into _cod_impuesto
		   from emipolim
		  where no_poliza = _no_poliza

			select factor_impuesto,
			       cta_incendio,
				   cta_danos
			  into _factor_impuesto,
			       _cuenta_inc,
				   _cuenta_dan
			  from prdimpue
			 where cod_impuesto = _cod_impuesto;
				    
			if _cant_impuestos = 1 then
				let _monto = _impuesto;
			else
				let _monto = _prima_neta * _factor_impuesto / 100;
			end if

			let _suma_impuesto = _suma_impuesto + _monto;

			If _cod_ramo in ("001", "003") then       -- Incendio, Multiriesgos
				Let _cuenta = sp_sis15(_cuenta_inc); 
			else								      -- Otros Ramos
				Let _cuenta = sp_sis15(_cuenta_dan); 
			end If

			let _debito  = _monto;
			let _credito = 0.00;
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

		end Foreach

		-- Diferencia en la Multiplicacion por la separacion del impuesto

		if _impuesto <> _suma_impuesto then

			let _debito  = _impuesto - _suma_impuesto;
			let _credito = 0.00;
			
			update cgltrx2
			   set trx2_debito = trx2_debito + _debito
			 where trx2_notrx  = _notrx
			   and trx2_tipo   = _tipo
			   and trx2_linea  = _linea;

			update cgltrx1
			   set trx1_debito  = trx1_debito  + _debito,
			       trx1_credito = trx1_credito + _credito,
				   trx1_monto   = trx1_monto   + _debito
			 where trx1_notrx   = _notrx;

		end if

     end If

end foreach
		
end

return 0, "Actualizacion Exitosa";

end procedure