-- Procedimiento que trae los clientes para programa Call Center

drop procedure sp_cob101a;

create procedure sp_cob101a(
a_compania 		CHAR(3),
a_agencia  		CHAR(3),
a_cobrador 		CHAR(3)
)

define _cod_cliente		char(10);
define _nombre	        char(100);
define v_documento      char(20);
define _contacto	    varchar(50);
define _direccion	    varchar(100);
define _telefono1		char(10);
define _telefono2		char(10);
define _celular			char(10);
define _telefono3		char(10);
define _fax				char(10);
define _e_mail			char(50);
define _apartado		char(20);
define _cedula			char(30);
define _dia_cobros1     smallint;
define _dia_cobros2     smallint;
define _dia_cobros3     smallint;
define _dia_actual      smallint;
define _dia3		    smallint;
define _tipo_cobrador   smallint;
define _cod_gestion     char(3);
define _code_pais       char(3);
define _code_provincia	char(2);
define _code_ciudad		char(2);
define _code_distrito	char(2);
define _code_correg		char(5);
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

define _prioridad		smallint;
define _tipo_otrodia	smallint;
define _procesado		smallint;
define _ultima_gestion	char(50);
define _cantidad		smallint;
define _existe			smallint;

define _fecha_ult_pro		   date;
define _fecha_ult_dia   	   date;
define _fecha_hoy			   date;
define _fecha_actual		   date;
define _fecha_tra			   date;
define _fecha_start			   date;
define _fecha_tmp			   date;
define _fecha_pago			   date;
define _fecha_pago_reciente    date;
define _fecha_aniversario 	   date;
define _cod_gestion_cascliente char(3);

define a_dia 			smallint;
define _pago_fijo		smallint;
define _hora_hoy		datetime hour to minute;
define _hora_tra		datetime hour to minute;
define _cant,i			integer;
define _li_return		integer;

--set debug file to "sp_cob101.trc";
--trace on;
set isolation to dirty read;

let _fecha_hoy    = today;
let _fecha_actual = today;
let _hora_hoy     = current;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

select tipo_cobrador,
       fecha_ult_pro
  into _tipo_cobrador,
       _fecha_ult_pro
  from cobcobra
 where cod_cobrador = a_cobrador;

let _prioridad = 0;
										--**************
		--registros para tabla cobca90p
		foreach
			select a.cod_cliente,
				   max(c.fecha)
			  into _cod_cliente,
				   _fecha_pago
			  from cascliente a, caspoliza b, cobredet c
			 where a.cod_cliente = b.cod_cliente
			   and b.no_documento = c.doc_remesa
			   and c.tipo_mov in ("P", "N")
			   and c.actualizado = 1
			   and a.cod_cobrador = a_cobrador
			 group by 1
			 order by 2 desc

		    select count(*)
			  into _cantidad
			  from cobcapen
			 where cod_cliente = _cod_cliente;

			select count(*)
			  into _existe
			  from cobruter1
			 where cod_pagador = _cod_cliente;

			if _cantidad = 0 and _existe = 0 then  --no existe
				insert into cobca90p(cod_cliente, fecha, procesado,cod_cobrador)
				values (_cod_cliente, _fecha_pago, 0,a_cobrador);
			end if

		end foreach

end procedure