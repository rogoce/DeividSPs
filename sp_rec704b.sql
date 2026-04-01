-- Procedimiento que Carga el Incurrido de Reclamos en un Periodo Dado
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 06/09/2001 - Autor: Amado Perez -- Agregando campo transaccion
-- MODIFICADO: 11/09/2009 - Henry Giron , COpia de sp_rec35 incluyendo salvamento,deducible y recupero solicitud por Omar Wong
-- Modificado: 24/09/2000 - Autor: Henry Giron se adiciono Subramo
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec704b;

CREATE PROCEDURE "informix".sp_rec704b(a_compania  CHAR(3),a_agencia   CHAR(3),a_periodo1  CHAR(7),a_periodo2  CHAR(7),a_sucursal  CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*",a_ajustador CHAR(255) DEFAULT "*",a_evento CHAR(255) DEFAULT "*",a_suceso CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*",
a_documento CHAR(20) default "*",a_numrecla  CHAR(20) default "*")
RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _reserva_total   DECIMAL(16,2);
DEFINE _reserva_bruto   DECIMAL(16,2);
DEFINE _reserva_neto    DECIMAL(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo      CHAR(10);
DEFINE _no_tranrec      CHAR(10);
DEFINE _transaccion     CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;
DEFINE _variacion       DECIMAL(16,2);
DEFINE _salvado_neto,_deducible_neto   DECIMAL(16,2);
DEFINE _fecha_1,_fecha_2  		 DATE;
DEFINE _mes    		 SMALLINT;
DEFINE _ano    	     SMALLINT;


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

-- Tabla Temporal

drop table if exists  tmp_sinis;

CREATE TEMP TABLE tmp_sinis(
		no_reclamo           CHAR(10)  NOT NULL,
		no_tranrec           CHAR(10)  ,
		no_poliza            CHAR(10)  NOT NULL,
		cod_sucursal         CHAR(3)   NOT NULL,
		cod_grupo			 CHAR(5)   NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		cod_subramo          CHAR(3)   NOT NULL,
		ajust_interno   	 CHAR(3)   NOT NULL,
		cod_evento     	     CHAR(3)   NOT NULL,
		cod_suceso     	     CHAR(3),
		cod_cliente          CHAR(10)  NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		transaccion          CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		pagado_neto          DEC(16,2) NOT NULL,
		reserva_total        DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		reserva_neto         DEC(16,2) NOT NULL,
		incurrido_total      DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		incurrido_neto       DEC(16,2) NOT NULL,
		posible_recobro		 INT       NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		doc_poliza           CHAR(20)  NOT NULL,
		PRIMARY KEY (no_reclamo)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_sinis ON tmp_sinis(cod_sucursal);
CREATE INDEX xie02_tmp_sinis ON tmp_sinis(cod_grupo);
CREATE INDEX xie03_tmp_sinis ON tmp_sinis(cod_ramo);
CREATE INDEX xie04_tmp_sinis ON tmp_sinis(ajust_interno);
CREATE INDEX xie05_tmp_sinis ON tmp_sinis(cod_evento);
CREATE INDEX xie06_tmp_sinis ON tmp_sinis(cod_suceso);
CREATE INDEX xie07_tmp_sinis ON tmp_sinis(no_poliza);

-- Pagos, Salvamentos, Recuperos y Deducibles    

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

LET _deducible_neto = 0;
LET _salvado_neto   = 0;

--SET DEBUG FILE TO 'sp_rec704.trc';
--TRACE ON;

SET ISOLATION TO DIRTY READ;


LET _ano = a_periodo1[1,4];
LET _mes = a_periodo1[6,7];
LET _fecha_1 = MDY(_mes, 1, _ano);

CALL sp_sis36(a_periodo1) RETURNING _fecha_1;
CALL sp_sis36(a_periodo2) RETURNING _fecha_2;

FOREACH
 SELECT a.no_reclamo,
        a.transaccion,
 		a.monto,
		a.variacion,
		a.no_tranrec
   INTO _no_reclamo,
        _transaccion,
   		_monto_total,
	    _reserva_total,
		_no_tranrec
   FROM rectrmae a,rectitra b
  WHERE a.cod_compania = a_compania
    AND a.actualizado = 1	
    AND a.cod_tipotran = b.cod_tipotran
    AND b.tipo_transaccion IN (4) --,5,6,7)  -- 29/01/2018: KCESAR solo PAGOS(004)
    --AND a.fecha_factura >= _fecha_1
    --AND a.fecha_factura <= _fecha_2	
    AND a.periodo >= a_periodo1 
    AND a.periodo <= a_periodo2
    AND a.monto <> 0
 
	-- Lectura de la Tablas de Reclamos
	select no_poliza,
	       periodo,
	       numrecla,
		   ajust_interno,
		   cod_evento,
		   cod_suceso,
		   posible_recobro
	  into _no_poliza,
	       _periodo,
	       _numrecla,
		   _ajust_interno,
		   _cod_evento,
		   _cod_suceso,
		   _posible_recobro
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	 IF a_numrecla <> "*" THEN
		 if _numrecla <> a_numrecla then
			continue foreach;
		end if
	END IF 		 

	-- Informacion de Polizas
	select cod_ramo,
		   cod_grupo,
		   cod_subramo,
		   cod_contratante,
		   no_documento,
		   cod_sucursal
	  into _cod_ramo,
	       _cod_grupo,
	       _cod_subramo,
		   _cod_cliente,
		   _doc_poliza,
		   _cod_sucursal
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	 IF a_documento <> "*" THEN
		 if _doc_poliza <> a_documento then
			continue foreach;
		end if
	END IF 

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

	LET _porc_reas = 0;
	-- Se corrigio por solicitud de Omar.23.11.2010
    foreach
		select sum(recreaco.porc_partic_prima)
		  into _porc_reas
		  from recreaco, reacomae
		 where recreaco.no_reclamo    = _no_reclamo
		   and recreaco.cod_contrato  = reacomae.cod_contrato
		   and reacomae.tipo_contrato = 1  
		  group by cod_cober_reas
	  
		if _porc_reas is null then
			let _porc_reas = 0;
	    end if;
	  exit foreach;
	end foreach

	-- Calculos
	LET _monto_bruto   = _monto_total   / 100 * _porc_coas;
	LET _monto_neto    = _monto_bruto   / 100 * _porc_reas;
	LET _reserva_bruto = _reserva_total / 100 * _porc_coas;
	LET _reserva_neto  = _reserva_bruto / 100 * _porc_reas;

	-- Actualizacion del Movimiento

	BEGIN
	ON EXCEPTION IN(-239)
		UPDATE tmp_sinis
		   SET pagado_total  = pagado_total  + _monto_total,
		       pagado_bruto  = pagado_bruto  + _monto_bruto,
		       pagado_neto   = pagado_neto   + _monto_neto,
			   reserva_total = reserva_total + _reserva_total,
		       reserva_bruto = reserva_bruto + _reserva_bruto,
		       reserva_neto  = reserva_neto  + _reserva_neto
		 WHERE no_reclamo    = _no_reclamo;
	END EXCEPTION

		INSERT INTO tmp_sinis(
		pagado_total,
		pagado_bruto,
		pagado_neto,
		reserva_total,
		reserva_bruto,
		reserva_neto,
		incurrido_total,
		incurrido_bruto,
		incurrido_neto,
		no_reclamo,
		no_tranrec,
		transaccion,
		no_poliza,
		cod_ramo,
		periodo,
		numrecla,
		cod_grupo,
		ajust_interno,
		cod_evento,
		cod_suceso,
		posible_recobro,
		cod_sucursal,
		cod_subramo,
		cod_cliente,
		doc_poliza,
		seleccionado
	    )
		VALUES(
		_monto_total,
		_monto_bruto,
		_monto_neto,
		_reserva_total,
		_reserva_bruto,
		_reserva_neto,
		0,
		0,
		0,
		_no_reclamo,
		_no_tranrec,
		_transaccion,
		_no_poliza,
		_cod_ramo,
		_periodo,
		_numrecla,
		_cod_grupo,
		_ajust_interno,
		_cod_evento,
		_cod_suceso,
		_posible_recobro,
		_cod_sucursal,
		_cod_subramo,
		_cod_cliente,
		_doc_poliza,
		1
		);
	END
END FOREACH

-- Actualizacion del Incurrido Total

UPDATE tmp_sinis
   SET incurrido_total = reserva_total + pagado_total,
       incurrido_bruto = reserva_bruto + pagado_bruto,
       incurrido_neto  = reserva_neto  + pagado_neto;

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

	ELSE		        -- Excluir estos Registros+

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

IF a_subramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " SubRamo: " ||  TRIM(a_subramo);

	LET _tipo = sp_sis04(a_subramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_subramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_subramo IN (SELECT codigo FROM tmp_codigos);

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

RETURN v_filtros;

END PROCEDURE;
  