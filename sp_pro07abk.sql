   DROP procedure sp_pro07abk;
   CREATE procedure "informix".sp_pro07abk(
   			a_cia 		  CHAR(03),
   			a_agencia 	  CHAR(255) DEFAULT "*",
   			a_codsucursal CHAR(255) DEFAULT "*",
   			a_codramo 	  CHAR(255) DEFAULT "*",
   			a_periodo 	  DATE
   			)
   RETURNING CHAR(3),
   			 CHAR(3),
   			 CHAR(50),
   			 CHAR(50),
   			 INT,
   			 DATE,
   			 CHAR(255),
			 char(50),
			 dec(16,2);
--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro07
--------------------------------------------
BEGIN

    DEFINE v_codramo,v_codsubramo,v_codsucursal    CHAR(3);
    DEFINE v_desc_ramo,v_desc_subramo,v_filtros    CHAR(255);
    DEFINE v_unidades,unidades2                    INT;
    DEFINE v_no_poliza                             CHAR(10);
    DEFINE _tipo                                   CHAR(01);
	DEFINE v_no_unidad                             CHAR(5);
	define _no_endoso							   char(10);
	define unidades1                               integer;
	define v_desc_prov                             char(50);
	define _code_provincia						   char(2);
	define _ubica								   char(3);
	define v_suma_asegurada, v_suma_asegurada_tot, _suma_aseg_end dec(16,2);

       CREATE TEMP TABLE temp_unidad_sub
             (cod_ramo         CHAR(3),
              cod_subramo      CHAR(3),
              cod_sucursal     CHAR(3),
              unidades         INT,
              seleccionado     SMALLINT DEFAULT 1,
			  no_poliza        CHAR(10),
			  code_provincia   char(3),
			  suma_asegurada   DEC(16,2)
              )WITH NO LOG;

    CREATE INDEX i1_perfil ON temp_unidad_sub(cod_subramo);
    CREATE INDEX i2_perfil ON temp_unidad_sub(cod_sucursal);
	CREATE INDEX i3_perfil ON temp_unidad_sub(code_provincia);	
	
	create temp table temp_poliza
		(no_poliza		char(10),
		no_unidad       char(5),
		cod_ubica       char(3),
		cod_ramo		char(3),
		cod_sucursal	char(3),
		suma_asegurada	dec(16,2) default 0.00,
	primary key (no_poliza, no_unidad)) with no log;

    LET v_filtros = sp_pro03(a_cia,a_agencia,a_periodo,a_codramo);
	--LET v_filtros = sp_pro83(a_cia,a_agencia,a_periodo,a_codramo);

    LET v_codsubramo   = NULL;
    LET v_codramo      = NULL;
    LET v_desc_subramo = NULL;
    LET v_desc_ramo    = NULL;
    LET v_unidades     = 0;
    LET unidades2      = 0;

    SET ISOLATION TO DIRTY READ;
	
--SET DEBUG FILE TO "sp_pro07a.trc"; 
--trace on;
	
	
FOREACH
       SELECT y.no_poliza,
       		  y.cod_sucursal,
       		  y.cod_ramo,
       		  y.cod_subramo,
			  y.suma_asegurada
         INTO v_no_poliza,
         	  v_codsucursal,
         	  v_codramo,
         	  v_codsubramo,
			  v_suma_asegurada
         FROM temp_perfil y,emitipro z
        WHERE y.cod_tipoprod = z.cod_tipoprod
		  AND z.tipo_produccion IN (1,4)
 		  AND y.cod_grupo NOT IN ('00069', '00081', '00056', '00060', '00051')
          AND y.seleccionado = 1
--		  and y.no_documento = "0213-01334-01"

       IF v_codramo IS NULL THEN
          CONTINUE FOREACH;
       END IF
	   
	let v_suma_asegurada_tot = 0;
	let _suma_aseg_end = 0;
	let v_suma_asegurada = 0;
   
	foreach
		select e.no_unidad, 
               c.code_provincia		
		  into v_no_unidad,
		       _code_provincia
		  from emipouni e, cliclien c
		WHERE e.cod_asegurado = c.cod_cliente
		  and e.no_poliza = v_no_poliza
		  
	   select cod_ubica
	     into _ubica
		 from genprov
		where code_pais = '001'
		  and code_provincia = _code_provincia;
		 
		foreach 
			select a.no_endoso
			  into _no_endoso
			  from endedmae a
			 where a.no_poliza = v_no_poliza
			   and a.fecha_emision <= a_periodo
			
			select b.suma_asegurada
			  into _suma_aseg_end
			  from endeduni b  
			 where b.no_poliza = v_no_poliza
			   and b.no_endoso = _no_endoso
			   and b.no_unidad = v_no_unidad;

			if _suma_aseg_end is null then
				let _suma_aseg_end = 0;
			end if
			   
			let v_suma_asegurada = 0.00;
			
			select SUM(suma_asegurada)
			  into v_suma_asegurada
			  from emifacon
			 where no_poliza = v_no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = v_no_unidad;
			   
			if v_suma_asegurada is null then
				let v_suma_asegurada = 0.00;
			end if
			 
			if v_suma_asegurada <> 0 then
				if abs (_suma_aseg_end - v_suma_asegurada) > 1.00 then
					let v_suma_asegurada = _suma_aseg_end;
				end if
			end if
			
			begin
				on exception in(-239)
					update temp_poliza
					   set suma_asegurada	= suma_asegurada + v_suma_asegurada
					 where no_poliza = v_no_poliza
					   and no_unidad = v_no_unidad;

				end exception

				insert into temp_poliza
				values(	v_no_poliza,
						v_no_unidad,
						_ubica,
						v_codramo,
						v_codsucursal,
						v_suma_asegurada);
			end
	    end foreach
		
		let v_suma_asegurada = 0;
		let _suma_aseg_end = 0;

	end foreach		 
	   
    foreach
	   SELECT COUNT(e.no_unidad),
	          c.code_provincia
		 INTO v_unidades,
              _code_provincia		 
         FROM emipouni e, cliclien c
		WHERE e.cod_asegurado = c.cod_cliente
		   AND e.no_poliza    = v_no_poliza
  	  GROUP BY c.code_provincia
		 
       IF v_unidades IS NULL OR v_unidades = 0  THEN
          LET v_unidades = 0;
          CONTINUE FOREACH;
       END IF;		

	   select cod_ubica
	     into _ubica
		 from genprov
		where code_pais = '001'
		  and code_provincia = _code_provincia;
		
       let v_suma_asegurada_tot = 0;		
       		 
	   select sum(suma_asegurada)
	     into v_suma_asegurada_tot
		 from temp_poliza
		where no_poliza = v_no_poliza
		  and cod_ubica = _ubica;
		  
		BEGIN
			  ON EXCEPTION IN(-239)

				  CONTINUE FOREACH;

			  END EXCEPTION
			  INSERT INTO temp_unidad_sub
				  VALUES(v_codramo,
						 v_codsubramo,
						 v_codsucursal,
						 v_unidades,
						 1,
						 v_no_poliza,
						 _ubica,
						 v_suma_asegurada_tot);
		END
	end foreach	

END FOREACH

	IF a_codramo <> "*" THEN
        LET v_filtros ="";
        LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
	END IF;

     -- Procesos v_filtros

    IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Agencia "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_unidad_sub
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_unidad_sub
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

    FOREACH
       SELECT y.cod_ramo,
       		  y.cod_subramo,
			  y.code_provincia,
       		  SUM(y.unidades),
			  SUM(y.suma_asegurada)
         INTO v_codramo,
         	  v_codsubramo,
			  _ubica,
         	  v_unidades,
			  v_suma_asegurada
         FROM temp_unidad_sub y
        WHERE y.seleccionado = 1
     GROUP BY y.cod_ramo,y.code_provincia,y.cod_subramo
     ORDER BY y.cod_ramo,y.code_provincia,y.cod_subramo

        SELECT a.nombre
          INTO v_desc_ramo
          FROM prdramo a
         WHERE a.cod_ramo  = v_codramo;

	   SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_subramo = v_codsubramo
          AND cod_ramo    = v_codramo;
		
		SELECT nombre
          INTO v_desc_prov
          FROM emiubica
         WHERE cod_ubica = _ubica;

       RETURN v_codramo,v_codsubramo,v_desc_ramo,v_desc_subramo,v_unidades,
              a_periodo,v_filtros,v_desc_prov,v_suma_asegurada WITH RESUME;

    END FOREACH

--DROP TABLE temp_unidad_sub;
--DROP TABLE temp_perfil;
--DROP TABLE temp_poliza;
END
END PROCEDURE;