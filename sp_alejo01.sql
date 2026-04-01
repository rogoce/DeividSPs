-- Creado: 12/12/2025 - Autor: Federico Coronado 

drop procedure sp_moro4;

create procedure "informix".sp_moro4(a_cod_formapago char(3))
returning varchar(50) AS poliza ,
          varchar(50) AS cliente,
          varchar(50) AS division,
          varchar(30) AS forma_pago,
          varchar(50) AS zona ,
          varchar(50) AS nombre_ramo ,
          varchar(50) AS nombre_subramo ,
          varchar(50) AS no_pagos,
          varchar(50) AS agente ,
          varchar(50) AS porc_partic_agt ,
          varchar(50) AS vigencia_inic ,
          varchar(50) AS vigencia_final ,
          varchar(50) AS fecha_aviso_canc,
          varchar(50) AS vendedor ,
          varchar(50) AS estatus ,
          varchar(50) AS razon_no_renov,
          varchar(50) AS leasing ,
          varchar(50) AS nombre_leasing ,
          varchar(50) AS nombre_acreedor,
          varchar(50) AS prima_bruta ,
          varchar(50) AS tipo_renovacion,
          varchar(50) AS cod_grupo ,
          varchar(50) AS grupo ,
          varchar(50) AS cobros ,
          varchar(50) AS saldo ,
          varchar(50) AS por_vencer ,
          varchar(50) AS exigible ,
          varchar(50) AS corriente,
          varchar(50) AS dias_30 ,
          varchar(50) AS dias_60 ,
          varchar(50) AS dias_90 ,
          varchar(50) AS dias_120 ,
          varchar(50) AS dias_150,
          varchar(50) AS dias_180,
          varchar(50) AS facultativo ,
          varchar(50) AS fronting,
          varchar(50) AS no_poliza ,
          varchar(50) AS periodo,
          varchar(50) AS porc_partic_coas,
          varchar(50) AS clase_prod;

define v_no_documento 		varchar(50);
define v_cliente 	  		varchar(50);
define v_division	  		varchar(50);
define v_forma_pago   		varchar(30);
define v_zona				varchar(50);
define v_nombre_ramo        varchar(50);
define v_nombre_subramo     varchar(50);
define v_no_pagos           varchar(50);
define v_agente             varchar(50);
define v_porc_partic_agt    varchar(50);
define v_vigencia_inic      varchar(50);
define v_vigencia_final     varchar(50);
define v_fecha_aviso_canc   varchar(50);
define v_vendedor           varchar(50);
define v_estatus_poliza     varchar(50);
define v_razon_no_renov     varchar(50);
define v_leasing            varchar(50);
define v_nombre_leasing     varchar(50);
define v_nombre_acreedor    varchar(50);
define v_prima_bruta        varchar(50);
define v_tipo_renovacion    varchar(50);
define v_cod_grupo          varchar(50);
define v_grupo              varchar(50);
define v_cobros             varchar(50);
define v_saldo              varchar(50);
define v_por_vencer         varchar(50);
define v_exigible           varchar(50);
define v_corriente          varchar(50);
define v_dias_30            varchar(50);
define v_dias_60            varchar(50);
define v_dias_90            varchar(50);
define v_dias_120           varchar(50);
define v_dias_150           varchar(50);
define v_dias_180           varchar(50);
define v_facultativo        varchar(50);
define v_fronting           varchar(50);
define v_no_poliza          varchar(50);
define v_periodo            varchar(50);
define v_porc_partic_coas   varchar(50);
define v_clase_prod         varchar(50);

set isolation to dirty read;

    FOREACH
		SELECT m.no_documento AS poliza, 
			   cl.nombre AS cliente, 
			   cd.nombre AS division, 
			   cf.nombre AS forma_pago, 
			   cb.nombre AS zona, 
			   pr.nombre AS nombre_ramo, 
			   sr.nombre AS nombre_subramo, 
			   ep.no_pagos, 
			   ag.nombre AS agente, 
			   ea.porc_partic_agt, 
			   ep.vigencia_inic, 
			   ep.vigencia_final, 
			   ep.fecha_aviso_canc, 
			   av.nombre AS vendedor, 
			   ep.estatus_poliza AS estatus, 
		       er.nombre AS razon_no_renov, 
			   ep.leasing AS leasing, 
		       m.nombre_leasing, 
			   m.acreedor AS nombre_acreedor, 
			   ep.prima_bruta, 
		       ep.nueva_renov AS tipo_renovacion, 
		       ep.cod_grupo, 
			   gr.nombre AS grupo, 
			   m.cobros_total AS cobros, 
			   m.saldo, 
			   m.por_vencer, 
			   m.exigible, 
		       m.corriente, 
			   m.dias_30, 
			   m.dias_60, 
			   m.dias_90, 
			   m.dias_120, 
			   m.dias_150, 
			   m.dias_180, 
		       m.facultativo AS facultativo, 
			   ep.fronting, 
			   m.no_poliza, 
			   m.periodo,
			   coa.porc_partic_coas,
			   ep.cod_tipoprod AS clase_prod
		into v_no_documento, 
			 v_cliente, 
			 v_division, 
			 v_forma_pago, 
			 v_zona, 
			 v_nombre_ramo, 
			 v_nombre_subramo, 
			 v_no_pagos, 
			 v_agente, 
			 v_porc_partic_agt, 
			 v_vigencia_inic, 
			 v_vigencia_final, 
			 v_fecha_aviso_canc, 
			 v_vendedor, 
			 v_estatus_poliza, 
			 v_razon_no_renov, 
			 v_leasing, 
			 v_nombre_leasing, 
			 v_nombre_acreedor, 
			 v_prima_bruta, 
			 v_tipo_renovacion, 
			 v_cod_grupo, 
			 v_grupo, 
			 v_cobros, 
			 v_saldo, 
			 v_por_vencer, 
			 v_exigible, 
			 v_corriente, 
			 v_dias_30, 
			 v_dias_60, 
			 v_dias_90, 
			 v_dias_120, 
			 v_dias_150, 
			 v_dias_180, 
			 v_facultativo, 
			 v_fronting, 
			 v_no_poliza, 
			 v_periodo,
			 v_porc_partic_coas,
			 v_clase_prod
		FROM deivid_cob:cobmoros4 m 
		INNER JOIN emipomae ep ON ep.no_documento=m.no_documento AND ep.no_poliza=m.no_poliza AND ep.actualizado=1 
		INNER JOIN cligrupo gr ON gr.cod_grupo=ep.cod_grupo 
		INNER JOIN cliclien cl ON cl.cod_cliente=ep.cod_contratante 
		LEFT  JOIN cobdivis cd ON cd.cod_division=ep.cobra_poliza 
		JOIN cobforpa cf ON cf.cod_formapag=ep.cod_formapag 
		INNER JOIN prdramo pr ON pr.cod_ramo=ep.cod_ramo 
		INNER JOIN prdsubra sr ON sr.cod_ramo=ep.cod_ramo AND sr.cod_subramo=ep.cod_subramo 
		INNER JOIN emipoagt ea ON ea.no_poliza=ep.no_poliza 
		INNER JOIN agtagent ag ON ag.cod_agente=ea.cod_agente 
		INNER JOIN cobcobra cb ON cb.cod_cobrador=ag.cod_cobrador 
		INNER JOIN agtvende av ON ((av.cod_vendedor=ag.cod_vendedor AND pr.cod_tiporamo<>'001') OR 
		(av.cod_vendedor=ag.cod_vendedor2 AND pr.cod_tiporamo='001')) 
		LEFT JOIN eminoren er ON er.cod_no_renov=ep.cod_no_renov 
		LEFT  JOIN emicoama coa  ON coa.no_poliza   = ep.no_poliza AND coa.cod_coasegur = '036'
		WHERE (NVL(m.cobros_total,0) <> 0 OR NVL(m.saldo,0) <> 0)
		AND ep.cod_formapag = a_cod_formapago

        -- Retornamos cada fila al cliente
        RETURN v_no_documento, 
			 v_cliente, 
			 v_division, 
			 v_forma_pago, 
			 v_zona, 
			 v_nombre_ramo, 
			 v_nombre_subramo, 
			 v_no_pagos, 
			 v_agente, 
			 v_porc_partic_agt, 
			 v_vigencia_inic, 
			 v_vigencia_final, 
			 v_fecha_aviso_canc, 
			 v_vendedor, 
			 v_estatus_poliza, 
			 v_razon_no_renov, 
			 v_leasing, 
			 v_nombre_leasing, 
			 v_nombre_acreedor, 
			 v_prima_bruta, 
			 v_tipo_renovacion, 
			 v_cod_grupo, 
			 v_grupo, 
			 v_cobros, 
			 v_saldo, 
			 v_por_vencer, 
			 v_exigible, 
			 v_corriente, 
			 v_dias_30, 
			 v_dias_60, 
			 v_dias_90, 
			 v_dias_120, 
			 v_dias_150, 
			 v_dias_180, 
			 v_facultativo, 
			 v_fronting, 
			 v_no_poliza, 
			 v_periodo,
			 v_porc_partic_coas,
			 v_clase_prod 
        WITH RESUME;
	END FOREACH;
END PROCEDURE;