	-- Seteos Iniciales

	create temp table tmp_rea(
	no_remesa	char(10)
	) with no log;

	foreach
	 select	no_remesa
	   into	_no_remesa
	   from	reatrx1
	  where actualizado  = 1
	    and sac_asientos = 1

		insert into tmp_rea
		values (_no_remesa);

		update reatrx1
		   set sac_asientos = 2
		 where no_remesa    = _no_remesa;

	end foreach

	-- Actualizacion de Tablas Intermedias

	let _origen		   = "REA"; -- Reaseguro
	let _tipo_comp2    = 0;
	let _periodo2      = "0";
	let _centro_costo2 = "0";

	foreach
	 select	e.periodo,
	        a.tipo_comp,
	        a.cuenta,
			a.centro_costo,
	        sum(a.debito),
			sum(a.credito)
	   into	_periodo,
	        _tipo_comp,
	        _cuenta,
			_centro_costo,
			_debito_tab,
			_credito_tab
	   from	tmp_rea e, reaasien a
	  where e.no_remesa  = a.no_remesa
	  group by a.centro_costo, e.periodo, a.tipo_comp, a.cuenta
	  order by a.centro_costo, e.periodo, a.tipo_comp, a.cuenta

		let _fecha = sp_sac62(_periodo);

		-- Encabezado del Comprobante

		if _tipo_comp    <> _tipo_comp2    or
		   _periodo      <> _periodo2      or
		   _centro_costo <> _centro_costo2 then

			if _tipo_comp = 1 then
				let _concepto	= "009"; -- Por Pagar Proveedores
			else
				let _concepto	= "009"; -- Por Definir
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

			let _tipo_comp2    = _tipo_comp;
			let _linea		   = 0;
			let _periodo2      = _periodo;
			let _centro_costo2 = _centro_costo;

		end if

		-- Trazabilidad con Reaseguro

		update reaasien
		   set sac_notrx    = _notrx
		 where periodo      = _periodo
		   and tipo_comp    = _tipo_comp
		   and cuenta       = _cuenta
		   and centro_costo = _centro_costo
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
		  from tmp_rea e, reaasien a
		 where a.no_remesa    = e.no_remesa
		   and a.cuenta       = _cuenta
		   and a.tipo_comp    = _tipo_comp
		   and a.periodo      = _periodo
		   and a.centro_costo = _centro_costo
		   and a.cod_auxiliar is not null
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

	drop table tmp_rea;
