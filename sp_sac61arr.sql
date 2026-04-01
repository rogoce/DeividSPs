-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac61arr;

create procedure sp_sac61arr(
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

	foreach
	 select	no_poliza,
	        no_endoso,
			periodo,
			fecha_emision
	   into	_no_poliza,
	        _no_endoso,
			_periodo,
			_fecha_anulado
	   from	endedmae
	  where actualizado  = 1
	    and sac_asientos = 1
		and periodo in ('2020-04','2020-08')

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

		update endedmae
		   set sac_asientos = 2
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso;

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

	let _origen		   = "PRO"; -- Produccion
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
		
elif a_origen = 2 then -- Reclamos

	-- Seteos Iniciales

	create temp table tmp_rec(
	no_tranrec	char(10),
	periodo		char(7)
	) with no log;

	foreach
	 select	no_tranrec,
	        periodo,
			no_reclamo
	   into	_no_tranrec,
	        _periodo,
			_no_reclamo
	   from	rectrmae
	  where actualizado  = 1
	    and sac_asientos = 1

		insert into tmp_rec
		values (_no_tranrec, _periodo);

		update rectrmae
		   set sac_asientos = 2
		 where no_tranrec   = _no_tranrec;

	end foreach

	-- Actualizacion de Tablas Intermedias

	let _origen		   = "REC"; -- Reclamos
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
	   from	tmp_rec e, recasien a
	  where e.no_tranrec  = a.no_tranrec
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

		-- Trazabilidad con Reclamos

		update recasien
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
		 select a.cod_auxiliar,
		        sum(a.debito),
			    sum(a.credito)
		  into _cod_auxiliar,
		  	   _debito_tab,
			   _credito_tab
		  from tmp_rec e, recasiau a
		 where a.no_tranrec   = e.no_tranrec
		   and a.cuenta       = _cuenta
		   and a.tipo_comp    = _tipo_comp
		   and a.periodo      = _periodo
		   and a.centro_costo = _centro_costo
		   and a.fecha        = _fecha_anulado
 		 group by a.cod_auxiliar

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

	drop table tmp_rec;

elif a_origen = 3 then -- Cobros

	-- Seleccion de Registros

	create temp table tmp_cob(
	no_remesa	char(10)
	) with no log;

	foreach
	 select	no_remesa
	   into	_no_remesa
	   from	cobredet
	  where actualizado  = 1
	    and sac_asientos = 1
	  group by no_remesa
	  order by no_remesa

		insert into tmp_cob
		values (_no_remesa);

		update cobredet
		   set sac_asientos = 2
		 where no_remesa    = _no_remesa;

	end foreach

	-- Tablas Temporales

	create temp table tmp_prod(
	centro_costo	char(3),
	periodo			char(7),
	fecha			date,
	tipo_comp		smallint,
	cuenta			char(25),
	debito      	dec(16,2),
	credito			dec(16,2)
	) with no log;

	create temp table tmp_prod2(
	centro_costo	char(3),
	periodo			char(7),
	fecha			date,
	tipo_comp		smallint,
	cuenta			char(25),
	cod_auxiliar	char(5),
	debito          dec(16,2),
	credito			dec(16,2)
	) with no log;

	create index idx_tmp_prod2_1 on tmp_prod2 (centro_costo, periodo, fecha, tipo_comp, cuenta); 

	-- Proceso Intermedio de Agrupacion de Asientos

   FOREACH 
	SELECT no_remesa
	  INTO _no_remesa
	  FROM tmp_cob

		SELECT tipo_remesa,
		       periodo,
			   fecha,
			   cod_chequera
		  INTO _tipo_remesa,
		       _periodo,
			   _fecha,
			   _cod_chequera
		  FROM cobremae
		 WHERE no_remesa = _no_remesa;

		if _no_remesa = "872951" then

			let _periodo = "2014-12";
			let _fecha   = "02/12/2014";

		end if

		if _fecha > "31/12/2009" then

			let _tipo_comp = _cod_chequera;

		else

			let _tipo_comp = 2;

		end if

		foreach
		 select renglon,
		        tipo_mov,
				no_poliza,
				no_reclamo
		   into _renglon,
		        _tipo_mov,
				_no_poliza,
				_no_reclamo
		   from cobredet
		  where no_remesa = _no_remesa

			if _tipo_mov in ("P", "N", "X") then 

				call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

				if _error <> 0 then

					if _error_desc is null then
						let _error_desc = "No Hay Centro de Costo para la Poliza: " || _no_poliza; 
					end if

					return _error, _error_desc;

				end if

			elif _tipo_mov in ("M", "C", "E", "A", "B", "O") then 

				call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

				if _error <> 0 then

					if _error_desc is null then
						let _error_desc = "No Hay Centro de Costo en Remesa: " || _no_remesa; 
					end if

					return _error, _error_desc;

				end if

			elif _tipo_mov in ("D", "S", "R", "T") then 

				call sp_sac93(_no_reclamo, 3) returning _error, _error_desc, _centro_costo;

				if _error <> 0 then

					if _error_desc is null then
						let _error_desc = "No Hay Centro de Costo en Reclamo: " || _no_reclamo; 
					end if

					return _error, _error_desc;

				end if

			end if

			update cobasien
			   set tipo_comp    = _tipo_comp,
			       periodo      = _periodo,
				   fecha        = _fecha,
				   centro_costo = _centro_costo,
				   sac_notrx    = null
			 where no_remesa    = _no_remesa
			   and renglon      = _renglon;

			update cobasiau
			   set tipo_comp    = _tipo_comp,
			       periodo      = _periodo,
				   centro_costo = _centro_costo
			 where no_remesa    = _no_remesa
			   and renglon      = _renglon;

		   foreach
			select debito,
				   credito,
				   cuenta
			  into _debito,
			       _credito,
			       _cuenta
			  from cobasien
			 where no_remesa = _no_remesa
			   and renglon   = _renglon

				insert into tmp_prod(
				centro_costo,
				periodo,
				fecha,
				tipo_comp,
				cuenta,   
				debito,	  
			    credito
				)
				values(
				_centro_costo,
				_periodo,
				_fecha,
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
					centro_costo,
					periodo,
					fecha,
					tipo_comp,
					cuenta,
					cod_auxiliar, 
					debito,	  
				    credito
					)
					VALUES(
					_centro_costo,
					_periodo,
					_fecha,
					_tipo_comp,
					_cuenta,  
					_cod_auxiliar,
					_debito,
					_credito
					);

				end foreach

			END FOREACH

		end foreach

	END FOREACH;

	-- Proceso de Actualizacion

	let _concepto	   = "015"; -- Cajas
	let _origen		   = "COB"; -- Cobros
	let _tipo_comp2    = 0;
	let _periodo2      = "0";
	let _centro_costo2 = "0";
	
	let _fecha_impresion = MDY(1, 1, 1901);

	foreach
	 select	centro_costo,
	 		periodo,
			fecha,
	        tipo_comp,
	        cuenta,
	        sum(debito),
			sum(credito)
	   into	_centro_costo,
	   		_periodo,
			_fecha,
	        _tipo_comp,
	        _cuenta,
			_debito_tab,
			_credito_tab
	   from	tmp_prod
	  group by periodo, fecha, centro_costo, tipo_comp, cuenta
	  order by periodo, fecha, centro_costo, tipo_comp, cuenta

		-- Encabezado del Comprobante

--		let _fecha = sp_sac62(_periodo);

		if _tipo_comp    <> _tipo_comp2      or
		   _periodo      <> _periodo2        or
		   _centro_costo <> _centro_costo2   or
		   _fecha        <> _fecha_impresion then

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
			0.00,
			_moneda,
			0.00,
			0.00,
			_status,
			_origen,
			_usuario,
			_fechacap
			);

			let _tipo_comp2      = _tipo_comp;
			let _periodo2        = _periodo;
			let _linea		     = 0;
			let _centro_costo2   = _centro_costo;
			let _fecha_impresion = _fecha;

		end if

		-- Trazabilidad con Cobros

		update cobasien
		   set sac_notrx    = _notrx
		 where periodo      = _periodo
		   and tipo_comp    = _tipo_comp
		   and cuenta       = _cuenta
		   and centro_costo = _centro_costo
		   and fecha        = _fecha
		   and sac_notrx    is null;

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

		let _linea_aux = 0;

		foreach
		 select cod_auxiliar,
		 		sum(debito),
		        sum(credito)
		   into _cod_auxiliar,
		  	    _debito_tab2,
			    _credito_tab2
		   from tmp_prod2
		  where centro_costo = _centro_costo
		    and periodo      = _periodo
			and fecha        = _fecha
		    and tipo_comp    = _tipo_comp
		    and cuenta       = _cuenta
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
	drop table tmp_cob;

elif a_origen = 4 then -- Cheques

	create temp table tmp_che(
	no_requis	char(10),
	fecha		date
	) with no log;

	let _cheq_planilla	= "013";

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
		and cod_chequera <> _cheq_planilla
	
		if _centro_costo is null then

			call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

			if _error <> 0 then
				return _error, _error_desc;
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
			   tipo_requis  = "C",
			   sac_notrx    = null
		 where no_requis    = _no_requis
		   and tipo         = 1;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 1
		   and centro_costo is null;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 1
		   and centro_costo = "0";

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

		let _concepto	   = "004"; -- Cheques
		let _origen		   = "CHE"; -- Cheques
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
		and cod_chequera <> _cheq_planilla
	
		if _centro_costo is null then

			call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

			if _error <> 0 then
				return _error, _error_desc;
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
			   tipo_requis  = "C",
			   sac_notrx    = null
		 where no_requis    = _no_requis
		   and tipo         = 2;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 2
		   and centro_costo is null;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 2
		   and centro_costo = "0";

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

		let _concepto	   = "004"; -- Cheques
		let _origen		   = "CHE"; -- Cheques
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
		and cod_chequera <> _cheq_planilla
	
		if _centro_costo is null then

			call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

			if _error <> 0 then
				return _error, _error_desc;
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
			   tipo_requis  = "A",
			   sac_notrx    = null
		 where no_requis    = _no_requis
		   and tipo         = 1;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 1
		   and centro_costo is null;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 1
		   and centro_costo = "0";

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

		let _concepto	   = "004"; -- Cheques
		let _origen		   = "CHE"; -- Cheques
		let _tipo_comp     = 3;
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
		and cod_chequera <> _cheq_planilla
	
		if _centro_costo is null then

			call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

			if _error <> 0 then
				return _error, _error_desc;
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
			   tipo_requis  = "A",
			   sac_notrx    = null
		 where no_requis    = _no_requis
		   and tipo         = 2;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 2
		   and centro_costo is null;

		update chqchcta
		   set centro_costo = _centro_costo
		 where no_requis    = _no_requis
		   and tipo         = 2
		   and centro_costo = "0";

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

		let _concepto	   = "004"; -- Cheques
		let _origen		   = "CHE"; -- Cheques
		let _tipo_comp     = 4;
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

	end if

	drop table tmp_che;

elif a_origen = 6 then -- Planilla

	-- Procedure para planilla
	 call sp_sac135(a_usuario,a_origen) returning _mayor_error, _mayor_desc;
	
	if _mayor_error <> 0 then
		return _mayor_error, _mayor_desc;
	end if

elif a_origen = 9 then -- Reaseguro

	-- Procedure para reaseguro
	-- call sp_sac134()

elif a_origen = 10 then -- Suministros

	call sp_sac139(a_usuario, a_origen) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then
		return _mayor_error, _mayor_desc;
	end if

elif a_origen = 11 then -- Agentes

elif a_origen = 12 then -- Reaseguro

	call sp_sac163(a_usuario, a_origen) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then
		return _mayor_error, _mayor_desc;
	end if

elif a_origen = 13 then -- Inventario

	call sp_sac199(a_usuario, a_origen) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then
		return _mayor_error, _mayor_desc;
	end if

end if

drop table tmp_cuenta;

-- Mayorizacion

foreach
 select notrx
   into _notrx
   from tmp_posteo

	call sp_sac64arr("001", _notrx, a_usuario) returning _mayor_error, _mayor_desc;

	if _mayor_error <> 0 then

		if _mayor_desc is null then
			let _mayor_desc = "Error en sp_sac64";
		end if

		return _mayor_error, _mayor_desc;
	end if
end foreach

drop table tmp_posteo;

end

return 0, "Actualizacion Exitosa";

end procedure