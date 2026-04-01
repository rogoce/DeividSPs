-- Reporte de Incurrido Neto por Ramo ----->>>> INCLUYENDO SALVAMENTO Y DEDUCIBLE
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 06/09/2001 - Autor: Amado Perez -- Inclusion del campo transaccion
-- Modificado: 15/04/2010 - Autor: Henry Giron -- Inclusion deducibles y salvamentos
-- SIS v.2.0 - d_sp_rec01a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_sinpag_info_deloitte2;
CREATE PROCEDURE "informix".sp_sinpag_info_deloitte2(a_compania  CHAR(3),a_agencia   CHAR(3),a_periodo1  CHAR(7),a_periodo2  CHAR(7),a_sucursal  CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*")
RETURNING 	CHAR(50) as Ramo,
            CHAR(20) as Poliza,
			CHAR(100) as Cliente,
			char(1) as Tipo_Persona,
			CHAR(18) as Reclamo,
			char(12) as Estatus_Reclamo,
			DECIMAL(16,2) as Prima_Neta,
			DATE as Fecha_Suscripcion,
			DATE as Vigenica_Inicial,
			DATE as Vigencia_Final,
			DECIMAL(16,2) as Suma_Asegurada,
			DATE as Fecha_Siniestro,
			DATE as Fecha_Reclamo,
			DECIMAL(16,2) as Pagado_total,
			DECIMAL(16,2) as Pagado_bruto,
			DECIMAL(16,2) as Reserva,
			DECIMAL(16,2) as Deducible_pagado;

DEFINE v_doc_reclamo     CHAR(18); 
DEFINE v_transaccion	 CHAR(10);
DEFINE v_cliente_nombre  CHAR(100);
DEFINE v_doc_poliza      CHAR(20);
DEFINE _fecha_suscripcion DATE;
DEFINE v_fecha_siniestro,_fecha_reclamo,_vig_ini,_vig_fin DATE; 
DEFINE v_pagado_total,v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto,_suma_as  DECIMAL(16,2);
DEFINE v_ramo_nombre     CHAR(50); 
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_filtros         CHAR(255);

DEFINE _no_reclamo       CHAR(10);
DEFINE _no_poliza        CHAR(10); 
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_cliente      CHAR(10); 
DEFINE _periodo          CHAR(7);

define _estatus_reclamo   char(1);
define _desc_estatus      char(12);
define _estimado 		DECIMAL(16,2);
define _deducible       DECIMAL(16,2);
define _pagos           DECIMAL(16,2);  
define _recupero		DECIMAL(16,2);  
define _salvamento		DECIMAL(16,2); 
define _prima_neta		DECIMAL(16,2); 
define _deducible_pagado DECIMAL(16,2);
define _deducible_devuel DECIMAL(16,2);
define v_porc_reas       DECIMAL(16,2);
define v_porc_coas       DECIMAL(16,2);
define _ded              DECIMAL(16,2);
define _incurrido_reclamo DECIMAL(16,2);
define _incurrido_bruto   DECIMAL(16,2);
define _incurrido_neto    DECIMAL(16,2);
define _reserva_inicial   DECIMAL(16,2);
define _reserva_actual    DECIMAL(16,2);  
define _tipo_persona      char(1);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

--DROP TABLE tmp_sinis;

LET v_filtros = sp_rec709(
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
'*'
); 


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
			transaccion
	   INTO	_no_reclamo, 
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
			v_transaccion
	   FROM tmp_sinis
	  WHERE seleccionado = 1
	  ORDER BY cod_ramo,numrecla

	SELECT fecha_siniestro,fecha_reclamo,estatus_reclamo,cod_reclamante
	  INTO v_fecha_siniestro,_fecha_reclamo,_estatus_reclamo,_cod_cliente
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion,
		   cod_ramo,
		   prima_neta
	  INTO v_doc_poliza,
	       _cod_cliente,
		   _suma_as,
		   _vig_ini,
		   _vig_fin,
		   _fecha_suscripcion,
		   _cod_ramo,
		   _prima_neta
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre,tipo_persona
	  INTO v_cliente_nombre,_tipo_persona
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;
	 
	if _estatus_reclamo = 'A' then
	   let _desc_estatus = 'Abierto';
	elif _estatus_reclamo = 'C' then
	   let _desc_estatus = 'Cerrado';
	elif _estatus_reclamo = 'D' then
	   let _desc_estatus = 'Declinado';
	elif _estatus_reclamo = 'N' then
	   let _desc_estatus = 'No Aplica';
	else
	 let _desc_estatus = '';
	end if

call sp_rec33(_no_reclamo) returning _estimado,_deducible,_reserva_inicial,_reserva_actual,_pagos,_recupero,_salvamento,_deducible_pagado,_deducible_devuel,v_porc_reas,
	   v_porc_coas, _ded, _incurrido_reclamo, _incurrido_bruto, _incurrido_neto;

	RETURN v_ramo_nombre,
		   v_doc_poliza,
		   v_cliente_nombre,
		   _tipo_persona,
	       v_doc_reclamo,
		   _desc_estatus,
		   _prima_neta,
		   _fecha_suscripcion,
		   _vig_ini,
		   _vig_fin,
		   _suma_as,
	 	   v_fecha_siniestro, 	
		   _fecha_reclamo,
	 	   v_pagado_total, 
		   v_pagado_bruto,	
		   v_reserva_bruto,
		   _deducible_pagado
		   WITH RESUME;
		   
		   
END FOREACH

DROP TABLE tmp_sinis;

END PROCEDURE;
