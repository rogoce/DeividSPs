-- Cumulos por Ubicacion
-- 
-- Creado    : 25/09/2001 - Autor: Amado Perez 
-- Modificado: 25/09/2001 - Autor: Amado Perez
--
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro77i;

CREATE PROCEDURE "informix".sp_pro77i(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE, a_fecha2 DATE) 
RETURNING   CHAR(50),  -- Ubicacion
            CHAR(50),  -- Ramo
            CHAR(50),  -- Subramo
            CHAR(20),  -- Documento
			DATE,
			CHAR(100), -- Asegurado
            INT,       -- Cnt. poliza
			DEC(16,2), -- Suma Asegurada
			DEC(16,2), -- Retencion ancon
			INT,
			DEC(16,2), -- 1er excedente
			INT,
			DEC(16,2), -- Facultativo
			INT,
			DEC(16,2), -- Prima suscrita terremoto
			CHAR(50),  -- Compania
			char(5);   -- unidad				

DEFINE v_filtros           CHAR(255);
DEFINE v_ubicacion         CHAR(50);
DEFINE v_cnt_poliza        INT; 
DEFINE v_suma_asegurada    DEC(16,2);
DEFINE v_retencion         DEC(16,2);
DEFINE v_excedente         DEC(16,2);
DEFINE v_facultativo       DEC(16,2);
DEFINE v_prima			   DEC(16,2);
DEFINE v_compania_nombre, v_ramo, v_subramo CHAR(50);
DEFINE v_nodocumento       CHAR(20);
DEFINE v_vigencia_final    DATE;
DEFINE v_asegurado         CHAR(100);
DEFINE _no_poliza          CHAR(10);
DEFINE _cod_contratante    CHAR(10);
DEFINE _no_unidad, _no_endoso CHAR(5);
DEFINE _cod_ubica, _cod_ramo, _cod_subramo  CHAR(3);
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
DEFINE _mes_contable       CHAR(2);
DEFINE _ano_contable       CHAR(4);
DEFINE _periodo            CHAR(7);
DEFINE _fecha_emision, _fecha_cancelacion DATE;
DEFINE _orden			   smallint;
DEFINE _prima_cobrada      DEC(16,2);
define _cod_endomov			char(3);
define _suma_aseg_total     dec(16,2);
define _prima_porcion       dec(16,2);
define _prima_cobrada_uni   dec(16,2);
define _prima_unidad        dec(16,2);
define _f_emision_unidad    date;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03c.trc";

   CREATE TEMP TABLE temp_ubica
         (cod_ubica        CHAR(3),
		  cod_ramo         CHAR(3),
		  cod_subramo      CHAR(3),
		  cod_contratante  CHAR(10),
		  no_poliza        CHAR(10),
		  vigencia_final   DATE,
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
		  orden            smallint,
		  no_unidad        char(5),   
		  suma_aseg_total  dec(16,2),
		  primary key (no_poliza,no_unidad)) with no log;


CREATE INDEX idx1_temp_ubica ON temp_ubica(orden);

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_pro77.trc";
--trace on;

LET  v_compania_nombre = sp_sis01(a_compania); 

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

FOREACH
   SELECT d.no_poliza, e.no_endoso, d.no_documento, d.cod_contratante, d.cod_ramo, d.cod_subramo, d.vigencia_final,  d.fecha_cancelacion
     INTO _no_poliza, _no_endoso, v_nodocumento, _cod_contratante, _cod_ramo, _cod_subramo, v_vigencia_final, _fecha_cancelacion
     FROM emipomae d, endedmae e
    WHERE d.cod_compania = a_compania
	  AND d.cod_ramo IN ('001','003')
      AND (d.vigencia_final >= a_fecha
	   OR d.vigencia_final IS NULL)
      AND d.fecha_suscripcion <= a_fecha
	  AND d.vigencia_inic < a_fecha
      AND d.actualizado = 1
	  AND e.no_poliza = d.no_poliza
	  --AND e.periodo <= _periodo   
	  --AND e.fecha_emision <= a_fecha
      AND e.actualizado = 1

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

	let _prima_cobrada = 0;
	
	let _prima_cobrada = sp_sis424(v_nodocumento, a_fecha2, a_fecha); -->buscando la prima cobrada en terremoto

	if  _prima_cobrada <= 0 then
		continue foreach;
	end if
	  
	  
	  LET _cant_ret = 0;
	  LET _cant_exe = 0;
	  LET _cant_fac = 0;
	  LET _mal_porc = '';
	  
	if  _documento <> v_nodocumento then
		if _documento <> '' then
			update temp_ubica			   
			   set suma_aseg_total =_suma_aseg_total 
			 where no_documento = _documento;
		 end if		
		let _suma_aseg_total = 0.00;
		let _documento = v_nodocumento;
	end if
	-- trace on;
	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni 
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso 
		   
		let _prima_cobrada_uni = 0.00;		
		
		-- HGIRON: 10/08/2017, no se toma en cuenta los casos donde hay endosos de eliminación de la unidad
			let _f_emision_unidad = null; 
			let _cod_endomov = '000';
			foreach 
				select e.fecha_emision,
					   e.cod_endomov
				  into _f_emision_unidad,
					   _cod_endomov
				  from endedmae e, endeduni u
				 where e.no_poliza = _no_poliza
		           and e.no_endoso = _no_endoso	   
				   and u.no_unidad = _no_unidad 					   
		           and e.no_poliza = u.no_poliza
				   and e.no_endoso = u.no_endoso
				   and e.cod_endomov in ('005','004')
				   and e.actualizado = 1
				 order by 1 desc
				exit foreach;					   
			end foreach
			
			if  _f_emision_unidad <= a_fecha and _cod_endomov = '005' then
				continue foreach;
			end if	-- hasta aqui	
			
			

		IF a_terremoto = 1 THEN

		 FOREACH
			 SELECT	cod_ubica, 
					no_unidad,
					suma_terremoto, 
					prima_terremoto 
			   INTO _cod_ubica, 
					_no_unidad,
					_suma, 
					_prima 
			   FROM	endcuend
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad 	

			LET _suma_retencion = 0;
			LET _suma_excedente = 0;
			LET _suma_facultativo = 0; 
			LET _porcentaje = 0;
			LET _es_terremoto = 0;
			let _suma_aseg_total  = _suma_aseg_total + _suma;				
				
			FOREACH
			 SELECT	no_cambio
			   INTO	_no_cambio
			   FROM	emireama
			  WHERE	no_poliza       = _no_poliza
				AND no_unidad       = _no_unidad
				AND vigencia_inic   <= a_fecha
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
				IF _porcentaje > 100.5 or _porcentaje < 99.5 THEN
				   LET _mal_porc = _no_unidad;
				ELSE
				   LET _mal_porc = '';
				END IF
					--hg_ini
					let _prima_porcion = 0.00;
					let _prima_porcion = _prima_cobrada * (_porc_partic_suma / 100); --(_porc_cober_reas / 100) *
					let _prima_cobrada_uni = _prima_cobrada_uni + _prima_porcion;

					if _prima_cobrada_uni is null then
						let _prima_cobrada_uni = 0;
					end if										
					--hg_fin				
			END FOREACH


			IF _es_terremoto = 1 THEN
				let _orden = sp_sis184(_cod_ubica);
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
							   cant_fac			= _cant_fac
							--   prima_terremoto  = prima_terremoto  + _prima
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
							   
					END EXCEPTION
					INSERT INTO temp_ubica
					   VALUES(_cod_ubica,
							  _cod_ramo,
							  _cod_subramo,
							  _cod_contratante,
							  _no_poliza,
							  v_vigencia_final,
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
							  _prima_cobrada,
							  _orden,
							  _no_unidad);
				END
			END IF 
		 END FOREACH
		ELSE
		 FOREACH
			 SELECT	cod_ubica, 
					no_unidad,
					suma_incendio, 
					prima_incendio 
			   INTO _cod_ubica, 
					_no_unidad,
					_suma, 
					_prima 
			   FROM	endcuend
			  where no_poliza = _no_poliza
				and no_endoso = _no_endoso
				and no_unidad = _no_unidad 

			LET _suma_retencion = 0;
			LET _suma_excedente = 0;
			LET _suma_facultativo = 0; 
			LET _porcentaje = 0;
			LET _es_terremoto = 1;
			let _suma_aseg_total  = _suma_aseg_total + _suma;			

			FOREACH
			 SELECT	no_cambio
			   INTO	_no_cambio
			   FROM	emireama
			  WHERE	no_poliza       = _no_poliza
				AND no_unidad       = _no_unidad
				AND vigencia_inic   <= a_fecha
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
				
				--hg_ini
				let _prima_porcion = 0.00;
				let _prima_porcion = _prima_cobrada * (_porc_partic_suma / 100); --(_porc_cober_reas / 100) *
				let _prima_cobrada_uni = _prima_cobrada_uni + _prima_porcion;
			   
				if _prima_cobrada_uni is null then
					let _prima_cobrada_uni = 0;
				end if
				--hg_fin													
			END FOREACH

			IF _es_terremoto = 0 THEN
				let _orden = sp_sis184(_cod_ubica);
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
							   cant_fac			= _cant_fac
							  -- prima_terremoto  = prima_terremoto  + _prima
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;	
					END EXCEPTION
					INSERT INTO temp_ubica
					   VALUES(_cod_ubica,
							  _cod_ramo,
							  _cod_subramo,
							  _cod_contratante,
							  _no_poliza,
							  v_vigencia_final,
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
							  _prima_cobrada_uni, --_prima_cobrada,
							  _orden,
							  _no_unidad,
							  0);
				END
			END IF
		 END FOREACH
		END IF 
	END FOREACH
END FOREACH

if  _documento = v_nodocumento then
	if _documento <> '' then
		update temp_ubica			   
		   set suma_aseg_total =_suma_aseg_total 
		 where no_documento = _documento;
	 end if		
	let _suma_aseg_total = 0.00;
	let _documento = v_nodocumento;
end if	
  FOREACH WITH HOLD

	  SELECT cod_ubica, 
	         cod_ramo,
			 cod_subramo,
	         cod_contratante,
	         no_poliza,
			 vigencia_final,
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
			 orden,
			 no_unidad,
             suma_aseg_total		 
		INTO _cod_ubica,
		     _cod_ramo, 
			 _cod_subramo,
		     _cod_contratante,
		     _no_poliza,
		     v_vigencia_final,    	  
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
			 _orden,
			 _no_unidad,
			 _suma_aseg_total
	   FROM temp_ubica
	  ORDER BY orden, cod_ramo, cod_subramo, vigencia_final, no_documento, no_unidad

	  SELECT nombre
		INTO v_ubicacion
		FROM emiubica
	   WHERE cod_ubica = _cod_ubica;

      SELECT nombre
	    INTO v_asegurado
      	FROM cliclien
	   WHERE cod_cliente = _cod_contratante;

      SELECT nombre
	    INTO v_ramo
		FROM prdramo
	   WHERE cod_ramo = _cod_ramo;

	  SELECT nombre 
		INTO v_subramo
		FROM prdsubra
	   WHERE cod_ramo = _cod_ramo
	     AND cod_subramo = _cod_subramo;
		 
		 if _suma_aseg_total = 0 then
			let _prima_unidad = v_prima;
		else
			let _prima_unidad = (v_suma_asegurada/_suma_aseg_total) * v_prima;
		end if			 

	RETURN v_ubicacion,
	       v_ramo,
		   v_subramo,
	       v_nodocumento,
		   v_vigencia_final,
		   v_asegurado,
		   v_cnt_poliza,    	
		   v_suma_asegurada/1000,	
		   v_retencion/1000,  	
		   _cant_ret,	
		   v_excedente/1000,	
		   _cant_exe,      	
		   v_facultativo/1000,   	
		   _cant_fac,	
		   _prima_unidad, --v_prima,
		   v_compania_nombre,
           _no_unidad		   
		   WITH RESUME;

END FOREACH

					 
DROP TABLE temp_ubica;

END PROCEDURE;
