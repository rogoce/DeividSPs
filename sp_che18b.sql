-- Reporte de Saldos de Banco
-- 
-- Creado    : 09/05/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/05/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cheq_sp_che15b_dw1 -- DEIVID, S.A.

DROP PROCEDURE sp_che18b;

CREATE PROCEDURE "informix".sp_che18b(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha DATE, a_banco CHAR(255))
RETURNING CHAR(50),	 --banco
		  SMALLINT,  --tipo_flujo
		  CHAR(3), 	 --cod_flujo
		  CHAR(50),	 --desc. cod_flujo
		  SMALLINT,  --fuente datos
		  CHAR(10),  --remesa/requisicion
		  SMALLINT,	 --renglon
		  CHAR(25),	 --cuenta
		  DEC(16,2), --debito
		  DEC(16,2), --credito
		  CHAR(50);	 --cia

DEFINE v_cod_banco	  CHAR(3);
DEFINE _tipo_flujo,_fuente_dato,_renglon    SMALLINT;
DEFINE _cod_flujo     CHAR(3);
DEFINE v_nombre,v_nombre_flujo	      CHAR(50);
DEFINE _cta  	      CHAR(25);
DEFINE _no_rem_req    CHAR(10);
DEFINE v_nombre_banco CHAR(50);
DEFINE v_debito  	  DEC(16,2);
DEFINE v_credito	  DEC(16,2);
DEFINE v_nombre_cia	  CHAR(50);
DEFINE _tipo          CHAR(1);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che15a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

-- Flujo de Caja del Dia

CALL sp_che18(
a_compania,
a_sucursal,
a_fecha,
a_fecha
);

--filtro de bancos
IF a_banco <> "*" THEN

	LET _tipo = sp_sis04(a_banco);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_flujo_det
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND banco NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_flujo_det
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND banco IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
	 SELECT banco,
			tipo_flujo,
			cod_flujo,
			fuente_dato,
			no_rem_req,
			renglon,
			cuenta,
			db,
			cr
	   INTO v_cod_banco,
			_tipo_flujo,
			_cod_flujo,
			_fuente_dato,
			_no_rem_req,
			_renglon,
			_cta,
	   		v_debito,
			v_credito
	   FROM tmp_flujo_det
	  WHERE seleccionado = 1

	SELECT nombre
	  INTO v_nombre_banco
 	  FROM chqbanco
	 WHERE cod_banco = v_cod_banco;

	SELECT nombre
	  INTO v_nombre_flujo
 	  FROM chqfluti
	 WHERE cod_flujo = _cod_flujo;


	RETURN v_nombre_banco,
		   _tipo_flujo,
		   _cod_flujo,
		   v_nombre_flujo,
		   _fuente_dato,
		   _no_rem_req,
		   _renglon,
		   _cta,
		   v_debito,
		   v_credito,
		   v_nombre_cia
		   WITH RESUME;
END FOREACH	

DROP TABLE tmp_flujo;
DROP TABLE tmp_flujo_det;
		
END PROCEDURE;