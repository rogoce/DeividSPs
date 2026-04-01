-- Totales de vencimiento por Ramo / Subramo
-- 
-- Creado    : 29/10/2001 - Autor: Lic. Armando Moreno 
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pr79g;

CREATE PROCEDURE "informix".sp_pr79g(
		a_compania 		 CHAR(3), 
		a_agencia  		 CHAR(3), 
		a_periodo1 		 CHAR(7), 
		a_periodo2 		 CHAR(7), 
		a_sucursal 		 CHAR(255) DEFAULT "*", 
		a_ramo     		 CHAR(255) DEFAULT "*", 
		a_grupo    		 CHAR(255) DEFAULT "*", 
		a_usuario  		 CHAR(255) DEFAULT "*", 
		a_reaseguro 	 CHAR(255) DEFAULT "*", 
		a_agente    	 CHAR(255) DEFAULT "*", 
		a_cod_cliente    CHAR(255) DEFAULT "*", 
		a_no_documento   CHAR(255) DEFAULT "*",
		a_opcion_renovar SMALLINT  DEFAULT 0, 
		a_rango1         SMALLINT  DEFAULT 0, 
		a_rango2         SMALLINT  DEFAULT 20, 
		a_rango3         SMALLINT  DEFAULT 21, 
		a_rango4         SMALLINT  DEFAULT 40, 
		a_rango5         SMALLINT  DEFAULT 41, 
		a_rango6         SMALLINT  DEFAULT 60
		)
RETURNING CHAR(20), CHAR(50), CHAR(50), DECIMAL(16,2), DECIMAL(16,2), CHAR(50), CHAR(255), SMALLINT, DECIMAL(16,2), DECIMAL(16,2),CHAR(1),CHAR(25);

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
DEFINE _estatus_descripcion     CHAR(25);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;

SET ISOLATION TO DIRTY READ;

LET v_filtros = sp_pro80(
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
a_cod_cliente,
a_no_documento,
a_opcion_renovar,
a_rango1,
a_rango2,
a_rango3,
a_rango4,
a_rango5,
a_rango6
);

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH WITH HOLD
 SELECT no_documento,
 		prima,
 		saldo,
 		cod_ramo,
 		cod_subramo,
		prima_sus,
		incurrido_bruto,
		estatus
   INTO _no_documento,																									 
        _prima,
        _saldo,
        _cod_ramo,
        _cod_subramo,
		_prima_sus,
		_incurrido_bruto,
		_estatus
   FROM tmp_prod
  WHERE seleccionado = 1
  ORDER BY estatus, cod_ramo, cod_subramo, no_documento

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

IF _estatus = "5" THEN
 LET _estatus_descripcion = "Con Saldo Credito";
ELIF _estatus = "1" THEN
 LET _estatus_descripcion = "Con Saldo hasta " || a_rango2 || "%";
ELIF _estatus = "2" THEN
 LET _estatus_descripcion = "Con Saldo de " || a_rango3 || "%" || "a " || a_rango4 || "%";
ELIF _estatus = "3" THEN
 LET _estatus_descripcion = "Con Saldo de " || a_rango5 || "%" || "a " || a_rango6 || "%";
ELIF _estatus = "4" THEN
 LET _estatus_descripcion = "Con Saldo Mayor a 60%";
ELIF _estatus = "6" THEN
 LET _estatus_descripcion = "Con Saldo Cero";
ELIF _estatus = "7" THEN
 LET _estatus_descripcion = "Prima Neta Cero";
END IF

RETURN    _no_documento,
		  v_nombre_ramo,
		  v_nombre_subramo,
		  _prima,
		  _saldo,	
		  v_compania_nombre,
		  v_filtros,
		  a_opcion_renovar,
		  _prima_sus,
		  _incurrido_bruto,
		  _estatus,
		  _estatus_descripcion
		  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;