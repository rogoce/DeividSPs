-- Reporte de Incurrido Neto por Periodo
-- 
-- Creado    : 23/10/2001 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_sp_rec04a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rec04d;

CREATE PROCEDURE "informix".sp_rec04d(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(3) DEFAULT "*", a_ramo CHAR(3) DEFAULT "*", a_ajustador CHAR(3) DEFAULT "*") RETURNING CHAR(18),CHAR(100),CHAR(100),CHAR(7),CHAR(20),DATE,DATE,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(10),CHAR(255);		

DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);

DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_proveedor  	 CHAR(100);
DEFINE v_doc_poliza      CHAR(20);
DEFINE v_fecha_siniestro DATE;
DEFINE v_fecha           DATE;
DEFINE v_pagado_total    DECIMAL(16,2);
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_transaccion     CHAR(10);

DEFINE _no_reclamo      CHAR(10);
DEFINE _no_tranrec      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _cod_proveedor   CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_sucursal    CHAR(3);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

--DROP TABLE tmp_sinis;

-- Cargar el Incurrido

{CALL sp_rec04(
a_compania, 
a_agencia, 
a_periodo1, 
a_periodo2
); }
LET v_filtros = sp_rec57(
a_compania,
a_agencia, 
a_periodo1,
a_periodo2,
a_sucursal,
'*', 
a_ramo,
'*', 
a_ajustador, 
'*', 
'*'
); 

FOREACH
 SELECT a.no_reclamo,		
        a.no_tranrec,
 		a.no_poliza,
 		a.pagado_total,			
 		a.pagado_bruto, 		
 		a.pagado_neto, 
	    a.reserva_bruto, 	
	    a.reserva_neto,		
	    a.incurrido_bruto,	
	    a.incurrido_neto,
		a.cod_ramo,	
		a.cod_grupo,
		a.cod_sucursal,
		a.numrecla,
		a.transaccion,
		a.ajust_interno,
		b.fecha,
		b.periodo,
		b.cod_cliente
   INTO	_no_reclamo, 
        _no_tranrec,		
   		_no_poliza,	   
   		v_pagado_total,	
   		v_pagado_bruto, 		
   		v_pagado_neto, 
	    v_reserva_bruto,		
	    v_reserva_neto, 	
	    v_incurrido_bruto,	
	    v_incurrido_neto,
		_cod_ramo,	
		_cod_grupo,
		_cod_sucursal,		
		v_doc_reclamo,
		v_transaccion,
		_ajust_interno,
		v_fecha,
		_periodo,
		_cod_proveedor
   FROM tmp_sinis a  , rectrmae b 
  WHERE a.seleccionado = 1
    AND b.no_reclamo = a.no_reclamo	  
    AND b.no_tranrec = a.no_tranrec
  ORDER BY  b.periodo, a.transaccion

{	SELECT fecha,
	       periodo,
		   cod_cliente
	  INTO v_fecha,
	       _periodo,
		   _cod_proveedor
	  FROM rectrmae
	 WHERE no_tranrec = _no_tranrec;	}

	SELECT cod_reclamante,	fecha_siniestro
	  INTO _cod_cliente,	v_fecha_siniestro
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
	  INTO v_proveedor		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_proveedor;

	RETURN v_doc_reclamo,
	 	   v_cliente_nombre,
	 	   v_proveedor, 	
		   _periodo,
	 	   v_doc_poliza,		
	 	   v_fecha_siniestro, 
		   v_fecha,
		   v_pagado_total,
		   v_pagado_bruto,		
		   v_pagado_neto,	 	
		   v_reserva_bruto,  	
		   v_reserva_neto,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_transaccion,
		   v_filtros
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
END PROCEDURE;

