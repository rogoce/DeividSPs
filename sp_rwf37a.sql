-- Procedimiento para actualizar una transaccion
-- 
-- creado: 20/12/2004 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf37a;
CREATE PROCEDURE "informix".sp_rwf37a(a_no_tranrec CHAR(10)) 
			RETURNING SMALLINT, VARCHAR(50), SMALLINT, SMALLINT;  

DEFINE _mes_char			CHAR(2);
DEFINE _ano_char			CHAR(4);
DEFINE _periodo			    CHAR(7);
DEFINE _user_added			CHAR(8);
DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_tipopago		CHAR(3);
DEFINE _anular_nt			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _no_reclamo			CHAR(10);
DEFINE _cerrar_rec			SMALLINT;
DEFINE _perd_total			SMALLINT;
DEFINE _generar_cheque		SMALLINT;
DEFINE _no_requis			CHAR(10);
DEFINE _cantidad      		SMALLINT;
DEFINE _tipo_transaccion   	SMALLINT;
DEFINE _no_tranrec_nt		CHAR(10);
DEFINE _monto_nt			DEC(16,2);
DEFINE _pagado_nt			SMALLINT;
DEFINE _user_anulo_nt 		CHAR(10);
DEFINE _fecha_anulo_nt		DATE;
DEFINE _variacion	        DEC(16,2);
DEFINE _monto_cob			DEC(16,2);
DEFINE _variacion_cob		DEC(16,2);
DEFINE _monto_con			DEC(16,2);
DEFINE _monto_cob_tot		DEC(16,2);
DEFINE _variacion_cob_tot	DEC(16,2);
DEFINE _monto_con_tot		DEC(16,2);
DEFINE _transaccion			CHAR(10);
DEFINE _error   			SMALLINT;
DEFINE _no_poliza			CHAR(10);
DEFINE _no_unidad			CHAR(5);
DEFINE _cod_cobertura       CHAR(5);
DEFINE _reserva_actual    	DEC(16,2);
DEFINE _descripcion         VARCHAR(50); 
DEFINE _genera_incidente    SMALLINT;
DEFINE _actualizado    		SMALLINT;
DEFINE _fecha			    DATE;
DEFINE _fecha_recl_default	CHAR(20);
DEFINE _fecha_recl_valor	CHAR(20);
DEFINE _no_tranrec_otro     CHAR(10);
DEFINE _monto_tr            DEC(16,2);
DEFINE _variacion_sum       DEC(16,2);
DEFINE _variacion_tot  		DEC(16,2);
DEFINE _cant                SMALLINT;
DEFINE _numrecla            CHAR(20);
DEFINE _envia_correo        SMALLINT;
DEFINE _wf_incidente_str    VARCHAR(10);
DEFINE _nombre_tipo_pago    VARCHAR(50);
DEFINE _hoy                 DATETIME HOUR TO FRACTION(5);

--SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rwf37.trc";
--trace on;																	 

--begin work;


LET _cantidad = 0;
LET _monto_cob_tot = 0;
LET _monto_cob = 0;
LET _variacion_cob_tot = 0;
LET _variacion_cob = 0;
LET _monto_con_tot = 0;
LET _monto_con = 0;
LET _pagado_nt = 0;
LET _user_anulo_nt = null;
LET _fecha_anulo_nt = null;
LET _genera_incidente = 0;
LET _monto_tr = 0;
LET _variacion_sum = 0;
LET _variacion	= 0;
LET _envia_correo = 0;
LET _hoy = CURRENT;
LET _transaccion = null;

 SELECT user_added,
        cod_compania,
		cod_sucursal,
		cod_tipotran,
		cod_tipopago,
		anular_nt,
		monto,
		no_reclamo,
		cerrar_rec,
		perd_total,
		generar_cheque,
		no_requis,
		actualizado,
		numrecla,
		wf_incidente,
		transaccion
   INTO _user_added,
        _cod_compania,
		_cod_sucursal,
		_cod_tipotran,
		_cod_tipopago,
		_anular_nt,
		_monto,
		_no_reclamo,
		_cerrar_rec,
		_perd_total,
		_generar_cheque,
		_no_requis,
		_actualizado,
		_numrecla,
		_wf_incidente_str,
		_transaccion
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

 IF _numrecla IS NULL OR TRIM(_numrecla) = "" THEN
    --rollback work;
 	RETURN 1, "Numero de reclamo es nulo", 0, 0;
 END IF

 IF _actualizado = 1 THEN
    --rollback work;
 	RETURN 0, "Esta transaccion ya esta actualizada", 0, 0;
 END IF 

 BEGIN
	ON EXCEPTION SET _error 
		--rollback work;
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
 --		LET _fecha = current;
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
 --		LET _fecha = MDY(_fecha_recl_valor[4,5], _fecha_recl_valor[1,2], _fecha_recl_valor[7,10]);
	 END IF	 
 END


 SELECT COUNT(*) 
   INTO _cantidad 
   FROM rectrcob
  WHERE no_tranrec = a_no_tranrec;

 IF _cantidad = 0 THEN
	--rollback work;
    RETURN 1, "Esta transaccion no Tiene Coberturas Registradas, Verifique... ", 0, 0;
 END IF

 -- Buscando # de transaccion externo
 IF trim(_transaccion) = "" OR _transaccion IS NULL THEN 
 	LET _transaccion = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);
 END IF
 --LET _transaccion = "ultimus";

 IF trim(_transaccion) = "" OR _transaccion IS NULL THEN
	--rollback work;
	RETURN 1, "Error generando # de transaccion", 0, 0;
 END IF

 SELECT tipo_transaccion
   INTO _tipo_transaccion
   FROM rectitra
  WHERE cod_tipotran = _cod_tipotran;

 IF _anular_nt is null THEN
	LET _anular_nt = "";
 END IF

 IF _tipo_transaccion = 4 AND _anular_nt <> "" THEN
 	SELECT no_tranrec,
 	       monto 
	  INTO _no_tranrec_nt,
	       _monto_nt
	  FROM rectrmae
	 WHERE transaccion = _anular_nt;
	   
	 IF _no_tranrec_nt = "" OR _no_tranrec_nt IS NULL THEN
		--rollback work;
	    RETURN 1, "La transaccion no existe, verifique...", 0, 0;
	 END IF

	 IF ABS(_monto) <> ABS(_monto_nt) THEN
		--rollback work;
	    RETURN 1, "Los montos son diferentes,verifique...", 0, 0;
	 END IF

     LET _pagado_nt      = 1;
	 LET _user_anulo_nt  = _user_added;
	 LET _fecha_anulo_nt = current;
	 -- actualizar pagado en la transaccion anulada
	 BEGIN
		ON EXCEPTION SET _error 
	        --rollback work;
		 	RETURN _error, "Error al actualizar transaccion anulada", 0, 0;         
		END EXCEPTION 
		UPDATE rectrmae 
		   SET pagado         = 1,
		       user_anulo     = _user_anulo_nt,
		       fecha_anulo    = _fecha_anulo_nt,
		       anular_nt      = _transaccion,
		       no_requis      = null,
		       generar_cheque = 0
		 WHERE no_tranrec     = _no_tranrec_nt;

		--call sp_rec95(_anular_nt) RETURNING _resultado,_mensaje;

	 END 

 END IF

 FOREACH
	SELECT monto,
	       variacion
	  INTO _monto_cob,
		   _variacion_cob
	  FROM rectrcob
	 WHERE no_tranrec = a_no_tranrec

     LET _monto_cob_tot = _monto_cob_tot + _monto_cob;
     LET _variacion_cob_tot = _variacion_cob_tot + _variacion_cob;
		   
 END FOREACH

 FOREACH
	SELECT monto
	  INTO _monto_con
	  FROM rectrcon
	 WHERE no_tranrec = a_no_tranrec

     LET _monto_con_tot = _monto_con_tot + _monto_con;
		   
 END FOREACH
 IF _monto_cob_tot <> _monto_con_tot And _tipo_transaccion = 4 THEN
 	--rollback work;
	RETURN 1, "Existen Diferencias Entre las Coberturas y los Conceptos de Pagos", 0, 0;
 END IF

 IF _monto_cob_tot = 0.00 THEN
 	LET _generar_cheque = 0;
	LET _no_requis = NULL;
 END IF

 -- actualizar monto y variacion en la transaccion
 -- actualizar periodo, transaccion
 BEGIN
	ON EXCEPTION SET _error 
		--rollback work;
	 	RETURN _error, "Error al actualizar transaccion", 0, 0;         
	END EXCEPTION 

	UPDATE rectrmae 
	   SET monto = _monto_cob_tot, 
	       variacion = _variacion_cob_tot,
		   transaccion = _transaccion,
		   periodo = _periodo,
		   pagado = _pagado_nt,
		   user_anulo = _user_anulo_nt,
		   fecha_anulo = _fecha_anulo_nt,
		   actualizado = 1,
		   generar_cheque = _generar_cheque,
		   no_requis = _no_requis
	 WHERE no_tranrec = a_no_tranrec;          
 END 

-- Actualizando en recrcmae cuando es cerrar reclamo
 IF _cerrar_rec = 1 THEN
	 BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar reclamo - cerrar reclamo", 0, 0;         
		END EXCEPTION 
		UPDATE recrcmae 
		   SET estatus_reclamo = "C"
		 WHERE no_reclamo = _no_reclamo;
 	 END 
 END IF

-- Actualizando tablas cuando es perdida
 IF _perd_total = 1 THEN
 	SELECT no_poliza,
	       no_unidad
	  INTO _no_poliza,
		   _no_unidad
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	 BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar reclamo - perdida total", 0, 0;         
		END EXCEPTION 
		UPDATE recrcmae 
		   SET perd_total = 1
		 WHERE no_reclamo = _no_reclamo;
 	 END 

	 BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar emipomae - cerrar reclamo", 0, 0;         
		END EXCEPTION 
		UPDATE emipomae 
		   SET perd_total = 1
		 WHERE no_poliza  = _no_poliza;
 	 END 
	 
	 BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar emipouni - cerrar reclamo", 0, 0;         
		END EXCEPTION 
		UPDATE emipouni 
		   SET perd_total = 1
		 WHERE no_poliza  = _no_poliza 
		   AND no_unidad  = _no_unidad;
 	 END
 	 
	 BEGIN
		CALL sp_rec163(a_no_tranrec) returning _error, _descripcion;
	    IF _error <> 0 THEN
		   --rollback work;
		   RETURN  _error, _descripcion, 0, 0;
		END IF
	 END
 	  
 END IF

 -- Insertado en Recnotas

 SELECT nombre
   INTO _nombre_tipo_pago
   FROM rectipag
  WHERE	cod_tipopago = _cod_tipopago;

 IF _nombre_tipo_pago IS NOT NULL AND TRIM(_nombre_tipo_pago) <> "" THEN
	 CALL sp_rwf104(_no_reclamo,_hoy,"La transaccion de " || trim(_nombre_tipo_pago) || " con incidente # " || trim(_wf_incidente_str) || " fue Aprobada",_user_added) returning _error, _descripcion;
	 IF _error <> 0 THEN
		--rollback work;
		RETURN  _error, _descripcion, 0, 0;
	 END IF
 END IF

-- Genera requisicion si es generar cheque
 IF _generar_cheque = 1 THEN
	LET _hoy = _hoy + 1 UNITS SECOND;
 	CALL sp_rwf39(a_no_tranrec, _hoy) returning _error, _descripcion, _genera_incidente;
    IF _error <> 0 THEN
	   --rollback work;
	   RETURN  _error, _descripcion, 0, 0;
	END IF
 END IF

-- Actualizando coberturas
 BEGIN
	 ON EXCEPTION SET _error 
	 	--rollback work;
		RETURN _error, "Error al actualizar las coberturas del reclamo", 0, 0;         
	 END EXCEPTION
	 
	 IF _cerrar_rec = 1 THEN
		FOREACH
			SELECT cod_cobertura,
			       reserva_actual
			  INTO _cod_cobertura,
			       _reserva_actual
			  FROM recrccob
			 WHERE no_reclamo = _no_reclamo

            IF _reserva_actual < 0 THEN
				LET _reserva_actual = 0;
			END IF

  			LET _cant = 0; 

            SELECT COUNT(*) 			 --> Se verifica que esten todas las coberturas al cerrar el reclamo, si no esta se incluye
			  INTO _cant
			  FROM rectrcob
			 WHERE no_tranrec = a_no_tranrec
			   AND cod_cobertura = _cod_cobertura;

			IF _cant > 0 THEN
				UPDATE rectrcob
				   SET variacion = _reserva_actual * -1
				 WHERE no_tranrec = a_no_tranrec
				   AND cod_cobertura = _cod_cobertura;
			ELSE
				INSERT INTO rectrcob (
				        no_tranrec,
					    cod_cobertura,
					    variacion
					    )
				VALUES (a_no_tranrec,
				        _cod_cobertura,
						_reserva_actual * -1
						);
			END IF

		END FOREACH

		SELECT SUM(variacion)
		  INTO _variacion_sum
		  FROM rectrcob
		 WHERE no_tranrec = a_no_tranrec;

        UPDATE rectrmae
		   SET variacion = _variacion_sum
		 WHERE no_tranrec = a_no_tranrec;
	 ELSE 	-- Verificar		-- Se modifica para que haga el recalculo de la variacion A.P.M. 24/10/2008
	    IF _tipo_transaccion = 4 OR _tipo_transaccion = 3 THEN	  -->Pago y Disminucion
		    
			IF _numrecla[1,2] = "02" OR _numrecla[1,2] = "20" THEN -- 7.26
	            LET _reserva_actual = sp_rwf96(_no_reclamo);
				IF _monto > _reserva_actual THEN
					LET _envia_correo = 1;	
				END IF
			END IF

			LET _variacion_sum = 0;

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

					LET _variacion = 0;

	               	IF _reserva_actual <= 0 THEN
						LET _variacion = 0;
					ELIF _monto_tr > _reserva_actual THEN
					    LET _variacion = _reserva_actual * -1;
					ELIF _monto_tr < 0 THEN
						LET _variacion = 0;
					ELSE
					    LET _variacion = _monto_tr * -1;
					END IF		

					UPDATE rectrcob
					   SET variacion = _variacion
					 WHERE no_tranrec = a_no_tranrec
					   AND cod_cobertura = _cod_cobertura;

		                LET _variacion_sum = _variacion_sum + _variacion;
				END FOREACH
			END FOREACH

	--		SELECT SUM(variacion)
	--		  INTO _variacion_sum
	--		  FROM rectrcob
	--		 WHERE no_tranrec = a_no_tranrec;

	        UPDATE rectrmae
			   SET variacion = _variacion_sum
			 WHERE no_tranrec = a_no_tranrec;
	    ELIF _tipo_transaccion = 2 THEN
			LET _variacion_sum = 0;

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

                    IF _monto_tr IS NULL THEN
						LET _monto_tr = 0;
					END IF

					LET _variacion = _monto_tr;

					UPDATE rectrcob
					   SET variacion = _variacion
					 WHERE no_tranrec = a_no_tranrec
					   AND cod_cobertura = _cod_cobertura;

		                LET _variacion_sum = _variacion_sum + _variacion;
				END FOREACH
			END FOREACH

	        UPDATE rectrmae
			   SET variacion = _variacion_sum
			 WHERE no_tranrec = a_no_tranrec;
		END IF

     	LET _variacion	= 0;
	 END IF

     LET _variacion_tot	= 0;
     
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

		IF _numrecla[1,2] = "18" THEN
	        SELECT reserva_actual
			  INTO _reserva_actual
			  FROM recrcmae
		 	WHERE no_reclamo = _no_reclamo;
		END IF

        IF _tipo_transaccion = 4 OR _tipo_transaccion = 3 THEN
			IF ABS(_variacion) > ABS(_reserva_actual) THEN
		   		--rollback work;
				RETURN 1, "Variacion de Reserva es Mayor que Reserva Actual", 0, 0;
			END IF
		END IF

        IF _tipo_transaccion = 4 THEN
			UPDATE recrccob
			   SET pagos = pagos + _monto_cob, 
			       reserva_actual = reserva_actual + _variacion
			 WHERE no_reclamo    = _no_reclamo
			   AND cod_cobertura = _cod_cobertura;

			IF _numrecla[1,2] = "18" THEN
				UPDATE recrcmae
					SET reserva_actual = reserva_actual + _variacion
				 WHERE no_reclamo     = _no_reclamo;
			END IF

		ELSE
			IF _numrecla[1,2] = "18" THEN
				IF _tipo_transaccion = 13 THEN
					LET _variacion = 0;
					UPDATE rectrcob
					   SET variacion = 0
					 WHERE no_tranrec     = a_no_tranrec
					   AND cod_cobertura  = _cod_cobertura;
		    	END IF
			END IF
			UPDATE recrccob
			   SET reserva_actual = reserva_actual + _variacion
			 WHERE no_reclamo     = _no_reclamo
			   AND cod_cobertura  = _cod_cobertura;
			IF _numrecla[1,2] = "18" THEN
				UPDATE recrcmae
				   SET reserva_actual = reserva_actual + _variacion
				 WHERE no_reclamo     = _no_reclamo;
			END IF
		END IF
		LET _variacion_tot = _variacion_tot + _variacion;
	 END FOREACH  

     IF _tipo_transaccion = 4 THEN
	    -- Actualizacion de los Pagos de Salud
	    CALL sp_rec56(_cod_compania, a_no_tranrec) returning _error, _descripcion;

	    IF _error <> 0 THEN
		   --rollback work;
		   RETURN  _error, _descripcion, 0, 0;
		END IF
	 END IF

 --	 UPDATE recrcmae
 --	    SET reserva_actual = reserva_actual + _variacion_tot
 --	  WHERE no_reclamo     = _no_reclamo;

 END

 -- Reaseguro a Nivel de Transaccion
 CALL sp_sis58(a_no_tranrec) returning _error, _descripcion;
 IF _error <> 0 THEN
 	--rollback work;
	RETURN  _error, "No se creo el Reaseguro a Nivel de Transaccion", 0, 0;
 END IF

 BEGIN
	 ON EXCEPTION SET _error 
		--rollback work;
	 	RETURN _error, "Error al actualizar recrcmae - lo ultimo", 0, 0;         
	 END EXCEPTION 

	 IF _tipo_transaccion = 12 THEN
		UPDATE recrcmae 
		   SET estatus_reclamo = "A"
		 WHERE no_reclamo = _no_reclamo;			
	 END IF
	 IF _tipo_transaccion = 13 THEN
		UPDATE recrcmae 
		   SET estatus_reclamo = "D"
		 WHERE no_reclamo = _no_reclamo;			
	 End If
	 IF _tipo_transaccion = 14 THEN
		UPDATE recrcmae 
		   SET estatus_reclamo = "N"
		 WHERE no_reclamo = _no_reclamo;			
	 END IF
 END

 FOREACH
	 SELECT no_tranrec
	   INTO _no_tranrec_otro
	   FROM rectrmae
	  WHERE transaccion = _transaccion

     IF _no_tranrec_otro IS NOT NULL AND _no_tranrec_otro <> "" THEN
		IF _no_tranrec_otro <> a_no_tranrec THEN
			rollback work;
		 	RETURN _error, "Transaccion Duplicada", 0, 0;         
		END IF
	 END IF
 END FOREACH

 -- Procedimiento que Genera el Recibo de Pago de los Movimientos de Reclamos de Primas Pendientes
 CALL sp_rec197(a_no_tranrec) returning _error, _descripcion;
 IF _error <> 0 THEN
 	--rollback work;
	RETURN  _error, "Error al generar Recibo de Pago de Primas Pend.", 0, 0;
 END IF
    
 --commit work;
-- rollback work;

 RETURN 0, "Actualizacion Exitosa", _genera_incidente, _envia_correo;
END PROCEDURE