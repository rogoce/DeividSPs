-- Procedure que carga los usuarios para el WEB

-- Creado: 13/03/2008 - Autor: Itzis Nunez Brown

drop procedure sp_usuariosweb;

create procedure "informix".sp_usuariosweb()
returning integer,
          char(100);

define _compania			char(3);
define _sucursal			char(3);
define _fecha_moros			date;
define _periodo_moros		char(7);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set isolation to dirty read;

--SET DEBUG FILE TO "sp_usuariosweb.trc";
--TRACE ON ;


-- Eliminar Registros de Tablas Temporales

delete from usuario_web:web_usuario_aa;


-- Corredores

foreach
 select cod_usuario
   into _cod_usuario
   from	web_usuario
  where	tipo_usuario   = 2
    and status_usuario = 1

	let _cod_agente = _cod_usuario;

	select nombre
	  into _nombre_agente
	  from agtagent
     where cod_agente = _cod_usuario;

	insert into deivid_web:web_agente(
	cod_agente,
	nombre
	)
	values(
	_cod_usuario,
	_nombre_agente
	);

	foreach
	 select p.no_documento
	   into _no_documento
	   from emipoagt a, emipomae p
	  where a.cod_agente  = _cod_usuario
	    and a.no_poliza   = p.no_poliza
		and p.actualizado = 1
 	  group by p.no_documento

		let _no_poliza = sp_sis21(_no_documento);
		let _flag = 0;
		foreach
		 select cod_agente
		   into _cod_agente1	
		   from emipoagt 
		  where no_poliza   = _no_poliza

			if _cod_agente = _cod_agente1 then
				let _flag = 1;
				exit foreach;
			end if
		end foreach

		if _flag = 0 then
			continue foreach;
		end if
		-- Datos de la Poliza

		select cod_ramo,
		       cod_subramo,
		       vigencia_inic,
		       vigencia_final,
		       estatus_poliza,
			   cod_formapag,
			   fecha_cancelacion,
			   cod_contratante,
			   prima_bruta,
			   dia_cobros1,
			   no_pagos,
			   cod_perpago,
			   carta_aviso_canc,
			   fecha_aviso_canc,
			   nueva_renov
		  into _cod_ramo,
		       _cod_subramo,
			   _vigencia_inic,
			   _vigencia_final,
			   _estatus_poliza,
			   _cod_formapag,
			   _fecha_cancelacion,
			   _cod_contratante,
			   _prima_bruta,
			   _dia_cobros1,
			   _no_pagos,
			   _cod_frec_pago,
			   _carta_aviso_canc,
			   _fecha_aviso_canc,
			   _nueva_renov
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre_asegurado
		  from cliclien
		 where cod_cliente = _cod_contratante;

		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _nombre_subramo
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;

		select nombre
		  into _nombre_formapag
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		-- Morosidad de la Poliza

		call sp_cob33(
			_compania,
			_sucursal,
			_no_documento,
			_periodo_moros,
			_fecha_moros
		   	) RETURNING _moro_por_vencer,
						_moro_exigible,
						_moro_corriente,
						_moro_30,
						_moro_60,
						_moro_90,
						_moro_saldo;


		-- Estatus de la Poliza

		if _estatus_poliza = 1 then
			let _estatus_desc = "VIGENTE";
		elif _estatus_poliza = 2 then
			let _estatus_desc = "CANCELADA";
		elif _estatus_poliza = 3 then
			let _estatus_desc = "VENCIDA";
		elif _estatus_poliza = 4 then
			let _estatus_desc = "ANULADA";
		end if


		-- Renovacion de la Poliza

		if _nueva_renov = 'N' then
			let _renov_desc = "NUEVA";
		elif _nueva_renov = 'R' then
			let _renov_desc = "RENOVADA";
	  	end if


		-- Frecuencia de Pago
		select nombre
		  into _frec_pago_desc
		  from cobperpa
		 where cod_perpago = _cod_frec_pago;


		if _deduc_acum is null then
			let _deduc_acum = 0.00;
		end if


		-- Datos del pago
	   foreach
		select no_recibo,
			   fecha,
			   prima_neta,
			   impuesto,
			   monto,
			   no_remesa,
			   monto_descontado
		  into _no_recibo,
			   _fecha_rec,
			   _prima_neta,
			   _impuesto,
			   _monto,
			   _no_remesa,
			   _monto_descontado
		  from cobredet
		 where doc_remesa  = _no_documento
		   and actualizado = 1
		   and tipo_mov    in ("P", "N")
		   and periodo     matches ("*")

		SELECT tipo_remesa
		  INTO _tipo_remesa 
		  FROM cobremae
		 WHERE no_remesa = _no_remesa;

	    IF   _tipo_remesa = 'C' THEN
	      LET v_referencia = 'COMPROBANTE';
		ELSE
	      LET v_referencia = 'RECIBO';
	    END IF


			-- Insertar Registros de Pagos
			insert into deivid_web:web_pago(
			num_poliza,
			num_recibo,
			fecha_recibo,
			prima,
			impuesto,
			total_pagado,
			referencia,
			monto_descontado
			)
			values(
			_no_documento,
			_no_recibo,
			_fecha_rec,
			_prima_neta,
			_impuesto,
			_monto,
			v_referencia,
			_monto_descontado
			);

		end foreach

		-- Datos de Cliente
		select cod_cliente,
			   nombre,
			   direccion_1,
			   telefono1,
			   telefono2,
			   direccion_cob,
			   e_mail,
			   apartado
		  into _cod_cliente,
			   _nombre_cliente,
			   _direccion,
			   _telefono1,
			   _telefono2,
			   _direccion_cob,
			   _email,
			   _apartado
		  from cliclien
		 where cod_cliente = _cod_contratante;

		-- Datos de Cobertura
		foreach
		    select no_unidad,
				   suma_asegurada,
				   prima,
				   descuento,
				   recargo,
				   prima_neta,
				   impuesto,
				   prima_bruta
		      into _no_unidad,
				   _suma_asegurada,
				   _prima_uni,
				   _desc_uni,
				   _recargo,
				   _prima_neta_uni,
				   _impuesto_uni,
				   _prima_bruta_uni
		      from emipouni
		     where no_poliza = _no_poliza
			   and activo    = 1

		foreach
			 select cod_parentesco,
					cod_cliente
			   into _cod_parentesco,
				    _cod_cliente1
			   from emidepen
			  where no_poliza = _no_poliza
				and no_unidad = _no_unidad

			 select nombre
			   into _nom_parentesco
			   from emiparen
			  where cod_parentesco = _cod_parentesco;

			 select nombre
			   into _nom_cliente1
			   from cliclien
			  where cod_cliente = _cod_cliente1;

			insert into deivid_web:web_dependiente(
				num_poliza,
				num_unidad,
				parentesco,
				nombre
				)
				values(
				_no_documento,
				_no_unidad,
				_nom_parentesco,
				_nom_cliente1
				);	

		end foreach

			   foreach
				select e.orden,
					   e.cod_cobertura,
					   e.limite_1,
					   e.limite_2,
					   e.deducible,
					   e.prima_neta
				  into _orden,
					   _cod_cobertura,
					   _limite1,
					   _limite2,
					   _deducible,
					   _prima_neta
				  from emipocob e
				 where e.no_poliza = _no_poliza
				   and e.no_unidad = _no_unidad

					if _deducible is null then
						let _deducible = 0.00;
					end if

					-- Descripcion de cobertura
					select nombre
					  into _cobertura
					  from prdcober
					 where cod_cobertura = _cod_cobertura;

					-- Insertar Registros de Cobertura
					insert into deivid_web:web_cobertura(
					num_poliza,
					num_unidad,
					orden,
					riesgos,
					limite1,
					limite2,
					deducibles,
					primas
				    )
					values(
					_no_documento,
					_no_unidad,
					_orden,
					_cobertura,
					_limite1,
					_limite2,
					_deducible,
					_prima_neta
					);

				end foreach

				-- Insertar Registros de Unidades
					insert into deivid_web:web_unidades(
					num_poliza,
					num_unidad,
					suma_asegurada,
					prima,
					descuento,
					recargo,
					prima_neta,
					impuesto,
					prima_bruta
				    )
					values(
					_no_documento,
					_no_unidad,
					_suma_asegurada,
				    _prima_uni,
				    _desc_uni,
				    _recargo,
				    _prima_neta_uni,
				    _impuesto_uni,
				    _prima_bruta_uni
					);

			end foreach

	-- Datos de Reclamos

	foreach
	 select no_reclamo,
	 		numrecla,
	        estatus_reclamo,
	        fecha_siniestro,
	        ajust_interno
	   into _no_reclamo,
	   		_numreclamo,
	        _estatus_reclamo,
	        _fecha_siniestro,
	        _cod_ajust_interno
	   from recrcmae
	  where no_documento = _no_documento
	    and no_unidad    = _no_unidad
		and actualizado  = 1

		


		-- Nombre de Ajustador Interno
		select nombre
		  into _nombre_ajust
		  from recajust
		 where cod_ajustador = _cod_ajust_interno;


		-- Estatus de Reclamo
		If _estatus_reclamo = 'A' Then
			LET _estatus = 'ABIERTO';
		ELIF _estatus_reclamo = 'C' Then
			LET _estatus = 'CERRADO';
		ELIF _estatus_reclamo = 'R' Then
			LET _estatus = 'RE-ABIERTO';
		ELIF _estatus_reclamo = 'T' Then
			LET _estatus = 'EN TRAMITE';
		ELIF _estatus_reclamo = 'D' Then
			LET _estatus = 'DECLINADO';
		ELIF _estatus_reclamo = 'N' Then
			LET _estatus = 'NO APLICA';
		END IF


		-- Insertar Registros de Reclamo
		insert into deivid_web:web_reclamo(
		num_poliza,
		num_reclamo,
		status,
		fecha_sinies,
		ded_caja,
		reserva,
		siniestrabilidad,
		num_unidad,
		ajustador
	    )
		values(
		_no_documento,
		_numreclamo,
		_estatus,
		_fecha_siniestro,
		0.00,
		0.00,
		0.00,
		_no_unidad,
		_nombre_ajust
		);

		-- Bitacora de reclamos/notas
		foreach
		 select fecha_nota,
		 		desc_nota,
		        user_added
		   into _fecha_nota,
		   		_desc_nota,
		        _user_added
		   from recnotas
		  where no_reclamo = _no_reclamo
		
		-- Insertar Registros de Notas del Reclamo
		insert into deivid_web:web_notasrecla(
		num_poliza,
		num_reclamo,
		fecha_nota,
		desc_nota,
		user_added
	    )
		values(
		_no_documento,
		_numreclamo,
		_fecha_nota,
		_desc_nota,
		_user_added
		);

	   end foreach


		-- Datos de Pago de Reclamo
	   foreach
		select cod_tipopago,
			   no_requis,
			   monto,
			   transaccion
		  into _cod_tipo_pago,
			   _no_requis,
			   _monto_cheque,
			   _transaccion
		  from rectrmae
		 where numrecla     = _numreclamo
		   and cod_tipotran = '004'
		   and actualizado  = 1
		   and anular_nt    is null

			-- Numero de Cheque
			select no_cheque,
			       fecha_impresion,
				   a_nombre_de
			  into _no_cheque,
				   _fecha_impresion,
				   _beneficiario
			  from chqchmae
			 where no_requis = 	_no_requis;

			if _no_cheque is null then
				continue foreach;
			end if

			-- Descripcion de Tipo de Pago
			select nombre
			  into _nom_tip_pago
			  from rectipag
			 where cod_tipopago = _cod_tipo_pago;

			-- Insertar Pagos de Reclamos
			insert into deivid_web:web_reclamo_pago(
			num_reclamo,
			cheque,
			fecha_pago,
			beneficiario,
			cobertura,
			total_pagado,
			tipo_pago,
			transaccion
			)
			values(
			_numreclamo,
			_no_cheque,
			_fecha_impresion,
			_beneficiario,
			'',
			_monto_cheque,
			_nom_tip_pago,
			_transaccion
			);

		end foreach


	end foreach

-- Insertar todos los registros en la base de datos Poliza_aa
		-- Insertar registros de Poliza
		insert into deivid_web:web_poliza(
		num_poliza,
		cod_cliente,
		vig_inicial,
		vig_final,
		saldo,
		saldo_venc,
		ramo,
		subramo,
		status_poliza,
		prima_anual,
		num_pagos,
	   	forma_pago,
		frec_pago,
		dia_corte,
		cod_agente,
		saldo_pend,
		saldo_corr,
		saldo_30dias,
		saldo_60dias,
		saldo_90dias,
		carta_aviso_canc,
		fecha_aviso_canc,
		fecha_cancelacion,
		renov_desc
		)
		values(
		_no_documento,
		_cod_contratante,
		_vigencia_inic,
		_vigencia_final,
		_moro_saldo,
		_moro_por_vencer,
		_nombre_ramo,
		_nombre_subramo,
		_estatus_desc,
		_prima_bruta,
		_no_pagos,
		_nombre_formapag,
		_frec_pago_desc,
		_dia_cobros1,
		_cod_agente,
		_moro_exigible,
		_moro_corriente,
		_moro_30,
		_moro_60,
		_moro_90,
		_carta_aviso_canc,
		_fecha_aviso_canc,
		_fecha_cancelacion,
		_renov_desc
		);


		-- Insertar Registros de Cliente

		select count(*)
		  into _cantidad
		  from deivid_web:web_cliente
		 where cod_cliente = _cod_cliente;

		if _cantidad = 0 then

			insert into deivid_web:web_cliente(
			cod_cliente,
			nom_cliente,
			ciudad,
			direccion,
			telefono1,
			telefono2,
			email,
			apartado,
			dir_cobro,
			ciudad_cobro,
			tel_cobro
			)
			values(
			_cod_cliente,
			_nombre_cliente,
			'',
			_direccion,
			_telefono1,
			_telefono2,
			_email,
			_apartado,
			_direccion_cob,
			'',
			''
			);

		end if

        let _vigencia_inic = 0;
		let _vigencia_final = 0;
		let _prima_neta = 0;
		let _impuesto = 0;
		let _prima_bruta = 0;

	   -- Datos de Endoso
	   foreach	
		select no_endoso,
			   cod_endomov,
			   vigencia_inic,
			   vigencia_final,
			   prima_neta,
			   impuesto,
			   prima_bruta,
			   no_factura,
			   periodo,
			   fecha_emision
		  into _no_endoso,
		  	   _cod_endomov,
			   _vigencia_inic,
			   _vigencia_final,
			   _prima_neta,
			   _impuesto,
			   _prima_bruta,
			   _no_factura,
			   _periodo,
			   _fecha_emision
		  from endedmae
		 where no_documento = _no_documento
		   and actualizado = 1
		   and prima_bruta <> 0
		   and activa = 1

		-- Descripcion de Tipo de Endoso
		if _cod_endomov = '001' then
			let _tipo_endomov = "AUMENTO DE VIGENCIA";
		elif _cod_endomov = '002' then
			let _tipo_endomov = "CANCELACION DE POLIZA";
		elif _cod_endomov = '003' then
			let _tipo_endomov = "REHABILITACION DE POLIZA";
		elif _cod_endomov = '004' then
			let _tipo_endomov = "INCLUSION DE UNIDADES";
		elif _cod_endomov = '005' then
			let _tipo_endomov = "ELIMINACION DE UNIDADES";
		elif _cod_endomov = '006' then
			let _tipo_endomov = "MODIFICACION DE UNIDADES";
		elif _cod_endomov = '007' then
			let _tipo_endomov = "CONVERSION";
		elif _cod_endomov = '008' then
			let _tipo_endomov = "REVERSAR";
		elif _cod_endomov = '009' then
			let _tipo_endomov = "CAMBIO DE NO. MOTOR Y/O CHASIS";
		elif _cod_endomov = '010' then
			let _tipo_endomov = "CAMBIO DE ACREEDOR(ES)";
		elif _cod_endomov = '011' then
			let _tipo_endomov = "POLIZA ORIGINAL";
		elif _cod_endomov = '012' then
			let _tipo_endomov = "CAMBIO DE CORREDORES";
		elif _cod_endomov = '013' then
			let _tipo_endomov = "CAMBIO DE ASEGURADO Y/O CONTRATANTE";
		elif _cod_endomov = '014' then
			let _tipo_endomov = "FACTURACION MENSUAL";
		elif _cod_endomov = '015' then
			let _tipo_endomov = "ENDOSO DESCRIPTIVO";
		elif _cod_endomov = '016' then
			let _tipo_endomov = "CAMBIO DE REASEGURO GLOBAL";
		elif _cod_endomov = '017' then
			let _tipo_endomov = "CAMBIO DE REASEGURO INDIVIDUAL";
		elif _cod_endomov = '018' then
			let _tipo_endomov = "CAMBIO DE COASEGURO";
		elif _cod_endomov = '019' then
			let _tipo_endomov = "DISMINUCION DE VIGENCIA";
		elif _cod_endomov = '021' then
			let _tipo_endomov = "RENOVACION DE DIFERIDAS";
		elif _cod_endomov = '022' then
			let _tipo_endomov = "FACTURACION VIDA INDIVIDUAL";
		elif _cod_endomov = '023' then
			let _tipo_endomov = "DECLARACIONES";
		end if
	
	 insert into deivid_web:web_endoso(
		num_poliza,
		no_endoso,
		tipo_endoso,
		vig_inicial,
		vig_final,
		prima_neta_end,
		impuesto_end,
	   	prima_bruta_end,
		num_factura,
		periodo,
		fecha_emision,
		referencia
		)
		values(
		_no_documento,
		_no_endoso,
		_tipo_endomov,
		_vigencia_inic,
		_vigencia_final,
		_prima_neta,
		_impuesto,
		_prima_bruta,
		_no_factura,
		_periodo,
		_fecha_emision,
		'FACTURA'
		);
	end foreach 

   end foreach

   let _no_recibo = 0;
   let _no_requis = 0;
   let _no_cheque = 0;
   let _fecha_impresion = '';
   let _tipo_requis_desc = '';

	-- Datos de Comisiones Pagadas
	   foreach
		select no_documento,
			   no_recibo,
			   fecha,
			   monto,
			   prima,
			   porc_partic,
			   porc_comis,
			   comision,
			   no_requis
		  into _no_documento1,	
		  	   _no_recibo,
		  	   _fecha_comis,
			   _monto_comis,
			   _prima_comis,
			   _porc_partic,
			   _porc_comis,
			   _comisiones,
			   _no_requis	
		  from chqcomis
		 where cod_agente   = _cod_agente

		 select cod_contratante
		   into _cod_contratante
		   from emipomae
		  where no_poliza = _no_poliza;

		select nombre
		  into _nombre_aseg
		  from cliclien
		 where cod_cliente = _cod_contratante;


			select no_cheque,
				   fecha_impresion,
				   tipo_requis
			   into _no_cheque,
					_fecha_impresion,
					_tipo_requis
			   from chqchmae
			  where no_requis = _no_requis;

		-- Descripcion de Tipo de Pago de Comisiones
			if _tipo_requis = 'A' then
				let _tipo_requis_desc = "ACH";
			elif _tipo_requis = 'C' then
				let _tipo_requis_desc = "Cheque";
			end if

	
		 insert into deivid_web:web_comisiones(
			num_poliza,
			cod_agente,
			nombre,
			num_recibo,
			fecha,
			monto,
			prima,
		   	porc_partic,
			porc_comis,
			comision,
			num_cheque,
			fecha_pagada,
			tipo_requis
			)
			values(
			_no_documento1,
			_cod_agente,
			_nombre_aseg,
			_no_recibo,
			_fecha_comis,
			_monto_comis,
			_prima_comis,
			_porc_partic,
			_porc_comis,
			_comisiones,
			_no_cheque,
			_fecha_impresion,
			_tipo_requis_desc
			);
	   end foreach

	let _no_documento1 = '';
	let _no_recibo	   = '';
	let _fecha_comis   = '';
	let _monto_comis   = '';
	let _prima_comis   = '';
	let _porc_partic   = '';
	let _porc_comis	   = '';
	let _comisiones	   = '';
	let _no_requis	   = '';

	-- Datos de Bonificaciones
	   foreach
		select no_documento,
			   no_poliza,
			   no_recibo,
			   fecha,
			   monto,
			   prima,
			   porc_partic,
			   porc_comis,
			   comision,
			   no_requis	
		  into _no_documento1,	
			   _no_poliza,
		  	   _no_recibo,
		  	   _fecha_comis,
			   _monto_comis,
			   _prima_comis,
			   _porc_partic,
			   _porc_comis,
			   _comisiones,
			   _no_requis	
		  from chqboni
		 where cod_agente   = _cod_agente

		 select cod_contratante
		   into _cod_contratante
		   from emipomae
		  where no_poliza = _no_poliza;

		select nombre
		  into _nombre_aseg
		  from cliclien
		 where cod_cliente = _cod_contratante;


			select no_cheque,
				   fecha_impresion,
				   tipo_requis
			   into _no_cheque,
					_fecha_impresion,
					_tipo_requis
			   from chqchmae
			  where no_requis = _no_requis;

			  if _no_cheque is null then
				continue foreach;
			end if

		-- Descripcion de Tipo de Pago de Bonificaciones
			if _tipo_requis = 'A' then
				let _tipo_requis_desc = "ACH";
			elif _tipo_requis = 'C' then
				let _tipo_requis_desc = "Cheque";
			end if

	
	
		 insert into deivid_web:web_bonificaciones(
			num_poliza,
			cod_agente,
			nombre,
			num_recibo,
			fecha,
			monto,
			prima,
		   	porc_partic,
			porc_comis,
			comision,
			num_cheque,
			fecha_pagada,
			tipo_requis
			)
			values(
			_no_documento1,
			_cod_agente,
			_nombre_aseg,
			_no_recibo,
			_fecha_comis,
			_monto_comis,
			_prima_comis,
			_porc_partic,
			_porc_comis,
			_comisiones,
			_no_cheque,
			_fecha_impresion,
			_tipo_requis_desc
			);
	   end foreach

	-- Datos de Incentivos
	   foreach	
		select no_documento,
			   no_poliza,
			   no_recibo,
			   fecha,
			   por_persistencia,
			   prima_neta,
			   cod_ramo,
			   cod_subramo,
			   comision,
			   no_requis	
		  into _no_documento1,	
			   _no_poliza,
		  	   _no_recibo,
		  	   _fecha_comis,
			   _monto_comis,
			   _prima_comis,
			   _cod_ramo,
			   _cod_subramo,
			   _comisiones,
			   _no_requis	
		  from chqfidel
		 where cod_agente   = _cod_agente

		select cod_contratante
		  into _cod_contratante
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre_aseg
		  from cliclien
		 where cod_cliente = _cod_contratante;

		select no_cheque,
			   fecha_impresion,
			   tipo_requis
		  into _no_cheque,
			   _fecha_impresion,
			   _tipo_requis
		  from chqchmae
		 where no_requis = _no_requis;

			  if _no_cheque is null then
				continue foreach;
			end if

		-- Descripcion de Tipo de Pago de Incentivos
			if _tipo_requis = 'A' then
				let _tipo_requis_desc = "ACH";
			elif _tipo_requis = 'C' then
				let _tipo_requis_desc = "Cheque";
			end if

		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _nombre_subramo
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;	
	
		 insert into deivid_web:web_incentivos(
			num_poliza,
			cod_agente,
			nombre,
			num_recibo,
			fecha,
			monto,
			prima,
		   	ramo,
			subramo,
			comision,
			num_cheque,
			fecha_pagada,
			tipo_requis
			)
			values(
			_no_documento1,
			_cod_agente,
			_nombre_aseg,
			_no_recibo,
			_fecha_comis,
			_monto_comis,
			_prima_comis,
			_porc_partic,
			_porc_comis,
			_comisiones,
			_no_cheque,
			_fecha_impresion,
			_tipo_requis_desc
			);
	   end foreach



end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
