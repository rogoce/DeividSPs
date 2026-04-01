-- buscar polizas vencidas y canceladas con saldo para reporte 
-- Creado    : 06/08/2003 - Autor: Armando Moreno M.
-- Modificado: 06/08/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas049;

create procedure sp_cas049()

define _no_documento char(20);
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
        cod_cliente
   into _no_documento,
        _cod_pagador
   from caspoliza

 select cod_cobrador
   into _cod_cobrador
   from cascliente
  where cod_cliente = _cod_pagador;

	let _no_poliza = sp_sis21(_no_documento);
	
	select estatus_poliza,
	       vigencia_final
	  into _estatus,
	       _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;
		
	if _estatus = 3 or _estatus = 2 then
		if _vigencia_final >= "01/12/2002" and _vigencia_final <= "30/06/2003" then
			CALL sp_cob33(
						'*',
						'*',
						_no_documento,
						_periodo,
						_fecha_hoy
						) RETURNING v_por_vencer,
								    v_exigible,  
								    v_corriente, 
								    v_monto_30,  
								    v_monto_60,  
								    v_monto_90,
								    _saldo
								    ;
			if _estatus = 2 and _saldo > 0 then --cancelada con saldo
				let _estatus = 1;
			elif _estatus = 2 and _saldo = 0 then --cancelada sin saldo
				let _estatus = 2;
			elif _estatus = 3 and _saldo > 0 then --vencida con saldo
				let _estatus = 3;
			elif _estatus = 3 and _saldo = 0 then --vencida sin saldo
				let _estatus = 4;
			end if

			INSERT INTO cobcatmp(
			no_documento,
			cod_pagador,
			saldo,
			cod_cobrador,
			estatus
			)
			VALUES(
			_no_documento,
			_cod_pagador,
			_saldo,
			_cod_cobrador,
			_estatus
			);
		else
			continue foreach;	
		end if
	else
		continue foreach;
	end if


end foreach

end procedure
