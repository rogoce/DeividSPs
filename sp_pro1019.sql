-- REPORTE DE POLIZAS - CARTERA VIGENTE POR CORREDOR - (SOLICITUD DE LOS REASEGURADORES)
-- BALANCEAR LA CARTERA DE INCENDIO 
-- Creado    : 19/08/2011      -- Autor: Henry Giron 
-- Execute Procedure sp_pro1019("001","001",'23/10/2018',"*","001,003;","*","00035;","*","*","*","*")
DROP procedure sp_pro1019;
CREATE procedure "informix".sp_pro1019(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*",a_usuario CHAR(255) DEFAULT "*", a_cod_cliente CHAR(255) DEFAULT "*", a_acreedor CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING 
CHAR(3) as cia, 
CHAR(50) as descr_cia,
DECIMAL(5,2) as porc_coaseguro,
CHAR(3) as cod_ramo,
CHAR(50) as desc_ramo,
CHAR(3)  as cod_subramo, 
char(50) as n_subramo,
char(5) as cod_producto, 
char(50)  as n_plan,			  
CHAR(20) as no_documento,
CHAR(45) as asegurado,
DATE as vigencia_inic,
DATE as vigencia_final, 
CHAR(40) as desc_grupo,
DECIMAL(16,2) as suma_asegurada,
DECIMAL(16,2) as prima_suscrita,
--CHAR(255) as filtros,
CHAR(10) as no_poliza,
CHAR(5) as cod_agente,
CHAR(50) as nombre_agente,
DECIMAL(5,2) as porc_partic_agt,
CHAR(50) as referencia,
CHAR(50) as tipo_asegurado, 
CHAR(5) as no_unidad,
DECIMAL(16,2) as suma_asegurada_uni,
DECIMAL(16,2) as prima_suscrita_uni,
INTEGER as zona_libre,
CHAR(50) as ubicacion,
char(50) as provincia,
char(50) as distrito,
char(50) as corregimiento,
DECIMAL(5,2) as porc_comision_agt,
char(30) as Ruc_agente;
		  
		  
    DEFINE v_cod_ramo,v_cod_sucursal  			 CHAR(3);
    DEFINE v_saber					  			 CHAR(2);
    DEFINE v_cod_grupo,_cod_acreedor,_limite	 CHAR(5);
    DEFINE v_contratante,v_codigo,_temp_poliza	 CHAR(10);
    DEFINE v_asegurado                			 CHAR(45);
    DEFINE v_desc_ramo,v_descr_cia,v_desc_agente CHAR(50);
    DEFINE v_desc_grupo               			 CHAR(40);
    DEFINE v_no_documento             			 CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   	 DATE;
    DEFINE v_cant_polizas             			 INTEGER;
    DEFINE v_prima_suscrita,v_suma_asegurada   	 DECIMAL(16,2);
    DEFINE _tipo              					 CHAR(1);
    DEFINE v_filtros          					 CHAR(255);
	DEFINE v_no_poliza							 CHAR(10);
    DEFINE _cod_agente                           CHAR(5); 
    DEFINE _nombre_agente                        CHAR(50); 
    DEFINE u_no_unidad                           CHAR(5);
    DEFINE u_suma_asegurada  					 DECIMAL(16,2);
	DEFINE u_prima_suscrita					     DECIMAL(16,2);
    DEFINE u_tipo_incendio                       INTEGER;
    DEFINE u_cod_manzana                         CHAR(15); 
    DEFINE u_tipo_asegurado                      CHAR(50); 
    DEFINE u_referencia                          CHAR(50); 
    DEFINE u_zona_libre                          INTEGER;
	DEFINE _cod_ubica                            CHAR(3);
    DEFINE v_ubicacion                           CHAR(50); 
	DEFINE v_porc_ubicacion					     DECIMAL(9,4);	
    DEFINE _cod_subramo                          CHAR(3);
    define _cod_tipoprod		                 char(3);		 
	define _cod_producto   	                     char(5);
    define _n_plan          	                 char(50);	
	define _n_subramo                            char(50);   
	define _porc_partic_agt	,_porc_comis_agt     dec(5,2);
	define _porc_coaseguro	                     dec(5,2);		
	define _cod_coasegur	                     char(3);
	
define _n_prov                  char(50);
define _n_dist					char(50);
define _cod_provincia           char(2);
define _cod_distrito            char(3);
define _cod_manzana             char(15);	
define _n_correg				char(50);
define _cod_correg              char(3);
define _cnt_vig                 integer;
define _cedula                  char(30);

---   v_filtros, v_descr_cia CHAR(255), CHAR(50)          
CREATE TEMP TABLE tmp_vigentes
    ( cod_ramo		   	CHAR(3),		 
	  desc_ramo		   	CHAR(50),		 
	  no_documento	   	CHAR(20),		 
	  asegurado		   	CHAR(45),		 
	  vigencia_inic	   	DATE,			 
	  vigencia_final   	DATE,			 
	  desc_grupo	   	CHAR(40),		 
	  suma_asegurada   	DEC(16,2),		 
	  prima_suscrita   	DEC(16,2),		 
	  filtros		   	CHAR(255),		 
	  descr_cia		   	CHAR(50),		 
	  no_poliza        	CHAR(10),		 
	  cod_agente       	CHAR(5),		 
	  nombre_agente    	CHAR(50),		 
	  referencia	   	CHAR(50),		 
	  tipo_asegurado   	CHAR(50),		 
	  no_unidad        	CHAR(5),		 
	  usuma_asegurada    DEC(16,2),		 
	  uprima_suscrita    DEC(16,2),		 
	  zona_libre        INTEGER,
	  ubicacion			CHAR(50),	  
	  cod_subramo       CHAR(3),		  
	  cod_tipoprod		char(3),
      cedula	        char(30),
      PRIMARY KEY (no_poliza,no_unidad)         
     )WITH NO LOG;

CREATE INDEX idx1_tmp_vigentes ON tmp_vigentes(no_poliza);
CREATE INDEX idx2_tmp_vigentes ON tmp_vigentes(no_unidad);


    LET v_cod_ramo       = NULL;
    LET v_cod_sucursal   = NULL;
    LET v_cod_grupo      = NULL;
    LET v_contratante    = NULL;
    LET v_no_documento   = NULL;
    LET v_desc_ramo      = NULL;
    LET v_descr_cia      = NULL;
    LET v_cant_polizas   = 0;
    LET v_prima_suscrita = 0;
    LET _tipo            = NULL;
	LET u_tipo_asegurado  = '';
	LET u_referencia      = '';
	LET u_zona_libre      = 0;
	LET v_porc_ubicacion  = 0;
	LET v_ubicacion       = '';
	let _cod_coasegur       = '';

    SET ISOLATION TO DIRTY READ;
--    SET DEBUG FILE TO "sp_pro4938.trc";
--    TRACE ON;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;

    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN       -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    IF a_agente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "; --  ||TRIM(a_agente);
         LET _tipo = sp_sis04(a_agente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = "";
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
			       LET v_saber = " Ex";
         END IF
		 FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
	          INTO v_desc_agente,v_codigo
	          FROM agtagent,tmp_codigos
	         WHERE agtagent.cod_agente = codigo
	         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
		 END FOREACH

         DROP TABLE tmp_codigos;
    END IF

    IF a_usuario <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor: "||TRIM(a_usuario);
         LET _tipo = sp_sis04(a_usuario); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND usuario NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND usuario IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cliente: "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF

    IF a_acreedor <> "*" THEN

		 CREATE TEMP TABLE tmp_acreedor
			   (cod_acreedor CHAR(5),
			    no_poliza    CHAR(10),
				limite       DEC(16,2),
				seleccionado SMALLINT DEFAULT 1)
              WITH NO LOG;

		 FOREACH
		 	SELECT no_poliza 
			  INTO _temp_poliza
			  FROM temp_perfil
			 WHERE seleccionado = 1
			FOREACH
				SELECT cod_acreedor, limite
				  INTO _cod_acreedor, _limite
				  FROM emipoacr
				 WHERE no_poliza = _temp_poliza

				INSERT INTO tmp_acreedor
				     VALUES(_cod_acreedor,
					        _temp_poliza,
							_limite,
							1);
			END FOREACH
		 END FOREACH

         LET v_filtros = TRIM(v_filtros) ||"Acreedor: "||TRIM(a_acreedor);
         LET _tipo = sp_sis04(a_acreedor); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_acreedor
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_acreedor NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_acreedor
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_acreedor IN(SELECT codigo FROM tmp_codigos);
         END IF

         UPDATE temp_perfil
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND no_poliza NOT IN(SELECT no_poliza FROM tmp_acreedor WHERE seleccionado = 1);

         DROP TABLE tmp_codigos;
         DROP TABLE tmp_acreedor;
    END IF

    FOREACH 
       SELECT y.no_documento,y.cod_ramo,y.cod_subramo,y.cod_tipoprod,y.cod_contratante,y.vigencia_inic,y.vigencia_final,y.cod_grupo,y.suma_asegurada,y.prima_suscrita,y.no_poliza
         INTO v_no_documento,v_cod_ramo,_cod_subramo,_cod_tipoprod,v_contratante,v_vigencia_inic,v_vigencia_final,v_cod_grupo,v_suma_asegurada,v_prima_suscrita,v_no_poliza
         FROM temp_perfil y
        WHERE y.seleccionado = 1 -- and y.no_poliza = '405212'
     ORDER BY y.cod_ramo,y.no_documento

		FOREACH
		SELECT cod_agente	 
		  INTO _cod_agente	 
		  FROM emipoagt	 
		 WHERE no_poliza = v_no_poliza	 

		SELECT nombre, cedula	 
		  INTO _nombre_agente, _cedula
		  FROM agtagent	 
		 WHERE cod_agente = _cod_agente;	 

		  EXIT FOREACH;
		   END FOREACH

       	SELECT a.nombre 
       	  INTO v_desc_ramo 
       	  FROM prdramo a 
       	 WHERE a.cod_ramo  = v_cod_ramo; 

       	SELECT nombre 
       	  INTO v_asegurado 
       	  FROM cliclien 
       	 WHERE cod_cliente = v_contratante; 

       	SELECT nombre 
       	  INTO v_desc_grupo 
       	  FROM cligrupo 
       	 WHERE cod_grupo = v_cod_grupo; 

           LET u_suma_asegurada = 0;
           LET u_prima_suscrita = 0;				 

       FOREACH 
          SELECT no_unidad,
          		 suma_asegurada,
				 prima_suscrita,
				 tipo_incendio,
				 cod_manzana
            INTO u_no_unidad,
            	 u_suma_asegurada,
				 u_prima_suscrita,
				 u_tipo_incendio,
				 u_cod_manzana
            FROM emipouni
           WHERE no_poliza = v_no_poliza

			 LET u_referencia      = '';
			 LET u_tipo_asegurado  = 'etc';

			  IF u_tipo_incendio = 1 THEN
				 LET u_tipo_asegurado  = 'Edificio';
			 END IF

			  IF u_tipo_incendio = 2 THEN
				 LET u_tipo_asegurado  = 'Contenido';
			 END IF

			  IF u_tipo_incendio = 3 THEN
				 LET u_tipo_asegurado  = 'Lucro Cesante';
			 END IF

	       	SELECT referencia
	       	  INTO u_referencia 
	       	  FROM emiman05 
	       	 WHERE cod_manzana = u_cod_manzana; 
			  
			  IF u_referencia is null THEN
				 LET u_referencia  = '';
			 END IF
			  IF u_cod_manzana[1,12] in ('030010020103','030010064400') THEN
				 LET u_zona_libre = 1;
			 ELSE
				 LET u_zona_libre = 0;
			 END IF

			FOREACH
			 SELECT	cod_ubica 
			   INTO _cod_ubica 
			   FROM	endcuend
			  WHERE no_poliza = v_no_poliza
				AND no_unidad = u_no_unidad

			 SELECT nombre
			   INTO v_ubicacion
			   FROM emiubica
			  WHERE cod_ubica = _cod_ubica;

			  EXIT FOREACH;
			   END FOREACH

--			BEGIN
--	   			ON EXCEPTION IN(-239)
--				END EXCEPTION

				INSERT INTO tmp_vigentes
	 					 ( cod_ramo,
						   desc_ramo,
						   no_documento,
						   asegurado,
				   		   vigencia_inic,
						   vigencia_final,
				           desc_grupo,
						   suma_asegurada,
						   prima_suscrita,
						   filtros,
						   descr_cia,
						   no_poliza,
						   cod_agente,
						   nombre_agente,
						   referencia,
						   tipo_asegurado,
						   no_unidad,
						   usuma_asegurada,
						   uprima_suscrita,
						   zona_libre,
						   ubicacion,
                           cod_subramo,
                           cod_tipoprod,
                           cedula)
				   VALUES( v_cod_ramo,				 
						   v_desc_ramo,				 
						   v_no_documento,			 
						   v_asegurado,				 
				   		   v_vigencia_inic,			 
						   v_vigencia_final,		 
				           v_desc_grupo,			 
						   v_suma_asegurada,		 
						   v_prima_suscrita,		 
						   v_filtros,				 
						   v_descr_cia,				 
						   v_no_poliza, 			 
						   _cod_agente,				 
						   _nombre_agente,			 
						   u_referencia,			 
						   u_tipo_asegurado,		 
						   u_no_unidad,				 
						   u_suma_asegurada,		 
						   u_prima_suscrita,
						   u_zona_libre,
						   v_ubicacion,
                           _cod_subramo,
                           _cod_tipoprod,_cedula);	 
  --			END			   
	    END FOREACH

    END FOREACH
    SET ISOLATION TO DIRTY READ;
	
	select par_ase_lider       
	  into _cod_coasegur	   
	  from parparam
	 where cod_compania = a_cia;	

    FOREACH 
       SELECT cod_ramo,
			  desc_ramo,
			  no_documento,
			  asegurado,
			  vigencia_inic,
			  vigencia_final,
			  desc_grupo,
			  suma_asegurada,
			  prima_suscrita,
			  filtros,
			  descr_cia,
			  no_poliza,
			  cod_agente,
			  nombre_agente,
			  referencia,
			  tipo_asegurado,
			  no_unidad,
			  usuma_asegurada,
			  uprima_suscrita,
			  zona_libre,
			  ubicacion,
              cod_subramo,
              cod_tipoprod,
              cedula			  
         INTO v_cod_ramo,
			  v_desc_ramo,
			  v_no_documento,
			  v_asegurado,
			  v_vigencia_inic,
			  v_vigencia_final,
			  v_desc_grupo,
			  v_suma_asegurada,
			  v_prima_suscrita,
			  v_filtros,
			  v_descr_cia,
			  v_no_poliza,
			  _cod_agente,
			  _nombre_agente,
			  u_referencia,
			  u_tipo_asegurado,
			  u_no_unidad,
			  u_suma_asegurada,
			  u_prima_suscrita,
			  u_zona_libre,
			  v_ubicacion,
			  _cod_subramo,
			  _cod_tipoprod,
			  _cedula
         FROM tmp_vigentes 
     ORDER BY nombre_agente,cod_ramo,zona_libre, no_documento, no_unidad	 	 	  	 	 
	   
	    let _cnt_vig = 0;
	 
		select count(*)
		into _cnt_vig
		  from emipoliza a, emipomae b
		where  a.cod_status = '1'
		and a.no_poliza = b.no_poliza
		and b.no_poliza = v_no_poliza;
		
		if _cnt_vig is null then
			let _cnt_vig = 0;
		end if	
		
		  if _cnt_vig = 0 then
		     continue foreach;
		 end if			   
	 
	     let _porc_coaseguro = 100;

		  if _cod_tipoprod = "001" then	--Coaseguro Mayoritario, sacar nuestra participacion	  

			select porc_partic_coas
			  into _porc_coaseguro
			  from emicoama
			 where no_poliza    = v_no_poliza
			   and cod_coasegur = _cod_coasegur;
	     end if		   

	 	 foreach
		 select cod_producto, nombre
	       into _cod_producto, _n_plan
	       from prdprod
	      where cod_ramo = v_cod_ramo 
		  and cod_subramo = _cod_subramo
		  AND activo = 1
		  exit foreach;
		  end foreach
	 
	    select nombre
          into _n_subramo
	      from prdsubra
	     where cod_ramo    = v_cod_ramo
	       and cod_subramo = _cod_subramo;	  
		  
		foreach
		select porc_partic_agt,porc_comis_agt
		  into _porc_partic_agt, _porc_comis_agt
		  from emipoagt
		 where no_poliza = v_no_poliza
		   and cod_agente = _cod_agente
		   exit foreach;
		   end foreach
		   
		foreach

			   SELECT cod_manzana
				 INTO _cod_manzana
				 FROM emipouni
				WHERE no_poliza = v_no_poliza
				and no_unidad = u_no_unidad

			   exit foreach;
		   end foreach

		  if _cod_manzana is null then
			 let _n_prov = "";
			 let _n_dist = "";
		  else
		   SELECT cod_provincia,
				  cod_distrito,
				  cod_correg
			 INTO _cod_provincia,
				  _cod_distrito,
				  _cod_correg
			 FROM emiman05
			WHERE cod_manzana = _cod_manzana;

			SELECT nombre
			  INTO _n_prov
			  FROM emiman01
			 WHERE cod_provincia = _cod_provincia;

			SELECT nombre
			  INTO _n_dist
			  FROM emiman02
			 WHERE cod_provincia = _cod_provincia
			   AND cod_distrito  = _cod_distrito;
			   
			SELECT nombre
			  INTO _n_correg	
			  FROM emiman03
			 WHERE cod_provincia = _cod_provincia
			   AND cod_distrito  = _cod_distrito
			   and cod_correg = _cod_correg;			   
			   
		  end if
		  
			if _n_prov is null then
				let _n_prov = '';
			end if		  
			if _n_dist is null then
				let _n_dist = '';			
			end if		  
			if _n_correg is null then
				let _n_correg = '';			
			end if		  	    					
	 

       RETURN a_cia,  v_descr_cia, _porc_coaseguro,
	          v_cod_ramo,
              v_desc_ramo,
			  _cod_subramo, _n_subramo, _cod_producto, _n_plan,
              v_no_documento,
              v_asegurado,
              v_vigencia_inic,
              v_vigencia_final,
              v_desc_grupo,
              v_suma_asegurada,
              v_prima_suscrita,
--              v_filtros,
              v_no_poliza,
              _cod_agente,
              _nombre_agente,
			  _porc_partic_agt,
              u_referencia,
              u_tipo_asegurado,
              u_no_unidad,
              u_suma_asegurada,
              u_prima_suscrita,
              u_zona_libre,
              v_ubicacion,
		      _n_prov,
		      _n_dist,
              _n_correg,
			  _porc_comis_agt,
			  _cedula
              WITH RESUME;  
												 
    END FOREACH


DROP TABLE temp_perfil;
DROP TABLE tmp_vigentes;
END PROCEDURE;

  