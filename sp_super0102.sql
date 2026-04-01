-- Detalle por Ramo Automovil(Canceladas) 
-- Creado:     agosto 2000 - Autor:  Yinia M. Zamora 
-- Modificado: 23/07/2001  - Autor: Marquelda Valdelamar (para incluir filtro de cliente)
--			   05/09/2001  -   							 filtro de poliza
-- Modificado: 31/10/2001  - Autor: Armando Moreno M. (para incluir columna de vigencia final)
-- Modificado: 18/12/2001  - Autor: Armando Moreno M. (para que filtrara por corredor)
-- Modificado: 23/04/2018  - Autor: Henry Giron (Filtro por Zona), DALBA
DROP procedure sp_super0102;
CREATE procedure sp_super0102(a_cia CHAR(3),a_agencia CHAR(03),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_periodo CHAR(7),a_periodo2 CHAR(7), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*",a_codvend   CHAR(255) DEFAULT "*")
RETURNING char(20),varchar(50),varchar(50),varchar(50),varchar(30),varchar(30),varchar(30),char(50),char(50),char(50),
          date,date,date,char(50),varchar(30),smallint,dec(16,2),decimal(16,2),char(30),varchar(50);

BEGIN
    DEFINE _cod_contratante,v_factura,_no_poliza,_cod_pagador,_cod_asegurado      						CHAR(10);
	define _n_perpago          											char(40);
	DEFINE _no_endoso													CHAR(5);
    DEFINE v_documento                           						CHAR(20);
    DEFINE v_codramo,v_codsucursal,cod_mov, _cod_tipocan       			CHAR(3);
    DEFINE v_codgrupo                            						CHAR(5);
    DEFINE v_prima_suscrita,v_prima_retenida,v_reaseguro,_suma_asegurada  				DECIMAL(16,2);
    DEFINE v_desc_cliente                        						CHAR(45);
    DEFINE v_desc_ramo,v_desc_grupo,v_descr_cia,v_tipo_cancelacion		CHAR(50);
    DEFINE v_filtros                             						CHAR(100);
    DEFINE _tipo                                 						CHAR(01);
    DEFINE _vig_ini,_vigencia_inic,_vig_fin,_fecha_suscripcion                           					DATE;
	DEFINE _periodo                                                  	CHAR(7);
	DEFINE _porc_partic_agt                                             DEC(5,2);
    DEFINE v_saber		     											CHAR(2);
    DEFINE v_codigo		     											CHAR(5);
    DEFINE _cod_agente													CHAR(5);
	DEFINE v_corredor,n_ramo													CHAR(50);
	DEFINE _suc_prom        	    CHAR(3);
    DEFINE _cod_vendedor		    CHAR(3);
    DEFINE _nombre_vendedor,n_agente	    	CHAR(50);
	define _user_added                                                  CHAR(10); 
	DEFINE _user_added_desc												CHAR(50);
	define n_riesgo,_ced_aseg,_ced_cont,_ced_pag						char(30);
	define _cod_perpago 		char(3);
	define _cod_cliente  		char(10);
	define _cliente_pep          smallint;
	define _cod_riesgo integer;
	define _nacionalidad,_nacionalidad_ase,_nacionalidad_pag,n_cont,n_aseg,n_pag             varchar(50);

    CREATE TEMP TABLE tmp_cancela
                (no_documento     CHAR(20),
                 cod_grupo        CHAR(05),
                 cod_ramo         CHAR(03),
                 cod_sucursal     CHAR(03),
                 cod_contratante  CHAR(10),
				 cod_tipocan      CHAR(03),
                 no_factura       CHAR(10),
                 prima_suscrita   DEC(16,2),
                 prima_retenida   DEC(16,2),
				 no_poliza        CHAR(10),
				 no_endoso        CHAR(5),
				 vig_ini		  DATE,
				 vig_fin		  DATE,
				 cod_agente       CHAR(5),
                 seleccionado     SMALLINT DEFAULT 1,
                 cod_vendedor	  CHAR(3),       -- cod_vendedor   -- Para manejo de Zonas, DALBA 19/04/2018
                 nombre_vendedor  CHAR(50),       -- nombre vendedor				 
				 user_added       CHAR(10)
				);

   CREATE INDEX i_cancela1 ON tmp_cancela(cod_grupo,cod_ramo,no_factura);
   CREATE INDEX i_cancela2 ON tmp_cancela(cod_sucursal);
   CREATE INDEX i_cancela3 ON tmp_cancela(cod_ramo);
   CREATE INDEX i_cancela4 ON tmp_cancela(cod_grupo);


    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET v_reaseguro      = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_ramo      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

    LET v_descr_cia = sp_sis01(a_cia);

    SET ISOLATION TO DIRTY READ;

    SELECT cod_endomov
      INTO cod_mov
      FROM endtimov
     WHERE tipo_mov = 2;

    FOREACH

       SELECT e.no_documento,
       		  e.cod_sucursal,
       		  e.cod_grupo,
              e.cod_ramo,
              e.cod_contratante,
              x.no_factura,
              x.prima_suscrita,
              x.prima_retenida,
              x.cod_tipocan,
			  x.vigencia_inic,
			  x.vigencia_final,
			  x.no_poliza,
			  x.no_endoso,
			  x.user_added
         INTO v_documento,
	      	  v_codsucursal,
	      	  v_codgrupo,
	      	  v_codramo,
	      	  _cod_contratante,
	          v_factura,
	          v_prima_suscrita,
	          v_prima_retenida,
	          _cod_tipocan,
	          _vig_ini,
	          _vig_fin,
			  _no_poliza,
			  _no_endoso,
			  _user_added
	     FROM emipomae e, endedmae x
	    WHERE e.cod_compania = a_cia
	      AND e.no_poliza    = x.no_poliza
	      AND x.periodo     >= a_periodo
		  AND x.periodo     <= a_periodo2
	      AND x.actualizado  = 1
	      AND x.cod_endomov  = cod_mov
	    ORDER BY e.cod_grupo,e.cod_ramo, x.no_factura

	   --Sacar el corredor
	   FOREACH
		  SELECT cod_agente
		    INTO _cod_agente
		    FROM emipoagt
		  WHERE no_poliza = _no_poliza
		  EXIT FOREACH;
	   END FOREACH
	   
		select sucursal_promotoria
		  into _suc_prom
		  from insagen
		 where codigo_agencia  = v_codsucursal
		   and codigo_compania = '001';

	   select cod_vendedor
		 into _cod_vendedor
		 from parpromo
		where cod_agente  = _cod_agente
		  and cod_agencia = _suc_prom
		  and cod_ramo	   = v_codramo;
		
		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;		
	   

       INSERT INTO tmp_cancela
       VALUES(
       v_documento,
       v_codgrupo,
       v_codramo,
       v_codsucursal,
       _cod_contratante,
	   _cod_tipocan,
       v_factura,
       v_prima_suscrita,
       v_prima_retenida,
      _no_poliza,
	  _no_endoso,
	  _vig_ini,
	  _vig_fin,
	  _cod_agente,
      1,
	  _cod_vendedor,
      _nombre_vendedor,
	  _user_added
      );

    END FOREACH

    -- Filtro de Agencia
      LET v_filtros = " ";
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      -- Filtro de Ramo
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
      -- Filtro de Grupo
      IF a_codgrupo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Grupo "||TRIM(a_codgrupo);
         LET _tipo = sp_sis04(a_codgrupo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_grupo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	--Filtro de Cliente
    IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Cte: "||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
    END IF

	--Filtro de poliza
   	IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
    END IF

	--Filtro de Agente
	IF a_agente <> "*" THEN

		LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);


		IF _tipo <> "E" THEN -- Incluir los Registros

			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       	   LET v_saber = "";

		ELSE		        -- Excluir estos Registros

			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	           LET v_saber = " Ex";
		END IF

	    FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
		      INTO v_corredor,v_codigo
		      FROM agtagent,tmp_codigos
		     WHERE agtagent.cod_agente = codigo
		     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_corredor) || (v_saber);
	    END FOREACH

		DROP TABLE tmp_codigos;

	END IF
	
	IF a_codvend <> "*" THEN   -- Aplica Filtro de Zona 
		LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String
		LET v_filtros = TRIM(v_filtros) ||" Zona :"; --||TRIM(a_codvend);

		IF _tipo <> "E" THEN -- Incluir los Registros
			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
			   LET v_saber = "";
		ELSE
			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
			   LET v_saber = " Ex";
		END IF
		
	    FOREACH
			SELECT Distinct tmp_cancela.nombre_vendedor,tmp_codigos.codigo
		      INTO _nombre_vendedor,v_codigo
		      FROM tmp_cancela,tmp_codigos
		     WHERE tmp_cancela.cod_vendedor = codigo
			 
		     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(_nombre_vendedor) || (v_saber);
	    END FOREACH		

		DROP TABLE tmp_codigos;

	END IF	

    FOREACH
		select cod_contratante,
			   sum(prima_suscrita)
		  into _cod_contratante,
			   v_prima_suscrita
		  from tmp_cancela
		 where seleccionado = 1
		 group by cod_contratante
		having sum(abs(prima_suscrita)) >= 10000
	
		foreach
		    SELECT no_documento,
				   cod_ramo,
				   prima_suscrita,
				   no_poliza,
				   vig_ini,
				   vig_fin,
				   cod_agente
			 INTO v_documento,
				  v_codramo,
				  v_prima_suscrita,
				  _no_poliza,
				  _vig_ini,
				  _vig_fin,
				  _cod_agente
			  FROM tmp_cancela
			 WHERE seleccionado = 1
			   and cod_contratante = _cod_contratante
			 ORDER BY cod_contratante

			foreach
				select cod_asegurado
				  into _cod_asegurado
				  from emipouni
				 where no_poliza = _no_poliza
				exit foreach; 
			end foreach
			
			SELECT cod_perpago,cod_pagador,fecha_suscripcion,suma_asegurada
			 INTO _cod_perpago,_cod_pagador,_fecha_suscripcion,_suma_asegurada
			 FROM emipomae
			WHERE no_poliza = _no_poliza;
			
			select nombre,cedula,cliente_pep,nacionalidad
			  into n_cont,_ced_cont,_cliente_pep,_nacionalidad
			  from cliclien
			 where cod_cliente = _cod_contratante;
			 
			select nombre,cedula,nacionalidad
			  into n_aseg,_ced_aseg,_nacionalidad_ase
			  from cliclien
			 where cod_cliente = _cod_asegurado;
			 
			select nombre,cedula,nacionalidad
			  into n_pag,_ced_pag,_nacionalidad_pag
			  from cliclien
			 where cod_cliente = _cod_pagador;
			 
			select cod_riesgo into _cod_riesgo from ponderacion
			where cod_cliente = _cod_contratante;
					
			select nombre into n_riesgo from cliriesgo
			where cod_riesgo = _cod_riesgo;	

		   --Ramo
		   SELECT nombre
			 INTO n_ramo
			 FROM prdramo
			WHERE cod_ramo = v_codramo;
			
		   SELECT nombre
			 INTO _n_perpago
			 FROM cobperpa
			WHERE cod_perpago = _cod_perpago;

		   --Corredor
		   SELECT nombre
			 INTO n_agente
			 FROM agtagent
			WHERE cod_agente = _cod_agente;
  
        RETURN v_documento, n_cont, n_aseg, n_pag,_ced_cont,_ced_aseg,_ced_pag,_nacionalidad,_nacionalidad_ase,_nacionalidad_pag, _fecha_suscripcion, _vig_ini, _vig_fin, n_ramo,n_riesgo, 
		      _cliente_pep,_suma_asegurada, v_prima_suscrita, _n_perpago, n_agente
              WITH RESUME;
		end foreach	  
    END FOREACH
   --DROP TABLE tmp_cancela;
END
END PROCEDURE;
