-- Procedimiento que realiza la carga de la morosidad en caspoliza cuando el modo de cobranza callcenter es por morosidad.
-- 
-- Creado    : 26/11/2008 - Autor: Armando Moreno M.
-- Modificado: 26/11/2008 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cas102a;
CREATE PROCEDURE "informix".sp_cas102a()
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
define _cnt             integer;

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

select cod_cobrador
  into _cod_cobrador
  from cobcobra
 where tipo_cobrador = 1
   and activo = 1

	let _cnt = 0;
	foreach

		select cod_cliente
		  into _cod_cliente
		  from cascliente
		 where cod_cobrador = '128'

		if _cnt < 60 then
			update cascliente
			   set cod_cobrador     = _cod_cobrador,
				   cod_cobrador_ant = null
			 where cod_cliente      = _cod_cliente;

			update cobcapen
			   set cod_cobrador = _cod_cobrador
			 where cod_cliente  = _cod_cliente;

			 let _cnt = _cnt + 1;
		else
			exit foreach;
		end if
	end foreach
end foreach

{foreach

	SELECT cod_cliente
	  INTO _cod_cliente
	  FROM cobcapen
	 WHERE cod_cobrador = '085'

	 update cascliente
	    set cod_gestion = null
      where cod_cliente = _cod_cliente;

end foreach	}

LET _mensaje = "Actualizacion Exitosa ...";

return 0,_mensaje;

END
END PROCEDURE