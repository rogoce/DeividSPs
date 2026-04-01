
DROP PROCEDURE sp_rec02g;

CREATE PROCEDURE "informix".sp_rec02g(a_compania CHAR(3),a_agencia CHAR(3),a_periodo CHAR(7),a_sucursal	CHAR(255) DEFAULT "*", a_ajustador CHAR(255) DEFAULT "*", a_ramo CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*") RETURNING CHAR(18),
			CHAR(100),
			CHAR(20),
			DATE,
			DATE,
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			CHAR(50),
			CHAR(50),
			CHAR(255),
			CHAR(3),
			CHAR(50),CHAR(1),SMALLINT,CHAR(20),CHAR(3),VARCHAR(50),DECIMAL(16,2),VARCHAR(50);	

DEFINE v_filtros         CHAR(255);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_cliente_nombre  CHAR(100);				 
DEFINE v_doc_poliza      CHAR(20);
DEFINE v_fecha_siniestro DATE;
DEFINE v_ultima_fecha    DATE;
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_ajustador_int	 CHAR(3);
DEFINE v_ajustador_desc	 CHAR(50);

DEFINE _nombre_ajust    CHAR(50);
DEFINE _ajust_interno   CHAR(50);
DEFINE _no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _estatus_reclamo	  CHAR(1);
DEFINE _estatus_audiencia SMALLINT;
DEFINE _cod_abogado		  CHAR(3);
DEFINE _estat_aud         CHAR(20);
DEFINE _abogado			  VARCHAR(50);
DEFINE _monto 			  DECIMAL(16,2);
DEFINE _cod_tipotran	  CHAR(3);
DEFINE _tipotran          VARCHAR(50);  
DEFINE _cant 			  INTEGER;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

CALL sp_rec02(
a_compania, 
a_agencia, 
a_periodo,
a_sucursal,
a_ajustador,
'*',
a_ramo,
a_agente
) RETURNING v_filtros; 


SET ISOLATION TO DIRTY READ;
FOREACH 
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_bruto, 		
 		pagado_neto, 
	    reserva_bruto, 	
	    reserva_neto,		
	    incurrido_bruto,	
	    incurrido_neto,
		cod_ramo,		
		periodo,
		numrecla,
		ultima_fecha
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		v_ultima_fecha
   FROM tmp_sinis 
  WHERE seleccionado = 1
  ORDER BY cod_ramo,numrecla

	SELECT cod_reclamante, fecha_siniestro, ajust_interno, estatus_reclamo, estatus_audiencia, cod_abogado
	  INTO _cod_cliente,   v_fecha_siniestro, v_ajustador_int, _estatus_reclamo, _estatus_audiencia, _cod_abogado 
	  FROM recrcmae
	 WHERE no_reclamo  = _no_reclamo
	   AND actualizado = 1;
	   
  SELECT recajust.nombre
	INTO v_ajustador_desc
    FROM recajust  
   WHERE recajust.cod_ajustador =  v_ajustador_int  ;


	IF _estatus_audiencia = 0 THEN
	   LET _estat_aud = "Perdido";
	ELIF _estatus_audiencia = 1 THEN
	   LET _estat_aud = "Ganado";
	ELIF _estatus_audiencia = 2 THEN
	   LET _estat_aud = "Por definir";
	ELIF _estatus_audiencia = 3 THEN
	   LET _estat_aud = "Proceso Penal";
	ELIF _estatus_audiencia = 4 THEN
	   LET _estat_aud = "Proceso Civil";
	ELIF _estatus_audiencia = 5 THEN
	   LET _estat_aud = "Apelacion";
	ELIF _estatus_audiencia = 6 THEN
	   LET _estat_aud = "Apelacion";
	ELIF _estatus_audiencia = 7 THEN
	   LET _estat_aud = "FUT - Ganado";
	ELIF _estatus_audiencia = 8 THEN
	   LET _estat_aud = "FUT - Responsable";
	ELSE
	   LET _estat_aud = NULL;
	END IF

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

    SELECT nombre_abogado
	  INTO _abogado
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado;



--    FOREACH WITH HOLD
--	    SELECT variacion, cod_tipotran
--		  INTO _monto, _cod_tipotran
--		  FROM rectrmae
--		 WHERE no_reclamo = _no_reclamo
--		   AND variacion > 0  AND cod_tipotran <> "001"
		LET _cant = 0;

	    SELECT count(*)
		  INTO _cant
		  FROM rectrmae
		 WHERE no_reclamo = _no_reclamo
		   AND variacion > 0  AND cod_tipotran = "001";
		IF 	_cant = 0 THEN
			continue foreach;
		END IF

--	    SELECT nombre
--		  INTO _tipotran
--		  FROM rectitra
--		 WHERE cod_tipotran = _cod_tipotran;

		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 	
		 	   v_doc_poliza,		
		 	   v_fecha_siniestro, 
			   v_ultima_fecha,
			   v_pagado_bruto,		
			   v_pagado_neto,	 	
			   v_reserva_bruto,  	
			   v_reserva_neto,
			   v_incurrido_bruto,	
			   v_incurrido_neto,	
			   v_ramo_nombre,
			   v_compania_nombre,
			   v_filtros,
			   v_ajustador_int,
			   v_ajustador_desc,
			   _estatus_reclamo,
			   _estatus_audiencia,
			   _estat_aud,
			   _cod_abogado,
			   _abogado,
			   0, --_monto,
			   NULL --_tipotran
			   WITH RESUME;
--	END FOREACH
END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE                                                        