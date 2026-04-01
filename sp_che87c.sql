-- Reporte de las bonificaciones de cobranza por Corredor - Detallado

-- Creado    : 11/03/2008 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 11/03/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che87c;

CREATE PROCEDURE sp_che87c(a_cod_agente CHAR(255) default '*', a_periodo char(7))
  RETURNING smallint;

DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10);
DEFINE v_fecha        DATE;
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE _fecha_comis   DATE;
DEFINE _cod_cliente   CHAR(10);
define _moro_045      DEC(16,2); 
define _moro_4690	  DEC(16,2);
define _porc_045	  DEC(5,2);
define _porc_4690	  DEC(5,2);
define _porc_partic   DEC(5,2);
define _045           DEC(16,2);
define _4690		  DEC(16,2);
define _91			  DEC(16,2);
define _pol_corr	  DEC(16,2);
define _pol_0045	  DEC(16,2);
define _pol_4690	  DEC(16,2);
define _comision2	  DEC(16,2);
define _comision1	  DEC(16,2);
define _licencia      CHAR(10);
define _tipo          CHAR(1);
define _tipo_pago     smallint;
define _no_requis     CHAR(10);
define _tipo_requis   CHAR(1);
define _fecha_imp     date;
define v_cod_agente2  char(5);
define _comision_enero DEC(16,2);
define _comision_tot   DEC(16,2);
define _comision_mes   DEC(16,2);


--SET DEBUG FILE TO "sp_che87c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

let	_pol_corr = 0;
let	_pol_0045 = 0;
let	_pol_4690 = 0;
let _comision1 = 0;
let _comision2 = 0;
let v_cod_agente2 = "";


FOREACH


 SELECT	cod_agente,
        sum(comision)
   INTO	v_cod_agente,
        _comision_mes
   FROM	chqboni
  WHERE  periodo     = a_periodo
  group by 1


		let _comision_enero = 0;
		let _comision_tot   = 0;

	SELECT SUM(saldo_act)
	  INTO _comision_enero
	  FROM chqbosal2
	 WHERE cod_agente = v_cod_agente;

	if _comision_enero is null then

		let _comision_enero = 0;

	end if

	let _comision_tot = _comision_mes - _comision_enero;

	if _comision_tot >= 0 then

		update chqbosal2
		   set saldo_act  = 0,
		       saldo_ant  = _comision_enero
		 WHERE cod_agente = v_cod_agente;

	else

		let _comision_tot = ABS(_comision_tot);

		update chqbosal2
		   set saldo_act  = _comision_tot,
		       saldo_ant  = _comision_enero
		 WHERE cod_agente = v_cod_agente;

	end if


		
END FOREACH

return 0;

END PROCEDURE;