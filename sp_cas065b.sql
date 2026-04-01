-- Procedimiento para pasar los reg. que quedaron del dia anterior al dia actual(registros del tipo otro dia)
-- de las gestoras
-- Creado    : 23/01/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

--drop procedure sp_cas065b;

create procedure sp_cas065b(a_cod_cliente char(10) default "*")
returning integer,
          char(100);

define _error			integer;
define _cod_cliente		char(10);
define _nombre	        char(50);
define v_documento      char(20);
define _contacto	    char(50);
define _direccion	    char(100);
define _ultima_gestion	char(100);
define a_cobrador		char(3);
define _cod_cobrador 	char(3);
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
define _estatus_poliza  smallint;
define _cod_gestion     char(3);
define _no_poliza	    char(10);
define _cod_cobrador_otro  char(3);
define _no_documento	char(20);
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
define _fecha_tra		date;
define _fecha_start		date;
define _fecha_tmp		date;
define _vigencia_final	date;
define _fecha_aniversario date;
define _cod_gestion_cascliente char(3);

define _pago_fijo		smallint;
define _hora_hoy		datetime hour to minute;
define _hora_tra		datetime hour to minute;
define _cant,i			integer;
define _li_return		integer;

define _cnt_otro_dia_hoy 		 smallint;
define _cnt_otro_dia_no  		 smallint;
define _cnt_rutero_si    		 smallint;
define _cnt_apagar_no    		 smallint;   
define _cnt_total        		 smallint;
define _cnt_nvo 		 		 smallint;
define _cnt_atrasado_sin_gestion smallint;
define _fecha_menos1 	 		 date;
define _dia_menos1,_dia_hoy		 smallint;

--set debug file to "sp_cob101.trc";

set isolation to dirty read;
begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception

let _fecha_hoy = today;
let _hora_hoy  = current;

let _fecha_menos1 = _fecha_hoy - 1;
let _dia_menos1   =  day(_fecha_menos1);
let _dia_hoy      = day(_fecha_hoy);
let _pago_fijo    = 0;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;
CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

let _prioridad = 0;

select cod_cobrador
  into _cod_cobrador_otro
  from cobcobra
 where tipo_cobrador = 6
   and activo = 1;

if a_cod_cliente = "*" then
foreach
	select c.cod_cliente,
		   b.cod_cobrador
	  into _cod_cliente,
		   a_cobrador
	  from cascliente c, cobcobra b
	 where c.cod_cobrador  = b.cod_cobrador
	   and b.tipo_cobrador = 1

	select count(*)
      into _cantidad
      from caspoliza
     where cod_cliente = _cod_cliente;

	if _cantidad = 1 then	--TIENE UNA SOLA POLIZA

		select no_documento
	      into _no_documento
	      from caspoliza
	     where cod_cliente = _cod_cliente;

		let _no_poliza = sp_sis21(_no_documento);

		select estatus_poliza,
			   vigencia_final	
	      into _estatus_poliza,
			   _vigencia_final
	      from emipomae
	     where no_poliza = _no_poliza;

        if _estatus_poliza = 3 then  --ESTA VENCIDA
		  if _vigencia_final <= "31/12/2003" then
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
		
			if v_saldo = 0 then

				delete from caspoliza
				 where cod_cliente = _cod_cliente;

				delete from cobcapen
				 where cod_cliente = _cod_cliente;

				delete from cascliente
				 where cod_cliente = _cod_cliente;

			else

				update cascliente
				   set cod_cobrador     = _cod_cobrador_otro,
					   cod_cobrador_ant = a_cobrador
				 where cod_cliente      = _cod_cliente;

				update cobcapen
				   set cod_cobrador     = _cod_cobrador_otro
				 where cod_cliente      = _cod_cliente;

				let _pago_fijo = _pago_fijo + 1;
			end if
		  end if
		end if

	end if

end foreach
else								 --un solo pagador
	select c.cod_cliente,
		   b.cod_cobrador
	  into _cod_cliente,
		   a_cobrador
	  from cascliente c, cobcobra b
	 where c.cod_cobrador  = b.cod_cobrador
	   and c.cod_cliente   = a_cod_cliente
	   and b.tipo_cobrador = 1;

	foreach
		select no_documento
	      into _no_documento
	      from caspoliza
	     where cod_cliente = _cod_cliente

		let _no_poliza = sp_sis21(_no_documento);

		select estatus_poliza,
			   vigencia_final	
	      into _estatus_poliza,
			   _vigencia_final
	      from emipomae
	     where no_poliza = _no_poliza;

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

        if _estatus_poliza = 1 and v_saldo = 0 then --vigente y saldo cero
		
			delete from caspoliza
			 where no_documento = _no_documento;

		end if
	end foreach

	update cascliente
	   set cod_cobrador     = _cod_cobrador_otro,
		   cod_cobrador_ant = a_cobrador
	 where cod_cliente      = _cod_cliente;

	update cobcapen
	   set cod_cobrador     = _cod_cobrador_otro
	 where cod_cliente      = _cod_cliente;

end if

end

return 0, "Actualizacion Exitosa ...";

end procedure