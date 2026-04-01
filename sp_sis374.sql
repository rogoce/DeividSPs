-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 03/04/2003 - Autor: Amado Perez  

drop procedure sp_sis374;

create procedure "informix".sp_sis374() 
	RETURNING CHAR(10),
	          INT,
	          CHAR(100),
			  DATE,
			  DATE,
			  CHAR(3),
			  CHAR(50),
			  CHAR(3),
			  CHAR(50),
			  DATE,
			  CHAR(8);
--}
DEFINE v_cotizacion     CHAR(10);
DEFINE v_fecha          DATE;
DEFINE v_usuario        CHAR(8);
DEFINE v_vigencia_inic  DATE;
DEFINE v_vigencia_final DATE;
DEFINE v_ramo           CHAR(50);
DEFINE v_subramo		CHAR(50);
DEFINE v_asegurado		CHAR(100);
DEFINE _li_cotizacion   INT;
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_contratante CHAR(10);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;

FOREACH WITH HOLD
	SELECT a.no_cotiza,
	       a.date_added,
		   a.user_added
	  INTO _li_cotizacion,
	 	   v_fecha,
		   v_usuario
	  FROM wf_cotizallave a, wf_cotizacion b
	 WHERE b.nrocotizacion = a.no_cotiza
	   AND (b.userautoriza IS NULL
	   OR b.userautoriza = "")
	   AND a.actualizado = 0

	LET v_cotizacion = _li_cotizacion;
	LET v_cotizacion = TRIM(v_cotizacion);
	LET _no_poliza = null;

	SELECT no_poliza,
	       cod_contratante,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   cod_subramo
	  INTO _no_poliza,      
		   _cod_contratante,
		   v_vigencia_inic, 
		   v_vigencia_final,
		   _cod_ramo,       
		   _cod_subramo    
	  FROM emipomae
	 WHERE cotizacion = v_cotizacion;

	 IF _no_poliza IS NULL OR _no_poliza = '' THEN
	 	CONTINUE FOREACH;
	 END IF

    SELECT nombre
	  INTO v_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

    SELECT nombre
	  INTO v_subramo
	  FROM prdsubra
	 WHERE cod_ramo = _cod_ramo
	   AND cod_subramo = _cod_subramo;

    SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	RETURN _no_poliza,
	       _li_cotizacion,
		   v_asegurado,
		   v_vigencia_inic,
		   v_vigencia_final,
		   _cod_ramo,
		   v_ramo,
		   _cod_subramo,
		   v_subramo,
		   v_fecha,
		   v_usuario
		   WITH RESUME;

END FOREACH
end procedure;
