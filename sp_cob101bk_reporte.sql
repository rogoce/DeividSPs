-- Procedimiento que trae los clientes para programa Call Center		Modificaciones de Cobros por Campana
																 
-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob101_reporte;

create procedure sp_cob101_reporte(a_compania char(3),a_agencia char(3),a_cod_campana char(10))
returning char(10),		--cod_cliente,			 1
       	  char(100),	--_nombre,				 2
	      varchar(100),	--_direccion,			 3
	      char(10),		--_telefono1,			 4
	      char(10),		--_telefono2,			 5
	      char(10),		--_celular,				 6
	      char(10),		--_fax,					 7
	      char(50),		--_e_mail,				 8
	      char(10),		--_telefono3,			 9
	      char(20),		--_apartado,			 10
	      char(30),		--_cedula				 11
		  smallint,		-- dia1					 12
		  smallint,		-- dia2					 13
		  char(3),		-- cod_gestion			 14
		  char(2),		-- ciudad				 15
		  char(2),		-- distrito				 16
		  char(5),		-- area					 17
		  char(3),		-- pais					 18
		  char(2),		-- prov					 19
		  varchar(50),	-- contacto				 20
		  dec(16,2),	-- a pagar				 21
		  smallint,		-- prioridad			 22
		  char(50),		-- ultima gestion		 23
		  date,			-- fecha aniversario	 24
		  smallint;		-- pago fijo			 25

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
define _mes_char        CHAR(2);
define _ano_char		CHAR(4);
define _periodo         CHAR(7);
define v_por_vencer     DEC(16,2);	 
define v_exigible       DEC(16,2);
define v_corriente		DEC(16,2);
define v_monto_30		DEC(16,2);
define v_monto_60		DEC(16,2);
define v_monto_90		DEC(16,2);
define v_monto_120		DEC(16,2);
define v_monto_150		DEC(16,2);
define v_monto_180		DEC(16,2);
define v_apagar			DEC(16,2);
define v_saldo			DEC(16,2);
define _cod_cobrador	CHAR(3);
define _prioridad		smallint;
define _tipo_otrodia	smallint;
define _procesado		smallint;
define _ultima_gestion	char(50);
define _cantidad		smallint;
define _existe			smallint;
define _dia_cobruter	smallint;
define _cant_proc		smallint;

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
define _modo_callcenter char(1);
define _cod_campana		char(10);

--set debug file to "sp_cob101bk3.trc";
--trace on;

set isolation to dirty read;

let _cod_cobrador 	= '';
let _fecha_hoy    	= today;
let _fecha_actual 	= today;
let _hora_hoy 	  	= current;
let _cod_gestion  	= '';
let _pago_fijo	  	= 0;
let	_dia_cobros1  	= 0;
let	_dia_cobros2  	= 0;
let _pago_fijo	  	= 0;
let _dia_cobruter	= day(_fecha_hoy);
let _cod_campana	= a_cod_campana;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

-- Consulta

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
	 order by procesado asc,monto_180 desc,monto_150 desc,monto_120 desc,monto_90 desc,monto_60 desc,monto_30 desc,corriente desc

	if _cod_cobrador is not null and _cod_cobrador <> a_cobrador then
		continue foreach;
	end if

	select count(*)
	  into _cnt_caspoliza
	  from caspoliza
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente;

	if _cnt_caspoliza = 0 then
		continue foreach;
	end if
		
	select cod_gestion,
		   dia_cobros3,
		   pago_fijo
	  into _cod_gestion_cascliente,
		   _dia3,
		   _pago_fijo
	  from cascliente
	 where cod_cliente = _cod_cliente
	   and cod_campana = _cod_campana;

	select tipo_otrodia
	  into _tipo_otrodia
	  from cobcages
	 where cod_gestion = _cod_gestion_cascliente;

	if _tipo_otrodia = 1 then	--tipo de gestion de otro dia  "002","006","005","008"
		let _dia_actual = day(_fecha_actual);
		if _dia_actual = _dia3 Then
		else
			continue foreach;
		end if				
	end if	 

	if v_monto_30 = 0 and v_monto_60 = 0 AND v_monto_90 = 0 and v_monto_120 = 0 and v_monto_150 = 0 and v_monto_180 = 0 and v_corriente = 0 then
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

	 select	cod_gestion,
			dia_cobros1,
			dia_cobros2,
			dia_cobros3,
			fecha_ult_pro,
			pago_fijo
	   into	_cod_gestion,
			_dia_cobros1,
			_dia_cobros2,
			_dia_cobros3,
			_fecha_ult_pro,
			_pago_fijo
	   from	cascliente
	  where	cod_cliente = _cod_cliente
	    and cod_campana = _cod_campana;

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
			   _pago_fijo with resume;		  
	end foreach	 	 
end procedure