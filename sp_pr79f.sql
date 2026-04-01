-- Totales de vencimiento por Ramo / Subramo
-- 
-- Creado    : 29/10/2001 - Autor: Lic. Armando Moreno 
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_pr79f;

CREATE PROCEDURE "informix".sp_pr79f(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7), a_sucursal CHAR(255) DEFAULT "*", a_ramo CHAR(255) DEFAULT "*", a_grupo CHAR(255) DEFAULT "*", a_usuario CHAR(255) DEFAULT "*", a_reaseguro CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*", a_saldo_cero SMALLINT, a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*", a_opcion_renovar SMALLINT DEFAULT 0)
RETURNING CHAR(20),
		  CHAR(50),
		  CHAR(50),
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  CHAR(50),
		  CHAR(255),
		  SMALLINT,
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  CHAR(1),
		  CHAR(7),
		  INTEGER;

DEFINE v_nombre_ramo   	 CHAR(50);
DEFINE v_nombre_subramo  CHAR(50);
DEFINE _saldo			 DECIMAL(16,2);
DEFINE _prima_sus		 DECIMAL(16,2);
DEFINE _incurrido_bruto	 DECIMAL(16,2);
DEFINE _prima			 DECIMAL(16,2);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_ramo,_cod_subramo         CHAR(3);
DEFINE _estatus          CHAR(1);
DEFINE _no_documento     CHAR(20);
DEFINE _cant_pol	     INTEGER;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);
LET _prima_sus = 0.00;


--DROP TABLE tmp_prod;

SET ISOLATION TO DIRTY READ;

LET v_filtros = sp_pro79(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo,
a_usuario,
a_reaseguro,
a_agente,
a_saldo_cero,
a_cod_cliente,
a_no_documento,
a_opcion_renovar
);

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH WITH HOLD
 SELECT COUNT(no_documento),
 		SUM(prima),
 		SUM(saldo),
 		cod_ramo,
 		cod_subramo,
		SUM(prima_sus),
		SUM(incurrido_bruto)
   INTO _cant_pol,																									 
        _prima,
        _saldo,
        _cod_ramo,
        _cod_subramo,
		_prima_sus,
		_incurrido_bruto
   FROM tmp_prod
  WHERE seleccionado = 1
  GROUP BY cod_ramo, cod_subramo
  ORDER BY cod_ramo, cod_subramo

--Selecciona los nombres de Ramos
         SELECT nombre
  	       INTO v_nombre_ramo
           FROM prdramo
          WHERE cod_ramo = _cod_ramo;

--Selecciona los nombres de Subramos
         SELECT nombre
  	       INTO v_nombre_subramo
           FROM prdsubra
          WHERE cod_ramo    = _cod_ramo
            AND cod_subramo = _cod_subramo;

RETURN    "", --_no_documento,
		  v_nombre_ramo,
		  v_nombre_subramo,
		  _prima,
		  _saldo,	
		  v_compania_nombre,
		  v_filtros,
		  a_opcion_renovar,
		  _prima_sus,
		  _incurrido_bruto,
		  "", --_estatus
		  a_periodo1,
		  _cant_pol
		  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;