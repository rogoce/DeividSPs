-- Procedimiento Para Aprobar la actualizacion de una poliza que fueron cotizadas en workflow
-- 
-- Creado    : 25/03/2003 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis377;

CREATE PROCEDURE "informix".sp_sis377(a_usuario CHAR(8) DEFAULT "*", a_agencia CHAR(3) DEFAULT "*") 
RETURNING CHAR(1),
          INTEGER,
		  CHAR(3),
		  CHAR(50),
		  CHAR(3),
		  CHAR(50),
		  CHAR(100),
		  DATE,
		  DATE,
		  DATE,
		  CHAR(8),
		  CHAR(20),
		  CHAR(10),
		  CHAR(5),
		  SMALLINT,
		  VARCHAR(20),
		  VARCHAR(250);

DEFINE _cod_cliente     CHAR(10);
DEFINE _nrocotizacion   CHAR(10);

DEFINE v_emitirpolizajefepr CHAR(1);
DEFINE v_nrocotizacion      INTEGER;
DEFINE v_ramo				CHAR(50);
DEFINE v_subramo			CHAR(50);
DEFINE v_nombre				CHAR(100);
DEFINE v_vigencia_inic  	DATE;
DEFINE v_vigencia_final		DATE;
DEFINE v_date_added			DATE;
DEFINE v_user_added			CHAR(8);
DEFINE v_documento          CHAR(20);
DEFINE v_no_poliza			CHAR(10);
DEFINE v_no_endoso          CHAR(5);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_cod_subramo		CHAR(3);
DEFINE v_por_certificado	SMALLINT;
DEFINE v_userautoriza       VARCHAR(20);
DEFINE v_obsjefeprod       	VARCHAR(250);
DEFINE _agencia				CHAR(3);
DEFINE _agencia2			CHAR(3);
DEFINE _usuario             CHAR(8);

define _cantidad			integer;

--SET DEBUG FILE TO "sp_sis377.trc";  
--TRACE ON;                                                                 

SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD
  SELECT a.nrocotizacion,   
         a.ramo,   																   
         a.subramo,   
         a.emitirpolizajefepr,
         a.userautoriza,
         a.obsjefeprod   
    INTO v_nrocotizacion,   
    	 v_ramo,   
    	 v_subramo,   
    	 v_emitirpolizajefepr,
		 v_userautoriza,
		 v_obsjefeprod
    FROM wf_cotizacion a, wf_db_autos b  
   WHERE a.nrocotizacion = b.nrocotizacion
     AND a.emitirpolizajefepr <> '1'
	 AND a.emitirpolizajefepr <> '3'
	 --AND b.cod_sucursal matches a_agencia

{  IF a_usuario <> "*" THEN
  	SELECT TRIM(codigo_agencia)
	  INTO _agencia
	  FROM insusco
	 WHERE usuario = a_usuario;

    SELECT TRIM(usuario)
	  INTO _usuario
	  FROM insuser
	 WHERE windows_user = v_userautoriza;

  	SELECT TRIM(codigo_agencia)
	  INTO _agencia2
	  FROM insusco
	 WHERE usuario = _usuario;

    IF TRIM(_agencia) <> TRIM(_agencia2) THEN
		CONTINUE FOREACH;
	END IF

  END IF
 }
  LET _nrocotizacion = v_nrocotizacion;
  LET v_no_endoso    = '00000';

  IF v_emitirpolizajefepr = '' THEN
	LET v_emitirpolizajefepr = NULL;
  END IF

  {SELECT count(*)
	INTO _cantidad
	FROM wf_db_autos
   WHERE nrocotizacion = v_nrocotizacion;

	if _cantidad > 1 then
		continue foreach;
	end if
  }
  FOREACH
	  SELECT nropoliza
		INTO v_documento
		FROM wf_db_autos
	   WHERE nrocotizacion = v_nrocotizacion
	   EXIT FOREACH;
  END FOREACH

  SELECT date_added,
		 user_added
	INTO v_date_added,
		 v_user_added
	FROM wf_cotizallave
   WHERE no_cotiza = v_nrocotizacion;

     LET _cod_cliente = NULL;
--foreach
  SELECT cod_contratante,
         vigencia_inic, 
		 vigencia_final,
		 no_poliza,
		 cod_ramo,
		 cod_subramo,
		 por_certificado   
    INTO _cod_cliente,
		 v_vigencia_inic, 
		 v_vigencia_final,
		 v_no_poliza,
		 v_cod_ramo,
		 v_cod_subramo,
		 v_por_certificado   
	FROM emipomae
   WHERE cotizacion = _nrocotizacion
     and actualizado = 0;			   -- 24/02/2012 enviaba error 284 : Henry
--	exit foreach;
--end foreach

	  IF _cod_cliente IS NULL or _cod_cliente = "" THEN

		 SELECT no_poliza,
		        no_endoso,
				vigencia_inic, 
				vigencia_final
		   INTO v_no_poliza,
		        v_no_endoso,
				v_vigencia_inic, 
				v_vigencia_final
		   FROM endedmae
		  WHERE cotizacion = _nrocotizacion;

	     SELECT cod_contratante,
				cod_ramo,
				cod_subramo,
				por_certificado
	       INTO _cod_cliente,
				v_cod_ramo,
				v_cod_subramo,
				v_por_certificado
		   FROM emipomae
	      WHERE no_poliza = v_no_poliza;

	  	 IF _cod_cliente IS NULL or _cod_cliente = "" THEN
		 	CONTINUE FOREACH;
		 END IF

	  END IF

	  SELECT nombre
		INTO v_nombre
		FROM cliclien
	   WHERE cod_cliente = _cod_cliente;

	RETURN	v_emitirpolizajefepr,
			v_nrocotizacion,
			v_cod_ramo,
			v_ramo,   
			v_cod_subramo,   
			v_subramo,
			v_nombre,
			v_vigencia_inic, 
			v_vigencia_final,
			v_date_added,
			v_user_added,
			v_documento,
			v_no_poliza,
			v_no_endoso,
			v_por_certificado,
			TRIM(v_userautoriza),
			TRIM(v_obsjefeprod)
		    WITH resume;

	END FOREACH

END PROCEDURE;
