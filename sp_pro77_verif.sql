-- Cumulos por Ubicacion
-- 
-- Creado    : 25/09/2001 - Autor: Amado Perez 
-- Modificado: 25/09/2001 - Autor: Amado Perez
--
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro77v;

CREATE PROCEDURE "informix".sp_pro77v(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE) 
RETURNING   CHAR(50),  -- Ubicacion
            CHAR(10),
			CHAR(20),
			CHAR(5),
            INT,       -- Cnt. poliza
			DEC(16,2), -- Suma Asegurada
			DEC(16,2), -- Retencion ancon
			INT,
			DEC(16,2), -- 1er excedente
			INT,
			DEC(16,2), -- Facultativo
			INT,
			DEC(16,2), -- Prima suscrita terremoto
			CHAR(50);  -- Compania
--			CHAR(255); -- Filtros

DEFINE v_filtros           CHAR(255);
DEFINE v_ubicacion         CHAR(50);
DEFINE v_cnt_poliza        INT; 
DEFINE v_suma_asegurada    DEC(16,2);
DEFINE v_retencion         DEC(16,2);
DEFINE v_excedente         DEC(16,2);
DEFINE v_facultativo       DEC(16,2);
DEFINE v_prima			   DEC(16,2);
DEFINE v_compania_nombre   CHAR(50);
DEFINE v_nodocumento       CHAR(20);

DEFINE _no_poliza          CHAR(10);
DEFINE _no_unidad          CHAR(5);
DEFINE _cod_ubica          CHAR(3);
DEFINE _suma     		   DEC(16,2);
DEFINE _prima    		   DEC(16,2);
DEFINE _suma_retencion     DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   DEC(16,2);
DEFINE _suma_excedente     DEC(16,2);
DEFINE _porc_partic_suma   DEC(9,6);
DEFINE _porcentaje		   DEC(9,6);
DEFINE _tipo_contrato      SMALLINT;
DEFINE _no_cambio, _es_terremoto SMALLINT;
DEFINE _mal_porc 		   CHAR(5);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

   CREATE TEMP TABLE temp_ubica
         (cod_ubica        CHAR(3),
		  no_poliza        CHAR(10),
		  no_documento	   CHAR(20),
          cantidad         INT,
          suma_asegurada   DEC(16,2),
		  mal_porc         CHAR(5),
		  retencion        DEC(16,2),
		  cant_ret         INT,
          primer_excedente DEC(16,2),
		  cant_exe         INT,
          facultativo      DEC(16,2),
		  cant_fac         INT,
          prima_terremoto  DEC(16,2),
          PRIMARY KEY (no_poliza))
          WITH NO LOG;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

FOREACH
   SELECT d.no_poliza, no_documento
     INTO _no_poliza, v_nodocumento
     FROM emipomae d
    WHERE d.cod_compania = a_compania
	  AND d.cod_ramo IN ('001','003')
      AND (d.vigencia_final >= a_fecha
	   OR d.vigencia_final IS NULL)
      AND (d.fecha_cancelacion IS NULL
       OR d.fecha_cancelacion > a_fecha)
      AND d.fecha_suscripcion <= a_fecha
      AND d.actualizado = 1

	  LET _cant_ret = 0;
	  LET _cant_exe = 0;
	  LET _cant_fac = 0;
	  LET _mal_porc = '';

	FOREACH
		SELECT no_unidad						 
		  INTO _no_unidad
		  FROM emipouni
		 WHERE no_poliza = _no_poliza

	IF a_terremoto = 1 THEN

	 FOREACH
		 SELECT	cod_ubica, 
				suma_terremoto, 
				prima_terremoto 
		   INTO _cod_ubica, 
				_suma, 
				_prima 
		   FROM	emicupol
		  WHERE no_poliza = _no_poliza
		    AND no_unidad = _no_unidad

		LET _suma_retencion = 0;
		LET _suma_excedente = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje = 0;
		LET _es_terremoto = 0;

		FOREACH
		 SELECT	no_cambio
		   INTO	_no_cambio
		   FROM	emireama
		  WHERE	no_poliza       = _no_poliza
		    AND no_unidad       = _no_unidad
			AND (vigencia_final >= a_fecha
			OR vigencia_final IS NULL)
		  ORDER BY no_cambio DESC
				EXIT FOREACH;
		END FOREACH


		FOREACH
			SELECT x.porc_partic_suma,
			       y.tipo_contrato,
				   z.es_terremoto
			  INTO _porc_partic_suma,
			       _tipo_contrato,
				   _es_terremoto
			  FROM emireaco x, reacomae y, reacobre z
			 WHERE x.no_poliza = _no_poliza
			   AND x.no_unidad = _no_unidad
			   AND x.no_cambio = _no_cambio
			   AND y.cod_contrato = x.cod_contrato
			   AND z.cod_cober_reas = x.cod_cober_reas
			   AND z.es_terremoto = 1

            IF _tipo_contrato = 1 THEN
				LET _suma_retencion = _suma * _porc_partic_suma / 100;
				LET _cant_ret = 1;
			ELIF _tipo_contrato = 3 THEN
				LET _suma_facultativo = _suma * _porc_partic_suma / 100;
				LET _cant_fac = 1;
			ELSE
				LET _suma_excedente = _suma * _porc_partic_suma / 100;
				LET _cant_exe = 1;
			END IF
			LET _porcentaje =  _porcentaje + _porc_partic_suma;
		END FOREACH


		IF _es_terremoto = 1 THEN
			IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
			   LET _mal_porc = _no_unidad;
			ELSE
		 --	   LET _mal_porc = '';
			END IF
			BEGIN
	   			ON EXCEPTION IN(-239)
					UPDATE temp_ubica			   
					   SET suma_asegurada   = suma_asegurada   + _suma,
					       mal_porc         = _mal_porc,
					       retencion        = retencion        + _suma_retencion,
						   cant_ret			= _cant_ret,
						   primer_excedente = primer_excedente + _suma_excedente,
						   cant_exe			= _cant_exe,
						   facultativo      = facultativo	   + _suma_facultativo,
						   cant_fac			= _cant_fac,
						   prima_terremoto  = prima_terremoto  + _prima
					 WHERE no_poliza = _no_poliza;
				END EXCEPTION
				INSERT INTO temp_ubica
				   VALUES(_cod_ubica,
				          _no_poliza,
						  v_nodocumento,
				          1,
				          _suma,  
						  _mal_porc,
						  _suma_retencion,
						  _cant_ret,
						  _suma_excedente,
						  _cant_exe,
						  _suma_facultativo,
						  _cant_fac,
						  _prima);
			END
		END IF 
	 END FOREACH
	ELSE
	 FOREACH
		 SELECT	cod_ubica, 
				suma_incendio, 
				prima_incendio 
		   INTO _cod_ubica, 
				_suma, 
				_prima 
		   FROM	emicupol
		  WHERE no_poliza = _no_poliza
		    AND no_unidad = _no_unidad 

		LET _suma_retencion = 0;
		LET _suma_excedente = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje = 0;
		LET _es_terremoto = 1;

		FOREACH
		 SELECT	no_cambio
		   INTO	_no_cambio
		   FROM	emireama
		  WHERE	no_poliza       = _no_poliza
		    AND no_unidad       = _no_unidad
			AND (vigencia_final >= a_fecha
			OR vigencia_final IS NULL)
		  ORDER BY no_cambio DESC
				EXIT FOREACH;
		END FOREACH


		FOREACH
			SELECT x.porc_partic_suma,
			       y.tipo_contrato,
				   z.es_terremoto
			  INTO _porc_partic_suma,
			       _tipo_contrato,
				   _es_terremoto
			  FROM emireaco x, reacomae y, reacobre z
			 WHERE y.cod_contrato = x.cod_contrato
			   AND x.no_poliza = _no_poliza
			   AND x.no_unidad = _no_unidad
			   AND x.no_cambio = _no_cambio
			   AND z.cod_cober_reas = x.cod_cober_reas
			   AND z.es_terremoto = 0

            IF _tipo_contrato = 1 THEN
				LET _suma_retencion = _suma * _porc_partic_suma / 100;
				LET _cant_ret = 1;
			ELIF _tipo_contrato = 3 THEN
				LET _suma_facultativo = _suma * _porc_partic_suma / 100;
				LET _cant_fac = 1;
			ELSE
				LET _suma_excedente = _suma * _porc_partic_suma / 100;
				LET _cant_exe = 1;
			END IF
			LET _porcentaje =  _porcentaje + _porc_partic_suma;
			IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
			   LET _mal_porc = _no_unidad;
			ELSE
			   LET _mal_porc = '';
			END IF
		END FOREACH

		IF _es_terremoto = 0 THEN
			BEGIN
	   			ON EXCEPTION IN(-239)
					UPDATE temp_ubica			   
					   SET suma_asegurada   = suma_asegurada   + _suma,
					       mal_porc         = _mal_porc,
					       retencion        = retencion        + _suma_retencion,
						   cant_ret			= _cant_ret,
						   primer_excedente = primer_excedente + _suma_excedente,
						   cant_exe			= _cant_exe,
						   facultativo      = facultativo	   + _suma_facultativo,
						   cant_fac			= _cant_fac,
						   prima_terremoto  = prima_terremoto  + _prima
					 WHERE no_poliza = _no_poliza;
				END EXCEPTION
				INSERT INTO temp_ubica
				   VALUES(_cod_ubica,
				          _no_poliza,
						  v_nodocumento,
				          1,
				          _suma,  
						  _mal_porc,
						  _suma_retencion,
						  _cant_ret,
						  _suma_excedente,
						  _cant_exe,
						  _suma_facultativo,
						  _cant_fac,
						  _prima);
			END
		END IF
	 END FOREACH
	END IF 

	END FOREACH

END FOREACH

  FOREACH WITH HOLD

{	  SELECT cod_ubica,       
			 SUM(cantidad),        
			 SUM(suma_asegurada),  
			 SUM(retencion), 
			 SUM(cant_ret),      
			 SUM(primer_excedente),
			 SUM(cant_exe),
			 SUM(facultativo),
			 SUM(cant_fac),     
			 SUM(prima_terremoto)
		INTO _cod_ubica,      	  
			 v_cnt_poliza,     
			 v_suma_asegurada, 
			 v_retencion,  
			 _cant_ret,
			 v_excedente,
			 _cant_exe,      
		     v_facultativo,    
			 _cant_fac,
			 v_prima
	   FROM temp_ubica
	  GROUP BY cod_ubica}

	  SELECT cod_ubica, 
	         no_poliza,
	         no_documento,      
			 cantidad,        
			 suma_asegurada,  
			 retencion, 
			 cant_ret,      
			 primer_excedente,
			 cant_exe,
			 facultativo,
			 cant_fac,     
			 prima_terremoto,
			 mal_porc
		INTO _cod_ubica, 
		     _no_poliza,
		     v_nodocumento,     	  
			 v_cnt_poliza,     
			 v_suma_asegurada,
			 v_retencion,  
			 _cant_ret,
			 v_excedente,
			 _cant_exe,      
		     v_facultativo,    
			 _cant_fac,
			 v_prima,
			 _mal_porc
	   FROM temp_ubica
	  WHERE mal_porc <> ''
	  ORDER BY cod_ubica, no_documento


	  SELECT nombre
		INTO v_ubicacion
		FROM emiubica
	   WHERE cod_ubica = _cod_ubica;
      

	RETURN v_ubicacion,
	       _no_poliza,
	       v_nodocumento,
		   _mal_porc,
		   v_cnt_poliza,    	
		   v_suma_asegurada/1000,	
		   v_retencion/1000,  	
		   _cant_ret,	
		   v_excedente/1000,	
		   _cant_exe,      	
		   v_facultativo/1000,   	
		   _cant_fac,	
		   v_prima,	
		   v_compania_nombre	
		   WITH RESUME;

END FOREACH

					 
DROP TABLE temp_ubica;

END PROCEDURE;
