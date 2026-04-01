-- Reporte de Total de Produccion de Reaseguro por Grupo
-- 
-- Creado    : 09/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 09/08/2000 - Autor: Lic. Armando Moreno
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pr112a;

CREATE PROCEDURE "informix".sp_pr112a(a_compania  CHAR(3),a_agencia  CHAR(3),a_periodo1  CHAR(7),a_periodo2  CHAR(7),a_sucursal  CHAR(255) DEFAULT "*",a_ramo  CHAR(255) DEFAULT "*",a_grupo CHAR(255) DEFAULT "*",a_agente    CHAR(255) DEFAULT "*")
  RETURNING CHAR(50),
            CHAR(50),
            CHAR(255),
			CHAR(10),
			CHAR(20),
			CHAR(50),
            DECIMAL(16,2), 
            DECIMAL(16,2),
            DECIMAL(5,2),
            DECIMAL(5,2),
            SMALLINT,
            CHAR(7),
            DECIMAL(16,2), 
            DECIMAL(16,2);

DEFINE v_nombre     	 							 CHAR(50);
DEFINE _no_poliza,_no_factura						 CHAR(10);
DEFINE _prima_fac,_prima_otr,_comis_fac,_comis_otr   DECIMAL(16,2);
DEFINE v_total_prima_neta_ret,_monto3,_monto2	     DECIMAL(16,2);
DEFINE _porc_fac,_porc_otr						     DECIMAL(5,2);
DEFINE v_compania_nombre,_nombre_contrato			 CHAR(50);
DEFINE v_filtros,v_filtros2							 CHAR(255);
DEFINE _cod_ramo         							 CHAR(3);
DEFINE _cantidad         							 INTEGER;
DEFINE _no_documento								 CHAR(20);
DEFINE _cod_contrato								 CHAR(5);
DEFINE _periodo										 CHAR(7);
DEFINE _serie										 SMALLINT;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_prod;

{CREATE TEMP TABLE tmp_prod2(
	        cod_ramo       		 CHAR(3) NOT NULL,
	     	nombre         		 CHAR(50),
	        total_pri_sus  		 DEC(16,2) NOT NULL,
	    	total_pri_ret  		 DEC(16,2) NOT NULL,
	    	total_pri_ced  		 DEC(16,2) NOT NULL,
			total_prima_neta_ret DEC(16,2) NOT NULL,
			comision_corredor 	 DEC(16,2) NOT NULL,
			impuesto		 	 DEC(16,2) NOT NULL,
			comision_rea_ced 	 DEC(16,2) NOT NULL,
	        no_poliza      		 CHAR(10)  NOT NULL,
			comision_fac     	 DEC(16,2) NOT NULL,
			comision_otr	 	 DEC(16,2) NOT NULL,
			prima_fac     	 	 DEC(16,2) NOT NULL,
			prima_otr	 	 	 DEC(16,2) NOT NULL,
	    PRIMARY KEY (no_poliza)) WITH NO LOG;}

LET v_filtros = sp_pro112(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_sucursal,
a_ramo,
a_grupo,
a_agente
);

--Recorre la tabla temporal y asigna valores a variables de salida

SET ISOLATION TO DIRTY READ;

FOREACH WITH HOLD
 SELECT no_poliza,
		no_factura,
		cod_contrato,
		porc_fac,
		porc_otr,
		prima_fac,
		prima_otr,
		cod_ramo,
		periodo,
		comis_fac,
		comis_otr
   INTO _no_poliza,
		_no_factura,
		_cod_contrato,
		_porc_fac,
		_porc_otr,
		_prima_fac,
		_prima_otr,
		_cod_ramo,
		_periodo,
		_comis_fac,
		_comis_otr
   FROM tmp_prod3
  WHERE seleccionado = 1
  ORDER BY cod_ramo,no_poliza

 SELECT nombre
   INTO v_nombre
   FROM prdramo
  WHERE cod_ramo = _cod_ramo;

 SELECT no_documento
   INTO	_no_documento
   FROM	emipomae
  WHERE no_poliza = _no_poliza;

 SELECT nombre,
		serie
   INTO	_nombre_contrato,
		_serie
   FROM	reacomae
  WHERE cod_contrato = _cod_contrato;

  RETURN  v_nombre,
		  v_compania_nombre,
		  v_filtros,
		  _no_factura,
		  _no_documento,
		  _nombre_contrato,	
		  _prima_fac,
		  _prima_otr,
		  _porc_fac,
		  _porc_otr,
		  _serie,
		  _periodo,
		  _comis_fac,
		  _comis_otr
		  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod3;

END PROCEDURE;
