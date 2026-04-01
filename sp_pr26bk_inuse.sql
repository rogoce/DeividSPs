-- Procedimiento que Carga los Totales de Produccion
-- en un Periodo Dado
-- 
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 21/09/2000 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pr26bk;

CREATE PROCEDURE "informix".sp_pr26bk(
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
		a_producto  CHAR(255) DEFAULT "*",
		a_codvend   CHAR(255) DEFAULT "*"
		) RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _no_poliza 		 CHAR(10); 
DEFINE _no_endoso 		 CHAR(5);
DEFINE _periodo      	 CHAR(7);
DEFINE _cod_ramo    	 CHAR(3); 
DEFINE _cod_grupo  		 CHAR(5); 
DEFINE _user_added  	 CHAR(8);
DEFINE _cod_sucursal     CHAR(3); 
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE _porc_partic_agt  DECIMAL(5,2); 
DEFINE _cod_agente       CHAR(5);

DEFINE _total_suma_sus	 DECIMAL(16,2);
DEFINE _total_suma_nva  DECIMAL(16,2);
DEFINE _total_suma_ren  DECIMAL(16,2);
DEFINE _total_suma_end  DECIMAL(16,2);
DEFINE _total_suma_can  DECIMAL(16,2);
DEFINE _total_suma_rev  DECIMAL(16,2);
DEFINE t_total_suma_sus DECIMAL(16,2);
DEFINE t_total_suma_nva DECIMAL(16,2);
DEFINE t_total_suma_ren DECIMAL(16,2);
DEFINE t_total_suma_end DECIMAL(16,2);
DEFINE t_total_suma_can DECIMAL(16,2);
DEFINE t_total_suma_rev DECIMAL(16,2);
DEFINE t_cnt_prima_sus 	 DECIMAL(16,2);
DEFINE t_cnt_prima_nva 	 DECIMAL(16,2);
DEFINE t_cnt_prima_ren 	 DECIMAL(16,2);
DEFINE t_cnt_prima_end 	 DECIMAL(16,2);
DEFINE t_cnt_prima_can 	 DECIMAL(16,2);
DEFINE t_cnt_prima_rev 	 DECIMAL(16,2);

DEFINE _cnt_prima_sus    DECIMAL(16,2);
DEFINE _cnt_prima_nva    DECIMAL(16,2);
DEFINE _cnt_prima_ren    DECIMAL(16,2);
DEFINE _cnt_prima_end    DECIMAL(16,2);
DEFINE _cnt_prima_can    DECIMAL(16,2);
DEFINE _cnt_prima_rev    DECIMAL(16,2);
DEFINE _cod_endomov      CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _tipo_mov		 SMALLINT;
DEFINE v_descripcion   	 CHAR(22);
DEFINE v_desc_ramo,v_desc_grupo,v_desc_suc,v_nombre_prod,v_desc_agt 	 CHAR(50);
DEFINE v_saber		   	 CHAR(2);
DEFINE v_codigo,_cod_producto  	 CHAR(5);

DEFINE _suc_prom        	    CHAR(3);
DEFINE _cod_vendedor		    CHAR(3);
DEFINE _nombre_vendedor	    	CHAR(50);
DEFINE _nom_sucursal		    CHAR(50);
DEFINE _vigencia_inic_pol       DATE;
DEFINE _vigencia_final_end      DATE;
DEFINE _dias_vigencia, _cadena  INTEGER;

DEFINE _cod_tipocan				CHAR(3);
DEFINE _reemplaza_poliza		CHAR(20);

-- Tabla Temporal tmp_prod

--DROP TABLE tmp_prod;

CREATE TEMP TABLE tmp_prod(
		no_poliza            CHAR(10) NOT NULL,
	 	user_added			 CHAR(8)  NOT NULL,	
		cod_ramo             CHAR(3)  NOT NULL,
		cod_grupo			 CHAR(5)  NOT NULL,
		cod_sucursal         CHAR(3)  NOT NULL,
		cod_agente           CHAR(5)  NOT NULL,
		tipo_produccion      CHAR(1),
		total_sum_sus        DECIMAL(16,2),
		total_sum_nva        DECIMAL(16,2),
		total_sum_ren        DECIMAL(16,2),
		total_sum_end        DECIMAL(16,2),
		total_sum_can        DECIMAL(16,2),
		total_sum_rev        DECIMAL(16,2),
		cnt_prima_sus    	 DECIMAL(16,2),
 		cnt_prima_nva   	 DECIMAL(16,2),
		cnt_prima_ren   	 DECIMAL(16,2),
		cnt_prima_end   	 DECIMAL(16,2),
		cnt_prima_can   	 DECIMAL(16,2),
		cnt_prima_rev   	 DECIMAL(16,2),
		seleccionado         SMALLINT DEFAULT 1 NOT NULL,
		cod_producto		 CHAR(5)  NOT NULL,
		cod_vendedor	     CHAR(3),                    -- cod_vendedor
		nombre_vendedor      CHAR(50)                    -- nombre vendedor
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(cod_sucursal);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(user_added);
CREATE INDEX iend7_tmp_prod ON tmp_prod(cod_vendedor);

LET _cod_agente = a_agente;

SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT e.no_poliza,	
 		e.no_endoso, 	
 		e.suma_asegurada,	 
 		e.cod_endomov,		
 		e.user_added,
		e.vigencia_final,
		e.cod_tipocan
   INTO _no_poliza, 	
   		_no_endoso, 	
   		_total_suma_sus,	 
   		_cod_endomov, 		
   		_user_added,
		_vigencia_final_end,
		_cod_tipocan
   FROM endedmae e
  WHERE e.periodo BETWEEN a_periodo1 AND a_periodo2
    AND e.actualizado = 1

   FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	endeduni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
   END FOREACH

	LET _total_suma_nva = 0;
	LET _total_suma_ren = 0;
	LET _total_suma_end = 0;
	LET _total_suma_can = 0;
	LET _total_suma_rev = 0;

	LET _cnt_prima_sus = 1;
	LET _cnt_prima_nva = 0;
	LET _cnt_prima_ren = 0;
	LET _cnt_prima_end = 0;
	LET _cnt_prima_can = 0;
	LET _cnt_prima_rev = 0;
    LET v_descripcion  = " "; 

	-- Lectura de la Tabla de tipo_mov

	SELECT  tipo_mov
	  INTO _tipo_mov
	  FROM endtimov
	 WHERE cod_endomov = _cod_endomov;

	-- Informacion de Poliza

    SELECT sucursal_origen,
    	   cod_tipoprod, 
    	   cod_ramo,	
    	   cod_grupo, 
    	   nueva_renov,
		   vigencia_inic,
		   reemplaza_poliza
      INTO _cod_sucursal,
      	   _cod_tipoprod, 
      	   _cod_ramo, 
      	   _cod_grupo, 
      	   _nueva_renov,
		   _vigencia_inic_pol,
		   _reemplaza_poliza
      FROM emipomae
     WHERE no_poliza = _no_poliza;
  
    SELECT tipo_produccion	
      INTO _tipo_produccion
      FROM emitipro
     WHERE cod_tipoprod = _cod_tipoprod;
         
	-- Calculos

	IF _tipo_mov = 2 THEN

		if _cod_tipocan = "009" then
			LET _total_suma_rev = _total_suma_sus;		
			LET _cnt_prima_rev   = 1;		
		else
			LET _total_suma_can = _total_suma_sus;		
			LET _cnt_prima_can   = 1;		
		end if

	ELIF _tipo_mov = 8 THEN

		LET _total_suma_rev = _total_suma_sus;		
		LET _cnt_prima_rev   = 1;		

	ELIF _tipo_mov = 11 THEN

	  IF _nueva_renov = "N" THEN

{		if _reemplaza_poliza is not null then	   -- Por solicitud de Omar 04/10/2011

			LET _total_prima_rev = _total_prima_sus;		
			LET _cnt_prima_rev   = 1;		

		else   }

			LET _total_suma_nva = _total_suma_sus;		
			LET _cnt_prima_nva   = 1;		

{		end if }

	  ELSE

		LET _total_suma_ren = _total_suma_sus;		
		LET _cnt_prima_ren   = 1;		

	  END IF

	ELIF _tipo_mov = 14 THEN -- Facturacion Mensual de Salud

{
		LET _total_prima_ren = 0.00;		
		LET _total_prima_nva = 0.00;		
		LET _cnt_prima_ren   = 0;		
		LET _dias_vigencia   = _vigencia_final_end -_vigencia_inic_pol;

		IF _dias_vigencia > 366 THEN
			LET _total_prima_ren = _total_prima_sus;		
			LET _cnt_prima_ren   = 1;		
		else
			LET _total_prima_nva = _total_prima_sus;		
		END IF
}

		LET _total_suma_ren = _total_suma_sus;		
		LET _cnt_prima_ren   = 1;		

	ELSE		

		LET _total_suma_end = _total_suma_sus;		
		LET _cnt_prima_end   = 1;		

	END IF


	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		exit foreach;
	end foreach

	select sucursal_promotoria,trim(descripcion)
	  into _suc_prom,_nom_sucursal
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = '001';

   select cod_vendedor
     into _cod_vendedor
     from parpromo
    where cod_agente  = _cod_agente
      and cod_agencia = _suc_prom
      and cod_ramo	  = _cod_ramo;
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;


	  -- Insercion a la tabla temporal tmp_prod
		INSERT INTO tmp_prod(
		no_poliza,
		user_added,
	  	cod_ramo, 
	  	cod_grupo,
	  	cod_sucursal,
	  	tipo_produccion,
		cod_agente,
		total_sum_sus,
		total_sum_nva,
		total_sum_ren,
		total_sum_end,
		total_sum_can,
		total_sum_rev,
		cnt_prima_sus,
		cnt_prima_nva,
		cnt_prima_ren,
		cnt_prima_end,
		cnt_prima_can,
		cnt_prima_rev,
		cod_producto,
		cod_vendedor,	
		nombre_vendedor 
		)
		VALUES(
		_no_poliza,
		_user_added,
		_cod_ramo,
		_cod_grupo,
	 	_cod_sucursal,
		_tipo_produccion,
		_cod_agente,
		_total_suma_sus,
		_total_suma_nva,
		_total_suma_ren,
		_total_suma_end,
		_total_suma_can,
		_total_suma_rev,
		_cnt_prima_sus,
		_cnt_prima_nva,	
		_cnt_prima_ren,	   
		_cnt_prima_end,	       
		_cnt_prima_can,
		_cnt_prima_rev,
		_cod_producto,
		_cod_vendedor,	
		_nombre_vendedor 
		);

END FOREACH

-- Procesos para Filtros

LET v_filtros = "";
LET _cadena = 0;

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

		 LET _cadena = LENGTH(TRIM(v_filtros)) + LENGTH(TRIM(v_codigo)) + LENGTH(TRIM(v_desc_grupo));

		 IF  _cadena <= 255	THEN
	        LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || (v_saber);
		 END IF

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

   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);


	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "Ex";
	END IF
    FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
      	  INTO v_desc_agt,v_codigo
          FROM agtagent,tmp_codigos
         WHERE agtagent.cod_agente = codigo

         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agt) || (v_saber);
 	END FOREACH
	DROP TABLE tmp_codigos;

END IF

IF a_codvend <> "*" THEN

	LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String
	LET v_filtros = TRIM(v_filtros) ||"Zona "||TRIM(a_codvend);

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;

END IF


IF a_reaseguro = "4;" THEN
   LET v_descripcion = "Sin Reaseguro Asumido";
END IF
IF a_reaseguro = "4;Ex" THEN
   LET v_descripcion = "Solo Reaseguro Asumido";
END IF

RETURN v_filtros;

END PROCEDURE;
