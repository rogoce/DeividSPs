-- Procedimiento para taer los Asegurados por Doctor del Plan "00500" Plan dental
--
-- Creado    : 07/09/2005 - Autor: Amado Perez Mendoza 
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro157;
--DROP TABLE tmp_arreglo;

CREATE PROCEDURE "informix".sp_pro157(a_fecha DATE)
			RETURNING 	CHAR(20),
						DATE,
						DATE,
						CHAR(100),
						CHAR(30),
						CHAR(10),
			 			CHAR(10),
						DATE,
						CHAR(10),
						CHAR(100),
						CHAR(10),
						CHAR(5);
	
DEFINE v_asegurado      CHAR(100);
DEFINE v_cedula         CHAR(30);
DEFINE v_no_documento   CHAR(20);
DEFINE v_vigencia_inic  DATE;
DEFINE v_vigencia_final DATE;
DEFINE v_telefono1      CHAR(10);
DEFINE v_telefono2	    CHAR(10);
DEFINE v_fecha_aniversario DATE;
DEFINE v_cod_doctor     CHAR(10);
DEFINE v_doctor         CHAR(100);
DEFINE v_no_unidad      CHAR(5);

DEFINE _no_poliza         CHAR(10);
DEFINE _cod_asegurado     CHAR(10);
DEFINE _fecha_cancelacion DATE;
DEFINE _fecha_emision     DATE;

SET ISOLATION TO DIRTY READ;

-- Crear la tabla


-- SET DEBUG FILE TO "sp_pro44.trc";      
-- TRACE ON;                                                                     

FOREACH
	SELECT no_poliza,
	       no_documento,
		   fecha_cancelacion
	  INTO _no_poliza,
	       v_no_documento,
		   _fecha_cancelacion
	  FROM emipomae
	 WHERE vigencia_inic < a_fecha
	   AND vigencia_final >= a_fecha
       AND fecha_suscripcion <= a_fecha
	   AND actualizado = 1
	   AND cod_ramo = "018"
 
    LET _fecha_emision = null;

	IF _fecha_cancelacion <= a_fecha THEN
		FOREACH
			SELECT fecha_emision
			  INTO _fecha_emision
			  FROM endedmae
		   	 WHERE no_poliza = _no_poliza
		   	   AND cod_endomov = '002'
		   	   AND vigencia_inic = _fecha_cancelacion
		END FOREACH

		IF  _fecha_emision <= a_fecha THEN
			CONTINUE FOREACH;
		END IF
	END IF

    FOREACH	WITH HOLD
		SELECT cod_asegurado,
		       vigencia_inic,
			   vigencia_final,
			   cod_doctor,
			   no_unidad
          INTO _cod_asegurado,
		       v_vigencia_inic,
			   v_vigencia_final,
			   v_cod_doctor,
			   v_no_unidad
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
		   AND activo = 1
		   AND cod_producto = "00500"

	    SELECT nombre,
		       cedula,
			   telefono1,
			   telefono2,
			   fecha_aniversario
		  INTO v_asegurado,
		       v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fecha_aniversario
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

	    SELECT nombre
		  INTO v_doctor
		  FROM cliclien
		 WHERE cod_cliente = v_cod_doctor;

		RETURN v_no_documento,
			   v_vigencia_inic,
			   v_vigencia_final,
		       v_asegurado,
			   v_cedula,
			   v_telefono1,
			   v_telefono2,
			   v_fecha_aniversario,
			   v_cod_doctor,
			   v_doctor,
			   _no_poliza,
			   v_no_unidad    
			   WITH RESUME; 
	END FOREACH
END FOREACH


END PROCEDURE
