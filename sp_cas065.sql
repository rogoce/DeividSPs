-- Procedimiento que Maneja los Estatus y los Registros de las Campañas de Cobros del Programa de Call Center.
-- Creado    : 23/10/2010- Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cas065;
create procedure sp_cas065()														 
returning	integer,																	 
			char(100);																 

define _ultima_gestion		char(100);
define _cod_cliente			char(10);										 
define _cod_campana			char(10);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo				char(7);
define _code_correg			char(5);
define _ano_char			char(4);
define _cod_cobrador_ant	char(3);
define _cod_cobrador		char(3);
define _cod_gestion			char(3);
define _mes_char			char(2);
define v_por_vencer			dec(16,2);	 
define v_corriente			dec(16,2);
define v_monto_180			dec(16,2);
define v_monto_150			dec(16,2);
define v_monto_120			dec(16,2);
define v_monto_90			dec(16,2);
define v_monto_60			dec(16,2);
define v_monto_30			dec(16,2);
define v_exigible			dec(16,2);
define v_saldo				dec(16,2);
define _estatus_poliza		smallint;
define _status_campana		smallint;
define _cnt_cas_prog		smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _dia_cobros3			smallint;
define _pendiente			smallint;
define _cantidad			smallint;
define _error				integer;
define _fecha_ult_pro		date;
define _fecha_ult_dia		date;
define _fecha_hasta			date;
define _fecha_hoy			date;
define _hora				datetime hour to minute;

--set debug file to "sp_cas065.trc";
--trace on;

set isolation to dirty read;
begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception

let _fecha_hoy = today;

-- Armar varibale que contiene el periodo(aaaa-mm)
if  month(_fecha_hoy) < 10 then
	let _mes_char = '0'|| month(_fecha_hoy);
else
	let _mes_char = month(_fecha_hoy);
end if

select cod_campana
  from cascampana
 where tipo_campana = 3
  into temp tmp_codigos_campana;

insert into tmp_codigos_campana
values('00000');

let _ano_char = year(_fecha_hoy);
let _periodo  = _ano_char || "-" || _mes_char;
call sp_sis36(_periodo) returning _fecha_ult_dia;

foreach
	select cod_campana,
		   estatus,
		   fecha_hasta
		  { filt_status,
		   filt_zonacob,
		   filt_sucursal,
		   filt_pago,
		   filt_moros,
		   filt_formapag,
		   filt_agente,
		   filt_grupo,
		   filt_diacob}
	  into _cod_campana,
		   _status_campana,
		   _fecha_hasta
		   {_filt_status,
		   _filt_zonacob,
		   _filt_sucursal,
		   _filt_pago,
		   _filt_moros,
		   _filt_formapag,
		   _filt_agente,
		   _filt_grupo,
		   _filt_diacob}
	  from cascampana
	 order by cod_campana

	if _fecha_hoy > _fecha_hasta then

		let _pendiente = 0;

		select count(*)
		  into _pendiente
		  from cascliente
		 where cod_campana = _cod_campana
		   and cod_gestion is null;

		if _pendiente is null then
			let _pendiente = 0;
		end if

		if _pendiente > 0 then
			if _status_campana = 2 then
				update cascampana
				   set fecha_hasta = fecha_hasta + 1 units day
				 where cod_campana = _cod_campana;

				continue foreach;
			end if
		end if

		update cascampana
		   set estatus = 3
		 where cod_campana = _cod_campana;

		update cobcobra		
		   set cod_campana = '00000'
		 where cod_campana = _cod_campana;

		foreach
			select cod_cliente, 
				   dia_cobros1, 
				   dia_cobros2, 
				   dia_cobros3, 
				   cod_gestion, 
				   cod_cobrador_ant, 
				   ultima_gestion, 
				   fecha_ult_pro,
				   hora
			  into _cod_cliente, 
				   _dia_cobros1, 
				   _dia_cobros2, 
				   _dia_cobros3, 
				   _cod_gestion, 
				   _cod_cobrador_ant,
				   _ultima_gestion, 
				   _fecha_ult_pro,
				   _hora
			  from cascliente
			 where cod_campana = _cod_campana

			select count(*)
			  into _cnt_cas_prog
			  from cascliente_prog
			 where cod_cliente = _cod_cliente;

			if _cnt_cas_prog > 0 then
				update cascliente_prog 
				   set dia_cobros1 		= _dia_cobros1,
					   dia_cobros2 		= _dia_cobros2, 
					   dia_cobros3 		= _dia_cobros3, 
					   cod_gestion 		= _cod_gestion, 
					   cod_cobrador_ant	= _cod_cobrador_ant,
					   ultima_gestion 	= _ultima_gestion, 
					   fecha_ult_pro	= _fecha_ult_pro,
					   hora				= _hora
				 where cod_cliente 		= _cod_cliente;
			else
				insert into cascliente_prog(
						dia_cobros1,
						dia_cobros2,
						dia_cobros3,
						cod_gestion,
						cod_cobrador_ant,
						ultima_gestion,
						fecha_ult_pro,
						hora,
						cod_cliente)
				values(	_dia_cobros1,
						_dia_cobros2,
						_dia_cobros3,
						_cod_gestion,
						_cod_cobrador_ant,
						_ultima_gestion,
						_fecha_ult_pro,
						_hora,
						_cod_cliente);
			end if
		end foreach
	end if

   {	foreach
		select cod_cliente,
			   no_documento
		  into _cod_cliente,
			   _no_documento
		  from caspoliza
		 where cod_campana = _cod_campana

	   --	call sp_sis21(_no_documento) returning _no_poliza;

		select cod_formapag,
			   cod_sucursal,
			   cod_agente,
			   cod_grupo,
			   cod_status,
			   cod_zona,
			   dia_cobros1,
			   dia_cobros2
		  into _cod_formapag, 
			   _cod_sucursal,
			   _cod_agente,
			   _cod_grupo,
			   _cod_status,
			   _cod_zona,
			   _dia_cobros1,
			   _dia_cobros2
		  from emipoliza
		 where no_documento = _no_documento;

		2 then 'Morosidad'
		3 then 'Forma de Pago'
		4 then 'Zona de Cobros'
		5 then 'Agente'
		6 then 'Sucursal'
		7 then 'Area'
		8 then 'Estatus'
		9 then 'Grupo Economico'
		10 then 'Dia de Cobros'
		12 then 'Pago Inicial'
		13 then 'Filtros Especiales')}
		
end foreach	 	

foreach
	select distinct cod_cliente
	  into _cod_cliente
	  from cascliente
	 where cod_campana <> '00000'

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

		select estatus_poliza
	      into _estatus_poliza
	      from emipomae
	     where no_poliza = _no_poliza;

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

		if v_saldo <= 0 then

			delete from caspoliza
			 where cod_cliente = _cod_cliente
			   and cod_campana not in (select cod_campana from tmp_codigos_campana);

			delete from cascliente
			 where cod_cliente = _cod_cliente
			   and cod_campana not in (select cod_campana from tmp_codigos_campana);
		else 
			update cascliente
			   set por_vencer	= v_por_vencer, 
			   	   exigible		= v_exigible,  
			   	   corriente	= v_corriente,	
			   	   monto_30		= v_monto_30,	
			   	   monto_60		= v_monto_60,	
			   	   monto_90		= v_monto_90,	
			   	   monto_120	= v_monto_120,
			   	   monto_150	= v_monto_150,
			   	   monto_180	= v_monto_180,	
				   saldo		= v_saldo
			 where cod_cliente	= _cod_cliente;
			   --and cod_campana <> '00000';
		end if
	else
		foreach
			select distinct no_documento
			  into _no_documento
			  from caspoliza
			 where cod_cliente = _cod_cliente

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

			if v_saldo <= 0 then
				delete from caspoliza
				 where no_documento = _no_documento
				   and cod_campana	not in (select cod_campana from tmp_codigos_campana);
			else			
				update cascliente				
				   set por_vencer	= v_por_vencer,
				   	   exigible		= v_exigible,  
				   	   corriente	= v_corriente,	
				   	   monto_30		= v_monto_30,	
				   	   monto_60		= v_monto_60,	
				   	   monto_90		= v_monto_90,	
				   	   monto_120	= v_monto_120,
				   	   monto_150	= v_monto_150,
				   	   monto_180	= v_monto_180,	
					   saldo		= v_saldo
				 where cod_cliente = _cod_cliente;
				   --and cod_campana <> '00000'; 				
			end if
		end foreach
	end if
end foreach

return 0, "Actualizacion Exitosa ...";

end
end procedure;