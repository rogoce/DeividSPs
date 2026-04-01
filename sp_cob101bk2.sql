-- Procedimiento que trae los clientes para programa Call Center		Modificaciones de Cobros por Campana
																 
-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob101bk2;

create procedure sp_cob101bk2(
a_compania 		CHAR(3),
a_agencia  		CHAR(3),
a_cobrador 		CHAR(3),
a_cod_cliente	CHAR(10) DEFAULT "*",
a_no_documento	CHAR(20) DEFAULT "*")
returning char(10),		--cod_cliente,	  --1
       	  char(100),	--_nombre,		  --2
	      varchar(100),	--_direccion,	  --3
	      char(10),		--_telefono1,	  --4
	      char(10),		--_telefono2,	  --5
	      char(10),		--_celular,		  --6
	      char(10),		--_fax,			  --7
	      char(50),		--_e_mail,		  --8
	      char(10),		--_telefono3,	  --9
	      char(20),		--_apartado,	  --10
	      char(30),		--_cedula		  --11
		  smallint,		-- dia1			  --12
		  smallint,		-- dia2			  --13
		  char(3),		-- cod_gestion	  --14
		  char(2),		-- ciudad		  --15
		  char(2),		-- distrito		  --16
		  char(5),		-- area			  --17
		  char(3),		-- pais			  --18
		  char(2),		-- prov			  --19
		  varchar(50),	-- contacto		  --20
		  dec(16,2),	-- a pagar			  21
		  smallint,		-- prioridad		  22
		  char(50),		-- ultima gestion	  23
		  date,			-- fecha aniversario  24
		  smallint;		-- pago fijo		  25

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
DEFINE v_monto_120		DEC(16,2);
DEFINE v_monto_150		DEC(16,2);
DEFINE v_monto_180		DEC(16,2);
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
define _modo_callcenter char(1);
define _cod_campana		char(10);

set debug file to "sp_cob101bk3.trc";
trace on;

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

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

select modo_callcenter
  into _modo_callcenter
  from parparam
 where cod_compania = '001';

select tipo_cobrador,
       fecha_ult_pro,
	   cod_campana
  into _tipo_cobrador,
       _fecha_ult_pro,
	   _cod_campana
  from cobcobra
 where cod_cobrador = a_cobrador;

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

		{ select	cod_cliente,
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
		  where	cod_cliente = a_cod_cliente;

		 if _cod_cliente is null then  --pagador no esta en el call center

			 let _li_return = sp_cas027(a_cod_cliente); --insertar cascliente y caspoliza

		 else

			if a_no_documento <> "*" then	--inserta poliza a un pagador existente
				let _li_return = sp_cas027(a_cod_cliente, a_no_documento); --insertar cascliente y caspoliza
			end if

		 end if		}

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
		  where	cod_cliente = a_cod_cliente;
		    --and cod_campana = _cod_campana;

		 let v_apagar = 0;

		-- if _cod_cliente is not null then

			 select nombre
			   into _ultima_gestion
			   from cobcages
			  where cod_gestion = _cod_gestion;

			 	foreach
				 select	no_documento
				   into	v_documento
				   from	emipomae
				  where	cod_pagador = a_cod_cliente

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
							    v_saldo
							    ;
			
					let v_apagar = v_apagar + v_exigible;

				end foreach

				let _direccion = trim(_direccion);

				{select count(*)
				  into _cantidad
				  from cobcapen
				 where cod_cliente = a_cod_cliente;

				if _cantidad = 0 then
					insert into cobcapen(cod_cliente, hora, cod_cobrador, nuevo, dia)
					values (a_cod_cliente, null, a_cobrador, 1, _dia_cobros1);
				end if}
	 {	 else
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
		 end if	 }

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
		   and cod_campana  = _cod_campana
		   and hora         <= _hora_hoy
		   and hora         is not null
		 order by nuevo, hora 

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

				if v_apagar <= 0.00 then

					delete from cobcapen
					 where cod_cliente = _cod_cliente;

			 		continue foreach;
				end if

			 select fecha_aniversario
			   into _fecha_aniversario
			   from cliclien
			  where cod_cliente = _cod_cliente;

			let _direccion = trim(_direccion);

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
				   monto_180
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
				   v_monto_180				   				   
  			  from cascliente
 			 where cod_campana = _cod_campana
			   and hora is null
			 order by procesado asc,cod_pagos,monto_180 desc,monto_150 desc,monto_120 desc,monto_90 desc,monto_60 desc,monto_30 desc,corriente desc

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
			 where cod_pagador = _cod_cliente;

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
end procedure
