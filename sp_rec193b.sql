-- Procedimiento que Carga el Incurrido de Reclamos
-- en un Periodo Dado
--
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 16/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 23/01/2003 - Autor: Amado Perez 
--                          Se modifico para que leyera la sucursal del campo sucursal_origen
--                          de emipomae y no de cod_sucursal
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec193b;
CREATE PROCEDURE "informix".sp_rec193b(
		a_compania  CHAR(3),
		a_agencia   CHAR(3)
		) RETURNING CHAR(255);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);
DEFINE _incurrido_abierto DEC(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;
DEFINE v_desc_grupo,v_desc_agente   CHAR(50);
DEFINE v_codigo,_cod_agente         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,v_no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo,_peri,v_periodo,_periodo_rec CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _no_unidad       CHAR(5);
DEFINE _no_tranrec      CHAR(10);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;
DEFINE _cod_acreedor    CHAR(5);
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _transaccion     CHAR(10);

DEFINE _cod_entrada     CHAR(10);
DEFINE _cod_asignacion  CHAR(10);
DEFINE _fecha_pagado    DATE;
DEFINE _periodo1        CHAR(7);
DEFINE _periodo2        CHAR(7);

DEFINE _mes             INT;
DEFINE _anio            INT;


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);
--set debug file to "sp_rec193b.trc";
--trace on;
let v_filtros = "";

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;
LET _cod_entrada = "";

FOREACH
   select periodo,periodo[6,7],periodo[1,4]
     into _periodo1,_mes,_anio
	 from periodo
	where activo = 1 

  FOREACH
   SELECT distinct cod_entrada
     INTO _cod_entrada
     FROM atcdocma
    WHERE month(fecha) = _mes -- 07
      AND year(fecha) = _anio  -- 2011
	  --and cod_entrada in ('56376','56517')  -- = '56517'

	  FOREACH
	   SELECT distinct cod_asignacion
	     INTO _cod_asignacion
	     FROM atcdocde
	    WHERE cod_entrada = _cod_entrada
	      AND no_documento[1,2] = '18'

			FOREACH
			 SELECT no_reclamo,fecha,sum(monto)
			   INTO _no_reclamo,_fecha_pagado,_monto_total
			   FROM rectrmae
			  WHERE cod_compania = a_compania
			    AND actualizado  = 1
				AND cod_asignacion = _cod_asignacion
                AND numrecla[1,2] = '18'
				AND cod_tipotran IN ('004','005','006','007')
			    AND monto        <> 0
				group by no_reclamo,fecha
				order by no_reclamo,fecha


			  if _monto_total is null then
				Let _monto_total = 0;
			  end if

		      call sp_sis39(_fecha_pagado) returning _periodo2;

				{if _periodo2 is null then
					let _periodo2 = _periodo1;
				end if}

				-- Actualizacion del Movimiento

				INSERT INTO tmp_incurrido(
				no_reclamo,
				pagado_total,
				pagado_bruto,
				pagado_neto,
				incurrido_abierto,
				periodo,
				periodo_pago,
				transaccion
				)
				VALUES(
				_no_reclamo,
				_monto_total,
				0,
				0,
				0,
				_periodo1,
				_periodo2,
				""
				);

			END FOREACH

		END FOREACH

	END FOREACH

END FOREACH

RETURN v_filtros;

END PROCEDURE;
