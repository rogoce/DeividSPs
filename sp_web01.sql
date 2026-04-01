-- Procedure que carga los registros para el WEB

-- Creado: 08/02/2007 - Autor: Demetrio Hurtado Almanza

drop procedure sp_web01;

create procedure sp_web01(a_cod_usuario char(10))
returning integer,
          char(100);

define _compania			char(3);
define _sucursal			char(3);
define _fecha_moros			date;
define _periodo_moros		char(7);

define _cod_usuario			char(10);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_poliza2			char(10);
define _cod_contratante		char(10);
define _flag				smallint;
define _cod_agente1			char(5);

define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _nombre_ramo			char(50);
define _nombre_subramo		char(50);
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_formapag		char(3);
define _nombre_formapag		char(50);
define _cod_agente			char(5);

define _cod_agente3			char(5);
define _cnt			    	SMALLINT;

define _nombre_agente		char(50);
define _fecha_cancelacion	date;
define _prima_bruta			dec(16,2);
define _dia_cobros1			smallint;
define _no_pagos			smallint;
define _nombre_asegurado	char(100);
define _carta_aviso_canc	smallint;
define _fecha_aviso_canc	date;
define _renov_desc		    char(20);
define _nueva_renov			char(1);

define _cod_frec_pago		char(3);
define _frec_pago_desc		char(50);

define _estatus_poliza		smallint;
define _estatus_desc		char(10);

define _moro_saldo			dec(16,2);
define _moro_por_vencer		dec(16,2);
define _moro_exigible		dec(16,2);
define _moro_corriente		dec(16,2);
define _moro_30				dec(16,2);
define _moro_60				dec(16,2);
define _moro_90				dec(16,2);

define _no_recibo			char(10);
define _fecha_rec			date;
define _prima_neta			dec(16,2);
define _impuesto			dec(16,2);
define _monto				dec(16,2);
define _transaccion			char(10);
define v_referencia			char(20);
define _no_remesa			char(10);
define _tipo_remesa			char(1);
define _monto_descontado	dec(16,2);
define _cod_cliente			char(10);
define _nombre_cliente		char(100);
define _direccion			char(50);
define _telefono1			char(10);
define _telefono2			char(10);
define _direccion_cob		char(100);
define _email				char(50);
define _apartado			char(20);

define _renglon				smallint;
define _no_unidad			char(5);
define _orden				smallint;
define _cod_cobertura		char(5);
define _cobertura			char(50);
define _limite1				dec(16,2);
define _limite2				dec(16,2);
define _deducible			char(50);
define _deduc_acum			dec(16,2);
define _cod_ajust_interno	char(3);

define _suma_asegurada		dec(16,2);
define _prima_uni			dec(16,2);
define _desc_uni			dec(16,2);
define _recargo				dec(16,2);
define _prima_neta_uni		dec(16,2);
define _impuesto_uni		dec(16,2);
define _prima_bruta_uni		dec(16,2);

define _no_reclamo			char(10);
define _numreclamo			char(18);
define _estatus_reclamo		char(1);
define _estatus				char(10);
define _fecha_siniestro		date;
define _ajust_interno		char(3);
define _nombre_ajust		char(50);
define _no_tranrec			char(10);

define _fecha_nota			datetime year to fraction(5);
define _desc_nota			char(250);
define _user_added			char(8);

define _cod_tipo_pago		char(3);
define _nom_tip_pago		char(50);
define _no_requis			char(10);
define _fecha_impresion		date;
define _beneficiario		char(100);
define _monto_cheque		dec(16,2);
define _no_cheque			integer;

define _cod_endomov			char(3);
define _tipo_endomov		char(50);
define _no_factura			char(10);
define _no_endoso			char(5);
define _periodo				char(7);
define _fecha_emision		date;

define _fecha_comis			date;
define _monto_comis			dec(16,2);
define _prima_comis			dec(16,2);
define _porc_partic			dec(5,2);
define _porc_comis			dec(5,2);
define _comisiones			dec(16,2);
define _nombre_aseg			char(50);
define _no_documento1		char(20);
define _tipo_requis			char(7);
define _tipo_requis_desc	char(7);

define _cod_parentesco		char(3);
define _cod_cliente1		char(10);
define _nom_cliente1		char(50);
define _nom_parentesco		char(50);

DEFINE v_fecha		        DATE;
DEFINE v_monto            	DEC(16,2);
DEFINE v_prima            	DEC(16,2);
DEFINE _tipo_fac         	CHAR(30);
define _pagado				SMALLINT;
define _cod_banco			CHAR(3);
define _anulado				SMALLINT;
DEFINE v_periodo            CHAR(7);
define v_documento			integer;
define _no_poliza_chq		char(10);

define _cantidad			integer;
define _actualizado			integer;
define _cant_reg			integer;
define _cnt_agente          integer;
define _activa				smallint;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _cod_grupo           char(5);
define _nombre_acreedor     varchar(100);
define _cod_acreedor        varchar(10);
define _cnt_acre            smallint;
define _nombre_grupo        varchar(100);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, trim(_error_desc) || " poliza: " || _no_documento || " no_poliza " || _no_poliza;
end exception

--SET DEBUG FILE TO "sp_web01.trc";
--TRACE ON ;

let _compania      = "001";
let _sucursal      = "001";
let _fecha_moros   = today;
let _periodo_moros = sp_sis39(_fecha_moros);
let _deduc_acum	   = 0.00;
let _nombre_acreedor = "";

-- return 1, "Actualizacion Inicio" with resume;

-- Corredores
--return 0, "Exito " || " Registros";

let _cod_agente = a_cod_usuario;

/****************************************************************************************************************************/
		-- Ciclo para verificar si las pólizas cargadas en web_poliza pertenecen al corredor Federico 07/02/2020
/****************************************************************************************************************************/
let _cnt_agente = 0;
	foreach
		select num_poliza
		  into _no_documento
		  from deivid_web:web_poliza 
		 where cod_agente = a_cod_usuario
		 
		 let _no_poliza = sp_sis21(_no_documento);
		 
		select count(*)
		  into _cnt_agente
		  from emipoagt
		 where no_poliza 	= _no_poliza
		   and cod_agente 	= a_cod_usuario;
		
		if _cnt_agente = 0 or _cnt_agente is null then
			delete deivid_web:web_poliza
			where num_poliza = _no_documento
			  and cod_agente = a_cod_usuario;
		end if
	end foreach
/****************************************************************************************************************************/
/****************************************************************************************************************************/
{
foreach
 select no_poliza
   into _no_poliza
   from emipoagt
  where cod_agente = a_cod_usuario

	select actualizado,
	       no_documento
	  into _actualizado,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

		if _actualizado = 0 then
			continue foreach;
		end if

		let _no_poliza = sp_sis21(_no_documento);
}

let _cantidad = 0;
let _no_documento = "";

foreach
	 select p.no_documento
	   into _no_documento
	   from emipoagt a, emipomae p
	  where a.cod_agente   = a_cod_usuario
		and a.no_poliza    = p.no_poliza
		and p.actualizado  = 1
		and p.no_documento is not null
		and cod_formapag <> '084' -- a solicitud de la Sra. Enilda Fernández la forma de pago coaseguro minoritario no debe salir en la pagina web
	  group by p.no_documento

		let _no_poliza = sp_sis21(_no_documento);
		let _flag = 0;

		foreach
		 select cod_agente
		   into _cod_agente1
		   from emipoagt
		  where no_poliza = _no_poliza

			if _cod_agente = _cod_agente1 then
				let _flag = 1;
				exit foreach;
			end if

		end foreach

		if _flag = 0 then 	-- 18/02/2010 esto es por que hubo cambio de corredor y no se estaba borrando el antiguio de la tabla web_poliza
			delete deivid_web:web_poliza
			where num_poliza = _no_documento
			  and cod_agente = _cod_agente;
			continue foreach;
		end if

		let _cantidad = _cantidad + 1;

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
			   nueva_renov,
			   cod_grupo
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
			   _nueva_renov,
			   _cod_grupo
		  from emipomae
		 where no_poliza = _no_poliza;

-- return 1, "Lectura de Poliza" with resume;

---Por solicitud de analisa excepcion especial porque el corredor fallecio solo se deben cargar las polizas del grupo 1118
		if _cod_agente = '01782' and _cod_grupo <> '1118' then
			continue foreach;
		end if
---
		select por_vencer,
			   exigible,
		       corriente,
		       monto_30,
		       monto_60,
		       monto_90 + monto_120 + monto_150 + monto_180,
		       saldo
		  into _moro_por_vencer,
			   _moro_exigible,
			   _moro_corriente,
			   _moro_30,
			   _moro_60,
			   _moro_90,
			   _moro_saldo
          from emipoliza
		 where no_documento = _no_documento;

-- return 1, "Actualizacion Morosidad" with resume;

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

		{
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
		}


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

--		if _deduc_acum is null then
--			let _deduc_acum = 0.00;
--		end if

		delete deivid_web:web_poliza
		 where num_poliza = _no_documento
		   and cod_agente = _cod_agente;

-- 18/02/2010 cuando el numero de poliza no esta en la tabla emipoagt se elimina de

		foreach
		   select cod_agente
		     into _cod_agente3
			 from deivid_web:web_poliza
			where num_poliza = _no_documento

		   select count(*)
		     into _cnt
			 from emipoagt
			 where no_poliza  = _no_poliza
			 and cod_agente = _cod_agente3;

			if _cnt = 0 then

				delete deivid_web:web_poliza
				where num_poliza = _no_documento
				and cod_agente = _cod_agente3;

			end if


		end foreach

		select count(*)
		  into _cnt_acre
	      from emipoacr
		 where no_poliza  = _no_poliza;
		let _nombre_acreedor = "";
		if _cnt_acre > 0 then
			foreach
				select cod_acreedor
				  into _cod_acreedor
				  from emipoacr
				 where no_poliza = _no_poliza
				exit foreach;
			end foreach

			select nombre
			  into _nombre_acreedor
			  from emiacre
			  where cod_acreedor = _cod_acreedor;
		end if

		select nombre
		  into _nombre_grupo
    	  from cligrupo
		 where cod_grupo = _cod_grupo;
--

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
		renov_desc,
		nombre_acreedor,
		nombre_grupo
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
		_renov_desc,
		_nombre_acreedor,
		_nombre_grupo
		);

-- return 1, "Actualizacion emipomae" with resume;

		-- Datos del pago

		let _cant_reg = 0;

	   foreach
		select no_recibo,
			   fecha,
			   prima_neta,
			   impuesto,
			   monto,
			   no_remesa,
			   monto_descontado,
			   renglon
		  into _no_recibo,
			   _fecha_rec,
			   _prima_neta,
			   _impuesto,
			   _monto,
			   _no_remesa,
			   _monto_descontado,
			   _renglon
		  from cobredet
		 where doc_remesa    = _no_documento
		   and actualizado   = 1
		   and tipo_mov      in ("P", "N", "X")
	       and flag_web_corr = 0

			let _cant_reg = _cant_reg + 1;

			SELECT tipo_remesa
			  INTO _tipo_remesa
			  FROM cobremae
			 WHERE no_remesa = _no_remesa;

		    IF   _tipo_remesa = 'C' THEN
		      LET v_referencia = 'COMPROBANTE';
			ELIF   _tipo_remesa = 'T' THEN
		      LET v_referencia = 'AJUSTE';
			ELSE
		      LET v_referencia = 'RECIBO';
		    END IF

			-- Insertar Registros de Pagos
			BEGIN
				ON EXCEPTION SET _error
					IF _error <> -239 AND _error <> -268 THEN

					 	RETURN _error, "Error al INSERTAR WEB_PAGO";
					ELSE

					END IF
				END EXCEPTION

				insert into deivid_web:web_pago(
					num_poliza,
					num_recibo,
					fecha_recibo,
					prima,
					impuesto,
					total_pagado,
					referencia,
					monto_descontado,
					no_remesa,
					renglon
					)
					values(
					_no_documento,
					_no_recibo,
					_fecha_rec,
					_prima_neta,
					_impuesto,
				   	_monto,
					v_referencia,
					_monto_descontado,
					_no_remesa,
					_renglon
					);
			END

			update cobredet
	   		   set flag_web_corr = 1
	         where no_remesa	 = _no_remesa
	           and renglon		 = _renglon;

	   end foreach

-- return 1, _cant_reg || " Actualizacion cobredet" with resume;

	   --Introducir cheques

	   LET v_referencia = 'CHEQUE';

	   FOREACH
		 SELECT monto,
		        prima_neta,
		 	    no_requis,
				no_poliza
		   INTO v_monto,
		        v_prima,
		 	    _no_requis,
				_no_poliza_chq
		   FROM chqchpol
		  WHERE no_documento  = _no_documento
		    AND flag_web_corr = 0

	--		LET v_monto = v_monto * -1;
	--		LET v_prima = v_prima * -1;

			SELECT fecha_impresion,
			       no_cheque,
				   periodo,
				   pagado,
				   cod_banco,
				   anulado
			  INTO v_fecha,
				   v_documento,
				   v_periodo,
				   _pagado,
				   _cod_banco,
				   _anulado
			  FROM chqchmae
			 WHERE no_requis = _no_requis;

	        SELECT nombre
			 INTO  _tipo_fac
			 FROM  chqbanco
			 WHERE cod_banco = _cod_banco;

				IF _pagado  = 1 AND
				   _anulado = 0 THEN
				  -- Insertar Registros de Pagos

					BEGIN
						ON EXCEPTION SET _error
							IF _error <> -239 AND _error <> -268 THEN

							 	RETURN _error, "Error al INSERTAR WEB_PAGO_CHEQUE";
							ELSE

							END IF
						END EXCEPTION

						INSERT INTO deivid_web:web_pago_cheque(
							fecha,
							referencia,
							no_documento,
							monto,
							prima_neta,
							periodo,
							no_poliza,
							tipo_fac,
							no_requis,
							num_poliza
							)
							VALUES(
							v_fecha,
							v_referencia,
							v_documento,
							v_monto,
							v_prima,
							v_periodo,
							_no_poliza_chq,
							_tipo_fac,
							_no_requis,
							_no_documento
							);
					END


						update chqchpol
				   		   set flag_web_corr = 1
				         where no_requis	 = _no_requis
				           and no_documento  = _no_documento;

				END IF

	   end foreach

-- return 1, "Actualizacion chqchpol" with resume;

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

			foreach
			 select cod_parentesco,
					cod_cliente
			   into _cod_parentesco,
			   	    _cod_cliente1
			   from emidepen
			  where no_poliza     = _no_poliza
			  	and no_unidad     = _no_unidad
			  	and flag_web_corr = 0

				delete from deivid_web:web_dependiente
				 where no_poliza 	 = _no_poliza
				   and num_unidad 	 = _no_unidad
				   and cod_cliente   = _cod_cliente1;

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
					nombre,
					no_poliza,
					cod_cliente
					)
					values(
					_no_documento,
					_no_unidad,
					_nom_parentesco,
					_nom_cliente1,
					_no_poliza,
					_cod_cliente1
					);

				update emidepen
		   		   set flag_web_corr = 1
		         where no_poliza     = _no_poliza
		           and no_unidad	 = _no_unidad
		           and cod_cliente	 = _cod_cliente1;

			end foreach

		    delete from deivid_web:web_cobertura
			 where no_poliza 	 = _no_poliza
			   and num_unidad 	 = _no_unidad;

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

			/*	delete from deivid_web:web_cobertura
				 where no_poliza 	 = _no_poliza
			       and num_unidad 	 = _no_unidad
			       and cod_cobertura = _cod_cobertura;
			*/
				insert into deivid_web:web_cobertura(
					num_poliza,
				    num_unidad,
				    orden,
					riesgos,
					limite1,
					limite2,
					deducibles,
					primas,
					no_poliza,
					cod_cobertura
					)
					values(
					_no_documento,
					_no_unidad,
					_orden,
					_cobertura,
					_limite1,
				    _limite2,
					_deducible,
					_prima_neta,
					_no_poliza,
					_cod_cobertura
					);

			end foreach

			delete from deivid_web:web_unidades
			 where no_poliza 	  = _no_poliza
		       and num_unidad 	  = _no_unidad;

			insert into deivid_web:web_unidades(
				num_poliza,
				num_unidad,
				suma_asegurada,
				prima,
				descuento,
				recargo,
				prima_neta,
				impuesto,
				prima_bruta,
				no_poliza
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
				_prima_bruta_uni,
				_no_poliza
				);

		end foreach

-- return 1, "Actualizacion emipouni" with resume;
let _numreclamo=NULL;
	-- Datos de Reclamos
 		foreach
	 		select no_reclamo,
	 			   numrecla,
	        	   estatus_reclamo,
	               fecha_siniestro,
	               ajust_interno,
				   no_unidad
	   		  into _no_reclamo,
	   			   _numreclamo,
	        	   _estatus_reclamo,
	        	   _fecha_siniestro,
	        	   _cod_ajust_interno,
				   _no_unidad
	   		  from recrcmae
	  		 where no_documento = _no_documento
			 --no_poliza    = _no_poliza
	    	   --and no_unidad    = _no_unidad
			   and actualizado  = 1

		If  _numreclamo is NULL OR trim(_numreclamo) = "" THEN
			continue foreach;
		End If

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

			delete from deivid_web:web_reclamo
			 where num_poliza  = _no_documento
		       and num_reclamo = _numreclamo;

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
			  where no_reclamo    = _no_reclamo
				and flag_web_corr = 0

				-- Insertar Registros de Notas del Reclamo
				BEGIN
					ON EXCEPTION SET _error
						IF _error <> -239 AND _error <> -268 THEN

						 	RETURN _error, "Error al INSERTAR WEB_NOTASRECLA";
						ELSE

						END IF
					END EXCEPTION

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
				END

	   		end foreach

			update recnotas
			   set flag_web_corr = 1
			 where no_reclamo    = _no_reclamo;

		-- Datos de Pago de Reclamo
		   Let _no_requis = '';

		    foreach
				select cod_tipopago,
					   no_requis,
					   monto,
					   transaccion,
					   no_tranrec
				  into _cod_tipo_pago,
					   _no_requis,
					   _monto_cheque,
					   _transaccion,
					   _no_tranrec
				  from rectrmae
				 where numrecla      = _numreclamo
				   and cod_tipotran  = '004'
				   and actualizado   = 1
				   and flag_web_corr = 0
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
				BEGIN
					ON EXCEPTION SET _error
						IF _error <> -239 AND _error <> -268 THEN

						 	RETURN _error, "Error al INSERTAR WEB_RECLAMO_PAGO";
						ELSE

						END IF
					END EXCEPTION

					insert into deivid_web:web_reclamo_pago(
					num_reclamo,
					cheque,
					fecha_pago,
					beneficiario,
					cobertura,
					total_pagado,
					tipo_pago,
					transaccion,
					no_tranrec
					)
					values(
					_numreclamo,
					_no_cheque,
					_fecha_impresion,
					_beneficiario,
					'',
					_monto_cheque,
					_nom_tip_pago,
					_transaccion,
					_no_tranrec
					);

				 END

				update rectrmae
	   		   	   set flag_web_corr = 1
	         	 where no_tranrec    = _no_tranrec;

		   end foreach

		end foreach

-- return 1, "Actualizacion recrcmae" with resume;


		-- Insertar Registros de Cliente

			{
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

			select count(*)
			  into _cant_reg
			  from web_cliente
		     where cod_cliente = _cod_cliente;

			if _cant_reg = 0 then

				insert into web_cliente(
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
			}

        let _vigencia_inic  = 0;
		let _vigencia_final = 0;
		let _prima_neta     = 0;
		let _impuesto       = 0;
		let _prima_bruta    = 0;

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
				   fecha_emision,
				   no_poliza,
				   activa
			  into _no_endoso,
				   _cod_endomov,
				   _vigencia_inic,
				   _vigencia_final,
				   _prima_neta,
				   _impuesto,
				   _prima_bruta,
				   _no_factura,
				   _periodo,
				   _fecha_emision,
				   _no_poliza2,
				   _activa
			  from endedmae
			 where no_documento  = _no_documento
			   and actualizado   = 1
			   and flag_web_corr = 0

			update endedmae
	   		   set flag_web_corr = 1
	         where no_poliza     = _no_poliza2
	           and no_endoso     = _no_endoso;

			if _activa = 0 then
				continue foreach;
			end if

			if _prima_bruta = 0 then
				continue foreach;
			end if

			select nombre
			  into _tipo_endomov
			  from endtimov
			 where cod_endomov = _cod_endomov;
/*
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
			elif _cod_endomov = '024' then
				let _tipo_endomov = "DESCUENTO DE PRONTO PAGO";
			elif _cod_endomov = '025' then
				let _tipo_endomov = "REVERSAR DESCUENTO PRONTO PAGO";
			elif _cod_endomov = '026' then
				let _tipo_endomov = "CAMBIO DE TIPO DE VEHICULO";
			elif _cod_endomov = '028' then
				let _tipo_endomov = "ENDOSO DE CAMBIO DE MANZANA";
			elif _cod_endomov = '029' then
				let _tipo_endomov = "CAMBIO DE PRODUCTO SALUD";
			end if
*/
		 	BEGIN
				ON EXCEPTION SET _error
					IF _error <> -239 AND _error <> -268 THEN

					 	RETURN _error, "Error al INSERTAR WEB_ENDOSO";
					ELSE

					END IF
				END EXCEPTION

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
					referencia,
					no_poliza
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
					'FACTURA',
					_no_poliza2
					);
			END

		end foreach

-- return 1, "Actualizacion endedmae" with resume;

    end foreach

    let _no_recibo = 0;
    let _no_requis = 0;
    let _no_cheque = 0;

    let _fecha_impresion  = '';
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
			   no_requis,
			   no_poliza
		  into _no_documento1,
		  	   _no_recibo,
		  	   _fecha_comis,
			   _monto_comis,
			   _prima_comis,
			   _porc_partic,
			   _porc_comis,
			   _comisiones,
			   _no_requis,
			   _no_poliza
		  from chqcomis
		 where cod_agente      = _cod_agente
		   and no_requis       is not null
		   and trim(no_requis) <> ''
		   and flag_web_corr   = 0

			let _no_documento = _no_documento1;

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
				tipo_requis,
				no_poliza
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
				_tipo_requis_desc,
				_no_poliza
				);

	end foreach

   update chqcomis
	  set flag_web_corr   = 1
	where cod_agente      = a_cod_usuario
	  and no_requis       is not null
	  and trim(no_requis) <> ''
	  and flag_web_corr   = 0;

	-- comisiones descontadas
    let _no_recibo 		= 0;
	let _comisiones 	= 0;
	let _monto			= 0;
	let _prima_comis	= 0;
	let _porc_comis		= 0;
	let _porc_partic	= 0;

	foreach
		SELECT c.doc_remesa,
			   c.no_recibo,
			   c.fecha,
               t.monto_man,
			   e.no_poliza,
			   t.cod_agente,
			   c.monto,
			   c.prima_neta,
			   t.porc_comis_agt,
			   t.porc_partic_agt
		  into _no_documento,
		       _no_recibo,
			   _fecha_comis,
			   _comisiones,
			   _no_poliza,
			   _cod_agente,
			   _monto,
			   _prima_comis,
			   _porc_comis,
			   _porc_partic
	      FROM cobredet c, cobreagt t, emipomae e, emitipro r
	     WHERE c.no_remesa 		= t.no_remesa
           and c.renglon   		= t.renglon
           and c.no_poliza 		= e.no_poliza
           and e.cod_tipoprod 	= r.cod_tipoprod
           and c.actualizado	= 1
	       AND c.tipo_mov		IN ('P','N','C')
	       AND c.monto_descontado <> 0
           and t.cod_agente 	= a_cod_usuario
           and r.tipo_produccion not in(3,4)
		   and t.flag_web_corr 	= 0

			select cod_contratante
			  into _cod_contratante
			  from emipomae
			 where no_poliza = _no_poliza;

			select nombre
			  into _nombre_aseg
			  from cliclien
			 where cod_cliente = _cod_contratante;

			-- Descripcion de Tipo de Pago de Comisiones

			let _tipo_requis_desc = "DES";


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
				tipo_requis,
				no_poliza
				)
				values(
				_no_documento,
				_cod_agente,
				_nombre_aseg,
				_no_recibo,
				_fecha_comis,
				_monto,
				_prima_comis,
				_porc_partic,
				_porc_comis,
				_comisiones,
				'',
				_fecha_comis,
				_tipo_requis_desc,
				_no_poliza
				);

	end foreach

   update cobreagt
	  set flag_web_corr = 1
    WHERE cod_agente = a_cod_usuario
	  and flag_web_corr = 0
      and monto_man <> 0;










	-- comisiones web 1%

    let _no_recibo = 0;
    let _no_requis = 0;
    let _no_cheque = 0;

    let _fecha_impresion  = '';
    let _tipo_requis_desc = '';

	-- Datos de Comisiones Pagadas
	    foreach
	     select no_documento,
		        no_recibo,
				fecha_genera,
				monto,
				prima,
				porc_partic,
				porc_comis,
				comision,
				no_requis,
				no_poliza
		  into _no_documento1,
		  	   _no_recibo,
		  	   _fecha_comis,
			   _monto_comis,
			   _prima_comis,
			   _porc_partic,
			   _porc_comis,
			   _comisiones,
			   _no_requis,
			   _no_poliza
		  from chqweb
		 where cod_agente      = _cod_agente
		   and no_requis       is not null
		   and trim(no_requis) <> ''
		   and (flag_web_corr is null or flag_web_corr = 0)

			let _no_documento = _no_documento1;

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
			if _no_recibo is null or trim(_no_recibo) = "" then
				let _no_recibo  = 0;
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
				tipo_requis,
				no_poliza
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
				_tipo_requis_desc,
				_no_poliza
				);

	    end foreach

	   update chqweb
		  set flag_web_corr   = 1
		where cod_agente      = a_cod_usuario
		  and no_requis       is not null
		  and trim(no_requis) <> ''
		  and (flag_web_corr is null or flag_web_corr = 0);


-- return 1, "Actualizacion chqcomis" with resume;

	   let _no_documento1 = '';
	   let _no_recibo	  = '';
	   let _fecha_comis   = '';
	   let _monto_comis   = '';
	   let _prima_comis   = '';
	   let _porc_partic   = '';
	   let _porc_comis	  = '';
	   let _comisiones	  = '';
	   let _no_requis	  = '';

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
			 where cod_agente      = _cod_agente
			   and no_requis       is not null
			   and trim(no_requis) <> ''
			   and flag_web_corr   = 0

			let _no_documento = _no_documento1;

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
			tipo_requis,
			no_poliza
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
			_tipo_requis_desc,
			_no_poliza
			);

	    end foreach

	   update chqboni
		  set flag_web_corr   = 1
		where cod_agente      = a_cod_usuario
		  and no_requis       is not null
		  and trim(no_requis) <> ''
		  and flag_web_corr   = 0;


-- return 1, "Actualizacion chqboni" with resume;

	   let _no_documento1 = '';
	   let _no_recibo	  = '';
	   let _fecha_comis   = '';
	   let _monto_comis   = '';
	   let _prima_comis   = '';
	   let _porc_partic   = '';
	   let _porc_comis	  = '';
	   let _comisiones	  = '';
	   let _no_requis	  = '';
	   let _tipo_requis   = '';

	   -- Datos de Incentivos

	    {foreach
			select no_documento,
				   no_poliza,
				   no_recibo,
				   fecha,
				   prima_neta,
				   comision,
				   nombre,
				   no_requis,
				   tipo_requis,
				   cod_ramo,
				   cod_subramo,
				   por_persistencia,
				   porcentaje
			  into _no_documento1,
				   _no_poliza,
			  	   _no_recibo,
			  	   _fecha_comis,
				   _prima_comis,
				   _comisiones,
				   _nombre_aseg,
				   _no_requis,
				   _tipo_requis,
				   _cod_ramo,
				   _cod_subramo,
				   _monto_comis,
				   _porc_comis
			  from chqfidel
			 where cod_agente      = _cod_agente
			   and no_requis       is not null
			   and trim(no_requis) <> ''
			   and flag_web_corr   = 0

			let _no_documento = _no_documento1;

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
			num_recibo,
			fecha,
			prima_neta,
			comision,
			nombre,
			num_cheque,
			tipo_requis,
			ramo,
			subramo,
			por_persistencia,
			porcentaje,
			fecha_pagada,
			no_poliza
			)
			values(
			_no_documento1,
			_cod_agente,
			_no_recibo,
			_fecha_comis,
			_prima_comis,
			_comisiones,
			_nombre_aseg,
			_no_cheque,
			_tipo_requis_desc,
			_nombre_ramo,
			_nombre_subramo,
			_monto_comis,
			_porc_comis,
			_fecha_impresion,
			_no_poliza
			);

		end foreach

		update chqfidel
		   set flag_web_corr   = 1
		 where cod_agente      = a_cod_usuario
		   and no_requis       is not null
		   and trim(no_requis) <> ''
		   and flag_web_corr   = 0;}

-- return 1, "Actualizacion chqfidel" with resume;

update agtagent
   set flag_web_corr = 1
 where cod_agente    = a_cod_usuario;

-- return 1, "Actualizacion agtagent" with resume;

end

return 0, "Exito " || _cantidad || " Registros";

end procedure
