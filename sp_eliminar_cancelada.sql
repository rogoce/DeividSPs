-- Procedimiento que procesa los "no cobros" de los Cobros Mobiles

-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob185;

CREATE PROCEDURE "informix".sp_cob185(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_fecha_sig     DATE,
a_fecha_hoy     DATE,
a_turno			integer,
a_id_usuario    integer
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;
define _error_desc		char(50);
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _cod_cobrador    CHAR(3);
define _id_transaccion  integer;
define _id_usuario      integer;
define _id_turno        integer;
define _existe          integer;
define _monto_total		DEC(16,2);
define _secuencia       integer;
define ld_fecha_hora	datetime year to fraction(5);
define _fecha_registro  datetime year to fraction(5);
define _id_cliente		char(30);
define _cod_motivo      integer;
define _tipo_cliente    smallint;
define _cod_gestor      char(3);
define _user_added      char(8);
define _user_cob		char(8);
define _dia_cobros1     smallint;
define li_dia_sig       smallint;
define _tipo_accion     smallint;
define _nombre_motivo   varchar(255);
define _fecha_ult_pro   date;
define _tipo_cobrador   smallint;
define _can             smallint;
define _dia_ult_pro     smallint;
define _cod_motivo_char char(3);
define _apag			DEC(16,2);
define _pago_fijo 		smallint;
define _cnt             smallint;
define _modo_callcenter smallint;
define _cod_user_added	char(3);

--SET DEBUG FILE TO "sp_cob185.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Procesar los No Cobros de los Cobros Moviles', '';
END EXCEPTION  