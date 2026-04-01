-- Informe de Honorarios prof Corredores para la SUPERINTENDENCIA DE SEGUROS Y REASEGUROS
-- Búsqueda de las comisiones descontadas y otros honorarios
-- 
-- Creado    : 30/12/2022 - Autor: Amado Pérez Mendoza
-- Modificado: 30/12/2022 - Autor: Amado Pérez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che163c;

CREATE PROCEDURE "informix".sp_che163c(a_fecha_desde DATE, a_fecha_hasta DATE) 

DEFINE _cod_agente       CHAR(5);

SET ISOLATION TO DIRTY READ;

-- Remesa de montos descontados -- Adicionado -- Amado -- según caso 850 Zuleyka 14-06-2021 

FOREACH
		SELECT	distinct  b.cod_agente
		  INTO  _cod_agente
		  FROM	cobredet a
	INNER JOIN  cobreagt b
			ON  b.no_remesa = a.no_remesa
			AND b.renglon = a.renglon
	INNER JOIN emipomae c
			ON c.no_poliza = a.no_poliza
	INNER JOIN emitipro d
			ON d.cod_tipoprod = c.cod_tipoprod
		   AND d.tipo_produccion not in (3,4)
		 WHERE	a.actualizado      = 1
		   AND a.tipo_mov         IN ('P','N','C')
		   AND a.fecha >= a_fecha_desde
		   AND a.fecha <= a_fecha_hasta	   
		   AND a.monto_descontado <> 0
		 ORDER BY 1
		 
		INSERT INTO tmp_agente(
		cod_agente,
		no_poliza,
		no_recibo,
		fecha,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision,
		nombre,
		no_documento,
		monto_vida,
		monto_danos,
		monto_fianza,
		no_licencia,
		cod_grupo,
		agente_agrupado
		)
		VALUES(
		_cod_agente,
		'no_poliza1',
		'no_recibo1',
		today,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		0,
		0,
		0,
		null,
		null,
		null
		);
END FOREACH

-- Otras comisiones

FOREACH
	 SELECT	distinct y.cod_agente
	   INTO _cod_agente
	   FROM	chqchcta x, chqchmae y
	  WHERE x.no_requis = y.no_requis
		AND y.fecha_impresion >= a_fecha_desde
		AND y.fecha_impresion <= a_fecha_hasta
		AND y.cod_agente is not null
		AND y.pagado = 1
		AND y.anulado = 0
		AND (x.cuenta[1,3] in ("564") 			   -->GASTOS POR ADMINISTRACION
		 OR x.cuenta[1,3] in ("521")			   -->HONORARIOS PROFESIONALES-AGENTES Y CORREDORES
		 OR x.cuenta[1,5] in ("26401"))   -->HONORARIOS POR PAGAR AGENTES Y CORREDORES / HONORARIOS Y COMISIONES POR PAGAR AGENTES AUXILIAR
	  ORDER BY 1

		INSERT INTO tmp_agente(
		cod_agente,
		no_poliza,
		no_recibo,
		fecha,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision,
		nombre,
		no_documento,
		monto_vida,
		monto_danos,
		monto_fianza,
		no_licencia,
		cod_grupo,
		agente_agrupado
		)
		VALUES(
		_cod_agente,
		'no_poliza2',
		'no_recibo2',
		today,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		0,
		0,
		0,
		null,
		null,
		null
		);

END FOREACH


END PROCEDURE