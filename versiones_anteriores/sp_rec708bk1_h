-- Procedimiento que Carga el Siniestros Incurridos Contrato Incluyendo pagos, recuperos, salvamento y Deducible)
-- en un Periodo Dado  -- COPIA DE sp_rec61
--
-- Creado    : 05/12/2001 - Autor: Amado Perez
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec708bk1;
CREATE PROCEDURE "informix".sp_rec708bk1(
	a_compania		CHAR(3),
	a_agencia		CHAR(3),
	a_periodo1		CHAR(7),
	a_periodo2		CHAR(7),
	a_sucursal		CHAR(255) DEFAULT "*",
	a_grupo			CHAR(255) DEFAULT "*",
	a_ramo			CHAR(255) DEFAULT "*",
	a_agente		CHAR(255) DEFAULT "*",
	a_ajustador		CHAR(255) DEFAULT "*",
	a_evento		CHAR(255) DEFAULT "*",
	a_suceso		CHAR(255) DEFAULT "*",
	a_tipo_contrato	CHAR(255) DEFAULT "*")
RETURNING	CHAR(255);

define v_filtros			char(255);
define _nombre_contrato		char(50);
define _doc_poliza			char(20);
define _numrecla			char(18);
define _cod_cliente			char(10);
define _transaccion			char(10);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_cobertura		char(5);
define _cod_contrato		char(5);
define _cod_grupo			char(5);
define _cod_cober_reas		char(3);
define _ajust_interno		char(3);
define _cod_coasegur    	char(3);
define _cod_sucursal		char(3);
define _cod_subramo			char(3);
define _cod_evento			char(3);
define _cod_suceso			char(3);
define _cod_ramo			char(3);
define _tipo_contrato		char(1);
define _tipo				char(1);
define _monto_variacion		decimal(16,2);
define _variacion_neta		decimal(16,2);
define _reserva_neto		decimal(16,2);
define _monto_total			decimal(16,2);
define _monto_bruto			decimal(16,2);
define _pagado_neto			decimal(16,2);
define _monto_neto			decimal(16,2);
define _variacion			decimal(16,2);
define _porc_coas			decimal;
define _porc_reas			decimal;
define _posible_recobro		integer;
define _tipo_transaccion	smallint;
define _vig_inic            date;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal
CREATE TEMP TABLE tmp_sinis(
	no_reclamo           CHAR(10)  NOT NULL,
	no_poliza            CHAR(10)  NOT NULL,
	cod_sucursal         CHAR(3)   NOT NULL,
	cod_grupo			 CHAR(5)   NOT NULL,
	cod_ramo             CHAR(3)   NOT NULL,
	cod_subramo          CHAR(3)   NOT NULL,
	ajust_interno   	 CHAR(3)   NOT NULL,
	cod_evento     	     CHAR(3)   NOT NULL,
	cod_suceso     	     CHAR(3),
	cod_cliente          CHAR(10)  NOT NULL,
	cod_contrato         CHAR(05)  NOT NULL,
	tipo_transaccion     SMALLINT,
	tipo_contrato        CHAR(1),
	periodo              CHAR(7)   NOT NULL,
	numrecla             CHAR(18)  NOT NULL,
	transaccion          CHAR(10)  NOT NULL,
	pagado_neto          DEC(16,2) NOT NULL,
	incurrido_neto       DEC(16,2) NOT NULL,
	posible_recobro		 INT       NOT NULL,
	seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
	doc_poliza           CHAR(20)  NOT NULL,
	nombre_contrato      CHAR(50)  NOT NULL,
	variacion       	 DEC(16,2) NOT NULL,
PRIMARY KEY (no_reclamo,transaccion,nombre_contrato)) WITH NO LOG;
CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno);
CREATE INDEX xie05_tmp_sinis ON tmp_sinis(cod_evento);
CREATE INDEX xie06_tmp_sinis ON tmp_sinis(cod_suceso);
CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);
CREATE INDEX xie08_tmp_sinis ON tmp_sinis(tipo_contrato);

-- Pagos, Salvamentos, Recuperos y Deducibles
LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;
LET _pagado_neto = 0;

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT a.no_reclamo,
		   a.no_tranrec,
		   a.monto,
		   a.cod_sucursal,
		   a.transaccion,
		   a.variacion,
		   b.tipo_transaccion
	  INTO _no_reclamo,
		   _no_tranrec,
		   _monto_total,
		   _cod_sucursal,
		   _transaccion,
		   _variacion,
		   _tipo_transaccion
	  FROM rectrmae a,rectitra b
	 WHERE a.cod_compania = a_compania
	   AND a.actualizado  = 1
	   AND a.cod_tipotran = b.cod_tipotran
	   AND a.periodo >= a_periodo1
	   AND a.periodo <= a_periodo2
	   AND a.monto   <> 0
	   AND b.tipo_transaccion in (4,5,6,7)

	-- Lectura de la Tablas de Reclamos
	SELECT no_poliza,
	       periodo,
	       numrecla,
		   ajust_interno,
		   cod_evento,
		   cod_suceso,
		   posible_recobro
	  INTO _no_poliza,
	       _periodo,
	       _numrecla,
		   _ajust_interno,
		   _cod_evento,
		   _cod_suceso,
		   _posible_recobro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	-- Informacion de Polizas
	SELECT cod_ramo,
		   cod_grupo,
		   cod_subramo,
		   cod_contratante,
		   no_documento,
		   vigencia_inic
	  INTO _cod_ramo,
	       _cod_grupo,
	       _cod_subramo,
		   _cod_cliente,
		   _doc_poliza,
		   _vig_inic
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

{   if _vig_inic < '01/07/2014' then
	  continue foreach;
   end if }

	-- Informacion de Coseguro
	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF
	
	-- Informacion de Reaseguro 
	FOREACH
		SELECT monto,
			   variacion,
			   cod_cobertura
		  INTO _monto_total,
			   _monto_variacion,
			   _cod_cobertura
		  FROM rectrcob
		 WHERE no_tranrec = _no_tranrec
		   and monto <> 0
		
		let _monto_bruto		= 0;
		let _monto_variacion	= 0;
		
		LET _monto_bruto     = _monto_total / 100 * _porc_coas;
		LET _monto_variacion = _variacion   / 100 * _porc_coas;
		
		select cod_cober_reas
		  into _cod_cober_reas
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

		foreach
            select cod_contrato,
		           porc_partic_prima
			  into _cod_contrato,
				   _porc_reas
			  from rectrrea
		     where no_tranrec     = _no_tranrec
		       and cod_cober_reas = _cod_cober_reas

			SELECT tipo_contrato
			  INTO _tipo_contrato
			  FROM reacomae
			 WHERE cod_contrato = _cod_contrato;

			if _porc_reas is null then
				let _porc_reas = 0;
			end if

			select reacomae.nombre,
				   reacomae.tipo_contrato
			  into _nombre_contrato,
				   _tipo_contrato
			  from reacomae
			 where reacomae.cod_contrato = _cod_contrato;

			if _porc_reas is null then
				let _porc_reas = 0;
			end if;

			if _porc_reas = 0 then
			   continue foreach;
			end if

			-- Calculos
			LET _pagado_neto    = _monto_bruto     / 100 * _porc_reas;
			LET _variacion_neta = _monto_variacion / 100 * _porc_reas;

		-- Actualizacion del Movimiento
			begin
				on exception in(-239)

					update tmp_sinis
					   set pagado_neto     = pagado_neto   + _pagado_neto,
						   variacion       = variacion     + _variacion_neta
					 where no_reclamo      = _no_reclamo
					   and transaccion     = _transaccion
					   and nombre_contrato = _nombre_contrato;
				end exception

				insert into tmp_sinis(
				pagado_neto,
				incurrido_neto,
				no_reclamo,
				no_poliza,
				cod_ramo,
				periodo,
				numrecla,
				transaccion,
				cod_grupo,
				ajust_interno,
				cod_evento,
				cod_suceso,
				posible_recobro,
				cod_sucursal,
				cod_subramo,
				cod_cliente,
				cod_contrato,
				tipo_transaccion,
				tipo_contrato,
				doc_poliza,
				nombre_contrato,
				variacion
				)
				VALUES(
				_pagado_neto,
				0,
				_no_reclamo,
				_no_poliza,
				_cod_ramo,
				_periodo,
				_numrecla,
				_transaccion,
				_cod_grupo,
				_ajust_interno,
				_cod_evento,
				_cod_suceso,
				_posible_recobro,
				_cod_sucursal,
				_cod_subramo,
				_cod_cliente,
				_cod_contrato,
				_tipo_transaccion,
				_tipo_contrato,
				_doc_poliza,
				_nombre_contrato,
				_variacion_neta
				);
			END

			LET _pagado_neto = 0;
			LET _variacion   = 0;
			LET _monto_total = 0;
		END FOREACH
	END FOREACH
END FOREACH

-- Actualizacion del Incurrido
UPDATE tmp_sinis
   SET incurrido_neto  = pagado_neto  + variacion;

-- Procesos para Filtros
LET v_filtros = "";

IF a_sucursal <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);
	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_grupo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);
	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_ramo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);
	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_ajustador <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Ajustador: " ||  TRIM(a_ajustador);
	LET _tipo = sp_sis04(a_ajustador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- Excluir estos Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_evento <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Evento: " ||  TRIM(a_evento);
	LET _tipo = sp_sis04(a_evento);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_suceso <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Suceso: " ||  TRIM(a_suceso);
	LET _tipo = sp_sis04(a_suceso);  -- Separa los Valores del String en una tabla de codigos
	
	IF _tipo <> "E" THEN -- (I) Incluir los Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_suceso NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- (E) Excluir estos Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_suceso IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;
END IF

IF a_tipo_contrato <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || "Contrato: " ||  TRIM(a_tipo_contrato);
	LET _tipo = sp_sis04(a_tipo_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato IN (SELECT codigo FROM tmp_codigos);
    END IF		        -- (E) Excluir estos Registros
   
   DROP TABLE tmp_codigos;
END IF

RETURN v_filtros;

END PROCEDURE;