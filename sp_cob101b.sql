-- Procedimiento que trae los clientes para programa Call Center		Modificaciones de Cobros por Campana
-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob101b;

create procedure sp_cob101b(
a_compania 		char(3),
a_agencia  		char(3),
a_cobrador 		char(3),
a_cod_cliente	char(10) default "*",
a_no_documento	char(20) default "*")
returning	char(10)		as cod_cliente,	--cod_cliente,		1
			char(100)		as nom_cliente,	--_nombre,		2
			varchar(200)	as direccion,	--_direccion,		3
			char(10)		as telefono1,	--_telefono1,		4
			char(10)		as telefono2,	--_telefono2,		5
			char(10)		as celular,		--_celular,		6
			char(10)		as fax,			--_fax,			7
			char(50)		as email,		--_e_mail,			8
			char(10)		as telefono3,	--_telefono3,		9
			char(20)		as aparatado,	--_apartado,		10
			char(30)		as cedula,		--_cedula			11
			smallint		as dia1,		-- dia1			12
			smallint		as dia2,		-- dia2			13
			char(3)			as cod_gestion,	-- cod_gestion		14
			char(2)			as ciudad,		-- ciudad			15
			char(2)			as distrito,	-- distrito			16
			char(5)			as area,		-- area			17
			char(3)			as pais,		-- pais			18
			char(2)			as provincia,	-- prov			19
			varchar(50)		as contacto,	-- contacto		20
			dec(16,2)		as a_pagar,		-- a pagar			21
			smallint		as prioridad,	-- prioridad		22
			char(50)		as ultima_gestion,		-- ultima gestion	23
			date			as fecha_aniversario,			-- fecha aniversario	24
			smallint		as pago_fijo,		-- pago fijo		25
			char(4)			as cod_estafeta,		-- cod estafeta
			varchar(50)		as estafeta,
			varchar(100)	as cliente_vip,
			smallint     	as vip,
			varchar(100)	as direccion12,	-- estafeta
			varchar(100)	as cliente_vocem,
			smallint     	as vocem;

define _direccion	    		varchar(200);
define _nom_estafeta    		varchar(50);
define _contacto	    		varchar(50);
define _direccion_1,_direccion_2 varchar(50);
define _direccion_12            varchar(100);
define _nombre	        		char(100);
define _no_documento			char(21);
define _e_mail					char(50);
define _ultima_gestion			char(50);
define _cedula					char(30);
define _apartado				char(20);
define v_documento				char(10);
define _no_poliza				char(10);
define _telefono1				char(10);
define _telefono2				char(10);
define _telefono3				char(10);
define _celular					char(10);
define _fax						char(10);
define _cod_cliente				char(10);
define _cod_campana				char(10);
define _periodo         		char(7);
define _code_correg				char(5);
define _cod_estafeta			char(4);
define _ano_char				char(4);
define _cod_gestion_cascliente	char(3);
define _cod_gestion     		char(3);
define _cod_cobrador			char(3);
define _code_pais       		char(3);
define _code_provincia			char(2);
define _code_ciudad				char(2);
define _code_distrito			char(2);
define _mes_char        		char(2);
define v_por_vencer     		dec(16,2);	 
define v_exigible       		dec(16,2);
define v_corriente				dec(16,2);
define v_monto_30				dec(16,2);
define v_monto_60				dec(16,2);
define v_monto_90				dec(16,2);
define v_monto_120				dec(16,2);
define v_monto_150				dec(16,2);
define v_monto_180				dec(16,2);
define v_apagar					dec(16,2);
define v_saldo					dec(16,2);
define _dia_cobros1     		smallint;
define _dia_cobros2     		smallint;
define _dia_cobros3     		smallint;
define _dia_actual      		smallint;
define _dia3		    		smallint;
define _estatus_poliza			smallint;
define _cnt_caspoliza			smallint;
define _tipo_cobrador   		smallint;
define _cnt_anulacion	 		smallint;
define _tipo_otrodia			smallint;
define _dia_cobruter			smallint;
define _tipo_campana			smallint;
define _tipo_accion				smallint;
define _mes_ult_pro				smallint;
define _procesado1				smallint;
define _tipo_orden		 		smallint;
define _cant_proc				smallint;
define _cnt_atent				smallint;
define _pago_fijo			  	smallint;
define _prioridad				smallint;
define _procesado				smallint;
define _pendiente				smallint;
define _cantidad				smallint;
define _mes_hoy					smallint;
define _existe					smallint;
define a_dia					smallint;
define _flag_return				smallint;
define i						integer;
define _cant					integer;
define _li_return				integer;
define _fecha_ult_pro			date;
define _fecha_ult_dia			date;
define _fecha_hoy				date;
define _fecha_actual			date;
define _fecha_tra				date;
define _fecha_start				date;
define _fecha_tmp				date;
define _fecha_pago				date;
define _fecha_pago_reciente		date;
define _fecha_primer_pago		date;
define _fecha_aniversario		date;
define _hora_hoy			  	datetime year to minute;
define _hora_tra				datetime year to minute;
define _cliente_vip			    smallint;
define _msg_vip				    varchar(100);
define _cliente_vocem			smallint;
define _msg_vocem				varchar(100);

if a_cobrador = '043' then --133' then
set debug file to "sp_cob101bk3.trc";
trace on;
end if

set isolation to dirty read;

let _cod_gestion_cascliente	= '';
let _nom_estafeta			= '';
let _cod_cobrador 			= '';
let _fecha_hoy    			= today;
let _fecha_actual 			= today;
let _hora_hoy 	  			= current;
let _cod_gestion  			= '';
let _pago_fijo	  			= 0;
let	_dia_cobros1  			= 0;
let	_dia_cobros2  			= 0;
let _pago_fijo	  			= 0;
let _cliente_vip  			= 0;
let _dia_cobruter 			= day(_fecha_hoy);
let _mes_hoy	 			= month(_fecha_hoy);
let _msg_vip                = '';
let _cliente_vocem  		= 0;
let _msg_vocem              = '';

-- Armar varibale que contiene el periodo(aaaa-mm)

{if  month(_fecha_hoy) < 10 then
	let _mes_char = '0'|| month(_fecha_hoy);
else
	let _mes_char = month(_fecha_hoy);
end if

let _ano_char = year(_fecha_hoy);
let _periodo  = _ano_char || "-" || _mes_char;}

call sp_sis39(_fecha_hoy) returning _periodo;
call sp_sis36(_periodo) returning _fecha_ult_dia;

select tipo_cobrador,
       fecha_ult_pro,
	   cod_campana
  into _tipo_cobrador,
       _fecha_ult_pro,
	   _cod_campana
  from cobcobra
 where cod_cobrador = a_cobrador;

select orden_camp,
	   tipo_campana
  into _tipo_orden,
	   _tipo_campana
  from cascampana
 where cod_campana = _cod_campana;

let _prioridad = 0;	

-- Consulta
if a_cod_cliente <> "*" then

	if a_no_documento = " " then
		let a_no_documento = "*";
	end if

	let _cod_cliente = null;

	call sp_cas012b(a_cod_cliente)
	returning _nombre,
			  _direccion,
		      _telefono1,
		      _telefono2,
		      _celular,
		      _fax,
		      _e_mail,
		      _telefono3,
		      _apartado,
		      _cedula,
		      _code_ciudad,
		      _code_distrito,
		      _code_correg,
		      _code_pais,
		      _code_provincia,
		      _contacto,
		      _fecha_aniversario,
			  _cod_estafeta, _direccion_1, _direccion_2 ;

	if _cod_estafeta <> '' then
		select nombre
		  into _nom_estafeta
		  from cobestafeta
		 where cod_estafeta = _cod_estafeta; 
	end if

	foreach
		select	cod_cliente,
				cod_gestion,
				dia_cobros1,
				dia_cobros2,
				pago_fijo
		   into	_cod_cliente,
				_cod_gestion,
				_dia_cobros1,
				_dia_cobros2,
				_pago_fijo
		   from	cascliente
		  where	cod_cliente = a_cod_cliente
			    --and cod_campana = _cod_campana;
		  exit foreach;
	end foreach;

	{if _cod_cliente is null then  --pagador no esta en el call center
		let _li_return = sp_cas027(a_cod_cliente); --insertar cascliente y caspoliza
	else  }
	if a_no_documento <> "*" then	--inserta poliza a un pagador existente
		let _li_return = sp_cas027(a_cod_cliente,a_no_documento ); --insertar cascliente y caspoliza
	else
		if _cod_cliente is null then  --pagador no esta en el call center
			let _li_return = sp_cas027(a_cod_cliente); --insertar cascliente y caspoliza
		else
			let _li_return = sp_cas027(_cod_cliente,a_no_documento ); --insertar cascliente y caspoliza
		end if
	end if
		--end if
	let v_apagar = 0;

	if _cod_cliente is null then
		let _cod_cliente = a_cod_cliente;
	end if

	if _cod_gestion is null then
		let _cod_gestion = '';
	end if

	select nombre
	  into _ultima_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	--let _li_return = sp_cas027(a_cod_cliente, a_no_documento); --insertar cascliente y caspoliza

	foreach
		select no_documento
		  into v_documento
		  from emipomae
		 where cod_pagador = a_cod_cliente

		CALL sp_cob33(
					a_compania,
					a_agencia,
					v_documento,
					_periodo,
					_fecha_ult_dia)
		RETURNING	v_por_vencer,
					v_exigible,  
					v_corriente,
					v_monto_30,  
					v_monto_60,  
					v_monto_90,
					v_saldo;
			
		let v_apagar = v_apagar + v_exigible;
	end foreach

	let _direccion = trim(_direccion);
	let _direccion_12 = trim(_direccion_1)||' '||trim(_direccion_2);	
	
	CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _msg_vip; 
	
	-- 2:Se Señaiiza Cliente VOCEM en Pantalla Unica, RGORDON 26/7/18  
	CALL sp_sis241 (_cod_cliente) returning _cliente_vocem, _msg_vocem; 	

	return a_cod_cliente,			  
		   _nombre,					  
		   trim(_direccion),		  
		   _telefono1,				  
		   _telefono2,				  
		   _celular,				  
		   _fax,					  
		   _e_mail,					  
		   _telefono3,				  
		   _apartado,				  
		   _cedula,					  
		   _dia_cobros1,			  
		   _dia_cobros2,			  
		   "",						  
		   _code_ciudad,			  
		   _code_distrito,			  
		   _code_correg,			  
		   _code_pais,				  
		   _code_provincia,			  
		   trim(_contacto),			  
		   v_apagar,				  
		   _prioridad,				  
		   _ultima_gestion,			  
		   _fecha_aniversario,		  
		   _pago_fijo,
		   _cod_estafeta,
		   _nom_estafeta,_msg_vip,_cliente_vip,_direccion_12,_msg_vocem,_cliente_vocem;
end if

--Campaña de Anulaciones
if _tipo_campana = 3 then
	let _flag_return = 0;

	foreach
		select distinct c.cod_cliente,
			   p.no_documento,
			   c.nuevo,
			   c.hora,
			   c.exigible,
			   c.corriente,
			   c.monto_30,
			   c.monto_60,
			   c.monto_90,
			   c.monto_120,
			   c.monto_150,
			   c.monto_180,
			   c.cod_cobrador,
			   c.procesado
		  into _cod_cliente,
			   _no_documento,
			   _prioridad,
			   _hora_tra,
			   v_exigible,
			   v_corriente,
			   v_monto_30,
			   v_monto_60,
			   v_monto_90,
			   v_monto_120,
			   v_monto_150,
			   v_monto_180,
			   _cod_cobrador,
			   _procesado1
		  from cascliente c, caspoliza p
		 where c.cod_campana = p.cod_campana
		   and c.cod_cliente = p.cod_cliente
		   and c.cod_campana = _cod_campana
		   --and hora is null
		 order by c.procesado asc,c.nuevo desc,monto_180 desc,monto_150 desc,monto_120 desc,monto_90 desc,monto_60 desc,monto_30 desc,corriente desc

		if _cod_cobrador is not null and _cod_cobrador <> a_cobrador then
			continue foreach;
		end if

		let _no_poliza = sp_sis21(_no_documento);

		select estatus_poliza,
			   fecha_primer_pago
		  into _estatus_poliza,
			   _fecha_primer_pago
		  from emipomae
		 where no_poliza = _no_poliza;

		if _estatus_poliza in (2,4) then
			continue foreach;
		end if

		select cod_gestion,
			   dia_cobros1,
			   dia_cobros2,
			   dia_cobros3,
			   fecha_ult_pro,
			   pago_fijo
		  into _cod_gestion,
			   _dia_cobros1,
			   _dia_cobros2,
			   _dia_cobros3,
			   _fecha_ult_pro,
			   _pago_fijo
		  from cascliente
		 where cod_cliente = _cod_cliente
		   and cod_campana = _cod_campana;

		let _cantidad = sp_cas027(_cod_cliente);

		select count(*)
		  into _cnt_caspoliza
		  from caspoliza
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;

		if _cnt_caspoliza is null then
			let _cnt_caspoliza = 0;
		end if

		if _cnt_caspoliza = 0 then
			delete from cascliente
			 where cod_campana = _cod_campana
			   and cod_cliente = _cod_cliente;

			continue foreach;
		end if

		if _fecha_ult_pro is null then
			let _fecha_ult_pro = _fecha_hoy;			
		else
			if _fecha_ult_pro > _fecha_hoy then
				let _fecha_hoy = _fecha_ult_pro;
			end if
		end if 

		update cobcobra
		   set fecha_ult_pro = _fecha_hoy
		 where cod_cobrador  = a_cobrador;

		select procesado
		  into _procesado
		  from cobcadate
		 where cod_cobrador = a_cobrador
		   and fecha        = _fecha_hoy;

		if _procesado is null then

			select count(*)
			  into _cantidad
			  from cascliente
			 where cod_campana = _cod_campana;

			select count(*)
			  into _pendiente
			  from cascliente
			 where cod_campana = _cod_campana
			   and cod_gestion is null;

			insert into cobcadate(
					cod_cobrador,
					fecha,
					procesado,
					total,
					atendidos,
					pendientes,
					nuevos,
					atrazados)
		   values(	a_cobrador,
					_fecha_hoy,
					1,
					_cantidad,
					_cantidad - _pendiente,
					_pendiente,
					0,
					0);
		end if 

		select tipo_otrodia
		  into _tipo_otrodia
		  from cobcages
		 where cod_gestion = _cod_gestion;

		if _tipo_otrodia = 1 then	--tipo de gestion de otro dia  "002","006","005","008"
			let _dia_actual = day(_fecha_actual);
			if _dia_cobros3 > _dia_actual Then
			
				let _mes_ult_pro = month(_fecha_ult_pro);
			
				if _mes_ult_pro >= _mes_hoy then 
					continue foreach;
				end if
				--continue foreach;
			end if				
		end if

		if ((v_monto_30 + v_monto_60 + v_monto_90 + v_monto_120 + v_monto_150 + v_monto_180 + v_corriente) = 0) and _tipo_campana <> 3 then
			update cascliente 
			   set procesado	= 1,
				   nuevo 		= 0
			 where cod_cliente = _cod_cliente
			   and cod_campana = _cod_campana;
			continue foreach;
		end if

		select count(*)
		  into _existe
		  from cobruter1
		 where cod_pagador = _cod_cliente
		   and (dia_cobros1 = _dia_cobruter or dia_cobros2 = _dia_cobruter)
		   and cod_cobrador <> '059';

		if _existe = 1 then  --el pagador esta en el rutero
			continue foreach;
		end if

		select nombre
		  into _ultima_gestion
		  from cobcages
		 where cod_gestion = _cod_gestion;

		call sp_cas012b(_cod_cliente)
		returning _nombre,
				  _direccion,
				  _telefono1,
				  _telefono2,
				  _celular,
				  _fax,
				  _e_mail,
				  _telefono3,
				  _apartado,
				  _cedula,
				  _code_ciudad,
				  _code_distrito,
				  _code_correg,
				  _code_pais,
				  _code_provincia,
				  _contacto,
				  _fecha_aniversario,
				  _cod_estafeta, _direccion_1,	   _direccion_2 ;

		if _cod_estafeta <> '' then
			select nombre
			  into _nom_estafeta
			  from cobestafeta
			 where cod_estafeta = _cod_estafeta; 
		end if

		let v_apagar = v_exigible;

		select fecha_aniversario
		  into _fecha_aniversario
		  from cliclien
		 where cod_cliente = _cod_cliente;		 		

		let _direccion = trim(_direccion);
	    let _direccion_12 = trim(_direccion_1)||' '||trim(_direccion_2);		

		if _cod_gestion is null then
			let _cod_gestion = '';
		end if

		update cascliente 
		   set cod_cobrador = a_cobrador 
		 where cod_cliente = _cod_cliente;

		let _flag_return = 1;
		CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _msg_vip; 

		-- Se Señaiiza Cliente VOCEM en Pantalla Unica, RGORDON 26/7/18 
		CALL sp_sis241 (_cod_cliente) returning _cliente_vocem, _msg_vocem; 			

		return _cod_cliente,
			   _nombre,			  
			   trim(_direccion),  
			   _telefono1,		  
			   _telefono2,		  
			   _celular,		  
			   _fax,			  
			   _e_mail,			  
			   _telefono3,		  
			   _apartado,		  
			   _cedula,			  
			   _dia_cobros1,	  
			   _dia_cobros2,	  
			   "",				  
			   _code_ciudad,	  
			   _code_distrito,	  
			   _code_correg,	  
			   _code_pais,		  
			   _code_provincia,	  
			   trim(_contacto),	  
			   v_apagar,		  
			   _prioridad,		  
			   _ultima_gestion,	  
			   _fecha_aniversario,
			   _pago_fijo,
			   _cod_estafeta,
		       _nom_estafeta,_msg_vip,_cliente_vip,_direccion_12,_msg_vocem,_cliente_vocem;
	end foreach
	
	if _flag_return = 0 then
		return '00000',
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   0,		   
			   0,		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   '',		   
			   0,		   
			   0,		   
			   '',		   
			   '',		   
			   0,
			   '',
			   '','',_cliente_vip,'',_msg_vocem,_cliente_vocem;
	end if
end if

--trace on;

-- Chequeo por Hora
foreach
	select cod_cliente,
	       nuevo,
		   hora,
		   exigible
	  into _cod_cliente,
	       _prioridad,
		   _hora_tra,
		   v_exigible
	  from cascliente c, cascampana a
	 where c.cod_campana = a.cod_campana
	   and c.cod_cobrador = a_cobrador
	   --and cod_campana  = _cod_campana
	   and c.hora         <= _hora_hoy
	   and c.hora         is not null
	   and a.tipo_campana = _tipo_campana
	 order by nuevo, hora 
	
	foreach
		select cod_gestion,
			   dia_cobros3,
			   pago_fijo,
			   fecha_ult_pro
		  into _cod_gestion_cascliente,
			   _dia3,
			   _pago_fijo,
			   _fecha_ult_pro
		  from cascliente
		 where cod_cliente = _cod_cliente
		 order by fecha_ult_pro desc
		   --and cod_campana = _cod_campana;
		exit foreach;
	end foreach
	
	
	select count(*)
	  into _cnt_anulacion
	  from cascliente
	 where cod_cliente = _cod_cliente
	   and cod_campana in (select cod_campana from cascampana where tipo_campana = 3);

	if _cnt_anulacion is null then
		let _cnt_anulacion = 0;
	end if

	if _cnt_anulacion > 0 and _tipo_campana <> 3 then
		continue foreach;
	end if

	if _cod_gestion_cascliente = '040' then
		continue foreach;
	end if
	
	select count(*)
	  into _cnt_caspoliza
	  from caspoliza
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente;

	if _cnt_caspoliza is null then
		let _cnt_caspoliza = 0;
	end if

	if _cnt_caspoliza = 0 then
		delete from cascliente
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;

		continue foreach;
	end if
	
	select tipo_otrodia,
		   tipo_accion
	  into _tipo_otrodia,
		   _tipo_accion
	  from cobcages
	 where cod_gestion = _cod_gestion_cascliente;

	if _tipo_otrodia = 1 then	--tipo de gestion de otro dia  "002","006","005","008"
		let _dia_actual = day(_fecha_actual);

		if _dia3 = 0 then
			continue foreach;
		end if
		
		if _dia3 > _dia_actual Then
			continue foreach;
		end if
		
		if _dia3 >= 28 and month(_fecha_actual) = 2 then
			continue foreach;
		elif _dia3 > 30 and day(_fecha_ult_dia) < 31 then
			continue foreach;
		end if
		
		if mdy(month(_fecha_actual),_dia3,year(_fecha_actual)) > _fecha_actual then
			continue foreach;
		end if

		--if _fecha_ult_pro > mdy(month(_fecha_ult_pro),_dia3,year(_fecha_ult_pro))  then
			--continue foreach;
		--end if
	else
		if _tipo_accion <> 7 then
			if _dia3 = 0 then
				continue foreach;
			end if
		end if
	end if

   	if _fecha_ult_pro is null then
   		let _fecha_ult_pro = _fecha_hoy;			
	else 
		if _fecha_ult_pro > _fecha_hoy then
			let _fecha_hoy = _fecha_ult_pro;
		end if
	end if 

	update cobcobra
	   set fecha_ult_pro = _fecha_hoy
	 where cod_cobrador  = a_cobrador;

	if _cod_campana <> '00000' then
		select procesado
		  into _procesado
		  from cobcadate
		 where cod_cobrador = a_cobrador
		   and fecha        = _fecha_hoy;

		if _procesado is null then

			select count(*)
			  into _cantidad
			  from cascliente
			 where cod_campana = _cod_campana;
			
			select count(*)
			  into _cant_proc
			  from cascliente
			 where cod_campana	= _cod_campana
			   and procesado	= 0;

			insert into cobcadate(
					cod_cobrador,
					fecha,
					procesado,
					total,
					atendidos,
					pendientes,
					nuevos,
					atrazados)
			values(	a_cobrador,
					_fecha_hoy,
					1,
					_cantidad,
					_cantidad - _cant_proc,
					_cant_proc,
					0,
					_cant_proc);
		end if
	end if

	select cod_gestion,
		   dia_cobros1,
		   dia_cobros2,
		   dia_cobros3,
		   fecha_ult_pro,
		   pago_fijo
	  into _cod_gestion,
		   _dia_cobros1,
		   _dia_cobros2,
		   _dia_cobros3,
		   _fecha_ult_pro,
		   _pago_fijo
	  from cascliente
	 where cod_cliente = _cod_cliente
	   and cod_campana = _cod_campana;

	select nombre
	  into _ultima_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	call sp_cas012b(_cod_cliente)
	returning	_nombre,
				_direccion,
				_telefono1,
				_telefono2,
				_celular,
				_fax,
				_e_mail,
				_telefono3,
				_apartado,
				_cedula,
				_code_ciudad,
				_code_distrito,
				_code_correg,
				_code_pais,
				_code_provincia,
				_contacto,
				_fecha_aniversario,
				_cod_estafeta, _direccion_1,	   _direccion_2 ;

	if _cod_estafeta <> '' then
		select nombre
		  into _nom_estafeta
		  from cobestafeta
		 where cod_estafeta = _cod_estafeta; 
	end if

	let v_apagar = v_exigible;

	select fecha_aniversario
	  into _fecha_aniversario
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _direccion = trim(_direccion);
    let _direccion_12 = trim(_direccion_1)||' '||trim(_direccion_2);			

	if _cod_gestion is null then			
		let _cod_gestion = '';
	end if

	update cascliente 
	   set cod_cobrador = a_cobrador 
	 where cod_cliente = _cod_cliente;
	 
	 CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _msg_vip; 
	 
--   Se Señaiiza Cliente VOCEM en Pantalla Unica, RGORDON 26/7/18  
	 CALL sp_sis241 (_cod_cliente) returning _cliente_vocem, _msg_vocem; 		 
	 
	return _cod_cliente,
	       _nombre,			  
		   trim(_direccion),  
		   _telefono1,		  
		   _telefono2,		  
		   _celular,		  
		   _fax,			  
		   _e_mail,			  
		   _telefono3,		  
		   _apartado,		  
		   _cedula,			  
		   _dia_cobros1,	  
		   _dia_cobros2,	  
		   "",				  
		   _code_ciudad,	  
		   _code_distrito,	  
		   _code_correg,	  
		   _code_pais,		  
		   _code_provincia,	  
		   trim(_contacto),	  
		   v_apagar,		  
		   _prioridad,		  
		   _ultima_gestion,	  
		   _fecha_aniversario,
		   _pago_fijo,
		   _cod_estafeta,
		   _nom_estafeta,_msg_vip,_cliente_vip,_direccion_12,_msg_vocem,_cliente_vocem;
end foreach

if _cod_campana = '00000' then	--Se entro solo para consulta
	return "",
		   "",
		   "",
		   "",
		   "",
		   "",
		   "",					  
		   "",					  
		   "",				  
		   "",				  
		   "",					  
		   0,			  
		   0,			  
		   "",						  
		   "",			  
		   "",			  
		   "",			  
		   "",				  
		   "",			  
		   "",			  
		   0,				  
		   0,				  
		   "",			  
		   "",		  
		   0,
		   '',
		   '','',_cliente_vip,'',_msg_vocem,_cliente_vocem;
end if


--trace off;
foreach
	select cod_cliente,
		   nuevo,
		   hora,
		   exigible,
		   corriente,
		   monto_30,
		   monto_60,
		   monto_90,
		   monto_120,
		   monto_150,
		   monto_180,
		   cod_cobrador
	  into _cod_cliente,
		   _prioridad,
		   _hora_tra,
		   v_exigible,
		   v_corriente,
		   v_monto_30,
		   v_monto_60,
		   v_monto_90,
		   v_monto_120,
		   v_monto_150,
		   v_monto_180,
		   _cod_cobrador				   				   
	  from cascliente
 	 where cod_campana = _cod_campana
	   and hora is null
	 order by procesado asc,nuevo desc ,monto_180 desc,monto_150 desc,monto_120 desc,monto_90 desc,monto_60 desc,monto_30 desc,corriente desc

	if _cod_cobrador is not null and _cod_cobrador <> a_cobrador then
		continue foreach;
	end if

	select cod_gestion,
		   dia_cobros1,
		   dia_cobros2,
		   dia_cobros3,
		   fecha_ult_pro,
		   pago_fijo
	  into _cod_gestion,
		   _dia_cobros1,
		   _dia_cobros2,
		   _dia_cobros3,
		   _fecha_ult_pro,
		   _pago_fijo
	  from cascliente
	 where cod_cliente = _cod_cliente
	   and cod_campana = _cod_campana;

	let _cantidad = sp_cas027(_cod_cliente);

	select count(*)
	  into _cnt_caspoliza
	  from caspoliza
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente;

	if _cnt_caspoliza is null then
		let _cnt_caspoliza = 0;
	end if

	if _cnt_caspoliza = 0 then
		delete from cascliente
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;

		continue foreach;
	end if

	if _fecha_ult_pro is null then
		let _fecha_ult_pro = _fecha_hoy;			
	else
		if _fecha_ult_pro > _fecha_hoy then
			let _fecha_hoy = _fecha_ult_pro;
		end if
	end if 

	update cobcobra
	   set fecha_ult_pro = _fecha_hoy
     where cod_cobrador  = a_cobrador;

	select procesado
	  into _procesado
	  from cobcadate
	 where cod_cobrador = a_cobrador
	   and fecha        = _fecha_hoy;

	if _procesado is null then
  
		select count(*)
		  into _cantidad
		  from cascliente
		 where cod_campana = _cod_campana;

		select count(*)
		  into _pendiente
		  from cascliente
		 where cod_campana = _cod_campana
		   and cod_gestion is null;

		insert into cobcadate(
				cod_cobrador,
				fecha,
				procesado,
				total,
				atendidos,
				pendientes,
				nuevos,
				atrazados)
	   values(	a_cobrador,
				_fecha_hoy,
				1,
				_cantidad,
				_cantidad - _pendiente,
				_pendiente,
				0,
				0);
	end if 

	select tipo_otrodia
      into _tipo_otrodia
      from cobcages
     where cod_gestion = _cod_gestion;

	if _tipo_otrodia = 1 then	--tipo de gestion de otro dia  "002","006","005","008"
		let _dia_actual = day(_fecha_actual);
		if _dia_actual > _dia_cobros3 Then
			let _mes_ult_pro = month(_fecha_ult_pro);

			if _mes_ult_pro >= _mes_hoy then 
				continue foreach;
			end if
		end if				
	end if

	if ((v_monto_30 + v_monto_60 + v_monto_90 + v_monto_120 + v_monto_150 + v_monto_180 + v_corriente) = 0) and _tipo_campana <> 3 then
		update cascliente 
		   set procesado	= 1,
		   	   nuevo 		= 0
		 where cod_cliente = _cod_cliente
		   and cod_campana = _cod_campana;
		continue foreach;
	end if

	select count(*)
	  into _existe
	  from cobruter1
	 where cod_pagador = _cod_cliente
	   and (dia_cobros1 = _dia_cobruter or dia_cobros2 = _dia_cobruter)
	   and cod_cobrador <> '059';

	if _existe = 1 then  --el pagador esta en el rutero
		continue foreach;
	end if

	select nombre
	  into _ultima_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	call sp_cas012b(_cod_cliente)
	returning _nombre,
			  _direccion,
			  _telefono1,
			  _telefono2,
			  _celular,
			  _fax,
			  _e_mail,
			  _telefono3,
			  _apartado,
			  _cedula,
			  _code_ciudad,
			  _code_distrito,
			  _code_correg,
			  _code_pais,
			  _code_provincia,
			  _contacto,
			  _fecha_aniversario,
			  _cod_estafeta, _direccion_1,	   _direccion_2 ;

	let v_apagar = v_exigible;
	let _direccion = trim(_direccion);

	if _cod_estafeta <> '' then
		select nombre
		  into _nom_estafeta
		  from cobestafeta
		 where cod_estafeta = _cod_estafeta; 
	end if

	if _cod_gestion is null then
		let _cod_gestion = '';
	end if

	update cascliente 
	   set cod_cobrador = a_cobrador 
	 where cod_cliente = _cod_cliente;
	 
	 CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _msg_vip; 
	 let _direccion_12 = trim(_direccion_1)||' '||trim(_direccion_2);
	 
--   Se Señaiiza Cliente VOCEM en Pantalla Unica, RGORDON 26/7/18 
	 CALL sp_sis241 (_cod_cliente) returning _cliente_vocem, _msg_vocem; 		 

	return _cod_cliente,
		   _nombre,			  
		   trim(_direccion),  
		   _telefono1,		  
		   _telefono2,		  
		   _celular,		  
		   _fax,			  
		   _e_mail,			  
		   _telefono3,		  
		   _apartado,		  
		   _cedula,			  
		   _dia_cobros1,	  
		   _dia_cobros2,	  
		   "",				  
		   _code_ciudad,	  
		   _code_distrito,	  
		   _code_correg,	  
		   _code_pais,		  
		   _code_provincia,	  
		   trim(_contacto),	  
		   v_apagar,		  
		   _prioridad,		  
		   _ultima_gestion,	  
		   _fecha_aniversario,
		   _pago_fijo,
		   _cod_estafeta,
		   _nom_estafeta,
		   _msg_vip,_cliente_vip,_direccion_12,_msg_vocem,_cliente_vocem;

end foreach

return '00000',
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   0,		   
	   0,		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   '',		   
	   0,		   
	   0,		   
	   '',		   
	   '',		   
	   0,
	   '',
	   '','',_cliente_vip,'',_msg_vocem,_cliente_vocem;	   
end procedure;