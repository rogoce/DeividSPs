-- Procedimiento que realiza la carga de la morosidad en caspoliza cuando el modo de cobranza callcenter es por morosidad.
-- 
-- Creado    : 26/11/2008 - Autor: Armando Moreno M.
-- Modificado: 26/11/2008 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas102;

CREATE PROCEDURE "informix".sp_cas102()
       RETURNING  int,char(100);

DEFINE _cod_cliente   CHAR(10);
DEFINE _cod_cobrador  CHAR(3);
DEFINE _error         integer;
DEFINE _error_2       integer;
DEFINE _error_desc    char(50);
define v_documento    char(20);
DEFINE _mensaje       char(100);
define _fecha_hoy     date;
define _fecha_ult_dia date;
define _fecha_ult_pro date;
define _mes_char      char(2);
define _ano_char      char(4);
define _periodo       char(7);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo			DEC(16,2);
define _cantidad        integer;

LET _cod_cliente  = null;
LET _cod_cobrador = null;
let _fecha_hoy    = current;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

SET ISOLATION TO DIRTY READ;

BEGIN							                

ON EXCEPTION SET _error, _error_2, _error_desc 
 	RETURN _error, _error_desc;
END EXCEPTION

foreach
	SELECT cod_cobrador
	  INTO _cod_cobrador
	  FROM cobcobra
	 WHERE activo		 = 1
	   AND tipo_cobrador = 1

	 update cobcapen
	    set por_vencer = 0,
			exigible   = 0,
			corriente  = 0,
			monto_30   = 0,
			monto_60   = 0,
			monto_90   = 0,
			saldo	   = 0
      where cod_cobrador = _cod_cobrador;

	foreach
		 select cod_cliente
		   into _cod_cliente
		   from cascliente
		  where cod_cobrador = _cod_cobrador

		foreach
			 select	no_documento
			   into	v_documento
			   from	caspoliza
			  where	cod_cliente = _cod_cliente

			 CALL sp_cob33(
				'001',
				'001',
				v_documento,
				_periodo,
				_fecha_ult_dia
				) RETURNING v_por_vencer,
						    v_exigible,  
						    v_corriente,
						    v_monto_30,  
						    v_monto_60,  
						    v_monto_90,
						    v_saldo
						    ;

			 update cobcapen
			    set por_vencer = por_vencer + v_por_vencer,
					exigible   = exigible   + v_exigible,
					corriente  = corriente  + v_corriente,
					monto_30   = monto_30   + v_monto_30,
					monto_60   = monto_60   + v_monto_60,
					monto_90   = monto_90   + v_monto_90,
					saldo	   = saldo	    + v_saldo
		      where cod_cliente = _cod_cliente;

		end foreach

	end foreach

	select count(*)
	  into _cantidad
	  from cobcapen
	 where cod_cobrador = _cod_cobrador;

	select fecha_ult_pro
	  into _fecha_ult_pro
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	update cobcadate
	   set total      = _cantidad,
	       atendidos  = 0,
		   pendientes = _cantidad,
		   nuevos     = 0,
		   atrazados  = _cantidad
	 where cod_cobrador = _cod_cobrador
	   and fecha        = _fecha_ult_pro;

end foreach

LET _mensaje = "Actualizacion Exitosa ...";

return 0,_mensaje;

END

END PROCEDURE