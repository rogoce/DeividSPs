-- Procedimiento para generar la informacion de Rechazo de Pagos ACH y TCR
--
-- Creado    : 31/05/2011 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob275;

create procedure "informix".sp_cob275(a_secuencia integer)
returning char(50), 	 --_nom_cliente
		  char(20),		 --_no_documento
		  char(200),	 --_direc_cli
		  char(10),		 --_tel_cli
		  varchar(30),	 --_no_tarjeta
		  char(7),
		  varchar(50),	 --_motivo_rechazo
		  varchar(50),	 --_banco			
		  dec(16,2),	 --_monto
		  char(50),		 --_nom_ejecutivo
		  char(50),		 --_email_ejecutivo
		  char(10),	  	 --_tel_ejecutivo
		  varchar(30),
		  varchar(50),
		  smallint;

define _direc_cli			char(200);
define _nom_cliente			char(50);
define _email				char(50);
define _nom_ejecutivo		char(30);
define _email_ejecutivo		char(30);
define _no_documento		char(20);
define _no_cuenta			char(17);
define _tel_cli				char(10);
define _tel_ejecutivo		char(10);
define _no_poliza			char(10);
define _cod_pagador			char(10);
define _user_added			char(8);
define _fecha_exp			char(7);
define _no_lote				char(6);
define _no_tarjeta_parte1	char(5);
define _no_tarjeta_parte2	char(5);
define _cod_banco			char(3);
define _cod_ramo			char(3);
define _tipo_transaccion	smallint;
define _motivo_rechazo		varchar(50);
define _banco				varchar(50);
define _ramo				varchar(50);
define _no_tarjeta			varchar(30);
define _no_tarjeta_final	varchar(30);
define _fecha_char			varchar(30);
define _no_cuenta_final		varchar(17);
define _renglon				smallint;
define _len_tarjeta			smallint;
define _len_cuenta			smallint;
define _tipo_tarjeta		smallint;
define _ano					smallint;
define _mes					smallint;
define _dia					smallint;
define _monto				dec(16,2);
define _fecha				date;
define _fecha_rechazo		date;


set isolation to dirty read;

--SET DEBUG FILE TO "sp_cob275.trc";
--TRACE ON;

{foreach
	select fecha
	  into _fecha
	  from cobtalot
	exit foreach;
end foreach 
}
foreach
	select fecha
	  into _fecha
	  from parmailcomp
	 where secuencia = a_secuencia
    exit foreach;
end foreach

--let _fecha = today;

let _ano = year(_fecha);
let _mes = month(_fecha);
let _dia = day(_fecha);

if _mes = '01' then
	let _fecha_char = _dia || ' de Enero de ' || _ano;
elif _mes = '02' then
	let _fecha_char = _dia || ' de Febrero de ' || _ano;
elif _mes = '03' then
	let _fecha_char = _dia || ' de Marzo de ' || _ano;
elif _mes = '04' then
	let _fecha_char = _dia || ' de Abril de ' || _ano;
elif _mes = '05' then
	let _fecha_char = _dia || ' de Mayo de ' || _ano;
elif _mes = '06' then
	let _fecha_char = _dia || ' de Junio de ' || _ano;
elif _mes = '07' then
	let _fecha_char = _dia || ' de Julio de ' || _ano;
elif _mes = '08' then
	let _fecha_char = _dia || ' de Agosto de ' || _ano;
elif _mes = '09' then
	let _fecha_char = _dia || ' de Septiembre de ' || _ano;
elif _mes = '10' then
	let _fecha_char = _dia || ' de Octubre de ' || _ano;
elif _mes = '11' then
	let _fecha_char = _dia || ' de Noviembre de ' || _ano;
elif _mes = '12' then
	let _fecha_char = _dia || ' de Diciembre de ' || _ano;
end if


foreach
	select no_remesa,
		   renglon,
		   no_documento,
		   asegurado,
		   fecha
	  into _user_added,
	  	   _tipo_transaccion,
		   _no_documento,
		   _no_tarjeta,
		   _fecha_rechazo
	  from parmailcomp
	 where secuencia = a_secuencia

	if _tipo_transaccion = 1 then					-----------------------Rechazo TCR
		select nombre,
			   motivo_rechazo,
			   monto
		  into _nom_cliente,
		  	   _motivo_rechazo,														   
		  	   _monto																   
		  from cobtatra												  
		 where no_documento = _no_documento									  
		   and no_tarjeta = _no_tarjeta;									  

		if _motivo_rechazo = 'CALL 18003372255"' then
			let _motivo_rechazo = 'Llamar al 337-22-55, Cuenta Bloqueada';
		elif _motivo_rechazo = 'INVALID CARD #"' then
			let _motivo_rechazo = 'Número de Tarjeta Incorrecto';
		elif _motivo_rechazo = 'Invalid Expiration Date"' or _motivo_rechazo = 'INVALID EXP DATE"' then
			let _motivo_rechazo = 'Fecha de Expiración Incorrecta';
		elif _motivo_rechazo = 'DECLINED"' then
			let _motivo_rechazo = 'Tarjeta Declinada';
		elif _motivo_rechazo = 'EXPIRED CARD"' then
			let _motivo_rechazo = 'Tarjeta Expirada';
		end if 

		call sp_sis21(_no_documento) returning _no_poliza;
		
		select cod_pagador,
			   cod_ramo
		  into _cod_pagador,
			   _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;
		
		select direccion_cob,
			   telefono1,
			   nombre
		  into _direc_cli,
			   _tel_cli,
			   _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_pagador;
			
		select cod_banco,
			   tipo_tarjeta,
			   fecha_exp
		  into _cod_banco,
			   _tipo_tarjeta,
			   _fecha_exp
		  from cobtahab
		 where no_tarjeta = _no_tarjeta;

		let _no_tarjeta = trim(_no_tarjeta);

	    if _no_tarjeta is not null then
			let _len_tarjeta = length(_no_tarjeta);
			let _no_tarjeta_parte1 = _no_tarjeta[1,5];
			let _no_tarjeta_parte2 = SUBSTR(_no_tarjeta,-5);

			if _tipo_tarjeta = 4 then
				let _no_tarjeta_final = trim(_no_tarjeta_parte1) || 'XXXXXX' || trim(_no_tarjeta_parte2);
			else
				let _no_tarjeta_final = trim(_no_tarjeta_parte1) || 'XXXX-XXXX' || trim(_no_tarjeta_parte2);	
			end if
		end if 
		
		select nombre
		  into _banco
		  from chqbanco
		 where cod_banco = _cod_banco;
		 
		select descripcion,
			   e_mail,
			   tel_directo
		  into _nom_ejecutivo,
			   _email_ejecutivo,
			   _tel_ejecutivo
		  from insuser
		 where usuario = _user_added;

		return _nom_cliente,				--char(50);				
			   _no_documento,				--char(20);				
			   _direc_cli,					--char(100);			
			   _tel_cli,					--char(10);				
			   _no_tarjeta_final,			--varchar(30);
			   _fecha_exp,			
			   _motivo_rechazo,				--varchar(50);			
			   _banco,						--varchar(50);			
			   _monto,						--dec(16,2)				
			   _nom_ejecutivo,				--char(50);				
			   _email_ejecutivo,			--char(50);				
			   _tel_ejecutivo,				--char(10);
			   _fecha_char,
			   _ramo,
			   _tipo_transaccion with resume;		--varchar(30);

	elif _tipo_transaccion = 2 then					-------------------Rechazo ACH

		select nombre_pagador,
			   motivo,
			   monto,
			   cod_pagador
		  into _nom_cliente,
		  	   _motivo_rechazo,
		  	   _monto,
			   _cod_pagador
		  from cobcutmpre
		 where no_cuenta = _no_tarjeta
		   and no_documento = _no_documento
		   and date(date_added) = _fecha_rechazo;

		let _no_cuenta = trim(_no_tarjeta);

		call sp_sis21(_no_documento) returning _no_poliza;

		if _motivo_rechazo[1,3] = 'R01' then
			let _motivo_rechazo = 'Fondos Insuficientes';
		elif _motivo_rechazo[1,3] = 'R02' then
			let _motivo_rechazo = 'Cuenta Cerrada';
		elif _motivo_rechazo[1,3] = 'R03' then
			let _motivo_rechazo = 'Cuenta no Existe';
		elif _motivo_rechazo[1,3] = 'R04' then
			let _motivo_rechazo = 'Número de Cuenta Invalido';
		elif _motivo_rechazo[1,3] = 'R09' then
			let _motivo_rechazo = 'Fondos Girados contra Producto';
		elif _motivo_rechazo[1,3] = 'R10' then
			let _motivo_rechazo = 'No Existe Autorización';
		elif _motivo_rechazo[1,3] = 'R16' then
			let _motivo_rechazo = 'Cuenta Bloqueada';
		elif _motivo_rechazo[1,3] = 'R17' then
			let _motivo_rechazo = 'Falta de Autorización';
		end if

 		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select direccion_cob,
			   telefono1,
			   nombre
		  into _direc_cli,
			   _tel_cli,
			   _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_pagador;

		let _no_cuenta = trim(_no_cuenta);

		select cod_banco
		  into _cod_banco
		  from cobcuhab
		 where no_cuenta = _no_cuenta;

		let _no_cuenta_final = 'XXXX' || substring(_no_cuenta from 5);

		select nombre
		  into _banco
		  from chqbanco
		 where cod_banco = _cod_banco;
		 
		select descripcion,
			   e_mail,
			   tel_directo
		  into _nom_ejecutivo,
			   _email_ejecutivo,
			   _tel_ejecutivo
		  from insuser
		 where usuario = _user_added;

		if _tel_ejecutivo is null then
			let _tel_ejecutivo = '210-8700';
		end if

		return _nom_cliente,				--char(50);				
			   _no_documento,				--char(20);				
			   _direc_cli,					--char(100);			
			   _tel_cli,					--char(10);				
			   _no_cuenta_final,			--varchar(30);
			   '',			
			   _motivo_rechazo,				--varchar(50);			
			   _banco,						--varchar(50);			
			   _monto,						--dec(16,2)				
			   _nom_ejecutivo,				--char(50);				
			   _email_ejecutivo,			--char(50);				
			   _tel_ejecutivo,				--char(10);
			   _fecha_char,
			   _ramo,
			   _tipo_transaccion  with resume;	--varchar(30);
		
	end if
end foreach
end procedure;