-- Reporte de Siniestros Incurridos Cedidos (Solo salvamento y Recupero)
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 26/12/2000 - Autor: Yinia M. Zamora
--
-- SIS v.2.0 - d_sp_rec61a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec61a;

CREATE PROCEDURE "informix".sp_rec61a(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*") RETURNING CHAR(18),CHAR(100),CHAR(20),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(20),CHAR(50),CHAR(255),CHAR(10);

DEFINE v_doc_reclamo      CHAR(18);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_doc_poliza       CHAR(20); 
DEFINE v_fecha_siniestro      DATE; 
DEFINE v_pagado_neto     DECIMAL(16,2); 
DEFINE v_variacion       DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50); 
DEFINE v_nom_contrato    CHAR(50);
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_nombre_tipo     CHAR(20);
DEFINE v_filtros         CHAR(255);

DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_cliente      CHAR(10); 
DEFINE _transaccion      CHAR(10); 
DEFINE _no_poliza		 CHAR(10); 
DEFINE _no_reclamo       CHAR(10); 
DEFINE _periodo           CHAR(7);
DEFINE _cod_contrato     CHAR(05);
DEFINE _tipo_transaccion CHAR(01);
DEFINE _tipo_contrato    SMALLINT;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido


LET v_filtros = sp_rec61(
a_compania,
a_agencia,
a_periodo1,
a_periodo2,
a_sucursal,
'*', 
a_ramo,
'*', 
'*', 
'*', 
'*',
a_contrato
); 

 
FOREACH
 SELECT no_reclamo,
 		no_poliza,
		pagado_neto,
		variacion,
 	    incurrido_neto,
		cod_ramo,
		periodo,
		numrecla,
		nombre_contrato,
		transaccion,
		tipo_transaccion,
		tipo_contrato
   INTO	_no_reclamo, 
   		_no_poliza,	
	    v_pagado_neto,
	    v_variacion,
	    v_incurrido_neto,
		_cod_ramo,
		_periodo,
		v_doc_reclamo,
		v_nom_contrato,
		_transaccion,
		_tipo_transaccion,
		_tipo_contrato
   FROM tmp_sinis
  WHERE seleccionado = 1
  ORDER BY nombre_contrato,cod_ramo
 
   	SELECT cod_reclamante
	  INTO _cod_cliente
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

  	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento
	  INTO v_doc_poliza
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

    SELECT nombre
	  INTO v_nombre_tipo
	  FROM rectitra
	 WHERE tipo_transaccion = _tipo_transaccion;

	RETURN v_doc_reclamo,
	 	   v_cliente_nombre,
	 	   v_doc_poliza,
	 	   v_pagado_neto,
	 	   v_variacion,
	 	   v_incurrido_neto,
		   v_ramo_nombre,
		   v_nom_contrato,
		   v_nombre_tipo,
		   v_compania_nombre,
		   v_filtros,
		   _transaccion
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
