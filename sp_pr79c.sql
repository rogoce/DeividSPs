-- Totales de vencimiento por Grupo
-- 
-- Creado    : 01/11/2001 - Autor: Lic. Armando Moreno 
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_pr79c;

CREATE PROCEDURE "informix".sp_pr79c(
		a_compania CHAR(3),
		a_agencia CHAR(3),
		a_periodo1 CHAR(7),
		a_periodo2 CHAR(7),
		a_sucursal CHAR(255) DEFAULT "*",
		a_ramo CHAR(255) DEFAULT "*", 
		a_grupo CHAR(255) DEFAULT "*", 
		a_usuario CHAR(255) DEFAULT "*", 
		a_reaseguro CHAR(255) DEFAULT "*", 
		a_agente CHAR(255) DEFAULT "*", 
		a_saldo_cero SMALLINT, 
		a_cod_cliente CHAR(255) DEFAULT "*", 
		a_no_documento CHAR(255) DEFAULT "*", 
		a_opcion_renovar SMALLINT DEFAULT 0
		)
RETURNING CHAR(20),
		  CHAR(50),
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  CHAR(50),
		  CHAR(255),
		  SMALLINT,
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  CHAR(1);

DEFINE v_nombre_grupo	 CHAR(50);
DEFINE _saldo			 DECIMAL(16,2);
DEFINE _prima_sus		 DECIMAL(16,2);
DEFINE _incurrido_bruto	 DECIMAL(16,2);
DEFINE _prima			 DECIMAL(16,2);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_grupo        CHAR(5);
DEFINE _estatus          CHAR(1);
DEFINE _no_documento     CHAR(20);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;

--SET DEBUG FILE TO "sp_pr79c.trc";

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
--TRACE ON;

FOREACH WITH HOLD
 SELECT no_documento,
 		prima,
 		saldo,
 		cod_grupo,
		prima_sus,
		incurrido_bruto,
		estatus
   INTO _no_documento,																									 
        _prima,
        _saldo,
        _cod_grupo,
		_prima_sus,
		_incurrido_bruto,
		_estatus
   FROM tmp_prod
  WHERE seleccionado = 1
  ORDER BY cod_grupo

--Selecciona los nombres de los Grupos
         SELECT nombre
  	       INTO v_nombre_grupo
           FROM cligrupo
          WHERE cod_grupo = _cod_grupo;

RETURN    _no_documento,
		  v_nombre_grupo,
		  _prima,
		  _saldo,	
		  v_compania_nombre,
		  v_filtros,
		  a_opcion_renovar,
		  _prima_sus,
		  _incurrido_bruto,
		  _estatus
		  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;