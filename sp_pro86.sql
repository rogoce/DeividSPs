-- Procedimiento que Carga los Totales de Produccion
-- en un Periodo Dado ***Corredores***
-- 
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 21/09/2000 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro86;

CREATE PROCEDURE "informix".sp_pro86(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7),
		a_periodo2  CHAR(7),
		a_sucursal  CHAR(255) DEFAULT "*",
		a_ramo      CHAR(255) DEFAULT "*",
		a_grupo     CHAR(255) DEFAULT "*",
		a_usuario   CHAR(255) DEFAULT "*",
		a_reaseguro CHAR(255) DEFAULT "*",
		a_agente    CHAR(255) DEFAULT "*",
		a_producto  CHAR(255) DEFAULT "*"
		) RETURNING CHAR(255); 

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _no_poliza 		 CHAR(10);        
DEFINE _no_endoso,_no_unidad CHAR(5);        
DEFINE _periodo      	 CHAR(7);        
DEFINE _cod_ramo,_cod_subramo CHAR(3);        
DEFINE _cod_grupo  		 CHAR(5);        
DEFINE _user_added  	 CHAR(8);
DEFINE _cod_sucursal     CHAR(3);        
DEFINE _cod_tipoprod     CHAR(3);    
DEFINE _tipo_produccion  CHAR(1);   
DEFINE _porc_partic_agt  DECIMAL(5,2); 
DEFINE _cod_agente       CHAR(5);  
						                 
DEFINE _total_prima_sus,_prima_compara,_prima_endoso DECIMAL(16,2);  
DEFINE _total_prima_nva  DECIMAL(16,2);  
DEFINE _total_prima_ren  DECIMAL(16,2);  
DEFINE _total_prima_end  DECIMAL(16,2);  
DEFINE _total_prima_can  DECIMAL(16,2);  
DEFINE _total_prima_rev  DECIMAL(16,2);  
DEFINE t_total_prima_sus DECIMAL(16,2); 
DEFINE t_total_prima_nva DECIMAL(16,2); 
DEFINE t_total_prima_ren DECIMAL(16,2); 
DEFINE t_total_prima_end DECIMAL(16,2); 
DEFINE t_total_prima_can DECIMAL(16,2); 
DEFINE t_total_prima_rev DECIMAL(16,2); 
DEFINE t_cnt_prima_sus DECIMAL(16,2);
DEFINE t_cnt_prima_nva DECIMAL(16,2);
DEFINE t_cnt_prima_ren DECIMAL(16,2);
DEFINE t_cnt_prima_end DECIMAL(16,2);
DEFINE t_cnt_prima_can DECIMAL(16,2);
DEFINE t_cnt_prima_rev DECIMAL(16,2);
DEFINE _prima_sus	   DECIMAL(16,2);
DEFINE _dif_prima      DECIMAL(16,2);
						                 
DEFINE _cnt_prima_sus    		DECIMAL(16,2);        
DEFINE _cnt_prima_nva    		DECIMAL(16,2);        
DEFINE _cnt_prima_ren    		DECIMAL(16,2);        
DEFINE _cnt_prima_end    		DECIMAL(16,2);        
DEFINE _cnt_prima_can    		DECIMAL(16,2);        
DEFINE _cnt_prima_rev    		DECIMAL(16,2);        
DEFINE _cod_endomov      		CHAR(3);        
DEFINE v_codigo		     		CHAR(5);
DEFINE v_saber		     		CHAR(2);
DEFINE v_desc_ramo,v_desc_grupo,v_nombre_prod	CHAR(50);
DEFINE v_desc_suc				CHAR(50);
DEFINE _nueva_renov      		CHAR(1);        
DEFINE _tipo_mov, _dif	 		SMALLINT;
DEFINE _vigencia_inic_pol       DATE;
DEFINE _vigencia_final_end      DATE;
DEFINE _dias_vigencia           INTEGER;
DEFINE _cod_producto  	CHAR(5);
-- Tabla Temporal tmp_prod

--DROP TABLE tmp_prod;

CREATE TEMP TABLE tmp_prod(
		no_poliza            CHAR(10) NOT NULL,
		no_endoso            CHAR(5)  NOT NULL,
		no_unidad			 CHAR(5)  NOT NULL,
	 	user_added			 CHAR(8)  NOT NULL,	
		cod_ramo             CHAR(3)  NOT NULL,
		cod_subramo          CHAR(3)  NOT NULL,
		cod_grupo			 CHAR(5)  NOT NULL,	
		cod_sucursal         CHAR(3)  NOT NULL,
		cod_agente           CHAR(5)  NOT NULL,
		tipo_produccion      CHAR(1),
		total_pri_sus        DECIMAL(16,2),
		total_pri_nva        DECIMAL(16,2),
		total_pri_ren        DECIMAL(16,2),
		total_pri_end        DECIMAL(16,2),
		total_pri_can        DECIMAL(16,2),
		total_pri_rev        DECIMAL(16,2),
		cnt_prima_sus    	 DECIMAL(16,2),
 		cnt_prima_nva   	 DECIMAL(16,2),
		cnt_prima_ren   	 DECIMAL(16,2),
		cnt_prima_end   	 DECIMAL(16,2),
		cnt_prima_can   	 DECIMAL(16,2),
		cnt_prima_rev   	 DECIMAL(16,2),
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		cod_producto		 CHAR(5)  NOT NULL,
		diferencia           SMALLINT DEFAULT 0
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(cod_sucursal);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(user_added);

SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT e.no_poliza,	
 		e.no_endoso, 	
 		e.prima_suscrita,	 
 		e.cod_endomov,		
 		e.user_added,
		e.vigencia_final,
		e.prima_suscrita
   INTO _no_poliza, 	
   		_no_endoso, 	
   		_total_prima_sus,	 
   		_cod_endomov, 		
   		_user_added,
		_vigencia_final_end,
		_prima_compara
   FROM endedmae e
  WHERE e.periodo >= a_periodo1 
    AND e.periodo <= a_periodo2
    AND e.actualizado = 1

   FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	endeduni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
   END FOREACH
	 
	LET _total_prima_nva = 0;
	LET _total_prima_ren = 0;
	LET _total_prima_end = 0;
	LET _total_prima_can = 0;
	LET _total_prima_rev = 0;
	LET _prima_endoso = 0;

	LET _cnt_prima_sus = 1;
	LET _cnt_prima_nva = 0;
	LET _cnt_prima_ren = 0;
	LET _cnt_prima_end = 0;
	LET _cnt_prima_can = 0;
	LET _cnt_prima_rev = 0;

	-- Lectura de la Tabla de tipo_mov

	SELECT tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;

	-- Informacion de Poliza

	SELECT sucursal_origen,
		   cod_tipoprod,  
		   cod_ramo,
		   cod_subramo,	 
		   cod_grupo,  
		   nueva_renov,
		   vigencia_inic
	  INTO _cod_sucursal,
	  	   _cod_tipoprod, 
	  	   _cod_ramo, 
		   _cod_subramo,
	  	   _cod_grupo, 
	  	   _nueva_renov,
		   _vigencia_inic_pol
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

   FOREACH

   		SELECT prima_suscrita,
		   	   no_unidad
		  INTO _prima_endoso,
		       _no_unidad
		  FROM endeduni
		 WHERE no_poliza = _no_poliza
		   AND no_endoso = _no_endoso

		 LET _total_prima_sus = 0;
		 LET _dif = 0;

         FOREACH
			 SELECT	c.prima
			   INTO	_prima_sus
			   FROM emifacon c
			  WHERE	c.no_poliza   = _no_poliza
				AND c.no_endoso   = _no_endoso
				AND c.no_unidad   = _no_unidad

			 LET _total_prima_sus = _total_prima_sus + _prima_sus;
		 END FOREACH

		LET _total_prima_nva = 0;
		LET _total_prima_ren = 0;
		LET _total_prima_end = 0;
		LET _total_prima_can = 0;
		LET _total_prima_rev = 0;

		LET _cnt_prima_sus = 1;
		LET _cnt_prima_nva = 0;
		LET _cnt_prima_ren = 0;
		LET _cnt_prima_end = 0;
		LET _cnt_prima_can = 0;
		LET _cnt_prima_rev = 0;

		LET _dif_prima = _prima_endoso - _total_prima_sus;

        IF 	_dif_prima >= 0.5 OR _dif_prima <= -0.5 THEN
		    LET _dif = 1;
		END IF

		-- Calculos

		IF _tipo_mov = 2 THEN
			LET _total_prima_can = _total_prima_sus;		
			LET _cnt_prima_can   = 1;		
		ELIF _tipo_mov = 8 THEN
			LET _total_prima_rev = _total_prima_sus;		
			LET _cnt_prima_rev   = 1;		
		ELIF _tipo_mov = 11 THEN
		  IF _nueva_renov = "N" THEN
			LET _total_prima_nva = _total_prima_sus;		
			LET _cnt_prima_nva   = 1;		
		  ELSE
			LET _total_prima_ren = _total_prima_sus;		
			LET _cnt_prima_ren   = 1;		
		  END IF
		ELIF _tipo_mov = 14 THEN -- Facturacion Mensual de Salud
			LET _dias_vigencia = _vigencia_final_end -_vigencia_inic_pol;
			IF _dias_vigencia <= 365 THEN
				LET _total_prima_nva = _total_prima_sus;		
				LET _cnt_prima_nva   = 1;		
			ELSE
				LET _total_prima_ren = _total_prima_sus;		
				LET _cnt_prima_ren   = 1;		
			END IF
		ELSE		
			LET _total_prima_end = _total_prima_sus;		
			LET _cnt_prima_end   = 1;		
		END IF

		--Selecciona el % de participacion de emipoagt

	  	FOREACH
	 	 SELECT porc_partic_agt, cod_agente
	   	   INTO _porc_partic_agt, _cod_agente
	  	   FROM emipoagt
		  WHERE	no_poliza = _no_poliza

			LET t_total_prima_sus = _porc_partic_agt * _total_prima_sus / 100;
			LET t_total_prima_nva = _porc_partic_agt * _total_prima_nva / 100;
			LET t_total_prima_ren = _porc_partic_agt * _total_prima_ren / 100;
			LET t_total_prima_end = _porc_partic_agt * _total_prima_end / 100;
			LET t_total_prima_can = _porc_partic_agt * _total_prima_can / 100;
			LET t_total_prima_rev = _porc_partic_agt * _total_prima_rev / 100;
			LET t_cnt_prima_sus   = _porc_partic_agt * _cnt_prima_sus   / 100;
			LET t_cnt_prima_nva   = _porc_partic_agt * _cnt_prima_nva   / 100;
			LET t_cnt_prima_ren   = _porc_partic_agt * _cnt_prima_ren   / 100;
			LET t_cnt_prima_end   = _porc_partic_agt * _cnt_prima_end   / 100;
			LET t_cnt_prima_can   = _porc_partic_agt * _cnt_prima_can   / 100;
			LET t_cnt_prima_rev   = _porc_partic_agt * _cnt_prima_rev   / 100;

		   -- Insercion a la tabla temporal tmp_prod

			INSERT INTO tmp_prod(
			no_poliza,
			no_endoso,
			no_unidad,
			user_added,
			cod_ramo,
			cod_subramo,
			cod_grupo,
			cod_sucursal,
			tipo_produccion,
			cod_agente,		
			total_pri_sus,			
			total_pri_nva,
			total_pri_ren,
			total_pri_end,	
			total_pri_can,
			total_pri_rev,		
			cnt_prima_sus,			
			cnt_prima_nva,
			cnt_prima_ren,		
			cnt_prima_end,			
			cnt_prima_can,
			cnt_prima_rev,
			cod_producto,
			diferencia
			)
			VALUES(
			_no_poliza,
			_no_endoso,
			_no_unidad,         
			_user_added, 	        
			_cod_ramo,  
			_cod_subramo,      	  
			_cod_grupo,		 	
			_cod_sucursal,    		
			_tipo_produccion,
			_cod_agente,		
			t_total_prima_sus,	    
			t_total_prima_nva,
			t_total_prima_ren,  
			t_total_prima_end,	    
			t_total_prima_can,
			t_total_prima_rev,  
			t_cnt_prima_sus,		
			t_cnt_prima_nva,	 	
			t_cnt_prima_ren,	
			t_cnt_prima_end,	    
			t_cnt_prima_can,
			t_cnt_prima_rev,
			_cod_producto,
			_dif
			);
	  END FOREACH
	END FOREACH
END FOREACH

-- Procesos para Filtros

LET v_filtros = "";
IF a_producto <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Producto: "; --||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_producto);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_producto IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
		SELECT prdprod.nombre,tmp_codigos.codigo
          INTO v_nombre_prod,v_codigo
          FROM prdprod,tmp_codigos
         WHERE prdprod.cod_producto = codigo;
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_prod) || TRIM(v_saber);
	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: "; --||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
    FOREACH
	SELECT prdramo.nombre,tmp_codigos.codigo
      INTO v_desc_ramo,v_codigo
      FROM prdramo,tmp_codigos
     WHERE prdramo.cod_ramo = codigo
     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_ramo) || TRIM(v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: "; --||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT cligrupo.nombre,tmp_codigos.codigo
	      INTO v_desc_grupo,v_codigo
	      FROM cligrupo,tmp_codigos
	     WHERE cligrupo.cod_grupo = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

IF a_usuario <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Usuario: " ||  TRIM(a_usuario);

	LET _tipo = sp_sis04(a_usuario);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND user_added NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND user_added IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: "; --||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT insagen.descripcion,tmp_codigos.codigo
		  INTO v_desc_suc,v_codigo
	      FROM insagen,tmp_codigos
	     WHERE insagen.codigo_compania = a_compania
		   AND insagen.codigo_agencia  = tmp_codigos.codigo	
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_suc) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

IF a_reaseguro <> "*" THEN

	LET _tipo = sp_sis04(a_reaseguro);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

	    LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";
		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_produccion NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

	    LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";
		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_produccion IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

   	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);


	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

RETURN v_filtros;
                                                     
END PROCEDURE;
