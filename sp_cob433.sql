-- Detalle por Ramo Automovil(Canceladas) 
-- Creado:     agosto 2000 - Autor:  Yinia M. Zamora 
-- Modificado: 23/07/2001  - Autor: Marquelda Valdelamar (para incluir filtro de cliente)
--			   05/09/2001  -   							 filtro de poliza
-- Modificado: 31/10/2001  - Autor: Armando Moreno M. (para incluir columna de vigencia final)
-- Modificado: 18/12/2001  - Autor: Armando Moreno M. (para que filtrara por corredor)
-- Modificado: 23/04/2018  - Autor: Henry Giron (Filtro por Zona), DALBA
DROP procedure sp_cob433;
CREATE procedure sp_cob433(a_cia CHAR(3),a_agencia CHAR(03),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",
                           a_periodo CHAR(7),a_periodo2 CHAR(7), a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*",
						   a_agente CHAR(255) DEFAULT "*",a_codvend   CHAR(255) DEFAULT "*")
RETURNING CHAR(50),
		  CHAR(5),
		  CHAR(50),
		  CHAR(3),
		  CHAR(50),
		  CHAR(50),	   --subramo
		  char(5),
		  char(50),
		  char(10),   --cod_contratante
		  char(50),
          CHAR(20),
          DATE,
          DATE,
	      char(3),      --tipo_cliente
		  char(10),     --tipo_poliza
          CHAR(50),
		  char(10),     --factura
          DECIMAL(16,2),
          CHAR(7),
		  char(3),
          CHAR(50), --corredor
          CHAR(50), --zona ventas
		  CHAR(50), --forma de pago
		  DEC(16,2),
		  char(50),
		  date,
		  varchar(100),
		  char(50),
		  char(50),
          DECIMAL(16,2);

BEGIN
    DEFINE v_contratante,v_factura,_no_poliza,_tipo_poliza,_cod_asegurado CHAR(10);
	DEFINE _no_endoso													CHAR(5);
    DEFINE v_documento                           						CHAR(20);
    DEFINE v_codramo,v_codsucursal,cod_mov, _cod_tipocan,_tipo_cliente	CHAR(3);
    DEFINE v_codgrupo                            						CHAR(5);
    DEFINE v_prima_suscrita,v_prima_retenida,v_reaseguro,_saldo,_prima_bruta  		DECIMAL(16,2);
    DEFINE v_desc_cliente                        						CHAR(45);
    DEFINE v_desc_ramo,v_desc_grupo,v_descr_cia,v_tipo_cancelacion		CHAR(50);
    DEFINE v_filtros                             						CHAR(100);
    DEFINE _tipo                                 						CHAR(1);
    DEFINE _vig_ini,_vig_fin,_fecha_cancela            					DATE;
	DEFINE _periodo                                                  	CHAR(7);
    DEFINE v_saber		     											CHAR(2);
    DEFINE v_codigo		     											CHAR(5);
    DEFINE _cod_agente,_cod_producto									CHAR(5);
	DEFINE v_corredor,_n_subramo,_n_producto,_n_asegurado,_zona_ventas	CHAR(50);
	DEFINE _suc_prom,_cod_cobrador,_cod_formapag        	    CHAR(3);
    DEFINE _cod_vendedor,_cod_subramo		    CHAR(3);
    DEFINE _nombre_vendedor	    	CHAR(50);
	define _user_added                                                  CHAR(10); 
	DEFINE _user_added_desc,_forma_pago,_zona_cobros					CHAR(50);
    define _cnt                     smallint;	
	
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
	      	   v_contratante,
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
		   and x.cod_tipocan <> '019'		--No Cancelacion Administrativa
	     ORDER BY e.cod_grupo,e.cod_ramo, x.no_factura

	    --Corredor
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
       v_contratante,
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
       SELECT no_documento,
       		  cod_grupo,
       		  cod_ramo,
              cod_contratante,
              no_factura,
              prima_suscrita,
              prima_retenida,
              cod_tipocan,
			  no_poliza,
			  no_endoso,
              vig_ini,
              vig_fin,
			  cod_agente,
			  user_added,
			  nombre_vendedor
         INTO v_documento,
              v_codgrupo,
              v_codramo,
              v_contratante,
              v_factura,
              v_prima_suscrita,
              v_prima_retenida,
              _cod_tipocan,
			  _no_poliza,
			  _no_endoso,
              _vig_ini,
              _vig_fin,
			  _cod_agente,
			  _user_added,
			  _zona_ventas
         FROM tmp_cancela
        WHERE seleccionado = 1
        ORDER BY cod_tipocan,cod_grupo,cod_ramo,no_factura

	   --Contratante
        SELECT nombre
          INTO v_desc_cliente
          FROM cliclien
         WHERE cod_cliente = v_contratante;
		
		select count(*)
		  into _cnt
		  from clivip
		 where cod_cliente = v_contratante;
		
		if _cnt is null THEN
			let _cnt = 0;
		end if
		if _cnt > 0 then 	--es VIP
			let _tipo_cliente = "VIP";
		ELSE
			let _tipo_cliente = "";
		end if

	   --Ramo
       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_codramo;

	   --Grupo
       SELECT nombre
         INTO v_desc_grupo
         FROM cligrupo
        WHERE cod_grupo = v_codgrupo;

	   --Tipo de Cancelacion
       SELECT nombre
	     INTO v_tipo_cancelacion
	     FROM endtican
	    WHERE cod_tipocan = _cod_tipocan;

	    --Corredor
        SELECT nombre,
	           cod_cobrador
          INTO v_corredor,
		       _cod_cobrador
          FROM agtagent
         WHERE cod_agente = _cod_agente;
		
		select nombre into _zona_cobros from cobcobra
		where cod_cobrador = _cod_cobrador;

	   SELECT periodo,
	          prima_bruta,
			  fecha_emision
	     INTO _periodo,
		      _prima_bruta,
			  _fecha_cancela
		 FROM endedmae
		WHERE no_poliza = _no_poliza
		  AND no_endoso = _no_endoso;
		  
		foreach
			select cod_producto,cod_cliente
			  into _cod_producto,_cod_asegurado
			  from endeduni
			 where no_poliza = _no_poliza
               and no_endoso = _no_endoso
				
			exit foreach;
		end foreach
		
		--Asegurado
        SELECT nombre
          INTO _n_asegurado
          FROM cliclien
         WHERE cod_cliente = _cod_asegurado;
		  
		select cod_subramo,
		       decode(nueva_renov,"N","NUEVA","R","RENOVADA"),
			   cod_formapag
		  into _cod_subramo,
		       _tipo_poliza,
			   _cod_formapag
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _n_producto
		  from prdprod
		 where cod_producto = _cod_producto;

		select nombre
		  into _forma_pago
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		select nombre
		  into _n_subramo
		  from prdsubra
		 where cod_ramo    = v_codramo
           and cod_subramo = _cod_subramo;

	   select trim(upper(descripcion))
 	     into _user_added_desc 
		 from insuser 
		where usuario = _user_added;
		
		let _saldo = 0;
		let _saldo = sp_cob174(v_documento);

       RETURN v_descr_cia,v_codgrupo,v_desc_grupo,v_codramo,v_desc_ramo,_n_subramo,_cod_producto,_n_producto,v_contratante,v_desc_cliente,v_documento,
			  _vig_ini,_vig_fin,_tipo_cliente,_tipo_poliza,_n_asegurado,v_factura,v_prima_suscrita,_periodo,_cod_tipocan,v_corredor,_zona_ventas,_forma_pago,
			  _prima_bruta,_zona_cobros,_fecha_cancela,v_filtros,v_tipo_cancelacion,_user_added_desc,_saldo WITH RESUME;

       LET v_prima_suscrita = 0;
    END FOREACH
   DROP TABLE tmp_cancela;
END
END PROCEDURE;
