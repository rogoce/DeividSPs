-- Procedure que Genera el Asiento de Diario en el Mayor General de la facturacion errada
-- de salud de octubre 2010

-- Creado    : 19/11/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac194;

create procedure sp_sac194(
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

define _no_factura		char(10);


--set debug file to "sp_sac61.trc";
--trace on;

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

-- Creacion / Actualizacion de los Centros de Costos
-- Desde el Modulo de Mayor General (SAC)

call sp_sac91() returning _error, _error_desc;

if _error <> 0 then

	if _error_desc is null then
		let _error_desc = "Error en sp_sac91";
	end if

	return _error, _error_desc;

end if

-- Proceso de Actualizacion

if a_origen = 1 then -- Produccion

	create temp table tmp_prod(
	no_poliza	char(10),
	no_endoso	char(5),
	periodo		char(7)
	) with no log;

	let _periodo = "2010-12";

	foreach
     select no_factura
       into _no_factura
	   from	deivid_tmp:error_salud
	  where sac_asientos = 1

		select no_poliza,
		       no_endoso,
		       fecha_emision
		  into _no_poliza,
		       _no_endoso,
		       _fecha_anulado
          from endedmae
         where no_factura = _no_factura;

		call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

		if _error <> 0 then

--			if _error_desc is null then
				let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza || " Endoso " || _no_endoso;
--			end if

			return _error, _error_desc;

		end if

		let _periodo2 = sp_sis39(_fecha_anulado);

		if _periodo = _periodo2 then
			let _fecha = _fecha_anulado;
		elif _periodo > _periodo2 then
			let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);
		elif _periodo < _periodo2 then
			let _fecha = sp_sis36(_periodo);
		end if

		insert into tmp_prod
		values (_no_poliza, _no_endoso, _periodo);

		update deivid_tmp:error_salud
		   set sac_asientos = 2
		 where no_factura   = _no_factura;

		update endasien
		   set periodo      = _periodo,
		       centro_costo = _centro_costo,
			   fecha	    = _fecha
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso;

		update endasiau
		   set periodo      = _periodo,
		       centro_costo = _centro_costo,
			   fecha        = _fecha
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso;

	end foreach

	-- Registros Contables Normales

	let _origen		   = "PR0"; -- Produccion
	let _concepto      = "003"; -- Facturacion
	let _tipo_comp2    = 0;
	let _periodo2      = "0";
	let _centro_costo2 = "0";

	let _fecha_impresion = MDY(1, 1, 1901);

	foreach
	 select	e.periodo,
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
	   from	tmp_prod e, endasien a
	  where e.no_poliza   = a.no_poliza
		and e.no_endoso   = a.no_endoso
	  group by a.centro_costo, e.periodo, a.fecha, a.tipo_comp, a.cuenta
	  order by a.centro_costo, e.periodo, a.fecha, a.tipo_comp, a.cuenta

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

		-- Trazabilidad con Produccion

		update endasien
		   set sac_notrx    = _notrx
		 where periodo      = _periodo
		   and tipo_comp    = _tipo_comp
		   and cuenta       = _cuenta
		   and centro_costo = _centro_costo
		   and fecha        = _fecha_anulado
		   and sac_notrx    is null;

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
		  from tmp_prod e, endasiau a
		 where e.no_poliza    = a.no_poliza
		   and e.no_endoso    = a.no_endoso
		   and a.cuenta       = _cuenta
		   and a.tipo_comp    = _tipo_comp
		   and a.periodo      = _periodo
		   and a.centro_costo = _centro_costo
		   and a.fecha        = _fecha_anulado
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

{
foreach
 select notrx
   into _notrx
   from tmp_posteo

	call sp_sac64("001", _notrx, a_usuario) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then

		if _mayor_desc is null then
			let _mayor_desc = "Error en sp_sac64";
		end if

		return _mayor_error, _mayor_desc;

	end if

end foreach
}

drop table tmp_posteo;

end

return 0, "Actualizacion Exitosa";

end procedure