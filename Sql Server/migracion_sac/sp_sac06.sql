-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac06;

create procedure sp_sac06(
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

--set debug file to "sp_sac06.trc";
--trace on;

set isolation to dirty read;

create temp table tmp_cuenta(
cuenta	char(25),
debito	dec(16,2),
credito	dec(16,2)
) with no log;

let _tipo		= "01";	 -- Comprobante Normal
let _fecha     	= sp_sis36(a_periodo);
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

if a_origen = 7 then -- Cancelaciones Masivas

	-- Registros Contables Normales

	let _origen		= "CM2"; -- Cancelacion Masiva
	let _tipo_comp2 = 0;

	foreach
	 select	tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	endedmae e, endasien a
	  where e.periodo     = a_periodo
	    and e.no_poliza   = a.no_poliza
		and e.no_endoso   = a.no_endoso
		and e.actualizado = 1
		and e.user_added  = "GERENCIA"
		and e.no_factura  = "01-526200"
	  group by tipo_comp, cuenta
	  order by tipo_comp, cuenta

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 then

			if _tipo_comp = 9 then
				let _concepto	= "014"; -- Consolidacion Companias
			else
				let _concepto	= "003"; -- Facturacion
			end if

			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
			
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
		  from endedmae e, endasiau a
		 where e.periodo     = a_periodo
		   and e.no_poliza   = a.no_poliza
		   and e.no_endoso   = a.no_endoso
		   and e.actualizado = 1
		   and a.cuenta      = _cuenta
		   and e.user_added  = "GERENCIA"
		   and e.no_factura  = "01-526200"
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

elif a_origen = 8 then -- Actualizacion de Creditos

	let _concepto	= "005"; -- Otros Ingresos
	let _origen		= "CRE"; -- Saldos Creditos
	let _tipo_comp2 = 0;

	-- Tablas Temporales

	create temp table tmp_prod(
	tipo_comp	smallint,
	cuenta		CHAR(25),
	debito      DECIMAL(16,2),
	credito		DECIMAL(16,2)
	) with no log;

	create temp table tmp_prod2(
	tipo_comp		smallint,
	cuenta			CHAR(25),
	cod_auxiliar	char(5),
	debito          DECIMAL(16,2),
	credito			DECIMAL(16,2)
	) with no log;

	-- Proceso de Actualizacion

	FOREACH 
	SELECT no_remesa,
	       tipo_remesa
	  INTO _no_remesa,
	       _tipo_remesa
	  FROM cobremae
	 WHERE periodo     = a_periodo
	   AND actualizado = 1
	   and no_remesa   = "135966"

		IF _tipo_remesa = "A" Or
		   _tipo_remesa = "M" THEN
		   LET _tipo_comp = 1;
		ELSE
		   LET _tipo_comp = 2;
		END IF

	   FOREACH
		SELECT debito,
			   credito,
			   cuenta
		  INTO _debito,
		       _credito,
		       _cuenta
		  FROM cobasien
		 WHERE no_remesa = _no_remesa

			INSERT INTO tmp_prod(
			tipo_comp,
			cuenta,   
			debito,	  
		    credito
			)
			VALUES(
			_tipo_comp,
			_cuenta,  
			_debito,
			_credito
			);

		END FOREACH

		foreach
		 select	a.debito,
			    a.credito,
			    a.cuenta,
				d.cod_auxiliar
		   INTO _debito,
		        _credito,
		        _cuenta,
				_cod_auxiliar
		   FROM cobasien a, cobredet d
		  WHERE a.no_remesa    = _no_remesa
		    and a.no_remesa    = d.no_remesa
			and a.renglon      = d.renglon
			and d.cod_auxiliar is not null

			INSERT INTO tmp_prod2(
			tipo_comp,
			cuenta,
			cod_auxiliar, 
			debito,	  
		    credito
			)
			VALUES(
			_tipo_comp,
			_cuenta,  
			_cod_auxiliar,
			_debito,
			_credito
			);

		END FOREACH

	END FOREACH;

	foreach
	 select	tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	tmp_prod
	  group by tipo_comp, cuenta
	  order by tipo_comp, cuenta

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 then

			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
			
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

		let _debito_rea  = 0.00;
		let _credito_rea = 0.00;

		if _debito_tab >= 0.00 then
			let _debito_rea  = _debito_rea  + _debito_tab;
		else
			let _credito_rea = _credito_rea + (_debito_tab * -1);
		end if

		if _credito_tab >= 0.00 then
			let _credito_rea = _credito_rea + _credito_tab;
		else
			let _debito_rea  = _debito_rea  + (_credito_tab * -1);
		end if

		let _monto_rea = _debito_rea - _credito_rea;

		let _debito  = 0.00;
		let _credito = 0.00;

		if _monto_rea >= 0.00 then
			let _debito  = _monto_rea;
		else
			let _credito = _monto_rea * -1;
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

		let _linea_aux = 0;

		foreach
		 select cod_auxiliar,
		 		sum(debito),
		        sum(credito)
		   into _cod_auxiliar,
		  	    _debito_tab2,
			    _credito_tab2
		   from tmp_prod2
		  where tipo_comp = _tipo_comp
		    and cuenta    = _cuenta
 		  group by cod_auxiliar

			let _debito_rea  = 0.00;
			let _credito_rea = 0.00;

			if _debito_tab2 >= 0.00 then
				let _debito_rea  = _debito_rea  + _debito_tab2;
			else
				let _credito_rea = _credito_rea + (_debito_tab2 * -1);
			end if

			if _credito_tab2 >= 0.00 then
				let _credito_rea = _credito_rea + _credito_tab2;
			else
				let _debito_rea  = _debito_rea  + (_credito_tab2 * -1);
			end if

			let _monto_rea = _debito_rea - _credito_rea;

			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto_rea >= 0.00 then
				let _debito  = _monto_rea;
			else
				let _credito = _monto_rea * -1;
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

	end foreach

	drop table tmp_prod;
	drop table tmp_prod2;
	
elif a_origen = 1 then -- Produccion

	-- Registros Contables Normales

	let _origen		= "PRO"; -- Produccion
	let _tipo_comp2 = 0;

	foreach
	 select	tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	endedmae e, endasien a
	  where e.periodo     = a_periodo
	    and e.no_poliza   = a.no_poliza
		and e.no_endoso   = a.no_endoso
		and e.actualizado = 1
		and e.user_added  <> "GERENCIA"
	  group by tipo_comp, cuenta
	  order by tipo_comp, cuenta

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 then

			if _tipo_comp = 9 then
				let _concepto	= "014"; -- Consolidacion Companias
			else
				let _concepto	= "003"; -- Facturacion
			end if

			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
			
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
		  from endedmae e, endasiau a
		 where e.periodo     = a_periodo
		   and e.no_poliza   = a.no_poliza
		   and e.no_endoso   = a.no_endoso
		   and e.actualizado = 1
		   and a.cuenta      = _cuenta
		   and e.user_added  <> "GERENCIA"
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
		
	-- Registros Contables Incobrables
{
	let _concepto	= "003"; -- Facturacion
	let _origen		= "INC"; -- Produccion
	let _tipo_comp2 = 0;

	foreach
	 select	tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	endedmae e, endasien a
	  where e.periodo     = a_periodo
	    and e.no_poliza   = a.no_poliza
		and e.no_endoso   = a.no_endoso
		and e.actualizado = 1
		and e.cod_tipocan = "013"
	  group by tipo_comp, cuenta
	  order by tipo_comp, cuenta

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 then

			let _tipo_compd  = sp_sac11(5, _tipo_comp);
			let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
			
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

	end foreach
}

elif a_origen = 2 then -- Reclamos

	let _concepto	= "003"; -- Facturacion
	let _origen		= "REC"; -- Reclamos
	let _tipo_comp2 = 0;

	foreach
	 select	tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	rectrmae e, recasien a
	  where e.periodo     = a_periodo
	    and e.no_tranrec  = a.no_tranrec
		and e.actualizado = 1
	  group by tipo_comp, cuenta
	  order by tipo_comp, cuenta

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 then

			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;

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
		  from rectrmae e, recasiau a
		 where e.periodo     = a_periodo
		   and e.actualizado = 1
		   and e.no_tranrec  = a.no_tranrec
		   and a.cuenta      = _cuenta
		   and a.tipo_comp   = _tipo_comp
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

elif a_origen = 3 then -- Cobros

	let _concepto	= "005"; -- Otros Ingresos
	let _origen		= "COB"; -- Cobros
	let _tipo_comp2 = 0;

	-- Tablas Temporales

	create temp table tmp_prod(
	tipo_comp	smallint,
	cuenta		CHAR(25),
	debito      DECIMAL(16,2),
	credito		DECIMAL(16,2)
	) with no log;

	create temp table tmp_prod2(
	tipo_comp		smallint,
	cuenta			CHAR(25),
	cod_auxiliar	char(5),
	debito          DECIMAL(16,2),
	credito			DECIMAL(16,2)
	) with no log;

	create index idx_tmp_prod2_1 on tmp_prod2 (tipo_comp, cuenta); 

	-- Proceso de Actualizacion

	FOREACH 
	SELECT no_remesa,
	       tipo_remesa
	  INTO _no_remesa,
	       _tipo_remesa
	  FROM cobremae
	 WHERE periodo     = a_periodo
	   AND actualizado = 1

		IF _tipo_remesa = "A" Or
		   _tipo_remesa = "M" THEN
		   LET _tipo_comp = 1;
		ELSE
		   LET _tipo_comp = 2;
		END IF

	   FOREACH
		SELECT debito,
			   credito,
			   cuenta,
			   renglon
		  INTO _debito,
		       _credito,
		       _cuenta,
			   _renglon
		  FROM cobasien
		 WHERE no_remesa = _no_remesa

			INSERT INTO tmp_prod(
			tipo_comp,
			cuenta,   
			debito,	  
		    credito
			)
			VALUES(
			_tipo_comp,
			_cuenta,  
			_debito,
			_credito
			);

			foreach
			 select	cod_auxiliar,
			        debito,
					credito
			   into _cod_auxiliar,
			        _debito,
					_credito
			   from	cobasiau
			  where no_remesa = _no_remesa
				and renglon   = _renglon
				and cuenta    = _cuenta

				INSERT INTO tmp_prod2(
				tipo_comp,
				cuenta,
				cod_auxiliar, 
				debito,	  
			    credito
				)
				VALUES(
				_tipo_comp,
				_cuenta,  
				_cod_auxiliar,
				_debito,
				_credito
				);

			end foreach

		END FOREACH

{
		foreach
		 select	renglon,
				cod_auxiliar
		   INTO _renglon,
		   		_cod_auxiliar
		   FROM cobredet
		  WHERE no_remesa    = _no_remesa
			and cod_auxiliar is not null

			foreach
			 select	debito,
				    credito,
				    cuenta
			   INTO _debito,
			        _credito,
			        _cuenta
			   FROM cobasien
			  WHERE no_remesa = _no_remesa
				and renglon   = _renglon

				select cta_auxiliar
				  into _cta_auxiliar
				  from cglcuentas
				 where cta_cuenta = _cuenta;
						
				if _cta_auxiliar = "S" then

					INSERT INTO tmp_prod2(
					tipo_comp,
					cuenta,
					cod_auxiliar, 
					debito,	  
				    credito
					)
					VALUES(
					_tipo_comp,
					_cuenta,  
					_cod_auxiliar,
					_debito,
					_credito
					);
			
				end if

			end foreach

		END FOREACH
}

	END FOREACH;

	foreach
	 select	tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	tmp_prod
	  group by tipo_comp, cuenta
	  order by tipo_comp, cuenta

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 then

			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
			
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
			0.00,
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

		let _linea_aux = 0;

		foreach
		 select cod_auxiliar,
		 		sum(debito),
		        sum(credito)
		   into _cod_auxiliar,
		  	    _debito_tab2,
			    _credito_tab2
		   from tmp_prod2
		  where tipo_comp = _tipo_comp
		    and cuenta    = _cuenta
 		  group by cod_auxiliar

			let _debito    = _debito_tab2;
			let _credito   = _credito_tab2;
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
	drop table tmp_prod2;

elif a_origen = 4 then -- Cheques

	-- Cheques Pagados

	let _concepto	= "004"; -- Cheques
	let _origen		= "CHE"; -- Cheques
	let _tipo_comp  = 1;
	let _linea		= 0;

	let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
	let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
	let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
	
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
	 select	x.cuenta,
	 		sum(x.debito),
			sum(x.credito)
	   into	_cuenta,
	   		_debito,
			_credito
	   from	chqchcta x, chqchmae y
	  where x.no_requis              = y.no_requis
	    and year(y.fecha_impresion)  = a_periodo[1,4]
	    and month(y.fecha_impresion) = a_periodo[6,7]
		and y.pagado                 = 1
	  group by x.cuenta
	  order by x.cuenta

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

		-- Auxiliar por Programa

		let _linea_aux = 0;

		foreach
		 select cod_auxiliar,
		 		sum(debito),
		        sum(credito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqctaux x, chqchmae y
		  where x.no_requis              = y.no_requis
		    and year(y.fecha_impresion)  = a_periodo[1,4]
		    and month(y.fecha_impresion) = a_periodo[6,7]
			and y.pagado                 = 1
		    and x.cuenta                 = _cuenta
			and cod_auxiliar             is not null
 		  group by cod_auxiliar

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

		-- Auxiliar por Usuario

		foreach
		 select cod_auxiliar,
		 		sum(debito),
		        sum(credito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqchcta x, chqchmae y
		  where x.no_requis              = y.no_requis
		    and year(y.fecha_impresion)  = a_periodo[1,4]
		    and month(y.fecha_impresion) = a_periodo[6,7]
			and y.pagado                 = 1
		    and x.cuenta                 = _cuenta
			and cod_auxiliar             is not null
 		  group by cod_auxiliar

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

	-- Cheques Anulados

	let _concepto	= "004"; -- Cheques
	let _origen		= "CHE"; -- Cheques
	let _tipo_comp  = 2;
	let _linea		= 0;

	let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
	let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
	let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
	
	select count(*)
	  into _cantidad
	  from cgltrx1
	 where trx1_comprobante = _comprobante;
	 
	 if _cantidad <> 0 then
	 	return 1, "El Comprobante " || _comprobante || " Ya Fue Capturado";
	 end if 

	create temp table tmp_cuenta2(
	cuenta			char(25),
	cod_auxiliar	char(5),
	debito			dec(16,2),
	credito			dec(16,2)
	) with no log;

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

	FOREACH
	 SELECT	x.cuenta,
	 		x.debito,
			x.credito,
			y.fecha_impresion,
			y.fecha_anulado,
			y.no_requis
	   INTO	_cuenta,
			_credito_tab,
	   		_debito_tab,
			_fecha_impresion,
			_fecha_anulado,
			_no_requis
	   FROM	chqchcta x, chqchmae y
	  WHERE x.no_requis            = y.no_requis
	    and year(y.fecha_anulado)  = a_periodo[1,4]
	    and month(y.fecha_anulado) = a_periodo[6,7]
		AND y.anulado              = 1

		let _periodo1 = sp_sis39(_fecha_impresion);
		let _periodo2 = sp_sis39(_fecha_anulado);

		if _periodo1 = _periodo2 then
			continue foreach;
		end if

		INSERT INTO tmp_cuenta(
		cuenta,
		debito,
		credito
		)
		VALUES(
		_cuenta,
		_debito_tab,
		_credito_tab
		);

		-- Auxiliar por Programa

		foreach
		 select cod_auxiliar,
		 		sum(credito),
		        sum(debito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqctaux x
		  where x.cuenta     = _cuenta
			and x.no_requis  = _no_requis
			and cod_auxiliar is not null
 		  group by cod_auxiliar

			INSERT INTO tmp_cuenta2(
			cuenta,
			cod_auxiliar,
			debito,
			credito
			)
			VALUES(
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito
			);

		end foreach

		-- Auxiliar por Usuario

		foreach
		 select x.cod_auxiliar,
		 		sum(x.credito),
		        sum(x.debito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	chqchcta x
		  where x.cuenta       = _cuenta
			and x.no_requis    = _no_requis
			and x.cod_auxiliar is not null
 		  group by x.cod_auxiliar

			INSERT INTO tmp_cuenta2(
			cuenta,
			cod_auxiliar,
			debito,
			credito
			)
			VALUES(
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito
			);

		end foreach

	END FOREACH

	foreach
	 select	cuenta,
	 		sum(debito),
			sum(credito)
	   into	_cuenta,
	   		_debito,
			_credito
	   from	tmp_cuenta
	  group by cuenta
	  order by cuenta

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

		-- Auxiliares

		let _linea_aux = 0;

		foreach
		 select cod_auxiliar,
		 		sum(debito),
		        sum(credito)
		   into _cod_auxiliar,
		  	    _debito,
			    _credito
		   from	tmp_cuenta2
		  where cuenta    = _cuenta
 		  group by cod_auxiliar

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

	drop table tmp_cuenta2;

elif a_origen = 6 then -- Planilla

	let _concepto	= "014"; -- Planilla
	let _origen		= "PLA"; -- Planilla
	let _tipo_comp2 = 0;

	foreach
	 select	tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	plaasien
	  where periodo  = a_periodo
	    and posteado = 0
	  group by tipo_comp, cuenta
	  order by tipo_comp, cuenta

		-- Encabezado del Comprobante

		if _tipo_comp <> _tipo_comp2 then

			let _tipo_compd  = sp_sac11(a_origen, _tipo_comp);
			let _descrip     = _origen || " " || a_periodo || " " || trim(_tipo_compd);
			let _comprobante = _origen || a_periodo[6,7] || a_periodo[3,4] || _tipo_comp;
			
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

	end foreach

end if

end

drop table tmp_cuenta;

return 0, "Actualizacion Exitosa";

end procedure