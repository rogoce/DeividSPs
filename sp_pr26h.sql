-- Procedimiento que Carga los Totales de Produccion
-- en un Periodo Dado
-- 
-- Creado    : 04/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 21/09/2000 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pr26h;

CREATE PROCEDURE "informix".sp_pr26h(
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
		a_codvend   CHAR(255) DEFAULT "*",
		a_origen    CHAR(3) DEFAULT "%"
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

DEFINE _total_prima_sus	 DECIMAL(16,2);
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
DEFINE t_cnt_prima_sus 	 DECIMAL(16,2);
DEFINE t_cnt_prima_nva 	 DECIMAL(16,2);
DEFINE t_cnt_prima_ren 	 DECIMAL(16,2);
DEFINE t_cnt_prima_end 	 DECIMAL(16,2);
DEFINE t_cnt_prima_can 	 DECIMAL(16,2);
DEFINE t_cnt_prima_rev 	 DECIMAL(16,2);

DEFINE _cnt_prima_sus    INTEGER;
DEFINE _cnt_prima_nva    INTEGER;
DEFINE _cnt_prima_ren    INTEGER;
DEFINE _cnt_prima_end    INTEGER;
DEFINE _cnt_prima_can    INTEGER;
DEFINE _cnt_prima_rev    INTEGER;
DEFINE _cod_endomov      CHAR(3);
DEFINE _nueva_renov      CHAR(1);
DEFINE _tipo_mov		 SMALLINT;
DEFINE v_descripcion   	 CHAR(22);
DEFINE v_desc_ramo,v_desc_grupo,v_desc_suc,v_nombre_prod,v_desc_agt 	 CHAR(50);
DEFINE v_saber		   	 CHAR(2);
DEFINE v_codigo,_cod_producto  	 CHAR(5);

DEFINE _vigencia_inic_pol       DATE;
DEFINE _vigencia_final_end      DATE;
DEFINE _dias_vigencia, _cadena  INTEGER;

DEFINE _cod_tipocan				CHAR(3);
DEFINE _reemplaza_poliza		CHAR(20);

DEFINE _suc_prom                CHAR(3); 
DEFINE _nom_sucursal            VARCHAR(50);
DEFINE _cod_vendedor            CHAR(3);
DEFINE _nombre_vendedor         VARCHAR(50);
DEFINE _fecha1  		 DATE;
DEFINE _fecha2	 		 DATE;
DEFINE _mes1     		 SMALLINT;
DEFINE _mes2     	     SMALLINT;
DEFINE _ano1     	     SMALLINT;
DEFINE _ano2     		 SMALLINT;
define _canceladas       SMALLINT;

DEFINE _cnt_prima_reh    DECIMAL(16,2);
DEFINE _suma_asegurada   DEC(16,2);
DEFINE _total_suma_nva   DEC(16,2);
DEFINE _total_suma_ren   DEC(16,2);
DEFINE _total_suma_end   DEC(16,2);
DEFINE _total_suma_can   DEC(16,2);
DEFINE _total_suma_rev   DEC(16,2);
DEFINE _total_suma       DEC(16,2);

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
		total_pri_sus        DECIMAL(16,2),
		total_pri_nva        DECIMAL(16,2),
		total_pri_ren        DECIMAL(16,2),
		total_pri_end        DECIMAL(16,2),
		total_pri_can        DECIMAL(16,2),
		total_pri_rev        DECIMAL(16,2),
		cnt_prima_sus    	 INTEGER,
 		cnt_prima_nva   	 INTEGER,
		cnt_prima_ren   	 INTEGER,
		cnt_prima_end   	 INTEGER,
		cnt_prima_can   	 INTEGER,
		cnt_prima_rev   	 INTEGER,
		cnt_prima_reh        INTEGER,
		seleccionado         SMALLINT DEFAULT 1 NOT NULL,
		cod_producto		 CHAR(5)  NOT NULL,
		cod_vendedor	     CHAR(3),                    -- cod_vendedor
		nombre_vendedor      CHAR(50),                    -- nombre vendedor
		no_endoso            CHAR(5)  NOT NULL,
		total_suma_nva       DECIMAL(16,2),
		total_suma_ren       DECIMAL(16,2),
		total_suma_end       DECIMAL(16,2),
		total_suma_can       DECIMAL(16,2),
		total_suma_rev       DECIMAL(16,2),
		total_suma           DECIMAL(16,2)
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(cod_sucursal);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(user_added);
CREATE INDEX iend7_tmp_prod ON tmp_prod(cod_vendedor);

LET _cod_agente = a_agente;
-- Descomponer los periodos en fechas
LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7];

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

LET _mes1 = _mes1;
LET _fecha1 = MDY(_mes1,1,_ano1);

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT e.no_poliza,	
 		e.no_endoso, 	
 		e.prima_suscrita,	 
 		e.cod_endomov,		
 		e.user_added,
		e.vigencia_final,
		e.cod_tipocan,
		e.suma_asegurada
   INTO _no_poliza, 	
   		_no_endoso, 	
   		_total_prima_sus,	 
   		_cod_endomov, 		
   		_user_added,
		_vigencia_final_end,
		_cod_tipocan,
		_suma_asegurada
   FROM endedmae e, emipomae f
  WHERE e.no_poliza = f.no_poliza
     AND f.cod_origen like a_origen
     AND e.periodo BETWEEN a_periodo1 AND a_periodo2
     AND e.actualizado = 1
--	 AND f.cod_ramo in ('002','020','023')
--	 AND f.cod_subramo = '005'
	--AND e.user_added <> 'GERENCIA'

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
	LET _canceladas = 0;
	
	LET _cnt_prima_reh = 0;
	

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
 --   IF _user_added <> 'GERENCIA' THEN
		IF _tipo_mov = 2 THEN

	--		if _cod_tipocan = "009" then
	--			LET _total_prima_rev = _total_prima_sus;		
	--			LET _cnt_prima_rev   = 1;		
	--		else
				LET _total_prima_can = _total_prima_sus;		
				LET _cnt_prima_can   = 1;		
				LET _total_suma_can = _suma_asegurada;		
	--		end if
			
			select count(*)
			  into _canceladas
			  from tmp_prod
			 where no_poliza = _no_poliza
               and cnt_prima_can = 1
			   and no_endoso <> _no_endoso;
			   
			if _canceladas > 0 then
				LET _cnt_prima_can   = 0;
			end if

		ELIF _tipo_mov = 8 THEN

			LET _total_prima_rev = _total_prima_sus;		
			LET _cnt_prima_rev   = 1;		
			LET _total_suma_rev = _suma_asegurada;		

		ELIF _tipo_mov = 11 THEN

		  IF _nueva_renov = "N" THEN

	{		if _reemplaza_poliza is not null then	   -- Por solicitud de Omar 04/10/2011

				LET _total_prima_rev = _total_prima_sus;		
				LET _cnt_prima_rev   = 1;		

			else   }

				LET _total_prima_nva = _total_prima_sus;		
				LET _cnt_prima_nva   = 1;		
				LET _total_suma_nva = _suma_asegurada;		

	{		end if }

		  ELSE

			LET _total_prima_ren = _total_prima_sus;		
			LET _cnt_prima_ren   = 1;		
			LET _total_suma_ren = _suma_asegurada;		

		  END IF

		ELIF _tipo_mov = 14 THEN -- Facturacion Mensual de Salud


			LET _total_prima_ren = 0.00;		
			LET _total_prima_nva = 0.00;		
			LET _cnt_prima_ren   = 0;		

			LET _dias_vigencia   = _vigencia_final_end -_vigencia_inic_pol;

			IF _dias_vigencia > 366 THEN
				LET _total_prima_ren = _total_prima_sus;		
				LET _cnt_prima_ren   = 1;		
				LET _total_suma_ren = _suma_asegurada;		
			else
				LET _total_prima_end = _total_prima_sus;		
				LET _cnt_prima_end   = 1;		
			END IF

	--		LET _total_prima_ren = _total_prima_sus;		
	--		LET _cnt_prima_ren   = 1;		

	--	ELIF _tipo_mov = 3 THEN
	--		LET _total_prima_nva = _total_prima_sus;		
	--		LET _cnt_prima_nva   = 1;		
	--		LET _total_suma_nva = _suma_asegurada;		
		ELSE		

			LET _total_prima_end = _total_prima_sus;		
			LET _cnt_prima_end   = 1;
			LET _total_suma_end = _suma_asegurada;		

		END IF
--	ELSE
--		LET _total_prima_end = _total_prima_sus;		
--		LET _cnt_prima_end   = 1;
--		LET _total_suma_end = _suma_asegurada;		
--	END IF

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
		cod_vendedor,	
		nombre_vendedor,
        no_endoso,		
		total_suma_nva,
		total_suma_ren,
		total_suma_end,
		total_suma_can,
		total_suma_rev,
		total_suma
		)
		VALUES(
		_no_poliza,
		_user_added,
		_cod_ramo,
		_cod_grupo,
	 	_cod_sucursal,
		_tipo_produccion,
		_cod_agente,
		_total_prima_sus,
		_total_prima_nva,
		_total_prima_ren,
		_total_prima_end,
		_total_prima_can,
		_total_prima_rev,
		_cnt_prima_sus,
		_cnt_prima_nva,	
		_cnt_prima_ren,	   
		_cnt_prima_end,	       
		_cnt_prima_can,
		_cnt_prima_rev,
		_cod_producto,
		_cod_vendedor,	
		_nombre_vendedor,
        _no_endoso,		
		_total_suma_nva,
		_total_suma_ren,
		_total_suma_end,
		_total_suma_can,
		_total_suma_rev,
		_suma_asegurada
		);

END FOREACH

{FOREACH
	SELECT no_poliza, 
		   sucursal_origen, 
		   cod_grupo, 
		   cod_tipoprod, 
		   cod_ramo, 
		   user_added
	  INTO _no_poliza, 
		   _cod_sucursal, 
		   _cod_grupo, 
		   _cod_tipoprod, 
		   _cod_ramo, 
		   _user_added
	  FROM emipomae
	 WHERE vigencia_final >= _fecha1 
	   AND vigencia_final <= _fecha2
	   AND actualizado = 1
--	   AND no_renovar  = 0
--	   AND incobrable  = 0
	   AND abierta     = 0
	   AND estatus_poliza IN (1,3)
	   AND cod_origen like a_origen

   FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	endeduni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
   END FOREACH
	   
    SELECT tipo_produccion	
      INTO _tipo_produccion
      FROM emitipro
     WHERE cod_tipoprod = _cod_tipoprod;

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
	 
	LET _no_endoso = null;
    
    FOREACH	
		SELECT no_endoso
		  INTO _no_endoso
		  FROM tmp_prod
		 WHERE no_poliza = _no_poliza
		 
		 EXIT FOREACH;
	END FOREACH
	
	IF _no_endoso IS NOT NULL THEN
		UPDATE tmp_prod
		   SET cnt_prima_can = cnt_prima_can + 1
		 WHERE no_poliza = _no_poliza
           AND no_endoso = _no_endoso;		 
	ELSE
		INSERT INTO tmp_prod(
		no_poliza,
		user_added,
	  	cod_ramo, 
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
		cod_vendedor,	
		nombre_vendedor,
        no_endoso		
		)
		VALUES(
		_no_poliza,
		_user_added,
		_cod_ramo,
		_cod_grupo,
	 	_cod_sucursal,
		_tipo_produccion,
		_cod_agente,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,	
		0,	   
		0,	       
		1,
		0,
		_cod_producto,
		_cod_vendedor,	
		_nombre_vendedor,
        '00000'		
		);
	
	
	END IF
	

END FOREACH
}
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
