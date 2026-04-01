-- Procedimiento que Selecciona los Filtros de cada Aviso Cancelacion Automatico 
-- Creado    : 23/12/2010 Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob756;

CREATE PROCEDURE sp_cob756(a_cod_avican CHAR(10),a_codramo CHAR(255) DEFAULT "*",a_codmoros CHAR(255) DEFAULT "*",a_codformapag CHAR(255) DEFAULT "*",a_codzonacob CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codsuc CHAR(255) DEFAULT "*",a_codarea CHAR(255) DEFAULT "*",a_codstatus CHAR(255) DEFAULT "*",a_codcobra CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codiacob CHAR(255) DEFAULT "*",a_codacre CHAR(255) DEFAULT "*",a_codpago CHAR(255) DEFAULT "*")
RETURNING INTEGER,
          CHAR(100);

DEFINE _error	  	 INTEGER;
DEFINE _tipo	  	 CHAR(1);
DEFINE _codigo	  	 CHAR(10);
DEFINE _ramo_nom  	 CHAR(50);
DEFINE _nom_moros	 CHAR(50);
DEFINE _nom_formapag CHAR(50);
DEFINE _nom_zonacob	 CHAR(50);
DEFINE _nom_suc		 CHAR(50);
DEFINE _nom_agente	 CHAR(50);
DEFINE _nom_area	 CHAR(50);
DEFINE _nom_status	 CHAR(50);
DEFINE _nom_grupo	 CHAR(50);
DEFINE _nom_pago	 CHAR(50);
DEFINE _nom_acre	 CHAR(50);
DEFINE _dia			 CHAR(10);


--BEGIN
ON EXCEPTION SET _error
   --	rollback work;
	RETURN _error, "Error al Ingresar los Filtros de Aviso Cancelacion Automatico";
END EXCEPTION

--set debug file to "sp_cob756.trc";
--trace on;

LET _codigo = "";
--Proceso que ingresa los filtros por Ramo en la tabla avicanfil
IF a_codramo <> "*" THEN
	LET _tipo = sp_sis04(a_codramo);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- (I) Incluir los Registros
	   FOREACH
		   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT nombre
			 INTO _ramo_nom
			 FROM prdramo
		   	WHERE cod_ramo = _codigo; 

		   INSERT INTO avicanfil(
			   cod_avican,
			   cod_filtro,
			   tipo_filtro,
			   descripcion)
		   VALUES(
			   a_cod_avican,
			   _codigo,
			   1,
			   _ramo_nom); 
	   END FOREACH;			
		  
		{ELSE		        -- (E) Excluir estos Registros

		   UPDATE tmp_cob
		   	  SET seleccionado = 0
			WHERE seleccionado = 1
			  AND cod_agente IN (SELECT codigo FROM tmp_codigos); }

		END IF
		DROP TABLE tmp_codigos;
END IF

LET _codigo = "";
--Proceso que ingresa los filtros por Morosidad en la tabla avicanfil
IF a_codmoros <> "*" THEN
	LET _tipo = sp_sis04(a_codmoros);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- (I) Incluir los Registros
	   FOREACH
		   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT descripcion
			 INTO _nom_moros
			 FROM insmoros
		   	WHERE cod_moros = _codigo; 

		   INSERT INTO avicanfil(
			   cod_avican,
			   cod_filtro,
			   tipo_filtro,
			   descripcion)
		   VALUES(
			   a_cod_avican,
			   _codigo,
			   2,
			   _nom_moros); 
	   END FOREACH;			
	   
	END IF
	DROP TABLE tmp_codigos;

END IF

LET _codigo = "";
--Proceso que ingresa los filtros por Forma de Pago en la tabla avicanfil
IF a_codformapag <> "*" THEN
	LET _tipo = sp_sis04(a_codformapag);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- (I) Incluir los Registros
	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT nombre
		     INTO _nom_formapag
		     FROM cobforpa
			WHERE cod_formapag = _codigo;

		   INSERT INTO avicanfil(
		      cod_avican,
		      cod_filtro,
		      tipo_filtro,
		      descripcion)
		   VALUES(
		      a_cod_avican,
		      _codigo,
		      3,
		      _nom_formapag); 
		END FOREACH;			
		  
		{ELSE		        -- (E) Excluir estos Registros

		   UPDATE tmp_cob
		   	  SET seleccionado = 0
			WHERE seleccionado = 1
			  AND cod_agente IN (SELECT codigo FROM tmp_codigos); }

		END IF
		DROP TABLE tmp_codigos;
END IF

LET _codigo = "";
--Proceso que ingresa los filtros por Forma de Pago en la tabla cascampanafil
IF a_codzonacob <> "*" THEN
	LET _tipo = sp_sis04(a_codzonacob);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- (I) Incluir los Registros
	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT nombre
		     INTO _nom_zonacob
		     FROM cobcobra
			WHERE cod_cobrador = _codigo;

		   INSERT INTO avicanfil(
		      cod_avican,
		      cod_filtro,
		      tipo_filtro,
		      descripcion)
		   VALUES(
		      a_cod_avican,
		      _codigo,
		      4,
		      _nom_zonacob); 
		END FOREACH;			

	END IF
		DROP TABLE tmp_codigos;
END IF


LET _codigo = "";
--Proceso que ingresa los filtros por Agente en la tabla avicanfil
IF a_codagente <> "*" THEN
	LET _tipo = sp_sis04(a_codagente);  -- Separa los Valores del String en una tabla de codigos
	IF _tipo <> "E" THEN -- (I) Incluir los Registros
	   FOREACH
		   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT nombre
		     INTO _nom_agente
			 FROM agtagent
			WHERE cod_agente = _codigo;

		   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  5,
			  _nom_agente);  
	   END FOREACH;			
	  
	{ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_cob
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_agente IN (SELECT codigo FROM tmp_codigos); }

	END IF
	DROP TABLE tmp_codigos;
END IF


LET _codigo = "";
--Proceso que ingresa los filtros por Sucursal en la tabla avicanfil
IF a_codsuc <> "*" THEN
	LET _tipo = sp_sis04(a_codsuc);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT descripcion
			 INTO _nom_suc
			 FROM insagen
			WHERE codigo_agencia = _codigo;

	   	   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  6,
			  _nom_suc); 
   	   END FOREACH;			
	   END IF
	   DROP TABLE tmp_codigos;
END IF


LET _codigo = "";
--Proceso que ingresa los filtros por Area de Cobros en la tabla avicanfil
IF a_codarea <> "*" THEN
	LET _tipo = sp_sis04(a_codarea);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT nombre
			 INTO _nom_area
			 FROM gencorr
			WHERE code_correg = _codigo;

	   	   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  7,
			  _nom_area); 
   	   END FOREACH;			
		  
		{ELSE		        -- (E) Excluir estos Registros

		   UPDATE tmp_cob
		   	  SET seleccionado = 0
			WHERE seleccionado = 1
			  AND cod_agente IN (SELECT codigo FROM tmp_codigos); }
	   END IF
	   DROP TABLE tmp_codigos;
END IF

LET _codigo = "";
--Proceso que ingresa los filtros por Estaus de la Poliza en la tabla avicanfil
IF a_codstatus <> "*" THEN
	LET _tipo = sp_sis04(a_codstatus);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT descripcion
			 INTO _nom_status
			 FROM statuspoli
			WHERE cod_status = _codigo;

	   	   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  8,
			  _nom_status); 
   	   END FOREACH;			
		  
		{ELSE		        -- (E) Excluir estos Registros

		   UPDATE tmp_cob
		   	  SET seleccionado = 0
			WHERE seleccionado = 1
			  AND cod_agente IN (SELECT codigo FROM tmp_codigos); }
	   END IF
	   DROP TABLE tmp_codigos;
END IF

LET _codigo = "";
--Proceso que ingresa los cobradores de la Avisos
IF a_codcobra <> "*" THEN
	LET _tipo = sp_sis04(a_codcobra);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   UPDATE cobcobra
	   	      SET cod_avican = a_cod_avican
	   	    WHERE cod_cobrador = _codigo;
   	   END FOREACH;			
		  
		{ELSE		        -- (E) Excluir estos Registros

		   UPDATE tmp_cob
		   	  SET seleccionado = 0
			WHERE seleccionado = 1
			  AND cod_agente IN (SELECT codigo FROM tmp_codigos); }
	   END IF
    DROP TABLE tmp_codigos;
END IF

LET _codigo = "";
--Proceso que ingresa los filtros por Grupo Economico en la tabla avicanfil
IF a_codgrupo <> "*" THEN
	LET _tipo = sp_sis04(a_codgrupo);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT nombre
			 INTO _nom_grupo
			 FROM cligrupo
			WHERE cod_grupo = _codigo;

	   	   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  9,
			  _nom_grupo);
	   END FOREACH;
	END IF
	DROP TABLE tmp_codigos;
END IF

LET _codigo = "";
--Proceso que ingresa los filtros por Dias de Cobros en la tabla avicanfil
IF a_codiacob <> "*" THEN
	LET _tipo = sp_sis04(a_codiacob);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT descripcion
			 INTO _dia
			 FROM casdiacob
			WHERE cod_dia = _codigo;

	   	   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  10,
			  _dia);
	    END FOREACH;	
	END IF
	DROP TABLE tmp_codigos;
END IF

IF a_codacre <> "*" THEN
   LET _tipo = sp_sis04(a_codacre);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT descripcion
			 INTO _nom_acre
			 FROM acreehip
			WHERE cod_acreencia = _codigo;

	   	   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  11,
			  _nom_acre);
	    END FOREACH;	
	END IF
	DROP TABLE tmp_codigos;
END IF

IF a_codpago <> "*" THEN
	LET _tipo = sp_sis04(a_codpago);  -- Separa los Valores del String en una tabla de codigos
   	IF _tipo <> "E" THEN -- (I) Incluir los Registros
   	   FOREACH
	   	   SELECT codigo
		     INTO _codigo	
		     FROM tmp_codigos

		   SELECT descripcion
			 INTO _nom_pago
			 FROM prima_orig
			WHERE cod_pago = _codigo;

	   	   INSERT INTO avicanfil(
			  cod_avican,
			  cod_filtro,
			  tipo_filtro,
			  descripcion)
		   VALUES(
			  a_cod_avican,
			  _codigo,
			  12,
			  _nom_pago);
	    END FOREACH;	
	END IF
	DROP TABLE tmp_codigos;
END IF
RETURN 0, "Filtros de Aviso Cancelacion Automatico Creados Exitosamente";

--END
END PROCEDURE


