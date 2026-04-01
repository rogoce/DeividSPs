-- Trae la Informacion de lo pagado de un Reclamo.
-- Creado: 10/08/2009 - Amado Perez

DROP PROCEDURE sp_rwf71_t;
CREATE PROCEDURE sp_rwf71_t(v_no_tranrec CHAR(10))
RETURNING DEC(16,2);

--- Reclamos

BEGIN

DEFINE v_monto_total  DEC(16,2);
DEFINE v_variacion    DEC(16,2);
DEFINE v_estatus      CHAR(1);
DEFINE v_fecha        CHAR(10);
DEFINE v_reserva      DEC(16,2);
DEFINE v_pagado       DEC(16,2);
DEFINE v_recuperos    DEC(16,2);
DEFINE v_incurrido    DEC(16,2);
DEFINE v_accion       CHAR(10);
DEFINE v_siniestro    CHAR(10);
DEFINE v_deducible    DEC(16,2);
DEFINE v_tr_ant_no    CHAR(10);
DEFINE v_tr_ant_fecha CHAR(10);
DEFINE v_reaseg       CHAR(15);
DEFINE v_reaseg_monto DECIMAL(8,2);
DEFINE v_coaseg       CHAR(15);
DEFINE v_coaseg_monto DECIMAL(8,2);
DEFINE v_cober        CHAR(15);
DEFINE v_cober_monto  DECIMAL(8,2);
DEFINE v_pagos        CHAR(15);
DEFINE v_pagos_monto  DECIMAL(8,2);

DEFINE v_tipotran     CHAR(3);
DEFINE v_reclamo      CHAR(10);
DEFINE v_compania     CHAR(3);
DEFINE v_no_poliza    CHAR(10);
DEFINE v_cliente      CHAR(10);
DEFINE v_contratante  CHAR(10);
DEFINE v_cod_reclamante CHAR(10);
DEFINE v_interno      CHAR(3);
DEFINE v_externo      CHAR(3);
DEFINE v_estado       CHAR(1);
DEFINE v_valor        CHAR(5);
DEFINE v_cod_grupo    CHAR(5);
DEFINE v_numrecla     CHAR(18);
DEFINE v_periodos     CHAR(10);
DEFINE v_duplicado    CHAR(10);
DEFINE v_no_recibo    CHAR(10);
DEFINE v_user_added   CHAR(8);

DEFINE _no_unidad     CHAR(5);
DEFINE _cod_coasegur  CHAR(3);
DEFINE _porc_coas     DEC(7,4);
DEFINE _porc_reas     DEC(9,6);
DEFINE _no_tranrec    CHAR(10);
DEFINE _tr_pago       CHAR(3);
DEFINE _tr_salv       CHAR(3);
DEFINE _tr_recup      CHAR(3);
DEFINE _tr_deduc      CHAR(3);
DEFINE _cant_impres   SMALLINT;
DEFINE _tran_ant      CHAR(10);
DEFINE _cerrar_rec    SMALLINT;
DEFINE _perd_total    SMALLINT;
DEFINE _perd_desc     CHAR(15);

DEFINE _no_tranrec_tmp   CHAR(10);
define _no_tranrec_int   char(10);
DEFINE _cod_tipotran_tmp CHAR(3);
DEFINE _fecha_tmp        DATE;
DEFINE _transaccion_tmp  CHAR(10);
DEFINE _variacion_tmp, _monto_tmp, _pagado_tr, _recuperos_tr DEC(16,2);
DEFINE _no_ttanrec_int, _tran_ant_int INTEGER; 

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf19.trc"; 
--trACE ON;

LET v_monto_total  = 0;
LET v_variacion    = 0;
LET v_reserva      = 0;
LET v_pagado       = 0;
LET v_recuperos    = 0;
LET v_incurrido    = 0;
LET v_deducible    = 0;
LET v_coaseg_monto = 0;
LET v_reaseg_monto = 0;
LET v_cober_monto  = 0;
LET v_pagos_monto  = 0;

CREATE TEMP TABLE tmp_rectrr(
            no_tranrec_int INTEGER,
			no_tranrec     CHAR(10),
			no_reclamo     CHAR(10),
			cod_tipotran   CHAR(3),
			fecha          DATE,
			transaccion    CHAR(10), 
			variacion      DEC(16,2),
			monto          DEC(16,2),
			PRIMARY KEY (no_tranrec)
			) WITH NO LOG;
 
select no_reclamo
  into v_reclamo
  from rectrmae
 where no_tranrec = v_no_tranrec;

foreach
	select no_tranrec,
		   cod_tipotran,
		   fecha,
		   transaccion,
		   variacion,
		   monto
	  into _no_tranrec_tmp,
		   _cod_tipotran_tmp,
		   _fecha_tmp,
		   _transaccion_tmp,
		   _variacion_tmp,
		   _monto_tmp
	  from rectrmae
	 where no_reclamo = v_reclamo
	   and cod_tipotran = 4
	   and (wf_aprobado in (3, 1, 0)
		or actualizado = 1)

	 let _no_tranrec_int = _no_tranrec_tmp;

	 insert into tmp_rectrr(
	 no_tranrec_int,
	 no_tranrec,
	 no_reclamo,
	 cod_tipotran,
	 fecha,
	 transaccion,
	 variacion,
	 monto
	 )
	 values(
	 _no_tranrec_int,
	 _no_tranrec_tmp,
	 v_reclamo,
	 _cod_tipotran_tmp,
	 _fecha_tmp,
	 _transaccion_tmp,
	 _variacion_tmp,
	 _monto_tmp
	 );
end foreach

let _no_tranrec_int = v_no_tranrec;

select no_reclamo,
	   cod_compania
  into v_reclamo,
	   v_compania
  from rectrmae
 where no_tranrec  = v_no_tranrec;

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = v_compania;

SELECT porc_partic_coas
  INTO _porc_coas
  FROM reccoas
 WHERE no_reclamo   = v_reclamo
   AND cod_coasegur = _cod_coasegur;

IF _porc_coas IS NULL THEN
  LET _porc_coas = 0;
END IF

IF v_reserva IS NULL THEN
	LET v_reserva = 0;
END IF

SELECT cod_tipotran
  INTO _tr_pago
  FROM rectitra
 WHERE tipo_transaccion = 4;

SELECT SUM(monto)
  INTO v_pagado
  FROM tmp_rectrr
 WHERE no_reclamo   = v_reclamo
   AND cod_tipotran = _tr_pago
   AND no_tranrec_int <= _no_tranrec_int;

IF v_pagado IS NULL THEN
	LET v_pagado = 0;
END IF

IF v_recuperos IS NULL THEN
	LET v_recuperos = 0;
END IF

LET v_reserva	= v_reserva;
LET v_pagado	= v_pagado;
LET v_recuperos	= v_recuperos;

LET v_incurrido = v_reserva + v_pagado+ v_recuperos;

DROP TABLE tmp_rectrr;

return v_incurrido;

END
END PROCEDURE;
