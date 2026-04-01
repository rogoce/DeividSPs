-- Reporte de Analisis del Dia de Cobros por cobrador
-- 
-- Creado    : 20/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 12/03/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob62;

CREATE PROCEDURE "informix".sp_cob62(a_compania CHAR(3), a_sucursal CHAR(3), a_cobrador CHAR(255) DEFAULT "*", a_dia INT, a_ramo CHAR(255) DEFAULT '*', a_formadepago CHAR(255) DEFAULT '*', a_incobrable SMALLINT, a_dia2 INT, a_gestion CHAR(255) DEFAULT '*')
RETURNING 	CHAR(100),	  --asegurado
			CHAR(20),	  --documento
			DATE,		  --vig ini
			DATE,		  --vig fin
			DEC(16,2),	  --saldo
			DEC(16,2),	  --a_pagar
			CHAR(50),	  --cobrador
			CHAR(1),	  --gestion
			CHAR(50),	  --cia
			CHAR(255),	  --v_filtros
			INTEGER,	  --dia1
			INTEGER,	  --dia2
			CHAR(1),      --flag de canceladas
			CHAR(50),	  --forma de pago
			CHAR(50);	  --corredor

DEFINE v_dia1,v_dia2,_dia_cobros1,_dia_cobros2 INT;
DEFINE v_documento        CHAR(20);
DEFINE v_asegurado,_descripcion CHAR(100);
DEFINE v_vigen_ini,v_vigen_fin        DATE;
DEFINE v_saldo            DEC(16,2);
DEFINE v_exigible,_prima_bruta DEC(16,2);
DEFINE v_apagar,v_a_pagar DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);	 
DEFINE v_corriente		  DEC(16,2);
DEFINE v_monto_30		  DEC(16,2);
DEFINE v_monto_60		  DEC(16,2);
DEFINE v_monto_90		  DEC(16,2);

DEFINE _cod_agente       CHAR(5);
DEFINE _no_poliza,_cod_pagador,v_nopoliza,_no_poliza_ult,v_codigo CHAR(10);
DEFINE _cod_compania,_cod_cobra	 CHAR(3);
DEFINE _cod_sucursal,_cod_cobrador,_cod_tipoprod    CHAR(3);
DEFINE _actualizado		 INT;
DEFINE _mes_char         CHAR(2);
DEFINE v_filtros         CHAR(255);
DEFINE _ano_char		 CHAR(4);
DEFINE _periodo          CHAR(7);
DEFINE _cod_formapag,v_saber     CHAR(3);
DEFINE _cod_cliente      CHAR(10);
DEFINE _des_pagador,v_cobrador,v_nombre_cia,_nombre_formadepago,_nombre_corredor,v_desc CHAR(50);
DEFINE _cobra_poliza,_cobra_poliza_pol,_tipo CHAR(1);
DEFINE _ramo_sis		    SMALLINT;
DEFINE _tipo_forma,_estatus_poliza,_incobrable,_tipo_produccion      SMALLINT;
DEFINE _cod_ramo		CHAR(3);
DEFINE _gestion,v_can			CHAR(1);


LET  v_nombre_cia = sp_sis01(a_compania);
IF  month(today) < 10 THEN
	LET _mes_char = '0'||month(today);
ELSE
	LET _mes_char = month(today);
END IF

LET _ano_char = year(today);
LET _periodo  = _ano_char || "-" || _mes_char;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob62.trc";
--trace on;

--DROP TABLE tmp_arreglo;

CREATE TEMP TABLE tmp_arreglo(
		cod_cobrador    CHAR(3) NOT NULL,
		dia_cobros1		INT,
		dia_cobros2		INT,
		vigen_ini       DATE,
		vigen_fin       DATE,
		no_documento    CHAR(20),
		cod_cliente     CHAR(10),
		saldo   	    DEC(16,2),
		a_pagar   	    DEC(16,2),
		gestion			CHAR(1),
		estatus_poliza	SMALLINT,
		no_poliza		CHAR(10),
		cod_ramo		CHAR(3),
		cod_formadepago CHAR(3),
		incobrable		SMALLINT,
		seleccionado   	SMALLINT  DEFAULT 1 NOT NULL,
		cod_agente      CHAR(5)
		) WITH NO LOG;   

FOREACH
 SELECT no_documento
   INTO v_documento
   FROM emipomae
  WHERE cod_compania = a_compania
    AND cod_sucursal = a_sucursal
    AND actualizado = 1
	AND estatus_poliza IN (1,2,3)
	AND (dia_cobros1 >= a_dia
	AND  dia_cobros1 <= a_dia2
	 OR  dia_cobros2 >= a_dia
	AND  dia_cobros2 <= a_dia2)
  GROUP BY no_documento

	FOREACH
	 SELECT no_poliza,
			vigencia_final,
			dia_cobros1,
			dia_cobros2
	   INTO _no_poliza_ult,
			v_vigen_fin,
			v_dia1,
	   	    v_dia2
	   FROM emipomae
	  WHERE no_documento   = v_documento
	    AND actualizado    = 1
		AND estatus_poliza IN (1,2,3)
	  ORDER BY vigencia_final DESC
			EXIT FOREACH;
	END FOREACH

	IF (v_dia1 >= a_dia AND v_dia1 <= a_dia2) OR (v_dia2 >= a_dia AND v_dia2 <= a_dia2) THEN
    -- Lectura de Polizas	

	SELECT x.dia_cobros1,
		   x.dia_cobros2,
		   x.cod_compania,
		   x.cod_sucursal,
		   x.actualizado,
		   x.cod_formapag,
		   x.no_documento,
		   x.cod_contratante,
		   x.no_poliza,
		   x.vigencia_inic,
		   x.vigencia_final,
		   x.prima_bruta,
		   x.cobra_poliza,
		   x.cod_pagador,
		   x.gestion,
		   x.cod_ramo,
		   x.estatus_poliza,
		   x.incobrable,
		   x.cod_tipoprod
	  INTO v_dia1,
	   	   v_dia2,
	   	   _cod_compania,
	   	   _cod_sucursal,
	   	   _actualizado,
		   _cod_formapag,
		   v_documento,
		   _cod_cliente,
		   _no_poliza,
		   v_vigen_ini,
		   v_vigen_fin,
		   _prima_bruta,
		   _cobra_poliza_pol,
		   _cod_pagador,
		   _gestion,
		   _cod_ramo,
		   _estatus_poliza,
		   _incobrable,
		   _cod_tipoprod
	  FROM emipomae x
	 WHERE x.no_poliza = _no_poliza_ult;

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _tipo_forma = 2 OR _tipo_forma = 4 THEN	
		CONTINUE FOREACH;
	END IF

	IF _gestion IS NULL THEN
		LET _gestion = 'P';
	END IF

-- Lectura de Emitipro(Saber el tipo de produccion)
 -- Si es Coaseg Minoritario debe excluir registros.
 	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_produccion = 3 OR _tipo_produccion = 4 THEN	
		CONTINUE FOREACH;
	END IF
 -- Lectura de Emipoagt(Corredores)

   FOREACH	
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza_ult
	 EXIT FOREACH;
   END FOREACH

   SELECT cobra_poliza,
		  cod_cobrador
     INTO _cobra_poliza,
		  _cod_cobrador
     FROM agtagent
    WHERE cod_agente = _cod_agente;

	IF _cobra_poliza = "C" THEN	
		CONTINUE FOREACH;
	END IF

	IF _cobra_poliza = "A" THEN	
		IF _cobra_poliza_pol = "C" OR 
		   _cobra_poliza_pol = "A" THEN
			CONTINUE FOREACH;
		END IF
	END IF

	{SELECT  saldo,
		    a_pagar,
		    dia_cobros1,
		    dia_cobros2,
		    cod_cobrador
    INTO    v_saldo,
		    v_a_pagar,
		    _dia_cobros1,
		    _dia_cobros2,
		    _cod_cobra
   FROM cobruter
   WHERE no_poliza = _no_poliza;}

	{IF v_saldo IS NOT NULL THEN

		IF _dia_cobros1 = a_dia AND _dia_cobros2 = a_dia THEN
		  LET _estatus = 1; --MISMO DIA
		ELSE
		  LET v_dia1 = _dia_cobros1;
		  LET v_dia2 = _dia_cobros2;
		  LET _estatus = 2; --LE CAMBIARON EL DIA
		END IF

	ELSE}

		CALL sp_cob33(
		a_compania,
		a_sucursal,
		v_documento,
		_periodo,
		today
		) RETURNING v_por_vencer,
				    v_exigible,  
				    v_corriente, 
				    v_monto_30,  
				    v_monto_60,  
				    v_monto_90,
				    v_saldo
				    ;

				SELECT ramo_sis
				  INTO _ramo_sis
				  FROM prdramo
				 WHERE cod_ramo = _cod_ramo;

				IF v_saldo <= 0 THEN 
					IF _ramo_sis <> 5 AND _ramo_sis <> 6 THEN
						CONTINUE FOREACH;
					END IF
				END IF
				IF _estatus_poliza = 2 AND v_saldo = 0 THEN --cancelada y saldo cero
					CONTINUE FOREACH;
				END IF
		LET v_a_pagar = v_exigible;

	  	--LET _estatus = 3; --NO SE GESTIONARON
	--END IF

	INSERT INTO tmp_arreglo(
	cod_cobrador,	   	
	dia_cobros1,
	dia_cobros2,
	vigen_ini,
	vigen_fin,
	no_documento,
	cod_cliente,
	saldo,
	a_pagar,
	gestion,
	estatus_poliza,
	no_poliza,
	cod_ramo,
	cod_formadepago,
	incobrable,
	seleccionado,
	cod_agente
	)
	VALUES(
	_cod_cobrador,
	v_dia1,
	v_dia2,
	v_vigen_ini,
	v_vigen_fin,
	v_documento,
	_cod_cliente,
	v_saldo,
	v_a_pagar,
	_gestion,
	_estatus_poliza,
	_no_poliza,
	_cod_ramo,
	_cod_formapag,
	_incobrable,
	1,
	_cod_agente
    );
  ELSE
	CONTINUE FOREACH;
 END IF
END FOREACH;

LET v_filtros = "";

IF a_cobrador <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Cobrador: " ||  TRIM(a_cobrador);

	LET _tipo = sp_sis04(a_cobrador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobrador IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_formadepago <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Forma de Pago: " ||  TRIM(a_formadepago);

	LET _tipo = sp_sis04(a_formadepago);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formadepago NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_formadepago IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_incobrable <> 1 THEN

	IF a_incobrable = 2 THEN  -- Sin Incobrables

		LET v_filtros = TRIM(v_filtros) || " Sin Incobrables ";

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 1;

	ELSE		        -- Solo Incobrables

		LET v_filtros = TRIM(v_filtros) || " Solo Incobrables ";

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND incobrable   = 0;

	END IF

END IF

IF a_gestion <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Gestion:"; -- ||  TRIM(a_gestion);

	LET _tipo = sp_sis04(a_gestion);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion NOT IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_arreglo
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND gestion IN (SELECT codigo FROM tmp_codigos);
		LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT cobgemae.nombre,tmp_codigos.codigo
          INTO v_desc,v_codigo
          FROM cobgemae,tmp_codigos
         WHERE cobgemae.cod_gestion = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc) || " " || TRIM(v_saber);
	 END FOREACH
	DROP TABLE tmp_codigos;

END IF

FOREACH
      SELECT cod_cobrador,
             dia_cobros1,
             dia_cobros2,     
			 vigen_ini,
			 vigen_fin,
			 no_documento,
			 cod_cliente,
			 saldo,
			 a_pagar,
			 gestion,
			 estatus_poliza,
			 no_poliza,
			 cod_formadepago,
			 cod_agente
	    INTO _cod_cobrador,
			 v_dia1,
			 v_dia2,
			 v_vigen_ini,
			 v_vigen_fin,
			 v_documento,
			 _cod_cliente,
			 v_saldo,
			 v_a_pagar,
			 _gestion,
			 _estatus_poliza,
			 _no_poliza,
			 _cod_formapag,
			 _cod_agente
        FROM tmp_arreglo
	    WHERE seleccionado = 1
		ORDER BY cod_cobrador,gestion

	LET v_can = " ";

	--Lectura de Asegurado
	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	--Lectura de Corredor
	SELECT nombre
	  INTO _nombre_corredor
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	--Lectura de Cobrador
	SELECT nombre
	  INTO v_cobrador
	  FROM cobcobra
	 WHERE cod_cobrador = _cod_cobrador;

	--Lectura de la forma de pago
	SELECT nombre
	  INTO _nombre_formadepago
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _gestion IS NULL THEN
		LET _gestion = "P";
	END IF

	IF _estatus_poliza = 2 THEN --cancelada
		SELECT fecha_cancelacion
		  INTO v_vigen_fin
		  FROM emipomae
		 WHERE no_poliza = _no_poliza
		   AND actualizado = 1;

		LET v_can = "C";
	END IF

	RETURN v_asegurado, 
		   v_documento, 
		   v_vigen_ini, 
		   v_vigen_fin, 
		   v_saldo,     
		   v_a_pagar,
		   v_cobrador,
		   _gestion,
		   v_nombre_cia,
		   v_filtros,
		   v_dia1,
		   v_dia2,
		   v_can,
		   _nombre_formadepago,
		   _nombre_corredor
		   WITH RESUME;

END FOREACH;
DROP TABLE tmp_arreglo;
END PROCEDURE