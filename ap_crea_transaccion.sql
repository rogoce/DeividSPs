-- Procedimiento que anula requisición desde una tabla

-- Creado    : 04/10/2017 - Autor: Amado Perez 

DROP PROCEDURE ap_crea_transaccion;

CREATE PROCEDURE "informix".ap_crea_transaccion(a_no_requis CHAR(10))
returning char(10) as Transaccion;

define _fecha_actual	date;
define _pagado        	smallint;
define v_periodo      	char(7);
define _no_requis     	char(10);
define _transaccion, _transaccion_n  char(10);
define _no_tranrec, _no_tranrec_n    char(10);
define _no_reclamo    	char(10);
define _numrecla      	char(20);
define _cod_sucursal  	char(3);
define _cod_tipotran  	char(3);
define _tipo_transaccion smallint;
define _error		  integer;
define _cerrar_rec    smallint;
define _cod_cobertura char(5);
define _reserva_actual dec(16,2);
define _variacion_sum  dec(16,2);
define _cant           smallint;
define _monto_tr       dec(16,2);
define _variacion      dec(16,2);
define _variacion_tot  dec(16,2);
define _monto_cob      dec(16,2);
DEFINE _descripcion    VARCHAR(50); 
define _monto          dec(16,2);
	  
SET ISOLATION TO DIRTY READ;

SET DEBUG FILE TO "ap_crea_transaccion.trc"; 
trace on;

BEGIN WORK;

BEGIN

ON EXCEPTION
	ROLLBACK WORK;
	RETURN null;
END EXCEPTION

let _fecha_actual = TODAY;
let _pagado = 0;
let _error = 0;

IF MONTH(_fecha_actual) < 10 THEN
	LET v_periodo = YEAR(_fecha_actual) || '-0' || MONTH(_fecha_actual);
ELSE
	LET v_periodo = YEAR(_fecha_actual) || '-' || MONTH(_fecha_actual);
END IF

SELECT pagado
  INTO _pagado
  FROM chqchmae
 WHERE no_requis = a_no_requis;
 
 IF _pagado = 1 THEN
	RETURN NULL;
 END IF

FOREACH
	SELECT no_requis,
	       transaccion
	  INTO _no_requis,
	       _transaccion
	  FROM tmp_trans_anulada
	 where creado = 0
	   and no_requis = a_no_requis
	 
	select * 
	  from rectrmae
	 where transaccion = _transaccion
	  into temp prueba;
	  
	select no_tranrec,
	       no_reclamo,
	       cod_sucursal,
		   cod_tipotran,
		   numrecla,
		   monto,
		   cerrar_rec
	  into _no_tranrec,
	       _no_reclamo,
	       _cod_sucursal,
		   _cod_tipotran,
		   _numrecla,
		   _monto,
		   _cerrar_rec
	  from rectrmae
	 where transaccion = _transaccion;
	 
	 LET _no_tranrec_n = sp_sis13('001',"REC","02","par_tran_genera");

	 IF _no_tranrec_n IS NULL OR _no_tranrec_n = "" OR _no_tranrec_n = "00000" THEN
		ROLLBACK WORK;
		RETURN null;
	 END IF 
	 
	 LET _transaccion_n = sp_sis12('001', _cod_sucursal, _no_reclamo);

	 IF trim(_transaccion_n) = "" OR _transaccion_n IS NULL THEN
		rollback work;
		RETURN null;
	 END IF

	update prueba 
	   set no_tranrec = _no_tranrec_n,
	       transaccion = _transaccion_n,
		   fecha = today,
		   periodo = v_periodo,
		   pagado = 0,
		   generar_cheque = 1,
		   no_requis = _no_requis,
		   anular_nt = null,
		   user_anulo = null,
		   fecha_anulo = null,
		   sac_asientos = 0,
		   subir_bo = 0;

	insert into rectrmae
	select * 
	  from prueba;
	 
   drop table prueba;	 

	select * 
	  from rectrcob
	 where no_tranrec = _no_tranrec
	  into temp prueba;
	  
	update prueba 
	   set no_tranrec = _no_tranrec_n,
		   subir_bo = 0;
 
	insert into rectrcob
	select * 
	  from prueba;
	 
   drop table prueba;	 

	select * 
	  from rectrcon
	 where no_tranrec = _no_tranrec
	  into temp prueba;
	  
	update prueba 
	   set no_tranrec = _no_tranrec_n,
		   subir_bo = 0;
 
	insert into rectrcon
	select * 
	  from prueba;
	 
   drop table prueba;	 
   
	------------------
	select * 
	  from rectrde2
	 where no_tranrec = _no_tranrec
	  into temp prueba;

	update prueba 
	   set no_tranrec = _no_tranrec_n;

	insert into rectrde2
	select * 
	  from prueba;

	drop table prueba;   

-- Actualizando coberturas

 SELECT tipo_transaccion
   INTO _tipo_transaccion
   FROM rectitra
  WHERE cod_tipotran = _cod_tipotran;

 BEGIN
	 ON EXCEPTION SET _error 
	 	rollback work;
		RETURN null;         
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
			 WHERE no_tranrec = _no_tranrec_n
			   AND cod_cobertura = _cod_cobertura;

			IF _cant > 0 THEN
				UPDATE rectrcob
				   SET variacion = _reserva_actual * -1
				 WHERE no_tranrec = _no_tranrec_n
				   AND cod_cobertura = _cod_cobertura;
			ELSE
				INSERT INTO rectrcob (
				        no_tranrec,
					    cod_cobertura,
					    variacion
					    )
				VALUES (_no_tranrec_n,
				        _cod_cobertura,
						_reserva_actual * -1
						);
			END IF

		END FOREACH

		SELECT SUM(variacion)
		  INTO _variacion_sum
		  FROM rectrcob
		 WHERE no_tranrec = _no_tranrec_n;

        UPDATE rectrmae
		   SET variacion = _variacion_sum
		 WHERE no_tranrec = _no_tranrec_n;
	 ELSE 	-- Verificar		-- Se modifica para que haga el recalculo de la variacion A.P.M. 24/10/2008
	    IF _tipo_transaccion = 4 OR _tipo_transaccion = 3 THEN	  -->Pago y Disminucion
		    
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
					 WHERE no_tranrec = _no_tranrec_n
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
					 WHERE no_tranrec = _no_tranrec_n
					   AND cod_cobertura = _cod_cobertura;

		                LET _variacion_sum = _variacion_sum + _variacion;
				END FOREACH
			END FOREACH


	        UPDATE rectrmae
			   SET variacion = _variacion_sum
			 WHERE no_tranrec = _no_tranrec_n;
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
					 WHERE no_tranrec = _no_tranrec_n
					   AND cod_cobertura = _cod_cobertura

                    IF _monto_tr IS NULL THEN
						LET _monto_tr = 0;
					END IF

					LET _variacion = _monto_tr;

					UPDATE rectrcob
					   SET variacion = _variacion
					 WHERE no_tranrec = _no_tranrec_n
					   AND cod_cobertura = _cod_cobertura;

		                LET _variacion_sum = _variacion_sum + _variacion;
				END FOREACH
			END FOREACH

	        UPDATE rectrmae
			   SET variacion = _variacion_sum
			 WHERE no_tranrec = _no_tranrec_n;
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
		 WHERE no_tranrec = _no_tranrec_n

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
		   		rollback work;
				RETURN null;
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
					 WHERE no_tranrec     = _no_tranrec_n
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
	    CALL sp_rec56('001', _no_tranrec_n) returning _error, _descripcion;

	    IF _error <> 0 THEN
		   rollback work;
		   RETURN  null;
		END IF
	 END IF


 END
     
 -- Reaseguro a Nivel de Transaccion
 CALL sp_sis58(_no_tranrec_n) returning _error, _descripcion;
 IF _error <> 0 THEN
 	rollback work;
	RETURN  null;
 END IF

	update chqchmae
		set monto     = monto + _monto
	 where no_requis = a_no_requis;

		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		a_no_requis,
		_transaccion_n,
		_monto,
		_numrecla
		);
 
	update tmp_trans_anulada
	   set creado = 1,
	       transaccion_n = _transaccion_n,
		   no_tranrec_n = _no_tranrec_n
     where no_requis = a_no_requis
	   and transaccion = _transaccion;
   
	return _transaccion_n WITH RESUME;
	 
END FOREACH     
	
   
COMMIT WORK;

END
END PROCEDURE
