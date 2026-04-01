-- Procedimiento para asegurar de que si es cierre del reclamo calcule bien la reserva
-- 
-- creado: 30/04/2010 - Autor: Armando Moreno M.

--DROP PROCEDURE sp_rec173;
CREATE PROCEDURE "informix".sp_rec173(a_no_tranrec CHAR(10)) 
			RETURNING SMALLINT, VARCHAR(50), SMALLINT;  

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

--SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rwf37.trc";
--trace on;



RETURN 0, "Actualizacion Exitosa", 0;
 
begin

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
		actualizado
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
		_actualizado
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

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

	 END IF

 RETURN 0, "Actualizacion Exitosa", 0;

END
END PROCEDURE