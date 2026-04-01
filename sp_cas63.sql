-- Procedimiento para verificacion de inf. callcenter

-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

--drop procedure sp_cas63;

create procedure sp_cas63(a_compania CHAR(3),a_agencia CHAR(3),a_cobrador CHAR(3))
returning smallint,smallint,smallint,smallint,smallint,char(50),smallint,smallint;

define _cod_cliente		char(10);
define _nombre	        char(50);
define v_documento      char(20);
define _contacto	    char(50);
define _direccion	    char(100);
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

define a_dia 			smallint;
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
CREATE TEMP TABLE tmp_cc
            (cnt_otro_dia_hoy SMALLINT DEFAULT 0,
			 cnt_otro_dia_no  SMALLINT DEFAULT 0,
			 cnt_rutero_si    SMALLINT DEFAULT 0,
			 cnt_apagar_no    SMALLINT DEFAULT 0,
			 cnt_nvo		  SMALLINT DEFAULT 0,
			 cnt_atrasado_sin_gestion SMALLINT DEFAULT 0);

INSERT INTO tmp_cc VALUES(0,0,0,0,0,0);

select tipo_cobrador,
       fecha_ult_pro,
	   nombre
  into _tipo_cobrador,
       _fecha_ult_pro,
	   _nombre
  from cobcobra
 where cod_cobrador = a_cobrador;

let _prioridad        = 0;
let _cnt_otro_dia_hoy = 0;
let _cnt_otro_dia_no  = 0;
let _cnt_rutero_si    = 0;
let _cnt_apagar_no    = 0;
let _cnt		      = 0;
let _cnt_nvo		  = 0;
let _cnt_atrasado_sin_gestion = 0;

-- Chequeos de los Pendientes
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
			pago_fijo
	  into	_cod_gestion_cascliente,
			_dia3,
			_pago_fijo
	  from	cascliente
	 where	cod_cliente = _cod_cliente;

	select count(*)
	  into _existe
	  from cobruter1
	 where cod_pagador = _cod_cliente;

	 if _existe = 1 then  --el pagador esta en el rutero
        UPDATE tmp_cc
           SET cnt_rutero_si = cnt_rutero_si + 1;

	 	continue foreach;
	 end if

  	 let v_apagar = 0;

     {foreach	Armando: se puso en comentario ya que demoraba demasiado.
		 select	no_documento
		   into	v_documento
		   from	caspoliza
		  where	cod_cliente  = _cod_cliente

			CALL sp_cob33(
			a_compania,
			a_agencia,
			v_documento,
			_periodo,
			_fecha_ult_dia
			) RETURNING v_por_vencer,
					    v_exigible,  
					    v_corriente, 
					    v_monto_30,  
					    v_monto_60,  
					    v_monto_90,
					    v_saldo;

			let v_apagar = v_apagar + v_exigible;

	 end foreach

	 if v_apagar <= 0.00 then  --a pagar <= 0
        UPDATE tmp_cc
           SET cnt_apagar_no = cnt_apagar_no + 1;
 		continue foreach;
	 end if}

	if _prioridad = 1 then  --nuevos procesar hoy
        UPDATE tmp_cc
           SET cnt_nvo = cnt_nvo + 1;

	 	continue foreach;
	end if

	select tipo_otrodia
	  into _tipo_otrodia
	  from cobcages
	 where cod_gestion = _cod_gestion_cascliente;

	if _tipo_otrodia = 1 then	--tipo de gestion de otro dia  "002","006","005","008"
	   let _dia_actual = day(_fecha_actual);

		if _dia_actual = _dia3 Then	   --deben salir hoy
	        UPDATE tmp_cc
	           SET cnt_otro_dia_hoy = cnt_otro_dia_hoy + 1;
			continue foreach;
		else						   --atrasados y deben salir otro dia
	        UPDATE tmp_cc
	           SET cnt_otro_dia_no = cnt_otro_dia_no + 1;

			continue foreach;
		end if
	else
        UPDATE tmp_cc
           SET cnt_atrasado_sin_gestion = cnt_atrasado_sin_gestion + 1;
	end if
end foreach

select cnt_otro_dia_hoy,
	   cnt_otro_dia_no,
	   cnt_rutero_si,
	   cnt_apagar_no,   
	   cnt_nvo,
	   cnt_atrasado_sin_gestion
  into _cnt_otro_dia_hoy,
  	   _cnt_otro_dia_no, 
  	   _cnt_rutero_si,   
  	   _cnt_apagar_no,   
	   _cnt_nvo,
	   _cnt_atrasado_sin_gestion
  from tmp_cc;

select count(*)        
  into _cnt
  from cobcapen
 where cod_cobrador = a_cobrador;

drop table tmp_cc;

  RETURN _cnt_otro_dia_hoy,
  		 _cnt_otro_dia_no, 
  		 _cnt_rutero_si,   
  		 0, --_cnt_apagar_no,   
		 _cnt_nvo,
		 _nombre,
		 _cnt,
		 _cnt_atrasado_sin_gestion;

end procedure