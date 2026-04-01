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

DROP PROCEDURE sp_rec193a;
CREATE PROCEDURE "informix".sp_rec193a(
		a_compania  CHAR(3),
		a_agencia   CHAR(3),
		a_periodo1  CHAR(7),
		a_periodo2  CHAR(7),
		a_sucursal  CHAR(255) DEFAULT "*",
		a_grupo     CHAR(255) DEFAULT "*",
		a_ramo      CHAR(255) DEFAULT "*",
		a_agente    CHAR(255) DEFAULT "*",
		a_ajustador CHAR(255) DEFAULT "*",
		a_evento    CHAR(255) DEFAULT "*",
		a_suceso    CHAR(255) DEFAULT "*",	
		a_tipoprod  CHAR(255) DEFAULT "*",
		a_no_reclamo char(10)
		) RETURNING CHAR(18), 
					CHAR(100), 
					CHAR(20),
					DATE,
					DECIMAL(16,2),
					DECIMAL(16,2),
					DECIMAL(16,2),
					DECIMAL(16,2),
					DECIMAL(16,2),
					DECIMAL(16,2),
					DECIMAL(16,2),
					DECIMAL(16,2);

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
define _periodo1        char(7);
define _periodo2        char(7);

define _pagado_t110		DECIMAL(16,2);
DEFINE _pagado_t210		DECIMAL(16,2);
DEFINE _pagado_t310		DECIMAL(16,2);
DEFINE _pagado_t410		DECIMAL(16,2);
DEFINE _pagado_t111		DECIMAL(16,2);
DEFINE _pagado_t211		DECIMAL(16,2);
DEFINE _pagado_t311		DECIMAL(16,2);
define _pagado_t411		DECIMAL(16,2);
define _pagado_total	DECIMAL(16,2);
DEFINE v_doc_poliza     CHAR(20);     
DEFINE v_doc_reclamo    CHAR(18);
define _fecha_reclamo    date;
define v_cliente_nombre char(100);

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(a_compania, a_agencia);

let v_filtros = "";

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;
let _pagado_total = 0;

CREATE TEMP TABLE tmp_incurrido(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_total        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_bruto        DEC(16,2) DEFAULT 0 NOT NULL,
		reserva_neto         DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_abierto	 DEC(16,2) DEFAULT 0 NOT NULL,
		periodo				 CHAR(7)  NOT NULL,
		transaccion          CHAR(10)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_incurrido ON tmp_incurrido(no_reclamo);
CREATE INDEX xie02_tmp_incurrido ON tmp_incurrido(no_reclamo,periodo);

CREATE TEMP TABLE tmp_salida(
		no_reclamo           CHAR(10)  NOT NULL,
		pagado_t110           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_t210           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_t310           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_t410           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_t111           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_t211           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_t311           DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_t411           DEC(16,2) DEFAULT 0 NOT NULL,
		PRIMARY KEY (no_reclamo)
		) WITH NO LOG;



FOREACH 
 SELECT no_reclamo		
   INTO	_no_reclamo
   FROM recrcmae
  where actualizado   = 1
	and numrecla[1,2] = '02'
	and periodo       >= a_periodo1
	and periodo       <= a_periodo2

	FOREACH

	   select periodo1,
	          periodo2
	     into _periodo1,
		      _periodo2
		 from trimestre
		where activo = 1

		FOREACH
		 SELECT sum(monto)
		   INTO _monto_total
		   FROM rectrmae
		  WHERE cod_compania = a_compania
		    AND actualizado  = 1
			AND no_reclamo   = _no_reclamo
			AND cod_tipotran IN ('004','005','006','007')
			AND periodo      >= _periodo1 
			AND periodo      <= _periodo2
		    AND monto        <> 0

		  if _monto_total is null then
			Let _monto_total = 0;
		  end if

			-- Actualizacion del Movimiento

			INSERT INTO tmp_incurrido(
			no_reclamo,
			pagado_total,
			pagado_bruto,
			pagado_neto,
			incurrido_abierto,
			periodo,
			transaccion
			)
			VALUES(
			_no_reclamo,
			_monto_total,
			0,
			0,
			0,
			_periodo2,
			""
			);

		END FOREACH

	END FOREACH

END FOREACH

FOREACH 
	select no_reclamo,
	       sum(pagado_total),
	       periodo
	  into _no_reclamo,
	       _pagado_total,
		   _periodo
      from tmp_incurrido
	 group by no_reclamo,periodo
	 order by no_reclamo,periodo

		let a_periodo1 = _periodo;

       BEGIN
       ON EXCEPTION IN(-239)

		if _periodo = '2012-03' then

			update tmp_salida
			   set pagado_t110 = pagado_t110 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-06' then

			update tmp_salida
			   set pagado_t210 = pagado_t210 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-09' then

			update tmp_salida
			   set pagado_t310 = pagado_t310 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2012-12' then

			update tmp_salida
			   set pagado_t410 = pagado_t410 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		---***---

		if _periodo = '2013-03' then

			update tmp_salida
			   set pagado_t111 = pagado_t111 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2013-06' then

			update tmp_salida
			   set pagado_t211 = pagado_t211 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2013-09' then

			update tmp_salida
			   set pagado_t311 = pagado_t311 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

		if _periodo = '2013-12' then

			update tmp_salida
			   set pagado_t411 = pagado_t411 + _pagado_total
			 where no_reclamo = _no_reclamo;
		end if

       END EXCEPTION

		let _pagado_t110 = 0;
		let _pagado_t210 = 0;
		let _pagado_t310 = 0;
		let _pagado_t410 = 0;
		let _pagado_t111 = 0;
		let _pagado_t211 = 0;
		let _pagado_t311 = 0;
		let _pagado_t411 = 0;

		if a_periodo1 = "2012-03" then
			let _pagado_t110 = _pagado_total;
		end if

		if a_periodo1 = "2012-06" then
			let _pagado_t210 = _pagado_total;
		end if

		if a_periodo1 = "2012-09" then
			let _pagado_t310 = _pagado_total;
		end if

		if a_periodo1 = "2012-12" then
			let _pagado_t410 = _pagado_total;
		end if


		if a_periodo1 = "2013-03" then
			let _pagado_t111 = _pagado_total;
		end if

		if a_periodo1 = "2013-06" then
			let _pagado_t211 = _pagado_total;
		end if

		if a_periodo1 = "2013-09" then
			let _pagado_t311 = _pagado_total;
		end if

		if a_periodo1 = "2013-12" then
			let _pagado_t411 = _pagado_total;
		end if

		INSERT INTO tmp_salida(
		no_reclamo,
		pagado_t110,
		pagado_t210,
		pagado_t310,
		pagado_t410,
		pagado_t111,
		pagado_t211,
		pagado_t311,
		pagado_t411
		)
		VALUES(
		_no_reclamo,
		_pagado_t110,
		_pagado_t210,
		_pagado_t310,
		_pagado_t410,
		_pagado_t111,
		_pagado_t211,
		_pagado_t311,
		_pagado_t411
		);
	  END

END FOREACH

foreach

	 select no_reclamo,
			pagado_t110,
			pagado_t110 + pagado_t210,
			pagado_t110 + pagado_t210 + pagado_t310,
			pagado_t110 + pagado_t210 + pagado_t310 + pagado_t410, 
			pagado_t110 + pagado_t210 + pagado_t310 + pagado_t410 + pagado_t111,
			pagado_t110 + pagado_t210 + pagado_t310 + pagado_t410 + pagado_t111 + pagado_t211,
			pagado_t110 + pagado_t210 + pagado_t310 + pagado_t410 + pagado_t111 + pagado_t211 + pagado_t311,
			pagado_t110 + pagado_t210 + pagado_t310 + pagado_t410 + pagado_t111 + pagado_t211 + pagado_t311 + pagado_t411
	   into	_no_reclamo,
	        _pagado_t110,
			_pagado_t210,
			_pagado_t310,
			_pagado_t410,
			_pagado_t111,
			_pagado_t211,
			_pagado_t311,
			_pagado_t411
	   from tmp_salida
	  order by no_reclamo

	SELECT cod_reclamante,
		   no_documento,
		   numrecla,
		   fecha_reclamo
	  INTO _cod_cliente,
		   v_doc_poliza,
		   v_doc_reclamo,
		   _fecha_reclamo
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

 		RETURN v_doc_reclamo,
		 	   v_cliente_nombre, 	
		 	   v_doc_poliza,		
		 	   _fecha_reclamo,
			   _pagado_t110,
			   _pagado_t210,
			   _pagado_t310,
			   _pagado_t410,
			   _pagado_t111,
			   _pagado_t211,
			   _pagado_t311,
			   _pagado_t411
			   WITH RESUME;

END FOREACH

DROP TABLE tmp_salida;
DROP TABLE tmp_incurrido;

update trimestre
   set activo = 0
 where periodo2 = a_periodo2;

END PROCEDURE;
