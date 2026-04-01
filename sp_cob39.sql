-- Recibos por cuenta-- 
-- Creado    : 12/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 12/12/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_cob39;

CREATE PROCEDURE "informix".sp_cob39(
a_compania CHAR(3),
a_agencia CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_cuenta CHAR(255) DEFAULT "*"
)
RETURNING CHAR(25),		 --CUENTA
		  DATE,		   	 --FECHA
          CHAR(10),		 --RECIBO
          CHAR(10),		 --REMESA
          DECIMAL(16,2), --DEBITO
          DECIMAL(16,2), --CREDITO
          CHAR(50),		 --COMPANIA
          CHAR(255),	 --FILTRO
		  CHAR(50),		 --NOMBRE_CUENTA
		  CHAR(50);		 --recibi de

DEFINE v_debito			  DECIMAL(16,2);
DEFINE v_credito 		  DECIMAL(16,2);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_filtros          CHAR(255);
DEFINE v_no_remesa        CHAR(10);
DEFINE v_no_recibo        CHAR(10);
DEFINE v_cuenta           CHAR(25);
DEFINE v_doc_remesa       CHAR(30);
DEFINE v_nombre_cuenta    CHAR(50);
DEFINE v_fecha		      DATE;
DEFINE _tipo              CHAR(1);

DEFINE v_renglon          SMALLINT;
define _recibi_de			  char(50);
	
-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_prod(
		cuenta		   	CHAR(25),
		fecha		 	DATE,
		no_recibo   	CHAR(10),
		no_remesa		CHAR(10),
		debito      	DECIMAL(16,2),
		credito		    DECIMAL(16,2),
		renglon		   	SMALLINT,
		seleccionado   	SMALLINT  DEFAULT 1 NOT NULL,
		recibi_de		char(50)
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cuenta);


FOREACH WITH HOLD
	-- Informacion de remesas

	SELECT c.fecha,
		   c.no_recibo,
		   c.no_remesa,
		   c.renglon,
		   c.doc_remesa,
		   m.recibi_de
	  INTO v_fecha,
	  	   v_no_recibo,
	  	   v_no_remesa,
	  	   v_renglon,
	  	   v_doc_remesa,
		   _recibi_de
	  FROM cobredet c, cobremae m
	 WHERE c.periodo     >= a_periodo1 
	   and c.periodo     <= a_periodo2
	   AND c.no_remesa   = m.no_remesa
	   AND c.tipo_mov    <> "B"
--	   AND m.tipo_remesa IN("A","M","T", "C")
	   AND c.renglon     <> 0
	   AND c.actualizado = 1

	FOREACH	
		SELECT debito,
			   credito,
			   cuenta
		  INTO v_debito,
		  	   v_credito,
		  	   v_cuenta
		  FROM cobasien
		 WHERE no_remesa = v_no_remesa
		   and renglon   = v_renglon

		-- Insercion / Actualizacion a la tabla temporal tmp_prod

		INSERT INTO tmp_prod(
		cuenta,
		fecha,
		no_recibo,
		no_remesa,
	    debito,
	    credito,
	 	renglon,
		recibi_de
		)
		VALUES(
		v_cuenta,
		v_fecha,
		v_no_recibo,
		v_no_remesa,
		v_debito,
		v_credito,
		v_renglon,
		_recibi_de
		);

	END FOREACH
END FOREACH;

-- Procesos para Filtros

LET v_filtros = "";

IF a_cuenta <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cuenta: " ||  TRIM(a_cuenta);

	LET _tipo = sp_sis04(a_cuenta);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cuenta NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cuenta IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--------------------------------------------------------------------------

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH WITH HOLD
	SELECT cuenta,
		   fecha,
	 	   no_recibo,
	 	   no_remesa,
	 	   debito,
	 	   credito,
		   recibi_de
	  INTO v_cuenta,
	   	   v_fecha,
	   	   v_no_recibo,
	   	   v_no_remesa,
	   	   v_debito,
	   	   v_credito,
		   _recibi_de
	  FROM tmp_prod
	 WHERE seleccionado = 1

	 SELECT cta_nombre
	   INTO v_nombre_cuenta
	   FROM cglcuentas
	  WHERE cta_cuenta = v_cuenta;

	RETURN    v_cuenta,
	   		  v_fecha,
			  v_no_recibo,
			  v_no_remesa,
			  v_debito,
			  v_credito,
			  v_compania_nombre,
			  v_filtros,
			  v_nombre_cuenta,
			  _recibi_de
			  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;