-- Reporte de Siniestros Incurridos Cedidos (Solo salvamento y Recupero)
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 26/12/2000 - Autor: Yinia M. Zamora
--
-- SIS v.2.0 - d_sp_rec61a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec89a;

CREATE PROCEDURE "informix".sp_rec89a(a_compania CHAR(3),a_agencia  CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*") 
  RETURNING CHAR(18),
  			CHAR(100),
			CHAR(100),
  			CHAR(20),
			DATE,
  			DECIMAL(16,2),
  			DECIMAL(16,2),
  			DECIMAL(16,2),
  			DECIMAL(16,2),
  			CHAR(50),
  			CHAR(50),
  			CHAR(50),
  			CHAR(50),
  			CHAR(255),
  			CHAR(10);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_cliente_nombre, v_asegurado_nombre CHAR(100);
DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_fecha_siniestro DATE; 
DEFINE v_pagado_ancon,v_pagado_contrato,v_pagado_otro,v_pagado_bruto,v_pagado_cedido,v_variacion    DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre,v_nom_contrato,v_compania_nombre,v_nombre_cobertura CHAR(50); 
DEFINE v_nombre_tipo     CHAR(20);
DEFINE v_filtros         CHAR(255);

DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_cliente,_cod_aseg,_transaccion,_no_poliza,_no_reclamo,_no_tranrec  CHAR(10); 
DEFINE _periodo          CHAR(7);
DEFINE _cod_contrato, _no_unidad, _cod_cobertura   CHAR(05);
DEFINE _tipo_transaccion CHAR(01);
DEFINE _tipo_contrato    SMALLINT;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido


LET v_filtros = sp_rec89(
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

--set debug file to "sp_rec89a.trc";
--trace on;

SET ISOLATION TO DIRTY READ; 
FOREACH
 SELECT no_reclamo,
 		no_poliza,
		pagado_ancon,
		pagado_contrato,
		pagado_otro,
		pagado_bruto,
		variacion,
 	    incurrido_neto,
		cod_ramo,
		periodo,
		numrecla,
		nombre_contrato,
		transaccion,
		tipo_transaccion,
		tipo_contrato,
		no_tranrec
   INTO	_no_reclamo, 
   		_no_poliza,	
	    v_pagado_ancon,
		v_pagado_contrato,
		v_pagado_otro,
		v_pagado_bruto,
	    v_variacion,
	    v_incurrido_neto,
		_cod_ramo,
		_periodo,
		v_doc_reclamo,			
		v_nom_contrato,
		_transaccion,
		_tipo_transaccion,
		_tipo_contrato,
		_no_tranrec
   FROM tmp_sinis
  WHERE seleccionado = 1
    AND pagado_bruto <> 0
  ORDER BY cod_ramo,numrecla
 
  LET v_nom_contrato = 'CUOTA PARTE';

   	SELECT cod_reclamante,
	       no_unidad,
	       fecha_siniestro
	  INTO _cod_cliente,
	       _no_unidad,
	       v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

    FOREACH 
	   SELECT cod_cliente
	     INTO _cod_aseg
		 FROM endeduni
		WHERE no_poliza = _no_poliza
		  AND no_unidad = _no_unidad
	   EXIT FOREACH;
	END FOREACH

    FOREACH 
	   SELECT cod_cobertura
	     INTO _cod_cobertura
		 FROM recrccob
		WHERE no_reclamo = _no_reclamo
	   EXIT FOREACH;
	END FOREACH

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
	  INTO v_asegurado_nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_aseg;

    SELECT nombre
	  INTO v_nombre_tipo
	  FROM rectitra
	 WHERE tipo_transaccion = _tipo_transaccion;

    SELECT nombre
	  INTO v_nombre_cobertura
	  FROM prdcober
	 WHERE cod_cobertura = _cod_cobertura;


	RETURN v_doc_reclamo,
	 	   v_cliente_nombre,
		   v_asegurado_nombre,
	 	   v_doc_poliza,
		   v_fecha_siniestro,
		   v_pagado_bruto,
	 	   v_pagado_ancon,
		   v_pagado_contrato,
		   v_pagado_otro,
		   v_ramo_nombre,
		   v_nom_contrato,
		   v_nombre_cobertura,
		   v_compania_nombre,
		   v_filtros,
		   _transaccion
		    WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
