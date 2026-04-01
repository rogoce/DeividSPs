-- Procedimiento para crear transacciones a partir de una global - Ordenes de Compra
-- 
-- Creado: 24/01/2005 - Autor: Amado Perez.
-- Modificado: 06/03/2012 - Autor: Amado Perez.  Insertando en recnotas

DROP PROCEDURE sp_rwf42;

CREATE PROCEDURE "informix".sp_rwf42(a_no_tranrec CHAR(10), a_deducible DEC(16,2) DEFAULT 0.00, a_cotizacion VARCHAR(10) DEFAULT NULL) -- a_cotizacion = g_nu_incidente_CRA
			RETURNING SMALLINT, VARCHAR(50), SMALLINT, SMALLINT;  

DEFINE _mes_char			CHAR(2);
DEFINE _ano_char			CHAR(4);
DEFINE _periodo			    CHAR(7);
DEFINE _user_added			CHAR(8);
DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_tipopago		CHAR(3);
DEFINE _monto				DEC(16,2);
DEFINE _monto_orig			DEC(16,2);
DEFINE _no_reclamo			CHAR(10);
DEFINE _generar_cheque		SMALLINT;
DEFINE _no_requis			CHAR(10);
DEFINE _tipo_transaccion   	SMALLINT;
DEFINE _variacion	        DEC(16,2);
DEFINE _monto_cob			DEC(16,2);
DEFINE _transaccion			CHAR(10);
DEFINE _error   			SMALLINT;
DEFINE _cod_cobertura       CHAR(5);
DEFINE _reserva_actual    	DEC(16,2);
DEFINE _descripcion         VARCHAR(50); 
DEFINE _genera_incidente    SMALLINT;
DEFINE _actualizado    		SMALLINT;
DEFINE _fecha			    DATE;
DEFINE _fecha_recl_default	CHAR(20);
DEFINE _fecha_recl_valor	CHAR(20);
DEFINE _wf_poveedor         CHAR(10);
DEFINE _no_tranrec          CHAR(10);
DEFINE _numrecla            CHAR(18);
DEFINE _wf_inc_auto         INTEGER;
DEFINE _wf_incidente        INTEGER;
DEFINE _wf_inc_padre		INTEGER;
DEFINE _cantidad      		SMALLINT;
DEFINE _null			    CHAR(1);
DEFINE _wf_apr_js			CHAR(8);
DEFINE _wf_apr_js_fh		DATETIME YEAR TO FRACTION (5);
DEFINE _wf_apr_j			CHAR(8);
DEFINE _wf_apr_j_fh			DATETIME YEAR TO FRACTION (5);
DEFINE _wf_apr_jt			CHAR(8);
DEFINE _wf_apr_jt_fh		DATETIME YEAR TO FRACTION (5);
DEFINE _wf_apr_jt_2			CHAR(8);
DEFINE _wf_apr_jt_2_fh		DATETIME YEAR TO FRACTION (5);
DEFINE _wf_apr_g			CHAR(8);
DEFINE _wf_apr_g_fh			DATETIME YEAR TO FRACTION (5);
DEFINE _hoy					DATETIME YEAR TO FRACTION (5);
DEFINE _tipo_orden          CHAR(1);
DEFINE _no_orden            CHAR(10);
DEFINE _envia_correo        SMALLINT;
DEFINE _wf_incidente_str    VARCHAR(10);
DEFINE _nombre_tipo_pago    VARCHAR(50);
DEFINE _monto_tr            DEC(16,2);
DEFINE _variacion_sum       DEC(16,2);

CREATE TEMP TABLE tmp_prov(
	wf_proveedor CHAR(10),
	wf_monto     DEC(16,2),
	tipo_orden   CHAR(1),
    PRIMARY KEY (wf_proveedor,tipo_orden)
	) WITH NO LOG;

--SET ISOLATION TO DIRTY READ;
if a_no_tranrec = '3158842' then
	set debug file to "sp_rwf42.trc";
	trace on;
end if
begin work;

LET _null = NULL;
LET _monto_cob = 0;
LET _genera_incidente = 0;
LET _hoy = CURRENT;
LET _cantidad = 0;
LET _monto = 0;
LET _envia_correo = 0;
LET _monto_tr = 0;
LET _variacion_sum = 0;
LET _variacion	= 0;


SELECT count(*)
  INTO _cantidad
  FROM rectrmae
 WHERE no_tranrec = a_no_tranrec;

IF _cantidad = 0 THEN
 	RETURN 1, "Esta transaccion no existe o ya fue procesada", 0, 0;
END IF

LET _cantidad = 0;

 SELECT user_added,
        cod_compania,
		cod_sucursal,
		cod_tipotran,
		cod_tipopago,
		no_reclamo,
		generar_cheque,
		no_requis,
		actualizado,
		numrecla,
		wf_incidente,
		wf_inc_auto,
		wf_apr_js,
		wf_apr_js_fh,
		wf_apr_j,
		wf_apr_j_fh,
		wf_apr_jt,
		wf_apr_jt_fh,
		wf_apr_jt_2,
		wf_apr_jt_2_fh,
		wf_apr_g,
		wf_apr_g_fh,
		wf_inc_padre,
		monto
   INTO _user_added,
        _cod_compania,
		_cod_sucursal,
		_cod_tipotran,
		_cod_tipopago,
		_no_reclamo,
		_generar_cheque,
		_no_requis,
		_actualizado,
		_numrecla,
		_wf_incidente,
		_wf_inc_auto,
		_wf_apr_js,
		_wf_apr_js_fh,
		_wf_apr_j,
		_wf_apr_j_fh,
		_wf_apr_jt,
		_wf_apr_jt_fh,
		_wf_apr_jt_2,
		_wf_apr_jt_2_fh,
		_wf_apr_g,
		_wf_apr_g_fh,
		_wf_inc_padre,
		_monto
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

  LET _wf_incidente_str = _wf_incidente;

	IF _numrecla[1,2] = "02" OR _numrecla[1,2] = "20" THEN -- 7.26
	    LET _reserva_actual = sp_rwf96(_no_reclamo);
		IF _monto > _reserva_actual THEN
			LET _envia_correo = 1;	
		END IF
		LET _monto = 0.00;
		LET _reserva_actual = 0.00;
	END IF


 IF a_deducible = 0.00 THEN
	 FOREACH
	  SELECT monto
	    INTO a_deducible
		FROM rectrcon
	   WHERE no_tranrec = a_no_tranrec
	     AND cod_concepto = "006"
	     
		 LET a_deducible = a_deducible * (-1);
       
	 END FOREACH
 END IF

 IF _actualizado = 1 THEN
 	RETURN 0, "Esta transaccion ya esta actualizada", 0, 0;
 END IF 

 IF _cod_tipopago <> "003" AND _cod_tipopago <> "004" THEN
	 FOREACH
		SELECT wf_proveedor,
		       wf_monto,
			   tipo_orden,
			   cantidad
		  INTO _wf_poveedor,
		       _monto,
			   _tipo_orden,
			   _cantidad
		  FROM wf_ordcomp
		 WHERE wf_incidente = _wf_inc_auto

         IF _tipo_orden = 'R' THEN			--> Cuando es 'C' ya viene con el precio completo, pero cuando es 'R' hay que multiplicarlo por la cantidad APM 7/11/2008
			LET _monto = _monto * _cantidad;	
		 END IF

		BEGIN
			ON EXCEPTION SET _error 
				IF _error <> -239 AND _error <> -268 THEN
					rollback work;
				 	RETURN _error, "Error al INSERTAR PROVEEDORES", 0, 0;
				ELSE
					UPDATE tmp_prov
					   SET wf_monto = wf_monto + _monto
					 WHERE wf_proveedor = _wf_poveedor
					   AND tipo_orden = _tipo_orden;
				END IF 	         
			END EXCEPTION 
			INSERT INTO tmp_prov(
			wf_proveedor,
			wf_monto,
			tipo_orden
			)
			VALUES(
			_wf_poveedor,
			_monto,
			_tipo_orden
			);
		END
	 END FOREACH

	 LET _cantidad = 0;

	 SELECT COUNT(*) 
	   INTO _cantidad 
	   FROM tmp_prov;

	 IF _cantidad = 0 THEN
	    DROP TABLE tmp_prov;
	    RETURN 1, "No tiene proveedores este comparativo, Verifique... ", 0, 0;
	 END IF
 END IF

 BEGIN
	ON EXCEPTION SET _error 
		rollback work;
        DROP TABLE tmp_prov;
	 	RETURN _error, "Error al BUSCAR PARAMETROS", 0, 0;         
	END EXCEPTION 

	 SELECT valor_parametro 
	   INTO _fecha_recl_default 
	   FROM inspaag
	  WHERE codigo_compania  = _cod_compania
	    AND aplicacion       = "REC"
	    AND version          = "02"
	    AND codigo_parametro = "fecha_recl_default";

	 IF TRIM(_fecha_recl_default) = "1" THEN
		IF  MONTH(current) < 10 THEN
			LET _mes_char = '0'|| MONTH(current);
		ELSE
			LET _mes_char = MONTH(current);
		END IF

		LET _ano_char = YEAR(current);
		LET _periodo  = _ano_char || "-" || _mes_char;
		LET _fecha_recl_valor = date(current);
	 ELSE
		SELECT valor_parametro 
		  INTO _fecha_recl_valor 
		  FROM inspaag
		 WHERE codigo_compania  = _cod_compania
		   AND aplicacion       = "REC"
		   AND version          = "02"
		   AND codigo_parametro = "fecha_recl_valor";

		LET _fecha_recl_valor = trim(_fecha_recl_valor);
	    LET _periodo = trim(_fecha_recl_valor[7,10]) || "-" || trim(_fecha_recl_valor[4,5]);
	 END IF	 
 END

 FOREACH
    SELECT cod_cobertura
	  INTO _cod_cobertura
	  FROM rectrcob
	 WHERE no_tranrec = a_no_tranrec
	   AND monto <> 0
 END FOREACH

 IF _cod_cobertura IS NULL OR _cod_cobertura = "" THEN
    DROP TABLE tmp_prov;
 	RETURN 1, "Error buscando la cobertura", 0, 0;
 END IF

 SELECT tipo_transaccion
   INTO _tipo_transaccion
   FROM rectitra
  WHERE cod_tipotran = _cod_tipotran;

 IF _cod_tipopago <> "003" AND _cod_tipopago <> "004" THEN

	 -- Insertado en Recnotas
	 CALL sp_rwf104(_no_reclamo,_hoy,"La transaccion de Orden de Compra con incidente # " || trim(_wf_incidente_str) || " fue Aprobada",_user_added) returning _error, _descripcion;
	 IF _error <> 0 THEN
		rollback work;
        DROP TABLE tmp_prov;
		RETURN  _error, _descripcion, 0, 0;
	 END IF


	 FOREACH
		SELECT wf_proveedor,
		       wf_monto,
			   tipo_orden
		  INTO _wf_poveedor,
			   _monto,
			   _tipo_orden
		  FROM tmp_prov

	    LET _monto = _monto + (_monto * 0.07);	 --> Cambiar a 7
		LET _monto_orig = _monto;

		LET _no_tranrec = sp_sis13(_cod_compania,"REC","02","par_tran_genera");

		IF _no_tranrec IS NULL OR _no_tranrec = "" OR _no_tranrec = "00000" THEN
	        DROP TABLE tmp_prov;
		    RETURN 1, "Error al generar # transaccion interno, verifique...", 0, 0;
		END IF

	 -- Buscando # de transaccion externo
	 	LET _transaccion = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);

		IF trim(_transaccion) = "" OR _transaccion IS NULL THEN
	        DROP TABLE tmp_prov;
			RETURN 1, "Error generando # de transaccion", 0, 0;
		END IF

		SELECT no_orden INTO _no_orden FROM recordma WHERE no_tranrec = a_no_tranrec;  

		DELETE FROM recordde WHERE no_orden = _no_orden;
		DELETE FROM recordma WHERE no_orden = _no_orden;
	  
		SELECT reserva_actual
		  INTO _reserva_actual
		  FROM recrccob
		 WHERE no_reclamo = _no_reclamo
		   AND cod_cobertura = _cod_cobertura;

		IF _reserva_actual IS NULL THEN
			LET _reserva_actual = 0.00;
		END IF

		IF _reserva_actual < 0 THEN
			LET _reserva_actual = 0.00;
		END IF

		IF _tipo_orden = 'C' THEN
			LET _cod_tipopago = '001';
		ELSE
			LET _cod_tipopago = '002';
			LET _monto = _monto - a_deducible;
		END IF

		IF _monto > 0.00 THEN
			IF _monto > _reserva_actual THEN
				LET _variacion = _reserva_actual * (-1);
			ELSE
				LET _variacion = _monto * (-1);
			END IF
		ELSE
			LET _variacion = 0.00;
		END IF 

		BEGIN
		ON EXCEPTION SET _error 
			rollback work;
	        DROP TABLE tmp_prov;
		 	RETURN _error, "Error al Insertar Transaccion", 0, 0;         
		END EXCEPTION 

		INSERT INTO rectrmae(
		no_tranrec, 
		cod_compania, 
		cod_sucursal, 
		no_reclamo, 
		cod_cliente, 
		cod_tipotran, 
		cod_tipopago,
		numrecla, 
		periodo, 
		pagado, 
		monto, 
		variacion, 
		generar_cheque, 
		user_added, 
		fecha, 	
		wf_incidente,
		wf_inc_auto,
		wf_aprobado,
		wf_ord_com,
		wf_apr_js,
		wf_apr_js_fh,
		wf_apr_j,
		wf_apr_j_fh,
		wf_apr_jt,
		wf_apr_jt_fh,
		wf_apr_jt_2,
		wf_apr_jt_2_fh,
		wf_apr_g,
		wf_apr_g_fh,
		wf_inc_padre,
		actualizado,
		transaccion
		)
		VALUES(
		_no_tranrec,
		_cod_compania,
		_cod_sucursal,
		_no_reclamo,
		_wf_poveedor,
		"004",
		_cod_tipopago,
		_numrecla,
		_periodo,
		0,
		_monto,
		_variacion,
		_generar_cheque,
		_user_added,
		_fecha_recl_valor,
		_wf_incidente,
		_wf_inc_auto,
		1,
		1,
		_wf_apr_js,
		_wf_apr_js_fh,
		_wf_apr_j,
		_wf_apr_j_fh,
		_wf_apr_jt,
		_wf_apr_jt_fh,
		_wf_apr_jt_2,
		_wf_apr_jt_2_fh,
		_wf_apr_g,
		_wf_apr_g_fh,
		_wf_inc_padre,
		1,
		_transaccion
		);
	    END	   	 

	-- Coberturas

		BEGIN
		ON EXCEPTION SET _error 
			rollback work;
		 	RETURN _error, "Error al Insertar Coberturas", 0, 0;         
		END EXCEPTION 
		insert into rectrcob(
		no_tranrec,
		cod_cobertura,
		monto,
		variacion,
		facturado,
		elegible,
		a_deducible,
		co_pago,
		cod_no_cubierto,
		monto_no_cubierto,
		cod_tipo,
		coaseguro,
		ahorro
		)
		select
		_no_tranrec,
		cod_cobertura,
		0.00, -- reserva_inicial,
		0.00, -- reserva_inicial,
		0.00,
		0.00,
		0.00,
		0.00,
		_null,
		0.00,
		_null,
		0.00,
		0.00
		from rectrcob
		where no_tranrec = a_no_tranrec;
		END

		BEGIN
		ON EXCEPTION SET _error 
			rollback work;
	        DROP TABLE tmp_prov;
		 	RETURN _error, "Error al Actualizar Coberturas", 0, 0;         
		END EXCEPTION 

		UPDATE rectrcob
		   SET monto = _monto,
		       variacion = _variacion
		 WHERE no_tranrec = _no_tranrec
		   AND cod_cobertura = _cod_cobertura;

		END

	 -- Actualizando coberturas
		BEGIN
		 ON EXCEPTION SET _error 
		 	rollback work;
			RETURN _error, "Error al actualizar las coberturas del reclamo", 0, 0;         
		 END EXCEPTION 
		 FOREACH
			SELECT cod_cobertura,
			       monto,
			       variacion
			  INTO _cod_cobertura,
			       _monto_cob,
			       _variacion
			  FROM rectrcob
			 WHERE no_tranrec = _no_tranrec

            IF _monto_cob IS NULL THEN
				LET _monto_cob = 0;
			END IF

            IF _variacion IS NULL THEN
				LET _variacion = 0;
			END IF

		    SELECT reserva_actual
			  INTO _reserva_actual
			  FROM recrccob
			 WHERE no_reclamo = _no_reclamo
			   AND cod_cobertura = _cod_cobertura;

		    IF _tipo_transaccion = 4 OR _tipo_transaccion = 3 THEN
				IF ABS(_variacion) > ABS(_reserva_actual) THEN
	                DROP TABLE tmp_prov;
					RETURN 1, "Variacion de Reserva es Mayor que Reserva Actual", 0, 0;
				END IF
			END IF

		    IF _tipo_transaccion = 4 THEN
				UPDATE recrccob
				   SET pagos = pagos + _monto_cob, 
				       reserva_actual = reserva_actual + _variacion
				 WHERE no_reclamo    = _no_reclamo
				   AND cod_cobertura = _cod_cobertura;

		        -- Actualizacion de los Pagos de Salud
		        CALL sp_rec56(_cod_compania, _no_tranrec) returning _error, _descripcion;

		        IF _error = 1 THEN
				   rollback work;
	               DROP TABLE tmp_prov;
				   RETURN  _error, "No se Actualizaron las Acumulaciones para el Ramo de Salud", 0, 0;
				END IF
			ELSE
				UPDATE recrccob
				   SET reserva_actual = reserva_actual + _variacion
				 WHERE no_reclamo     = _no_reclamo
				   AND cod_cobertura  = _cod_cobertura;
			END IF

		 END FOREACH
		END


		-- Conceptos

		BEGIN
		ON EXCEPTION SET _error 
			rollback work;
	        DROP TABLE tmp_prov;
		 	RETURN _error, "Error al Insertar Concepto", 0, 0;         
		END EXCEPTION 

		IF _tipo_orden = 'C' THEN
		    INSERT INTO rectrcon(
			no_tranrec,
			cod_concepto,
			monto
			)
			VALUES(
			_no_tranrec,
			"017",
			_monto
			);
	    ELSE
		    INSERT INTO rectrcon(
			no_tranrec,
			cod_concepto,
			monto
			)
			VALUES(
			_no_tranrec,
			"003",
			_monto + a_deducible
			);

	        IF a_deducible <> 0.00 THEN
			    INSERT INTO rectrcon(
				no_tranrec,
				cod_concepto,
				monto
				)
				VALUES(
				_no_tranrec,
				"006",
				a_deducible * (-1)
				);
			END IF
		END IF
		END
	 -- Reaseguro a Nivel de Transaccion
		CALL sp_sis58(_no_tranrec) returning _error, _descripcion;
		IF _error <> 0 THEN
			rollback work;
	        DROP TABLE tmp_prov;
			RETURN  _error, "No se creo el Reaseguro a Nivel de Transaccion", 0, 0;
		END IF

	 -- Procedimiento que Genera el Recibo de Pago de los Movimientos de Reclamos de Primas Pendientes
		CALL sp_rec197(a_no_tranrec) returning _error, _descripcion;
		IF _error <> 0 THEN
			rollback work;
			RETURN  _error, "Error al generar Recibo de Pago de Primas Pend.", 0, 0;
		END IF

	 -- Creacion de Orden de compra o reparacion
	 	LET _hoy = _hoy + 1 UNITS SECOND;
		CALL sp_rwf43(_no_tranrec,_tipo_orden,a_deducible,_monto_orig,_hoy,a_cotizacion) returning _error, _descripcion;
		IF _error <> 0 THEN
			rollback work;
	        DROP TABLE tmp_prov;
			RETURN  _error, _descripcion, 0, 0;
		END IF
		LET _hoy = _hoy + 1 UNITS SECOND;
	 END FOREACH  --- foreach de leer tabla temporal de proveedor

	 --*************************************** fin **************************--

	 BEGIN
		ON EXCEPTION SET _error 
			rollback work;
	        DROP TABLE tmp_prov;
		 	RETURN _error, "Error al actualizar transaccion", 0, 0;         
		END EXCEPTION 

		DELETE FROM rectrrea WHERE no_tranrec = a_no_tranrec;
		DELETE FROM rectrcob WHERE no_tranrec = a_no_tranrec;
		DELETE FROM rectrcon WHERE no_tranrec = a_no_tranrec;
		DELETE FROM rectrde2 WHERE no_tranrec = a_no_tranrec;
		DELETE FROM rectrmae WHERE no_tranrec = a_no_tranrec;
	 END
	--************ Si el pago directo a Asegurado o a Tercero ***************--

 ELSE

	SELECT monto
	  INTO _monto
	  FROM rectrmae
	 WHERE no_tranrec = a_no_tranrec;

 	LET _transaccion = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);

	IF _transaccion = "" OR _transaccion IS NULL THEN
        DROP TABLE tmp_prov;
		RETURN 1, "Error generando # de transaccion", 0, 0;
	END IF
  
	BEGIN
	ON EXCEPTION SET _error 
		rollback work;
        DROP TABLE tmp_prov;
	 	RETURN _error, "Error al Actualizar Transaccion", 0, 0;         
	END EXCEPTION 

	UPDATE rectrmae
	   SET actualizado = 1,
		   transaccion = _transaccion,
		   periodo     = _periodo,
		   fecha       = _fecha_recl_valor
	 WHERE no_tranrec = a_no_tranrec;

	END

	 -- Insertado en Recnotas
	 SELECT nombre
	   INTO _nombre_tipo_pago
	   FROM rectipag
	  WHERE	cod_tipopago = _cod_tipopago;
     
	 CALL sp_rwf104(_no_reclamo,_hoy,"La transaccion de " || trim(_nombre_tipo_pago) || " con incidente # " || trim(_wf_incidente_str) || " fue Aprobada",_user_added) returning _error, _descripcion;
	 IF _error <> 0 THEN
		rollback work;
        DROP TABLE tmp_prov;
		RETURN  _error, _descripcion, 0, 0;
	 END IF

 -- Genera requisicion si es generar cheque
	IF _generar_cheque = 1 THEN
	 	LET _hoy = _hoy + 1 UNITS SECOND;
		CALL sp_rwf39(a_no_tranrec, _hoy) returning _error, _descripcion, _genera_incidente;
		IF _error <> 0 THEN
		   rollback work;
           DROP TABLE tmp_prov;
		   RETURN  _error, _descripcion, 0, 0;
		END IF
	END IF

    -- Validacion que esta en el sp_rwf37
    IF _tipo_transaccion = 4 THEN
	    
		IF _numrecla[1,2] = "02" OR _numrecla[1,2] = "20" THEN -- 7.26
            LET _reserva_actual = sp_rwf96(_no_reclamo);
			IF _monto > _reserva_actual THEN
				LET _envia_correo = 1;	
			END IF
		END IF

		FOREACH
			SELECT cod_cobertura,
			       reserva_actual
			  INTO _cod_cobertura,
			       _reserva_actual
			  FROM recrccob
			 WHERE no_reclamo = _no_reclamo

            FOREACH
            	SELECT monto
				  INTO _monto_tr
				  FROM rectrcob
				 WHERE no_tranrec = a_no_tranrec
				   AND cod_cobertura = _cod_cobertura

                IF _monto_tr > _reserva_actual THEN
					LET _variacion = _reserva_actual * -1;

					UPDATE rectrcob
					   SET variacion = _reserva_actual * -1
					 WHERE no_tranrec = a_no_tranrec
					   AND cod_cobertura = _cod_cobertura;
			    ELSE 
					IF _monto_tr < 0 THEN
						LET _variacion = 0;

						UPDATE rectrcob
						   SET variacion = 0
						 WHERE no_tranrec = a_no_tranrec
						   AND cod_cobertura = _cod_cobertura;
					ELSE
						LET _variacion	=  _monto_tr * -1;

						UPDATE rectrcob
						   SET variacion = _monto_tr * -1
						 WHERE no_tranrec = a_no_tranrec
						   AND cod_cobertura = _cod_cobertura;
					END IF
				END IF

                LET _variacion_sum = _variacion_sum + _variacion;
			END FOREACH
		END FOREACH

        UPDATE rectrmae
		   SET variacion = _variacion_sum
		 WHERE no_tranrec = a_no_tranrec;
	END IF
	--


 -- Actualizando coberturas
	BEGIN
	 ON EXCEPTION SET _error 
	 	rollback work;
		RETURN _error, "Error al actualizar las coberturas del reclamo", 0, 0;         
	 END EXCEPTION 
	 FOREACH
		SELECT cod_cobertura,
		       monto,
		       variacion
		  INTO _cod_cobertura,
		       _monto_cob,
		       _variacion
		  FROM rectrcob
		 WHERE no_tranrec = a_no_tranrec

	    SELECT reserva_actual
		  INTO _reserva_actual
		  FROM recrccob
		 WHERE no_reclamo = _no_reclamo
		   AND cod_cobertura = _cod_cobertura;


	    IF _tipo_transaccion = 4 THEN
			IF ABS(_variacion) > ABS(_reserva_actual) THEN
                DROP TABLE tmp_prov;
				RETURN 1, "Variacion de Reserva es Mayor que Reserva Actual", 0, 0;
			END IF
		END IF

	    IF _tipo_transaccion = 4 THEN
			UPDATE recrccob
			   SET pagos = pagos + _monto_cob, 
			       reserva_actual = reserva_actual + _variacion
			 WHERE no_reclamo    = _no_reclamo
			   AND cod_cobertura = _cod_cobertura;

	        -- Actualizacion de los Pagos de Salud
	        CALL sp_rec56(_cod_compania, a_no_tranrec) returning _error, _descripcion;

	        IF _error = 1 THEN
			   rollback work;
               DROP TABLE tmp_prov;
			   RETURN  _error, "No se Actualizaron las Acumulaciones para el Ramo de Salud", 0, 0;
			END IF
		ELSE
			UPDATE recrccob
			   SET reserva_actual = reserva_actual + _variacion
			 WHERE no_reclamo     = _no_reclamo
			   AND cod_cobertura  = _cod_cobertura;
		END IF

	 END FOREACH
	END

 -- Reaseguro a Nivel de Transaccion
	CALL sp_sis58(a_no_tranrec) returning _error, _descripcion;
	IF _error <> 0 THEN
		rollback work;
        DROP TABLE tmp_prov;
		RETURN  _error, "No se creo el Reaseguro a Nivel de Transaccion", 0, 0;
	END IF

 -- Procedimiento que Genera el Recibo de Pago de los Movimientos de Reclamos de Primas Pendientes
	CALL sp_rec197(a_no_tranrec) returning _error, _descripcion;
	IF _error <> 0 THEN
		rollback work;
		RETURN  _error, "Error al generar Recibo de Pago de Primas Pend.", 0, 0;
	END IF
	 
 END IF

 DROP TABLE tmp_prov;

 commit work;
-- rollback work;

 RETURN 0, "Actualizacion Exitosa", _genera_incidente, _envia_correo;
END PROCEDURE