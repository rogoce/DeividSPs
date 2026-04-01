-- Procedimiento que trae los clientes para programa Call Center		Modificaciones de Cobros por Campana
-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob101bk3;

create procedure sp_cob101bk3(
a_compania 		char(3),
a_agencia  		char(3),
a_cobrador 		char(3),
a_cod_cliente	char(10) default "*",
a_no_documento	char(20) default "*")
returning	char(10),		--cod_cliente,		1
			char(100),		--_nombre,		2
			varchar(200),	--_direccion,		3
			char(10),		--_telefono1,		4
			char(10),		--_telefono2,		5
			char(10),		--_celular,		6
			char(10),		--_fax,			7
			char(50),		--_e_mail,			8
			char(10),		--_telefono3,		9
			char(20),		--_apartado,		10
			char(30),		--_cedula			11
			smallint,		-- dia1			12
			smallint,		-- dia2			13
			char(3),		-- cod_gestion		14
			char(2),		-- ciudad			15
			char(2),		-- distrito			16
			char(5),		-- area			17
			char(3),		-- pais			18
			char(2),		-- prov			19
			varchar(50),	-- contacto		20
			dec(16,2),		-- a pagar			21
			smallint,		-- prioridad		22
			char(50),		-- ultima gestion	23
			date,			-- fecha aniversario	24
			smallint;		-- pago fijo		25

define _direccion	    		varchar(200);
define _contacto	    		varchar(50);
define _nombre	        		char(100);
define _e_mail					char(50);
define _ultima_gestion			char(50);
define _cedula					char(30);
define _apartado				char(20);
define v_documento				char(10);
define _telefono1				char(10);
define _telefono2				char(10);
define _celular					char(10);
define _telefono3				char(10);
define _fax						char(10);
define _cod_cliente				char(10);
define _cod_campana				char(10);
define _periodo         		char(7);
define _code_correg				char(5);
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


--set debug file to "sp_cob101bk3.trc";
--trace on;

set isolation to dirty read;

let _cod_gestion_cascliente	= '';
let _cod_cobrador 			= '';
let _fecha_hoy    			= today;
let _fecha_actual 			= today;
let _hora_hoy 	  			= current;
let _cod_gestion  			= '';
let _pago_fijo	  			= 0;
let	_dia_cobros1  			= 0;
let	_dia_cobros2  			= 0;
let _pago_fijo	  			= 0;
let _dia_cobruter 			= day(_fecha_hoy);
let _mes_hoy	 			= month(_fecha_hoy);

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

	call sp_cas012(a_cod_cliente)
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
		      _fecha_aniversario;

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
		   _pago_fijo;
end if

--Campaña de Anulaciones
if _tipo_campana = 3 then
	let _flag_return = 0;

	foreach
		select distinct c.cod_cliente,
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
			   e.fecha_primer_pago,
			   e.estatus_poliza,
			   c.procesado
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
			   _cod_cobrador,
			   _fecha_primer_pago,
			   _estatus_poliza,
			   _procesado1
		  from cascliente c, caspoliza p, emipomae e
		 where c.cod_campana = p.cod_campana
		   and c.cod_cliente = p.cod_cliente
		   and e.no_documento = p.no_documento
		   and c.cod_campana = _cod_campana
		   --and hora is null
		 order by c.procesado asc,c.nuevo desc,e.fecha_primer_pago,monto_180 desc,monto_150 desc,monto_120 desc,monto_90 desc,monto_60 desc,monto_30 desc,corriente desc

		if _cod_cobrador is not null and _cod_cobrador <> a_cobrador then
			continue foreach;
		end if

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

		if _cnt_caspoliza = 0 then
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

		call sp_cas012(_cod_cliente)
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
				  _fecha_aniversario;

		let v_apagar = v_exigible;

		select fecha_aniversario
		  into _fecha_aniversario
		  from cliclien
		 where cod_cliente = _cod_cliente;

		let _direccion = trim(_direccion);

		if _cod_gestion is null then
			let _cod_gestion = '';
		end if

		update cascliente 
		   set cod_cobrador = a_cobrador 
		 where cod_cliente = _cod_cliente;

		let _flag_return = 1;

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
			   _pago_fijo;
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
			   0 ;
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
	  from cascliente
	 where cod_cobrador = a_cobrador
	   --and cod_campana  = _cod_campana
	   and hora         <= _hora_hoy
	   and hora         is not null
	 order by nuevo, hora 
	if _cod_cliente = '340898' then
		continue foreach;
	end if
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
	
	select tipo_otrodia
	  into _tipo_otrodia
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

	call sp_cas012(_cod_cliente)
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
				_fecha_aniversario;

	let v_apagar = v_exigible;

	select fecha_aniversario
	  into _fecha_aniversario
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _direccion = trim(_direccion);

	if _cod_gestion is null then			
		let _cod_gestion = '';
	end if

	update cascliente 
	   set cod_cobrador = a_cobrador 
	 where cod_cliente = _cod_cliente;
	 
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
		   _pago_fijo;		  
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
		   0;
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

	if _cnt_caspoliza = 0 then
		continue foreach;
	end if

	if _cod_cliente = '340898' then
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
			continue foreach;
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

	call sp_cas012(_cod_cliente)
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
			  _fecha_aniversario;

	let v_apagar = v_exigible;

	select fecha_aniversario
	  into _fecha_aniversario
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _direccion = trim(_direccion);

	if _cod_gestion is null then
		let _cod_gestion = '';
	end if

	update cascliente 
	   set cod_cobrador = a_cobrador 
	 where cod_cliente = _cod_cliente;

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
		   _pago_fijo;		  

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
	   0 ;		   
end procedure;