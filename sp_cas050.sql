-- buscar polizas vencidas y canceladas con saldo para reporte 
-- Creado    : 06/08/2003 - Autor: Armando Moreno M.
-- Modificado: 06/08/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cas050;

create procedure sp_cas050()
RETURNING   CHAR(20),  -- poliza
			CHAR(3),   -- cod_cobrador
			CHAR(10),  -- cod_pagador
			DEC(16,2), -- saldo
			SMALLINT,  -- estatus
			CHAR(50);  -- nombre_cobrador

define _no_documento    char(20);
define _nombre_cobrador char(50);
define _no_poliza	 char(10);
define _cod_pagador	 char(10);
define _cod_cobrador char(3);
define _periodo      char(7);
define _estatus		 smallint;
define v_por_vencer dec(16,2);
define v_exigible  	dec(16,2);
define v_corriente 	dec(16,2);
define v_monto_30  	dec(16,2);
define v_monto_60  	dec(16,2);
define v_monto_90	dec(16,2);
define _saldo		dec(16,2);
define _vigencia_final date;
define _fecha_hoy date;
define _mes_char            CHAR(2);
define _ano_char		    CHAR(4);

let _fecha_hoy = today;
let _saldo     = 0;
let v_por_vencer = 0;
let v_exigible   = 0;
let v_corriente  = 0;
let v_monto_30   = 0;
let v_monto_60   = 0;
let v_monto_90	 = 0;

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

set isolation to dirty read;

foreach with hold
	select no_documento,
		   cod_pagador,
		   saldo,
		   cod_cobrador,
		   estatus   
	  into _no_documento,
           _cod_pagador,
		   _saldo,
		   _cod_cobrador,
		   _estatus
      from cobcatmp

	 select nombre
	   into _nombre_cobrador
	   from cobcobra
	  where cod_cobrador = _cod_cobrador;

	RETURN 	_no_documento,
			_cod_cobrador,
			_cod_pagador,
			_saldo,
			_estatus,
 			_nombre_cobrador
 	  		WITH RESUME;

end foreach

end procedure
