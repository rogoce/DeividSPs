-- Cumulos por Ubicacion
-- 
-- Creado    : 25/09/2001 - Autor: Amado Perez 
-- Modificado: 25/09/2001 - Autor: Amado Perez
--
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro2c;

CREATE PROCEDURE "informix".sp_pro2c(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE, a_poliza CHAR(10), a_endoso CHAR(5)) 

DEFINE v_filtros           CHAR(255);
DEFINE v_ubicacion         CHAR(50);
DEFINE v_cnt_poliza        INT; 
DEFINE v_suma_asegurada    DEC(16,2);
DEFINE v_retencion         DEC(16,2);
DEFINE v_prima_retencion   DEC(16,2);
DEFINE v_excedente         DEC(16,2);
DEFINE v_prima_excedente   DEC(16,2);
DEFINE v_facultativo       DEC(16,2);
DEFINE v_prima_facultativo DEC(16,2);
DEFINE v_prima			   DEC(16,2);
DEFINE v_compania_nombre   CHAR(50);
DEFINE v_nodocumento       CHAR(20);

DEFINE _no_poliza          CHAR(10);
DEFINE _no_unidad          CHAR(5);
DEFINE _cod_ubica          CHAR(3);
DEFINE _suma     		   DEC(16,2);
DEFINE _prima    		   DEC(16,2);
DEFINE _suma_retencion     DEC(16,2);
DEFINE _prima_retencion    DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   DEC(16,2);
DEFINE _prima_facultativo  DEC(16,2);
DEFINE _suma_excedente     DEC(16,2);
DEFINE _prima_excedente    DEC(16,2);
DEFINE _porc_partic_suma   DEC(9,6);
DEFINE _porc_partic_prima  DEC(9,6);
DEFINE _porcentaje		   DEC(9,6);
DEFINE _tipo_contrato      SMALLINT;
DEFINE _no_cambio, _es_terremoto SMALLINT;
DEFINE _mal_porc 		   CHAR(5);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";


-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 


LET v_suma_asegurada = 0; 
LET v_retencion = 0; 
LET v_prima_retencion = 0; 
LET v_excedente = 0; 
LET v_prima_excedente = 0;
LET v_facultativo = 0;    
LET v_prima_facultativo = 0;
LET v_prima	= 0;
LET _no_poliza = null;
LET _cant_exe = 0;
 

	 FOREACH

		 SELECT	no_unidad,
		        suma_incendio, 
				prima_incendio,
				cod_ubica 
		   INTO _no_unidad,
		        _suma, 
				_prima,
				_cod_ubica 
		   FROM	endcuend
		  WHERE no_poliza = a_poliza
			AND no_endoso = a_endoso

         SELECT no_documento
		   INTO v_nodocumento
		   FROM emipomae
		  WHERE no_poliza = a_poliza;

		LET _suma_retencion    = 0;
		LET _prima_retencion   = 0;
		LET _suma_excedente    = 0;
		LET _prima_excedente   = 0;
		LET _suma_facultativo  = 0; 
		LET _prima_facultativo = 0; 
		LET _porcentaje = 0;
		LET _es_terremoto = 0;
		LET _no_cambio = null;
--		LET _no_poliza = '';

		FOREACH
		 SELECT	no_cambio
		   INTO	_no_cambio
		   FROM	emireama
		  WHERE	no_poliza       = a_poliza
		    AND no_unidad       = _no_unidad
			AND vigencia_inic   <= a_fecha
			AND (vigencia_final >= a_fecha
			OR vigencia_final IS NULL)
		  ORDER BY no_cambio DESC
				EXIT FOREACH;
		END FOREACH

		IF _no_cambio IS NULL THEN
		   LET _no_cambio = 0;
		END IF

		FOREACH
			SELECT x.porc_partic_suma,
			       x.porc_partic_prima,
			       y.tipo_contrato,
				   z.es_terremoto
			  INTO _porc_partic_suma,
			       _porc_partic_prima,
			       _tipo_contrato,
				   _es_terremoto
			  FROM emireaco x, reacomae y, reacobre z
			 WHERE y.cod_contrato = x.cod_contrato
			   AND x.no_poliza = a_poliza
			   AND x.no_unidad = _no_unidad
			   AND x.no_cambio = _no_cambio
			   AND z.cod_cober_reas = x.cod_cober_reas
			   AND z.es_terremoto = 0
  --			   AND y.tipo_contrato not in (1,3)

            IF _tipo_contrato = 1 THEN
				LET _suma_retencion = _suma * _porc_partic_suma / 100;
				LET _prima_retencion = _prima * _porc_partic_prima / 100;
			ELIF _tipo_contrato = 3 THEN
				LET _suma_facultativo = _suma * _porc_partic_suma / 100;
				LET _prima_facultativo = _prima * _porc_partic_prima / 100;
			ELSE
				LET _suma_excedente = _suma * _porc_partic_suma / 100;
				LET _prima_excedente = _prima * _porc_partic_prima / 100;
				LET _cant_exe = 1;
			END IF
		END FOREACH

		IF _es_terremoto = 0 THEN
			BEGIN
	   			ON EXCEPTION IN(-239)
					UPDATE temp_ubica			   
					   SET suma_asegurada     = suma_asegurada   + _suma,
					       retencion          = retencion        + _suma_retencion,
						   retencion_prima    = retencion_prima  + _prima_retencion,
						   primer_excedente   = primer_excedente   + _suma_excedente,
						   cnt_excedente      = _cant_exe,
						   primer_exced_prima = primer_exced_prima + _prima_excedente,
						   facultativo        = facultativo	      + _suma_facultativo,
						   facultativo_prima  = facultativo_prima + _prima_facultativo,
						   prima_terremoto    = prima_terremoto  + _prima
					 WHERE no_poliza = a_poliza;
				END EXCEPTION
				INSERT INTO temp_ubica
				   VALUES(_cod_ubica,
				   		  a_poliza,
						  v_nodocumento,
				          _suma,  
						  _suma_retencion,
						  _prima_retencion,
						  _suma_excedente,
						  _cant_exe,
						  _prima_excedente,
						  _suma_facultativo,
						  _prima_facultativo,
						  _prima);

			END
		END IF
	 END FOREACH

 --	END FOREACH


END PROCEDURE;
