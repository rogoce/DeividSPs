-- Actualizacion de Registros Segun el Tipo de Gestion

-- Creado    : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2010 - Autor: Roman Gordon

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cas014bk;

create procedure sp_cas014bk(
a_cobrador 			char(3),
a_cod_gestion		char(3),
a_cod_cliente		char(10),
a_dia				smallint,
a_ultima_gestion	char(100),
a_hora				datetime hour to minute,
a_saldo             dec(16,2) default 0,
a_corriente         dec(16,2) default 0,
a_exigible          dec(16,2) default 0,
a_monto30           dec(16,2) default 0,
a_monto60           dec(16,2) default 0,
a_monto90           dec(16,2) default 0,
a_monto120			dec(16,2) default 0,
a_monto150			dec(16,2) default 0,
a_monto180			dec(16,2) default 0,
a_por_vencer        dec(16,2) default 0
)
returning integer;

define _error					integer;
define _dia_cobros1				integer;
define _dia_cobros2				integer;
define _dia_hoy					integer;
define _dia_sig					integer;
define _dias					integer;
define _dia_rutero				integer;
define _cantidad				integer;
define _cantidad2				integer;
define _saldo_x_unidad      	integer;
define _dia_semana				integer;
define _fecha_hoy				date;
define _fecha_ult_pro			date;
define _fecha_ult_pro_gestor	date;
define _vigencia_inic			date;
define _vigencia_final			date;
define _fecha_tra				date;
define _fecha_hora		    	datetime year to fraction(5);
define _tipo_cobrador			smallint;
define _tipo_accion				smallint;
define _exige_fecha				smallint;
define _tipo_contacto			smallint;
define _mando_mail          	smallint;
define _contacto				char(50);
define v_documento    			char(20);
define v_doc    				char(20);
define v_tarjeta	  	    	char(19); 
define _cod_pagador		    	char(10);
define _no_pol			    	char(10);
define _no_poliza		    	char(10);
define _usuario			    	char(10);										 
define _cod_campana				char(10);										 
define _periodo			    	char(7);										 
define _no_unidad           	char(5);										 
define _code_correg  	    	char(5);
define _code_agente  	    	char(5);
define _an_estatus_charo_char	char(4);
define _ano_char				char(4);
define _cod_supervisor			char(3);
define _cod_cobrador_ant_gestor	char(3);
define _cod_investigador		char(3);
define _cod_sucursal			char(3);
define _code_pais		    	char(3);
define _cod_motiv   			char(3);
define _cod_cobrador_cl			char(3);
define _code_provincia	    	char(2);
define _code_ciudad  	    	char(2);
define _code_distrito	    	char(2);
define _mes_char            	char(2);
define v_apagar             	dec(16,2);
define v_saldo					dec(16,2);
define v_exigible				dec(16,2);
define v_corriente				dec(16,2);
define v_monto_30				dec(16,2);
define v_monto_60				dec(16,2);
define v_monto_90           	dec(16,2);
define v_monto_120				dec(16,2);
define v_monto_150				dec(16,2);
define v_monto_180				dec(16,2);
define v_por_vencer         	dec(16,2); 

--set debug file to "sp_cas014bk.trc";
--trace on;
set isolation to dirty read;

let _fecha_hoy   = today;
let _fecha_hora  = current;
let v_por_vencer = 0;
let _cantidad2   = 0;
let _saldo_x_unidad = 0;
let _no_unidad      = "";

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

begin

on exception set _error
 	return _error;         
end exception

select tipo_cobrador,
	   cod_supervisor,
	   cod_sucursal,
	   fecha_ult_pro,
	   usuario,
	   cod_campana
  into _tipo_cobrador,
       _cod_supervisor,
	   _cod_sucursal,
	   _fecha_ult_pro,
	   _usuario,
	   _cod_campana
  from cobcobra
 where cod_cobrador = a_cobrador;

if a_cod_gestion <> '032' then --regresar al callcenter
	update cascliente
	   set cant_call   = cant_call + 1
	 where cod_cliente = a_cod_cliente
	   and cod_campana = _cod_campana;
else
	update cascliente
	   set cant_call   = 0
	 where cod_cliente = a_cod_cliente
	   and cod_campana = _cod_campana;
end if

select tipo_accion,
       tipo_contacto,
	   exige_fecha
  into _tipo_accion,
       _tipo_contacto,
	   _exige_fecha
  from cobcages
 where cod_gestion = a_cod_gestion;


 if _fecha_ult_pro is null then
	let _fecha_ult_pro = _fecha_hoy;
 end if

update cobcadate
   set atendidos    = atendidos  + 1,
	   pendientes   = pendientes - 1
 where cod_cobrador = a_cobrador
   and fecha        = _fecha_ult_pro;

	if _tipo_accion = 1 then -- Rutero
		{update cascliente
		   set procesado = 1,
			   cod_cobrador = null
		 where cod_cliente = a_cod_cliente
		   --and cod_campana = _cod_campana;}
	   

		let _fecha_tra   = _fecha_hoy + 1;
		let _dia_rutero	 = day(_fecha_tra);
		let _dia_hoy	 = day(_fecha_hoy);
		let _dia_sig	 = day(_fecha_ult_pro);

		if _dia_sig > _dia_hoy then
			let _fecha_tra   = _fecha_ult_pro + 1;
			let _dia_rutero	 = day(_fecha_tra);
		end if

		if _exige_fecha = 1 or a_cod_gestion = "001" then
			let _dia_rutero	 = a_dia;
		end if

		update cascliente
		   set fecha_ult_pro  = _fecha_hoy,
		       dia_cobros3    = 0,
			   cod_gestion    = a_cod_gestion,
			   ultima_gestion = a_ultima_gestion,
			   cant_call      = 0,
			   procesado	  = 1,
			   nuevo		  = 0
		 where cod_cliente    = a_cod_cliente
		   --and cod_campana	  = _cod_campana;

		select count(*)
		  into _cnt_cobclidir
		 where cod_cliente 	= a_cod_cliente
		   and no_documento = 

		select code_pais,
		 	   code_provincia,
		 	   code_ciudad,
		 	   code_distrito
  		  into c_pa,
		 	   c_pr,
		 	   c_ci,
		 	   c_di
 		  from gencorr
		 where code_correg =	_code_correg;

		select code_pais,
			   code_provincia,
			   code_ciudad,
			   code_distrito,
			   code_correg,
			   contacto
		  into _code_pais,
			   _code_provincia,
			   _code_ciudad,
			   _code_distrito,
			   _code_correg,
			   _contacto
		  from cliclien
		 where cod_cliente = a_cod_cliente;

		let _cod_cobrador_cl = null;

		select cod_cobrador
		  into _cod_cobrador_cl
		  from gencorr
		 where code_pais      =	_code_pais
		   and code_provincia =	_code_provincia
		   and code_ciudad	  =	_code_ciudad
		   and code_distrito  =	_code_distrito
		   and code_correg	  =	_code_correg;

		if _contacto is null then
			let _contacto = "";
		end if

		if _cod_cobrador_cl is null then
			--mandar error de que no se ha asignado el cobrador de calle para esta area
		end if

		--** borrar cobruter2 y cobruter1 para ser insertado el reg.
		delete from cobruter2
		 where cod_pagador = a_cod_cliente
		   and tipo_labor <> 1;

		delete from cobruter1
		 where cod_pagador = a_cod_cliente
		   and tipo_labor <> 1;

		let _cod_motiv   = null;
		let _code_agente = null;

			INSERT INTO cobruter1(
			cod_cobrador,   	
			cod_motiv,
			a_pagar,      
			saldo,       
			por_vencer,  
			exigible,    
			corriente,   
			monto_30,    
			monto_60,    
			monto_90,
			monto_120,
			monto_150,
			monto_180,
			dia_cobros1,	
			dia_cobros2,
			fecha,
			cod_agente,
			cod_pagador,
			code_pais,     
			code_provincia,
			code_ciudad,	 
			code_distrito,
			code_correg,
			descripcion,
			user_added
			)
			VALUES(
			_cod_cobrador_cl,
			_cod_motiv,    
			a_exigible,
			a_saldo,     
			a_por_vencer,
			a_exigible,  
			a_corriente,	
			a_monto30,	
			a_monto60,	
			a_monto90,
			a_monto120,
			a_monto150,
			a_monto180,	
		    _dia_rutero,
			_dia_rutero,
			_fecha_hora,
			_code_agente,
			a_cod_cliente,
			_code_pais,
			_code_provincia,
			_code_ciudad,
			_code_distrito,
			_code_correg,
			_contacto,
			_usuario
		    );

			--historia de rutero(cobruhis)
			INSERT INTO cobruhis(
			cod_cobrador,   	
			cod_motiv,
			a_pagar,      
			dia_cobros1,	
			fecha,
			cod_agente,
			cod_pagador,
			code_pais,     
			code_provincia,
			code_ciudad,	 
			code_distrito,
			code_correg,
			user_added,
			procedencia
			)
			VALUES(
			_cod_cobrador_cl,
			_cod_motiv,    
			a_exigible,
			_dia_rutero,
			_fecha_hora,
			_code_agente,
			a_cod_cliente,
			_code_pais,
			_code_provincia,
			_code_ciudad,
			_code_distrito,
			_code_correg,
			_usuario,
			1
		    );

	    foreach
			select distinct no_documento,
				   a_pagar
			  into v_documento,
				   v_apagar
			  from caspoliza
			 where cod_cliente = a_cod_cliente
			   --and cod_campana = _cod_campana

			CALL sp_cob245(
			'*',
			'*',
			v_documento,
			_periodo,
			_fecha_hoy
			) RETURNING v_por_vencer,
					    v_exigible,  
					    v_corriente, 
					    v_monto_30,  
					    v_monto_60,  
					    v_monto_90,
						v_monto_120,
						v_monto_150,
						v_monto_180,
					    v_saldo
					    ;

			 if v_apagar = 0 then
			 	let v_apagar = v_exigible;
			 end if

			 let v_doc = null;

		 	 if v_apagar  <= 0.00 then
			 	continue foreach;
			 end if

			LET _fecha_hora = _fecha_hora + 1 UNITS SECOND;

			INSERT INTO cobruter2(
			no_documento,
			cod_cobrador,   	
			cod_motiv,
			a_pagar,      
			saldo,       
			por_vencer,  
			exigible,    
			corriente,   
			monto_30,    
			monto_60,    
			monto_90,
			monto_120,
			monto_150,
			monto_180,
			dia_cobros1,	
			dia_cobros2,
			fecha,
			cod_agente,
			cod_pagador,
			code_pais,     
			code_provincia,
			code_ciudad,	 
			code_distrito,
			code_correg
			)
			VALUES(
			v_documento,
			_cod_cobrador_cl,
			_cod_motiv,    
			v_apagar,
			v_saldo,     
			v_por_vencer,
			v_exigible,  
			v_corriente,	
			v_monto_30,	
			v_monto_60,	
			v_monto_90,
			v_monto_120,
			v_monto_150,
			v_monto_180,	
		    _dia_rutero,
			_dia_rutero,
			_fecha_hora,
			_code_agente,
			a_cod_cliente,
			_code_pais,
			_code_provincia,
			_code_ciudad,
			_code_distrito,
			_code_correg
		    );

	   end foreach

	elif _tipo_accion = 2 then -- Otro Dia

		if a_cod_gestion = '026' then --cte. ya pago
			update cascliente
			   set cant_call   = 0,
			       procesado   = 1,
				   cod_cobrador = null
			 where cod_cliente = a_cod_cliente
			   and cod_campana = _cod_campana;
		   
		end if

	   {	if _tipo_cobrador = 12 and a_cod_gestion <> '026' then  --es 90 dias o mas
			select count(*)
			  into _cantidad
			  from cascliente
			 where cod_cliente = a_cod_cliente,
			   and cod_campana = _cod_campana;

			if _cantidad = 0 then
				insert into cascliente(cod_cliente, hora, cod_cobrador, nuevo, dia,cod_campana)
				values (a_cod_cliente, null, a_cobrador, 1, a_dia,_cod_campana);
			end if
		end if }

		if a_cod_gestion = '010' then --aviso de cancelacion
			let _cod_motiv		= null;
			let _code_agente	= null;
			let a_dia			= 0;

			select code_pais,
				   code_provincia,
				   code_ciudad,
				   code_distrito,
				   code_correg,
				   contacto
			  into _code_pais,
				   _code_provincia,
				   _code_ciudad,
				   _code_distrito,
				   _code_correg,
				   _contacto
			  from cliclien
			 where cod_cliente = a_cod_cliente;

			let _cod_cobrador_cl = null;

			select cod_cobrador
			  into _cod_cobrador_cl
			  from gencorr
			 where code_pais      =	_code_pais
			   and code_provincia =	_code_provincia
			   and code_ciudad	  =	_code_ciudad
			   and code_distrito  =	_code_distrito
			   and code_correg	  =	_code_correg;

			if _contacto is null then
				let _contacto = "";
			end if

			INSERT INTO cobruter1(
			cod_cobrador,   	
			a_pagar,      
			saldo,       
			por_vencer,  
			exigible,    
			corriente,   
			monto_30,    
			monto_60,    
			monto_90,
			monto_120,
			monto_150,
			monto_180,
			dia_cobros1,	
			dia_cobros2,
			fecha,
			cod_agente,
			cod_pagador,
			code_pais,     
			code_provincia,
			code_ciudad,	 
			code_distrito,
			code_correg,
			descripcion,
			user_added,
			tipo_labor
			)
			VALUES(
			"059",
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
		    a_dia,
			a_dia,
			_fecha_hora,
			_code_agente,
			a_cod_cliente,
			_code_pais,
			_code_provincia,
			_code_ciudad,
			_code_distrito,
			_code_correg,
			_contacto,
			_usuario,
			1
		    );

			--historia de rutero(cobruhis)
			INSERT INTO cobruhis(
			cod_cobrador,   	
			cod_motiv,
			a_pagar,      
			dia_cobros1,	
			fecha,
			cod_pagador,
			code_pais,     
			code_provincia,
			code_ciudad,	 
			code_distrito,
			code_correg,
			user_added,
			procedencia,
			tipo_labor
			)
			VALUES(
			"059",
			_cod_motiv,    
			0,
			a_dia,
			_fecha_hora,
			a_cod_cliente,
			_code_pais,
			_code_provincia,
			_code_ciudad,
			_code_distrito,
			_code_correg,
			_usuario,
			1,
			1
		    );
		    foreach
				select no_documento
				  into v_documento
				  from caspoliza
				 where cod_cliente  = a_cod_cliente
				   and cod_campana  = _cod_campana

				LET _fecha_hora = _fecha_hora + 1 UNITS SECOND;

				INSERT INTO cobruter2(
				no_documento,
				cod_cobrador,   	
				cod_motiv,
				a_pagar,      
				saldo,       
				por_vencer,  
				exigible,    
				corriente,   
				monto_30,    
				monto_60,    
				monto_90,
				monto_120,
				monto_150,
				monto_180,
				dia_cobros1,	
				dia_cobros2,
				fecha,
				cod_pagador,
				code_pais,     
				code_provincia,
				code_ciudad,	 
				code_distrito,
				code_correg,
				tipo_labor
				)
				VALUES(
				v_documento,
				"059",
				_cod_motiv,    
				0,
				0,     
				0,
				0,  
				0,	
				0,	
				0,	
				0,
				0,
				0,
				0,	
			    a_dia,
				a_dia,
				_fecha_hora,
				a_cod_cliente,
				_code_pais,
				_code_provincia,
				_code_ciudad,
				_code_distrito,
				_code_correg,
				1
			    );
		   end foreach
		end if

		let _dia_sig	= a_dia;

		if a_cod_gestion = '019' then
			select dias
			  into _dias
			  from cobcages 
			 where cod_gestion = a_cod_gestion;

			let _fecha_tra  = _fecha_hoy + _dias;
			let _dia_sig	= day(_fecha_tra);
			let _dia_semana = weekday(_fecha_tra);

			if _dia_semana = 0 then
				let _dia_semana = _dia_semana + 1;
			end if
		end if

	    update cascliente
		   set fecha_ult_pro  = _fecha_hoy,
		       dia_cobros3    = _dia_sig,
			   cod_gestion    = a_cod_gestion,
			   ultima_gestion = a_ultima_gestion,
			   hora           = null,
			   cod_cobrador	  = null
		 where cod_cliente    = a_cod_cliente
		   and cod_campana	  = _cod_campana;

	elif _tipo_accion = 3 then 								-- ****Supervisor****

		update cascliente
		   set fecha_ult_pro 	= _fecha_hoy,
		       dia_cobros3   	= 0,
			   cod_gestion   	= a_cod_gestion,
			   ultima_gestion	= a_ultima_gestion,
			   cod_cobrador     = _cod_supervisor,
			   cod_cobrador_ant = a_cobrador,
			   cant_call        = 0,
			   procesado		= 1
		 where cod_cliente   	= a_cod_cliente
		   and cod_campana 		= _cod_campana;

		
	elif _tipo_accion = 4 then -- Investigador

	    let _cod_investigador = sp_cas006(_cod_sucursal, 7);

		update cascliente
		   set fecha_ult_pro 	= _fecha_hoy,
		       dia_cobros3   	= 0,
			   cod_gestion   	= a_cod_gestion,
			   ultima_gestion	= a_ultima_gestion,
			   cod_cobrador     = _cod_investigador,
			   cod_cobrador_ant = a_cobrador,
			   procesado		= 1
		 where cod_cliente   	= a_cod_cliente
		   and cod_campana		= _cod_campana;

		if a_cod_gestion = '009' OR a_cod_gestion = '014' then --no se pudo localizar,tel. equivocado
			update cascliente
			   set cant_call   = 0,
			   	   cod_cobrador = null
			 where cod_cliente = a_cod_cliente
			   and cod_campana = _cod_campana;
		end if
	elif _tipo_accion = 5 then -- Visa

	    foreach
			select no_documento
			  into v_documento
			  from caspoliza
			 where cod_cliente  = a_cod_cliente
			   and cod_campana  = _cod_campana

			exit foreach;
		end foreach

		let _no_poliza = sp_sis21(v_documento);

		select no_tarjeta,
		       saldo_por_unidad
		  into v_tarjeta,
		       _saldo_x_unidad
		  from emipomae
		 where no_poliza = _no_poliza;

		if v_tarjeta is not null then

			update cobtahab
			   set rechazada  = 0
			 where no_tarjeta = v_tarjeta;

			update emipomae
			   set cobra_poliza = "T",
			       cod_formapag = "003"		--tarjeta de credito
			 where no_poliza    = _no_poliza;

			if _saldo_x_unidad = 1 then
				foreach
				    select no_unidad
					  into _no_unidad
					  from emipouni
					 where no_poliza   = _no_poliza
					   and cod_pagador = a_cod_cliente
					exit foreach;
				end foreach

				update emipouni
				   set cobra_poliza = "T",
				       cod_formapag = "003"		--tarjeta de credito
				 where no_poliza    = _no_poliza
				   and no_unidad    = _no_unidad;

			 	delete from caspoliza
				 where no_documento = v_documento
				   and cod_cliente  = a_cod_cliente
				   and cod_campana  = _cod_campana;
		   
				select count(*)
				  into _cantidad2
				  from caspoliza
				 where cod_cliente = a_cod_cliente
				   and cod_campana = _cod_campana;

				if _cantidad2 = 0 then	--borrar maestro, no hay reg en detalle
					delete from cascliente
					 where cod_cliente = a_cod_cliente
					   and cod_campana = _cod_campana;
				end if

			else

				delete from caspoliza
				 where cod_cliente = a_cod_cliente
				   and cod_campana = _cod_campana;

				delete from cascliente
				 where cod_cliente = a_cod_cliente
				   and cod_campana = _cod_campana;
			end if
		else
			return 1;
		end if

	elif _tipo_accion = 7 then -- Mismo Dia

			select count(*)
			  into _cantidad
			  from cascliente
			 where cod_cliente = a_cod_cliente
			   and cod_campana = _cod_campana;

	   {	if _tipo_cobrador = 12 then  --es rol 90 dias o mas

			if _cantidad = 0 then
				insert into cascliente(cod_cliente, hora, cod_cobrador, nuevo, dia,cod_campana)
				values (a_cod_cliente, null, a_cobrador, 1, a_dia,_cod_campana);
			end if
		else}
			if _cantidad = 0 then
				insert into cascliente(cod_cliente, hora, cod_cobrador, nuevo, dia,cod_campana)
				values (a_cod_cliente, a_hora, a_cobrador, 1, a_dia, _cod_campana);
			end if
--		end if

		update cascliente
		   set fecha_ult_pro  = _fecha_hoy,
		       dia_cobros3    = 0,
			   cod_gestion    = a_cod_gestion,
			   ultima_gestion = a_ultima_gestion,
			   cod_cobrador	  = a_cobrador,
			   hora		      = a_hora
		 where cod_cliente    = a_cod_cliente
		   and cod_campana 	  = _cod_campana;

	elif _tipo_accion = 8 then -- Corredor

		foreach
			select	no_documento
			  into	v_documento
			  from	caspoliza
			 where	cod_cliente  = a_cod_cliente
			   and  cod_campana  = _cod_campana

			let _no_poliza = sp_sis21(v_documento);

			update emipomae
			   set cobra_poliza = "C",
			       cod_formapag = "008"
			 where no_poliza    = _no_poliza;

			select saldo_por_unidad
			  into _saldo_x_unidad
			  from emipomae
			 where no_poliza = _no_poliza;

            if _saldo_x_unidad = 1 then
				foreach
				    select no_unidad
					  into _no_unidad
					  from emipouni
					 where no_poliza   = _no_poliza
					   and cod_pagador = a_cod_cliente
					exit foreach;
				end foreach

				update emipouni
				   set cobra_poliza = "C",
				       cod_formapag = "008"		--tarjeta de credito
				 where no_poliza    = _no_poliza
				   and no_unidad    = _no_unidad;

			end if

		end foreach

		delete from caspoliza
		 where cod_cliente = a_cod_cliente
		   and cod_campana = _cod_campana;

		delete from cascliente
		 where cod_cliente = a_cod_cliente
		   and cod_campana = _cod_campana;


	elif _tipo_accion = 9 then -- Call Center

		select cod_cobrador_ant,
			   mando_mail
		  into _cod_cobrador_ant_gestor,
			   _mando_mail
		  from cascliente
		 where cod_cliente = a_cod_cliente
		   and cod_campana = _cod_campana;
		
	   	if _cod_cobrador_ant_gestor is null then
			let _cod_cobrador_ant_gestor = sp_cas006(_cod_sucursal, 1);
		end if

		if _tipo_cobrador = 6 then	--incobrable
			select tipo_cobrador
			  into _tipo_cobrador
			  from cobcobra
			 where cod_cobrador = _cod_cobrador_ant_gestor;

			if _tipo_cobrador <> 1 then
				let _cod_cobrador_ant_gestor = sp_cas006(_cod_sucursal, 1);
			end if
		end if

		select fecha_ult_pro
		  into _fecha_ult_pro_gestor
		  from cobcobra
		 where cod_cobrador = _cod_cobrador_ant_gestor;

	   if _fecha_ult_pro_gestor is null then
	   		let _fecha_ult_pro_gestor = _fecha_hoy;
	   end if

	   let _fecha_ult_pro_gestor = _fecha_ult_pro_gestor + 2;
	   let _dia_cobros1          = day(_fecha_ult_pro_gestor);

		update cascliente
		   set cod_cobrador     = _cod_cobrador_ant_gestor,
			   cod_cobrador_ant = null,
			   dia_cobros3      = _dia_cobros1,
			   procesado		= 0
		 where cod_cliente      = a_cod_cliente
		   and cod_campana		= _cod_campana;

		foreach
			select	no_documento
			  into	v_documento
			  from	caspoliza
			 where	cod_cliente  = a_cod_cliente
			   and  cod_campana	 = _cod_campana

			let _no_poliza = sp_sis21(v_documento);

			update emipomae
			   set cobra_poliza = "E",
			       cod_formapag = "006"
			 where no_poliza    = _no_poliza;

		end foreach

		{if _tipo_cobrador = 7 then  --es investigador
			if _mando_mail = 1 then
				update cascliente
				   set mando_mail  = 0
				 where cod_cliente = a_cod_cliente;
			end if
		end if}

	elif _tipo_accion = 10 then -- Por Cancelar

		foreach
		 select	no_documento
		   into	v_documento
		   from	caspoliza
		  where	cod_cliente  = a_cod_cliente
		    and cod_campana  = _cod_campana

			let _no_poliza = sp_sis21(v_documento);

			update emipomae
			   set cobra_poliza = "P",
			       cod_formapag = "080"
			 where no_poliza    = _no_poliza;

		end foreach

		delete from caspoliza
		 where cod_cliente = a_cod_cliente
		   and cod_campana = _cod_campana;

		delete from cascliente
		 where cod_cliente = a_cod_cliente
		   and cod_campana = _cod_campana;

	end if

end

return 0;

end procedure;

