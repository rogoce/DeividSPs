-- Procedimiento para sacar del callcenter las polizas que estan canceladas y con saldo cero
-- de las gestoras
-- Creado    : 23/01/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cas065;

create procedure sp_cas065()
returning integer,
          char(100);

define _ultima_gestion				char(100);
define _nombre_pagador				char(100);
define _direccion					char(100);
define _contacto					char(50);
define _e_mail						char(50);
define _nombre						char(50);
define _cedula						char(30);
define _no_documento				char(20);
define v_documento					char(20);
define _apartado					char(20);
define _cod_cliente					char(10);
define _no_poliza					char(10);
define _telefono1					char(10);
define _telefono2					char(10);
define _telefono3					char(10);
define _celular						char(10);
define _fax							char(10);
define _periodo						char(7);
define _code_correg					char(5);
define _ano_char					char(4);
define _cod_gestion_cascliente		char(3);
define _cod_cobrador_otro			char(3);
define _code_provincia				char(2);
define _cod_cobrador				char(3);
define _cod_gestion					char(3);
define a_cobrador					char(3);
define _code_pais					char(3);
define _code_distrito				char(2);
define _code_ciudad					char(2);
define _mes_char					char(2);
define _cnt_atrasado_sin_gestion	smallint;
define _estatus_poliza				smallint;
define _cnt_apagar_no				smallint;
define _tipo_cobrador				smallint;
define _tipo_otrodia				smallint;
define _dia_cobros1					smallint;
define _dia_cobros2					smallint;
define _dia_cobros3					smallint;
define _dia_actual					smallint;
define _dia_menos1					smallint;   
define _pago_fijo					smallint;
define _prioridad					smallint;
define _procesado					smallint;
define _cnt_total        		 	smallint;
define _cantidad					smallint;
define _cnt_nvo 		 		 	smallint;
define _dia_hoy						smallint;
define _existe						smallint;
define _dia3						smallint;
define _cnt							smallint;
define v_por_vencer					dec(16,2);	 
define v_corriente					dec(16,2);
define v_monto_30					dec(16,2);
define v_monto_60					dec(16,2);
define v_monto_90					dec(16,2);
define v_exigible					dec(16,2);
define v_apagar						dec(16,2);
define v_saldo						dec(16,2);
define _li_return					integer;
define _error						integer;
define _cant						integer;
define i							integer;
define _fecha_aniversario			date;
define _fecha_ult_pro				date;
define _fecha_ult_dia   			date;
define _fecha_start					date;
define _fecha_hoy					date;
define _fecha_tra					date;
define _fecha_tmp					date;
define _hora_hoy					datetime hour to minute;
define _hora_tra					datetime hour to minute;


--set debug file to "sp_cob101.trc";

set isolation to dirty read;
begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception

let _fecha_hoy = today;
let _hora_hoy  = current;

let _fecha_menos1 = _fecha_hoy - 1;
let _dia_menos1   = day(_fecha_menos1);
let _dia_hoy      = day(_fecha_hoy);

-- Armar varibale que contiene el periodo(aaaa-mm)

if  month(_fecha_hoy) < 10 then
	let _mes_char = '0'|| month(_fecha_hoy);
else
	let _mes_char = month(_fecha_hoy);
end if

let _ano_char = year(_fecha_hoy);
let _periodo  = _ano_char || "-" || _mes_char;
call sp_sis36(_periodo) returning _fecha_ult_dia;

let _prioridad = 0;

--let _cod_cobrador_otro = sp_cas006('001', 11); se pone en comentario por que no hay este rol ahorita. 05/10/2010 Armando.

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
	     where cod_cliente = _cod_cliente

		let _no_poliza = sp_sis21(_no_documento);

		select estatus_poliza
	      into _estatus_poliza
	      from emipomae
	     where no_poliza = _no_poliza;

        --if _estatus_poliza = 2 then  --ESTA CANCELADA
		select por_vencer,
			   exigible,
			   corriente,
			   monto_30,
			   monto_60,
			   monto_90,
			   monto_120,
			   monto_150,
			   monto_180,
			   saldo
		  into v_por_vencer,
			   v_exigible,  
			   v_corriente,	
			   v_monto_30,	
			   v_monto_60,	
			   v_monto_90,	
			   v_monto_120,
			   v_monto_150,
			   v_monto_180,		
			   v_saldo
		  from emipoliza
		 where no_documento = _no_documento;

   		{call sp_cob33(
			'001',
			'001',
			_no_documento,
			_periodo,
			_fecha_ult_dia
			) returning v_por_vencer,
					    v_exigible,  
					    v_corriente, 
					    v_monto_30,  
					    v_monto_60,  
					    v_monto_90,
				   	    v_saldo;}
	
		if v_saldo = 0 then

			delete from caspoliza
			 where cod_cliente = _cod_cliente;

			{delete from cobcapen
			 where cod_cliente = _cod_cliente;}

			delete from cascliente
			 where cod_cliente = _cod_cliente;
		else 
			update cascliente
			   set por_vencer	= ,
			   	   exigible		= ,
			   	   corriente	= ,
			   	   monto_30		= ,
			   	   monto_60		= ,
			   	   monto_90		= ,
			   	   monto_120	= ,
			   	   monto_150	= ,
			   	   monto_180	= ,
				   saldo		= ,
			 where cod_cliente = _cod_cliente; 
			   
			    

		end if
		--end if
	else
	   foreach

		   select no_documento
		     into _no_documento
		     from caspoliza
		    where cod_cliente = _cod_cliente

		   let _no_poliza = sp_sis21(_no_documento);

		   select estatus_poliza
		     into _estatus_poliza
		     from emipomae
		    where no_poliza = _no_poliza;

	       --if _estatus_poliza = 2 then  --ESTA CANCELADA

		   call sp_cob33(
		   		'001',
				'001',
				_no_documento,
				_periodo,
				_fecha_ult_dia
				) returning v_por_vencer,
						    v_exigible,  
						    v_corriente, 
						    v_monto_30,  
						    v_monto_60,  
						    v_monto_90,
						    v_saldo;
		
			if v_saldo = 0 then

				delete from caspoliza
				 where no_documento = _no_documento;

			end if
			--end if
	   end foreach
	end if

end foreach

end

return 0, "Actualizacion Exitosa ...";

end procedure