-- pasar reg. a rol 90 dias y mas.

-- Creado    : 12/07/2004 - Autor: Armando Moreno M.

drop procedure sp_cas065d;

create procedure sp_cas065d()

define _cod_cliente		char(10);
define _nombre	        char(50);
define a_cobrador		char(3);
define _cod_cobrador	char(3);
define _tipo_cobrador   smallint;
define _no_documento	char(20);
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
DEFINE v_por_vencer     DEC(16,2);	 
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo			DEC(16,2);
define _dia_cobros3		smallint;

define _cant_tot		smallint;
define _cant_90			smallint;

define _fecha_ult_dia   date;
define _fecha_hoy		date;

--set debug file to "sp_cob101.trc";

set isolation to dirty read;

let _fecha_hoy = today;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;
CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

let _cant_90  = 0;
let _cant_tot = 0;

foreach
	select c.cod_cliente,
		   b.cod_cobrador,
		   b.nombre,
		   c.dia_cobros3
	  into _cod_cliente,
		   a_cobrador,
		   _nombre,
		   _dia_cobros3
	  from cascliente c, cobcobra b
	 where c.cod_cobrador = b.cod_cobrador
	   and b.activo       = 1
	   and b.tipo_cobrador in (1) --gestor
	 order by b.cod_cobrador

--	   and b.tipo_cobrador in (1,8,9) --gestor, sup, jefe

	if a_cobrador = "017" or   --suc colon
	   a_cobrador = "018" or   --suc chiriqui
	   a_cobrador = "037" then --margarita de franco
	   
	   continue foreach;
	else

	  let _cant_90 = 0;

	  foreach
		select no_documento
	      into _no_documento
	      from caspoliza
	     where cod_cliente = _cod_cliente

		CALL sp_cob33(
			'001',
			'001',
			_no_documento,
			_periodo,
			_fecha_ult_dia
			) RETURNING v_por_vencer,
					    v_exigible,  
					    v_corriente, 
					    v_monto_30,  
					    v_monto_60,  
					    v_monto_90,
					    v_saldo;
		
		if v_monto_90 > 0 then	--90 dias o mas
			let _cant_90 = 1;
			exit foreach;
		end if
	  end foreach

	  if _cant_90 = 1 then --al menos una poliza esta a 90, asi es que hay que pasar al cliente

		let _cod_cobrador = sp_cas006("001", 12); --busca al cobrador que menos reg. tiene

		update cascliente
		   set cod_cobrador     = _cod_cobrador,
			   cod_cobrador_ant = null
		 where cod_cliente      = _cod_cliente;

		if _dia_cobros3 is null or _dia_cobros3 = 0 then

			delete from cobcapen
			 where cod_cliente = _cod_cliente;
        else

			update cobcapen
			   set cod_cobrador     = _cod_cobrador
			 where cod_cliente      = _cod_cliente;
		end if
	  end if
	end if

end foreach
end procedure