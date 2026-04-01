-- Creado    : 23/10/2025 Armando Moreno M.
-- Análisis de Siniestros Pagados, d_recl_sp_rec751_dw1

DROP PROCEDURE sp_rec751;
CREATE PROCEDURE sp_rec751(a_compania  CHAR(3),a_agencia   CHAR(3),a_periodo1  CHAR(7),a_periodo2  CHAR(7),a_sucursal  CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*")
RETURNING CHAR(10),CHAR(10),CHAR(10),CHAR(20),CHAR(3),CHAR(5),CHAR(3),CHAR(3),CHAR(5),VARCHAR(50),VARCHAR(50),CHAR(10),CHAR(7),CHAR(18),CHAR(10),
          DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),
          DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(255);

DEFINE v_doc_reclamo     CHAR(18); 
DEFINE v_transaccion,_no_tranrec	 CHAR(10);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_doc_poliza      CHAR(20); 
DEFINE v_fecha_siniestro DATE; 
DEFINE v_pagado_total,v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto,_reserva_fac     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
define _reserva_total,_pagado_fac    DECIMAL(16,2);
DEFINE _reserva_coaseg  DECIMAL(16,2);
DEFINE _incurrido_coaseg  DECIMAL(16,2);
define _incurrido_fac,_pagado_coaseg     DECIMAL(16,2);
define _incurrido_total	DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_filtros         CHAR(255);
DEFINE _no_reclamo       CHAR(10);
DEFINE _no_poliza        CHAR(10); 
DEFINE _cod_ramo,_cod_sucursal         CHAR(3);
DEFINE _cod_cliente      CHAR(10); 
DEFINE _periodo          CHAR(7);
define _n_sucursal       char(40);
define _n_corredor,_n_vendedor   varchar(50);
define _cod_vendedor,_cod_subramo char(3);
define _cod_agente,_cod_grupo char(5);
-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_rec709(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*', '*', '*', '*'); 

SET ISOLATION TO DIRTY READ; 
FOREACH
	SELECT no_reclamo,
		   no_poliza,
		   pagado_total,
		   pagado_bruto, 
		   pagado_neto,
		   reserva_bruto,
		   reserva_neto,	
		   incurrido_bruto,
		   incurrido_neto,
		   cod_ramo,	
		   periodo,
		   numrecla,
		   transaccion,
		   cod_sucursal,
		   no_tranrec,
		   cod_grupo,
		   cod_subramo,
		   pagado_fac,
		   reserva_total,
		   reserva_fac,
		   incurrido_total,
		   incurrido_fac
	  INTO _no_reclamo, 
		   _no_poliza,	
		   v_pagado_total,
		   v_pagado_bruto, 
		   v_pagado_neto,
		   v_reserva_bruto,
		   v_reserva_neto, 
		   v_incurrido_bruto,
		   v_incurrido_neto,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   v_transaccion,
		   _cod_sucursal,
		   _no_tranrec,
		   _cod_grupo,
		   _cod_subramo,
		   _pagado_fac,
		   _reserva_total,
		   _reserva_fac,
		   _incurrido_total,
		   _incurrido_fac
	  FROM tmp_sinis
	 WHERE seleccionado = 1
	 ORDER BY cod_ramo,numrecla

	SELECT cod_reclamante,
	       fecha_siniestro
	  INTO _cod_cliente,
	       v_fecha_siniestro
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
	
	FOREACH
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit FOREACH;
	end FOREACH

	call sp_sis525(_cod_agente,_cod_sucursal,_cod_ramo) RETURNING _n_corredor,_cod_vendedor,_n_vendedor;
	 
	SELECT nombre
	  INTO v_cliente_nombre
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;
	 
	SELECT descripcion
	  INTO _n_sucursal
	  FROM insagen
	 WHERE codigo_agencia = _cod_sucursal;
	 
	let _pagado_coaseg = 0;
	let _pagado_coaseg = v_pagado_total - v_pagado_bruto;
	
	let _reserva_coaseg = 0;
	let _reserva_coaseg = _reserva_total - v_reserva_bruto;
	
	let _incurrido_coaseg = 0;
	let _incurrido_coaseg = _incurrido_total - v_incurrido_bruto;

	RETURN _no_reclamo,
		   _no_tranrec,
		   _no_poliza,
		   v_doc_poliza,
		   _cod_sucursal,
		   _cod_grupo,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_agente,
		   _n_corredor,
		   _n_vendedor,
		   _cod_cliente,
		   _periodo,
	       v_doc_reclamo,
	       v_transaccion,
		   v_pagado_total,
		   _pagado_coaseg,
		   v_pagado_bruto,
		   _pagado_fac,
		   v_pagado_neto,
		   _reserva_total,
		   _reserva_coaseg,
		   v_reserva_bruto,
		   _reserva_fac,
		   v_reserva_neto,
		   _incurrido_total,
		   _incurrido_coaseg,
		   v_incurrido_bruto,
		   _incurrido_fac,
		   v_incurrido_neto,
		   v_compania_nombre,
		   v_filtros
		   WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;
END PROCEDURE;
