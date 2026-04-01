DROP PROCEDURE sp_pro998_dif;

CREATE PROCEDURE "informix".sp_pro998_dif(a_compania CHAR(03), a_terremoto SMALLINT, a_fecha DATE) 
RETURNING CHAR(20),
		  CHAR(10),
		  CHAR(5),
		  CHAR(5),
		  CHAR(3),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  DEC(9,6), 
		  CHAR(250);

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
DEFINE _no_documento       CHAR(20);
DEFINE v_ramo, v_subramo   CHAR(50);
define _cod_cober_reas	   char(3);
DEFINE _no_poliza          CHAR(10);
DEFINE _cod_ramo, _cod_subramo CHAR(3);
DEFINE _no_unidad, _no_endoso  CHAR(5);
DEFINE _cod_ubica          CHAR(3);
DEFINE _suma    		   DEC(16,2);
DEFINE _dif      		   DEC(16,2);
DEFINE _prima    		   DEC(16,2);
DEFINE _suma_retencion     DEC(16,2);
DEFINE _cant_ret, _cant_exe, _cant_fac INT;
DEFINE _suma_facultativo   DEC(16,2);
DEFINE _suma_excedente     DEC(16,2);
DEFINE _porc_partic_suma   DEC(9,6);
DEFINE _porc_partic_prima   DEC(9,6);
DEFINE _porcentaje		   DEC(9,6);
DEFINE _tipo_contrato      SMALLINT;
DEFINE _no_cambio, _es_terremoto,_es_terremoto_f SMALLINT;
DEFINE _mal_porc 		   CHAR(5);
DEFINE _mes_contable       CHAR(2);
DEFINE _ano_contable       CHAR(4);
DEFINE _periodo            CHAR(7);
DEFINE _fecha_emision, _fecha_cancelacion DATE;

DEFINE _p_suscrita		   DEC(16,2);
DEFINE _p_retenida		   DEC(16,2);
DEFINE _p_provincial       DEC(16,2);
DEFINE codigo1         	   SMALLINT;
DEFINE v_cant_coasegur1    SMALLINT;
DEFINE v_cant_coasegur2    SMALLINT;
DEFINE v_rango_inicial	   DEC(16,2);
DEFINE v_rango_final	   DEC(16,2);
DEFINE rango_max 		   DEC(16,2);
DEFINE rango_min       	   DEC(16,2);

DEFINE _pri_sus_tot		   DEC(16,2);
DEFINE _pri_sus_inc		   DEC(16,2);
DEFINE _pri_sus_ter		   DEC(16,2);
DEFINE _pri_ret_inc		   DEC(16,2);
DEFINE _pri_ret_ter		   DEC(16,2);
DEFINE v_codsucursal       CHAR(3);
DEFINE v_cant_polizas 	   SMALLINT;
DEFINE _descripcion        CHAR(250);

   CREATE TEMP TABLE temp_valor
         (cod_sucursal     CHAR(03),
          no_poliza        CHAR(10),
          no_endoso        CHAR(5),
          no_unidad        CHAR(5),
		  cod_ramo         CHAR(3),
		  suma_asegurada   DEC(16,2),
		  retencion        DEC(16,2),
		  excedente 	   DEC(16,2),
		  facultativo      DEC(16,2),
		  prima_terremoto  DEC(16,2),
		  prima_suscrita   DEC(16,2),
		  prima_retenica   DEC(16,2),
		  provincial       DEC(16,2),
		  pri_sus_inc 	   DEC(16,2),
		  pri_sus_ter 	   DEC(16,2),
		  pri_ret_inc 	   DEC(16,2),
		  pri_ret_ter 	   DEC(16,2),
		  porcentaje	   DEC(9,6) default 0,
		  descripcion	   CHAR(250) default null,
          PRIMARY KEY (no_poliza,no_endoso,no_unidad))
          WITH NO LOG;


   CREATE TEMP TABLE temp_cumulo
         (cod_sucursal     CHAR(03),
          cod_ramo         CHAR(03),
          rango_inicial    DECIMAL(16,2),
          rango_final      DECIMAL(16,2),
          cant_polizas     SMALLINT,
          prima_suscrita   DEC(16,2),
          prima_retenida   DEC(16,2),
          cant_coasegur1   SMALLINT,
          cant_coasegur2   SMALLINT,
          seleccionado     SMALLINT DEFAULT 1,
		  suma_asegurada   dec(16,2),	
		  pri_sus_inc	   dec(16,2) default 0,
		  pri_sus_ter	   dec(16,2) default 0,
		  pri_ret_inc	   dec(16,2) default 0,
		  pri_ret_ter	   dec(16,2) default 0,
          PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;
set debug file to "sp_pr998.trc";

LET  v_compania_nombre = sp_sis01(a_compania); 
LET _ano_contable = YEAR(a_fecha);

LET v_rango_inicial  = 0;
LET v_rango_final    = 0;

LET v_cant_coasegur1 = 0;
LET v_cant_coasegur2 = 0;
LET v_filtros        = "";
LET _dif = 0;

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || "-" || _mes_contable;
--trace on;

FOREACH
   SELECT d.no_poliza, e.no_endoso, d.no_documento, d.cod_ramo, d.cod_subramo, d.fecha_cancelacion, d.cod_sucursal 
     INTO _no_poliza, _no_endoso, v_nodocumento, _cod_ramo, _cod_subramo, _fecha_cancelacion, v_codsucursal
     FROM emipomae d, endedmae e
    WHERE d.cod_compania      = a_compania
	  AND d.cod_ramo          IN ('001','003')
      AND (d.vigencia_final   >= a_fecha
	   OR d.vigencia_final    IS NULL)
      AND d.fecha_suscripcion <= a_fecha
	  AND d.vigencia_inic     < a_fecha
--	  AND e.no_poliza         = '400674'   ---in ( '393514','400674')
      AND d.actualizado       = 1
	  AND e.no_poliza         = d.no_poliza
	  AND e.periodo           <= _periodo
	  AND e.fecha_emision     <= a_fecha
      AND e.actualizado       = 1

      LET _fecha_emision = null;
	  LET _p_suscrita    = 0;
	  LET _p_retenida    = 0;
	  LET _p_provincial  = 0;
	  -- 00576 -2008,  00585-2 009,  00593- 2010

      IF _fecha_cancelacion <= a_fecha THEN
	     FOREACH
			SELECT fecha_emision
			  INTO _fecha_emision
			  FROM endedmae
			 WHERE no_poliza     = _no_poliza
			   AND cod_endomov   = '002'
			   AND vigencia_inic = _fecha_cancelacion
		 END FOREACH

		 IF  _fecha_emision <= a_fecha THEN
			CONTINUE FOREACH;
		 END IF
	  END IF

	  LET _prima =  0;
	  LET _cant_ret    = 0;
	  LET _cant_exe    = 0;
	  LET _cant_fac    = 0;
	  LET _mal_porc    = '';

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
		  WHERE no_poliza = _no_poliza
			AND no_endoso = _no_endoso

		LET _suma_retencion   = 0;
		LET _suma_excedente   = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje       = 0;
		LET _porc_partic_prima = 0;
		LET _es_terremoto      = 0;
		LET _p_suscrita    = 0;
		LET _p_retenida    = 0;
		LET _pri_sus_inc   = 0.00;
		LET _pri_sus_ter   = 0.00;
		LET _pri_ret_inc   = 0.00;
		LET _pri_ret_ter   = 0.00;
		LET _descripcion   = "";

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

		if _cod_ramo in ("001", "003") then

			LET _p_suscrita    = 0    ;
			LET _p_retenida    = 0    ;
			LET _pri_sus_tot   = 0.00 ;

		    SELECT prima_suscrita,
			  	   prima_retenida
		      INTO _p_suscrita,
			  	   _p_retenida
		      FROM endeduni
		     WHERE no_poliza = _no_poliza
			   AND no_endoso = _no_endoso
			   and no_unidad = _no_unidad;

			foreach
				select e.cod_cober_reas,e.porc_partic_prima
				  into _cod_cober_reas,_porc_partic_prima
				  FROM emifacon	e, endeduni r, reacomae t , reacobre x
				 WHERE e.no_poliza = r.no_poliza
					AND e.no_endoso = r.no_endoso
					AND e.no_unidad = r.no_unidad
					AND e.cod_contrato = t.cod_contrato
				        AND e.cod_cober_reas = x.cod_cober_reas
					AND t.tipo_contrato <> 1
					AND e.no_poliza = _no_poliza
					AND e.no_endoso = _no_endoso
					and e.no_unidad = _no_unidad
				    AND x.es_terremoto = 1

					select es_terremoto
					  into _es_terremoto
					  from reacobre
					 where cod_cober_reas = _cod_cober_reas;

					 let _pri_sus_tot = _prima * _porc_partic_prima / 100 ;

					if _es_terremoto = 1 then
						let _pri_sus_ter = _pri_sus_ter + _pri_sus_tot;
					else
						let _pri_sus_inc = 0;
					end if

			end foreach					   
			
			foreach
				select e.cod_cober_reas,e.porc_partic_prima
				  into _cod_cober_reas,_porc_partic_prima
				  FROM emifacon	e, endeduni r, reacomae t , reacobre x
				 WHERE e.no_poliza = r.no_poliza
					AND e.no_endoso = r.no_endoso
					AND e.no_unidad = r.no_unidad
					AND e.cod_contrato = t.cod_contrato
				    AND e.cod_cober_reas = x.cod_cober_reas
					AND t.tipo_contrato = 1
					AND e.no_poliza = _no_poliza
					AND e.no_endoso = _no_endoso
					and e.no_unidad = _no_unidad
				    AND x.es_terremoto = 1

					select es_terremoto
					  into _es_terremoto
					  from reacobre
					 where cod_cober_reas = _cod_cober_reas;

					 let _pri_sus_tot = _prima * _porc_partic_prima / 100 ;

					if _es_terremoto = 1 then
						let _pri_ret_ter = _pri_ret_ter + _pri_sus_tot;
					else
						let _pri_ret_inc = 0;
					end if

			end foreach		
						
			let _p_suscrita = _prima;
			let _p_retenida = _pri_ret_ter;	
		end if


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
				LET _descripcion = _no_poliza||"-"||_no_endoso||"-"||_no_unidad||"-"||_no_cambio||",";
			ELSE
			    LET _mal_porc = '';
			END IF

		END FOREACH

		IF _es_terremoto = 1 THEN

			BEGIN
	   			ON EXCEPTION IN(-239)
					UPDATE temp_valor			   
					   SET suma_asegurada   = suma_asegurada   + _suma,
					       retencion        = retencion        + _suma_retencion,
						   excedente        = excedente        + _suma_excedente,
						   facultativo      = facultativo	   + _suma_facultativo,
						   prima_terremoto  = prima_terremoto  + _prima,
						   prima_suscrita   = prima_suscrita   + _p_suscrita,
						   prima_retenica   = prima_retenica   + _p_retenida,
						   provincial       = provincial       + _p_provincial,
						   pri_sus_inc      = pri_sus_inc      + _pri_sus_inc,
						   pri_sus_ter      = pri_sus_ter      + _pri_sus_ter,
						   pri_ret_inc      = pri_ret_inc      + _pri_ret_inc,
						   pri_ret_ter      = pri_ret_ter      + _pri_ret_ter,
						   porcentaje		= _porcentaje,
						   descripcion		= _descripcion
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso
					   AND no_unidad = _no_unidad;
				END EXCEPTION

				INSERT INTO temp_valor							
							(cod_sucursal,
							no_poliza,
							no_endoso,
							no_unidad,
							cod_ramo,
							suma_asegurada,
							retencion, 
							excedente,
							facultativo,
							prima_terremoto,
							prima_suscrita,
							prima_retenica,
							provincial,
							pri_sus_inc, 
							pri_sus_ter, 
							pri_ret_inc, 
							pri_ret_ter,
							porcentaje,
							descripcion 																	
							)
				   VALUES(v_codsucursal,
				          _no_poliza,
						  _no_endoso,
						  _no_unidad,
						  _cod_ramo,
				          _suma,  
						  _suma_retencion,
						  _suma_excedente,
						  _suma_facultativo,
						  _prima,
						  _p_suscrita,
						  _p_retenida,
						  _p_provincial,
						  _pri_sus_inc,
						  _pri_sus_ter,
						  _pri_ret_inc,
						  _pri_ret_ter,
						  _porcentaje,
						  _descripcion
						  );
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
		  WHERE no_poliza = _no_poliza
			AND no_endoso = _no_endoso

		LET _suma_retencion   = 0;
		LET _suma_excedente   = 0;
		LET _suma_facultativo = 0; 
		LET _porcentaje       = 0;
		LET _porc_partic_prima = 0;
		LET _es_terremoto     = 1;
		LET _p_suscrita    = 0;
		LET _p_retenida    = 0;
		LET _pri_sus_inc = 0.00;
		LET _pri_sus_ter = 0.00;
		LET _pri_ret_inc = 0.00;
		LET _pri_ret_ter = 0.00;


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


		if _cod_ramo in ("001", "003") then

			LET _p_suscrita    = 0    ;
			LET _p_retenida    = 0    ;
			LET _pri_sus_tot   = 0.00 ;

		    SELECT prima_suscrita,
			  	   prima_retenida
		      INTO _p_suscrita,
			  	   _p_retenida
		      FROM endeduni
		     WHERE no_poliza = _no_poliza
			   AND no_endoso = _no_endoso
			   and no_unidad = _no_unidad;

			foreach
				select e.cod_cober_reas,e.porc_partic_prima
				  into _cod_cober_reas,_porc_partic_prima
				  FROM emifacon	e, endeduni r, reacomae t , reacobre x
				 WHERE e.no_poliza = r.no_poliza
					AND e.no_endoso = r.no_endoso
					AND e.no_unidad = r.no_unidad
					AND e.cod_contrato = t.cod_contrato
				        AND e.cod_cober_reas = x.cod_cober_reas
					AND t.tipo_contrato <> 1
					AND e.no_poliza = _no_poliza
					AND e.no_endoso = _no_endoso
					and e.no_unidad = _no_unidad
				    AND x.es_terremoto = 0

				select es_terremoto
				  into _es_terremoto
				  from reacobre
				 where cod_cober_reas = _cod_cober_reas;

				 let _pri_sus_tot = _prima * _porc_partic_prima / 100 ;

				if _es_terremoto = 1 then
					let _pri_sus_ter = 0;
				else
					let _pri_sus_inc = _pri_sus_inc + _pri_sus_tot;
				end if

			end foreach					   
			
			foreach
				select e.cod_cober_reas,e.porc_partic_prima
				  into _cod_cober_reas,_porc_partic_prima
				  FROM emifacon	e, endeduni r, reacomae t , reacobre x
				 WHERE e.no_poliza = r.no_poliza
					AND e.no_endoso = r.no_endoso
					AND e.no_unidad = r.no_unidad
					AND e.cod_contrato = t.cod_contrato
				    AND e.cod_cober_reas = x.cod_cober_reas
					AND t.tipo_contrato = 1
					AND e.no_poliza = _no_poliza
					AND e.no_endoso = _no_endoso
					and e.no_unidad = _no_unidad
				    AND x.es_terremoto = 0

				select es_terremoto
				  into _es_terremoto
				  from reacobre
				 where cod_cober_reas = _cod_cober_reas;

				 let _pri_sus_tot = _prima * _porc_partic_prima / 100 ;

				if _es_terremoto = 1 then
					let _pri_ret_ter = 0 ;
				else
					let _pri_ret_inc = _pri_ret_inc + _pri_sus_tot;
				end if

			end foreach		
						
			let _p_suscrita = _prima;
			let _p_retenida = _pri_ret_inc;	

		end if

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
				LET _descripcion = _no_poliza||"-"||_no_endoso||"-"||_no_unidad||"-"||_no_cambio||",";
			ELSE
			    LET _mal_porc = '';
				LET _descripcion = "";
			END IF
		END FOREACH

		IF _es_terremoto = 0 THEN

			BEGIN
	   			ON EXCEPTION IN(-239)
					UPDATE temp_valor			   
					   SET suma_asegurada   = suma_asegurada   + _suma,
					       retencion        = retencion        + _suma_retencion,
						   excedente        = excedente        + _suma_excedente,
						   facultativo      = facultativo	   + _suma_facultativo,
						   prima_terremoto  = prima_terremoto  + _prima,
						   prima_suscrita   = prima_suscrita   + _p_suscrita,
						   prima_retenica   = prima_retenica   + _p_retenida,
						   provincial       = provincial       + _p_provincial,
						   pri_sus_inc      = pri_sus_inc      + _pri_sus_inc,
						   pri_sus_ter      = pri_sus_ter      + _pri_sus_ter,
						   pri_ret_inc      = pri_ret_inc      + _pri_ret_inc,
						   pri_ret_ter      = pri_ret_ter      + _pri_ret_ter,
						   porcentaje		= _porcentaje,
						   descripcion		= _descripcion
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso
					   AND no_unidad = _no_unidad;
				END EXCEPTION

				INSERT INTO temp_valor							
							(cod_sucursal,
							no_poliza,
							no_endoso,
							no_unidad,
							cod_ramo,
							suma_asegurada,
							retencion, 
							excedente,
							facultativo,
							prima_terremoto,
							prima_suscrita,
							prima_retenica,
							provincial,
							pri_sus_inc, 
							pri_sus_ter, 
							pri_ret_inc, 
							pri_ret_ter,
							porcentaje,
							descripcion 																	
							)
				   VALUES(v_codsucursal,
				          _no_poliza,
						  _no_endoso,
						  _no_unidad,
						  _cod_ramo,
				          _suma,  
						  _suma_retencion,
						  _suma_excedente,
						  _suma_facultativo,
						  _prima,
						  _p_suscrita,
						  _p_retenida,
						  _p_provincial,
						  _pri_sus_inc,
						  _pri_sus_ter,
						  _pri_ret_inc,
						  _pri_ret_ter,
						  _porcentaje,
						  _descripcion
						  );
			END	

		END IF
	 END FOREACH
	END IF 
END FOREACH

--trace on;

FOREACH 
	SELECT cod_sucursal,
	       no_poliza,
		   no_endoso,
		   no_unidad,
		   cod_ramo,
		   suma_asegurada,
		   retencion, 
		   excedente,
		   facultativo,
		   prima_terremoto,
		   prima_suscrita,
		   prima_retenica,
		   provincial,
		   pri_sus_inc,
		   pri_sus_ter,
		   pri_ret_inc,
		   pri_ret_ter,
		   porcentaje,
		   descripcion		    
	  INTO v_codsucursal,
	       _no_poliza,
		   _no_endoso,
		   _no_unidad,
		   _cod_ramo,
           _suma,  
		   _suma_retencion,
		   _suma_excedente,
		   _suma_facultativo,
		   _prima,
		   _p_suscrita,
		   _p_retenida,
		   _p_provincial,
		   _pri_sus_inc,
		   _pri_sus_ter,
		   _pri_ret_inc,
		   _pri_ret_ter,
		   _porcentaje,		   
		   _descripcion		   		   	
	FROM temp_valor
	order by 1,5,2,3,4

	LET _dif = _suma	- (_suma_retencion + _suma_excedente + _suma_facultativo);

   	if 	ABS(_dif) = 0  or ABS(_dif) <= 10 then
	else
		continue Foreach;
	end if

	select no_documento
	  into _no_documento
	  from emipomae
	  where no_poliza = _no_poliza;
	   
	--if ABS( _p_retenida	- (_pri_ret_inc+ _pri_ret_ter)) = 0  then
	--	 continue Foreach;
	--end if 


    RETURN _no_documento,
           _no_poliza,
		   _no_endoso,
		   _no_unidad,
     	   _cod_ramo,
     	   _suma,  
		   _dif,
           _suma_retencion,
           _suma_excedente,
           _suma_facultativo,
           _prima,
           _p_suscrita,
           _p_retenida,
           _p_provincial,
           _pri_sus_inc,
		   _pri_sus_ter,
		   _pri_ret_inc,
		   _pri_ret_ter,
		   _porcentaje,
  		   _descripcion		   		   			   
            WITH RESUME;
END FOREACH

DROP TABLE temp_valor;
DROP TABLE temp_cumulo;

END PROCEDURE                                                                                                                    
   
 