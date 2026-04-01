-- Procedimiento para verificacion de inf. callcenter

-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

--drop procedure sp_cas059;

create procedure sp_cas059(a_compania CHAR(3),a_agencia CHAR(3),a_cobrador CHAR(3), a_dia smallint)
returning char(10),CHAR(100),char(100),char(3),smallint,smallint,date,char(50),CHAR(3),CHAR(3),CHAR(3),smallint;

define _cod_cliente		char(10);
define _nombre	        char(50);
define v_documento      char(20);
define _contacto	    char(50);
define _direccion	    char(100);
define _ultima_gestion	char(100);
define _nombre_pagador	char(100);
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
define _tipo_otrodia    smallint;
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
define _procesado		smallint;
define _cantidad		smallint;
define _existe			smallint;
define _cnt				smallint;

define _fecha_ult_pro	date;
define _fecha_ult_dia   date;
define _fecha_hoy		date;
define _fecha_actual	date;
define _fecha_tra		date;
define _fecha_start		date;
define _fecha_tmp		date;
define _fecha_aniversario date;
define _cod_gestion_cascliente char(3);

define _pago_fijo		smallint;
define _hora_hoy		datetime hour to minute;
define _hora_tra		datetime hour to minute;
define _cant,i			integer;
define _li_return		integer;

define _cnt_otro_dia_hoy smallint;
define _cnt_otro_dia_no smallint;
define _cnt_rutero_si smallint;
define _cnt_apagar_no smallint;   
define _cnt_total   smallint;
define _cnt_nvo smallint;
define _cnt_atrasado_sin_gestion smallint;

--set debug file to "sp_cob101.trc";

set isolation to dirty read;

let _fecha_hoy    = today;
let _fecha_actual = today;
let _hora_hoy  = current;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;
CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

select tipo_cobrador,
	   nombre
  into _tipo_cobrador,
	   _nombre
  from cobcobra
 where cod_cobrador = a_cobrador;

let _prioridad        = 0;

foreach
	select cod_cliente,
	       nuevo
	  into _cod_cliente,
	       _prioridad
	  from cobcapen
	 where cod_cobrador = a_cobrador
	 order by nuevo

	select	cod_gestion,
			dia_cobros3,
			ultima_gestion,
	       	fecha_ult_pro
	  into	_cod_gestion_cascliente,
			_dia3,
			_ultima_gestion,
  	        _fecha_ult_pro
	  from	cascliente
	 where	cod_cliente = _cod_cliente;

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select tipo_otrodia
      into _tipo_otrodia
      from cobcages
     where cod_gestion = _cod_gestion_cascliente;

   if _prioridad = 0 then
	if _tipo_otrodia = 1 then	--tipo de gestion de otro dia  "002","006","005","008"

		if a_dia = _dia3 Then	   --deben salir hoy

		  RETURN _cod_cliente,
				 _nombre_pagador,
		  		 _ultima_gestion,
		  		 _cod_gestion_cascliente,   
		  		 _dia3,   
				 _prioridad,
				 _fecha_ult_pro,
				 _nombre,
				 a_compania,
				 a_agencia,
				 a_cobrador,
				 _dia3
				with resume;
	    else
	 		continue foreach;
		end if
			continue foreach;
	else
		continue foreach;
	end if
   else
   		continue foreach;
   end if

end foreach
end procedure