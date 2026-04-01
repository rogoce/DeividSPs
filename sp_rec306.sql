-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec306;

CREATE PROCEDURE informix.sp_rec306() 
RETURNING   CHAR(20) as reclamo,
			VARCHAR(100) as asegurado,
			DATE as fecha_siniestro,
			DATE as fecha_notificacion,
			DECIMAL(16,2) as reserva_actual,
			DECIMAL(16,2) as reserva_inicial,
			CHAR(20) as poliza,
			DATE as vigencia_inic,
			DATE as vigencia_final,
			CHAR(1) as nueva_renovada,
			VARCHAR(50) as cobertura,
			VARCHAR(50) as sucursal,
			VARCHAR(50) as ajustador,
			VARCHAR(50) as corredor,
			DATE as fecha_suscripcion;
				   		
DEFINE _no_reclamo     CHAR(10);
DEFINE _numrecla       CHAR(20);
DEFINE _cod_asegurado  CHAR(10);
DEFINE _no_documento   CHAR(20);
DEFINE _no_poliza	   CHAR(10); 	
DEFINE _fecha_siniestro DATE;
DEFINE _fecha_notificacion DATE;
DEFINE _ajust_interno	CHAR(3);	
DEFINE _cod_cobertura CHAR(5);
DEFINE _reserva_inicial DEC(16,2); 
DEFINE _reserva_actual  DEC(16,2); 
DEFINE _pagos           DEC(16,2);
DEFINE _cobertura       VARCHAR(50);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final  DATE;
DEFINE _nueva_renov     char(1);
DEFINE _fecha_suscripcion DATE;
DEFINE _sucursal_origen CHAR(3);
DEFINE _cod_agente      CHAR(5);
DEFINE _corredor        VARCHAR(50);
DEFINE _asegurado       VARCHAR(100);
DEFINE _sucursal        VARCHAR(50);
DEFINE _ajustador       VARCHAR(50);

FOREACH
 SELECT no_reclamo,
        numrecla,
        cod_asegurado,
        no_documento,
        no_poliza,		
        fecha_siniestro,	
        fecha_documento,
        ajust_interno		
   INTO	_no_reclamo,
        _numrecla,
        _cod_asegurado,
        _no_documento,
        _no_poliza,		
        _fecha_siniestro,	
        _fecha_notificacion,
        _ajust_interno		
   FROM recrcmae
  WHERE fecha_reclamo >= '01/01/2019'
    AND fecha_reclamo <= '31/12/2019'
    AND perd_total = 1	
	
	FOREACH
		SELECT cod_cobertura, 
		       reserva_inicial, 
			   reserva_actual, 
			   pagos
		  INTO _cod_cobertura,
		       _reserva_inicial, 
			   _reserva_actual, 
			   _pagos
		  FROM recrccob
		 WHERE no_reclamo = _no_reclamo
		   and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'ROBO%' OR nombre like 'COLI%')
	    EXIT FOREACH;
	END FOREACH
	
	SELECT nombre
	  INTO _cobertura
	  FROM prdcober
	 WHERE cod_cobertura = _cod_cobertura;
	
	SELECT vigencia_inic,
	       vigencia_final,
		   nueva_renov,
		   fecha_suscripcion,
	       sucursal_origen
      INTO _vigencia_inic,
	       _vigencia_final,
		   _nueva_renov,
		   _fecha_suscripcion,
	       _sucursal_origen
      FROM emipomae
     WHERE no_poliza = _no_poliza;
   
   FOREACH
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza	 
	EXIT FOREACH;
   END FOREACH
   
   SELECT nombre
     INTO _corredor 
	 FROM agtagent
	WHERE cod_agente = _cod_agente;
	
  SELECT nombre 
    INTO _asegurado
	FROM cliclien
   WHERE cod_cliente = _cod_asegurado;
   
  SELECT descripcion
    INTO _sucursal
	FROM insagen
   WHERE codigo_compania = '001'
     AND codigo_agencia = _sucursal_origen;
   
  SELECT nombre
    INTO _ajustador
	FROM recajust
   WHERE cod_ajustador = _ajust_interno;
   
 
	RETURN _numrecla,
	       _asegurado,
		   _fecha_siniestro,
		   _fecha_notificacion,
		   _reserva_actual,
		   _reserva_inicial,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _nueva_renov,
		   _cobertura,
		   _sucursal,
		   _ajustador,
	       _corredor,
		   _fecha_suscripcion
	WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;
END PROCEDURE;