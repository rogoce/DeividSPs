-- Procedimiento para generar la informacion de Rechazo de Pagos ACH y TCR
--
-- Creado    : 31/05/2011 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob275a;

create procedure "informix".sp_cob275a(a_secuencia integer)
returning char(50), 	 --_nom_cliente
		  char(20),		 --_no_documento
		  varchar(50),	 --_motivo_rechazo
		  dec(16,2),	 --_monto
		  varchar(30),	 --_tipo_tran_char
		  char(50);		 --_nom_agente

define _direc_cli			char(200);
define _nom_cliente			char(50);
define _dir2				char(50);
define _nom_agente			char(50);
define _dir1				char(30);
define _no_documento		char(20);
define _no_cuenta			char(17);
define _tel_cli				char(10);
define _cod_agente			char(5);
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
define _tipo_tran_char		varchar(30);
define _no_tarjeta			varchar(30);
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


set isolation to dirty read;

--SET DEBUG FILE TO "sp_cob275a.trc";
--TRACE ON;


foreach
	select renglon,
		   no_documento,
		   asegurado
	  into _tipo_transaccion,
		   _no_documento,
		   _no_tarjeta		   
	  from parmailcomp
	 where mail_secuencia = a_secuencia

	if _tipo_transaccion = 1 then

		let _tipo_tran_char = 'Tarjeta de Credito';  --Rechazo TCR

		 select motivo_rechazo,
		  		monto
		  into _motivo_rechazo,
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

	elif _tipo_transaccion = 2 then					-------------------Rechazo ACH
		let _tipo_tran_char = 'Transferencia ACH';
		select motivo,
			   monto
		  into _motivo_rechazo,
		  	   _monto
		  from cobcutmp
		 where no_cuenta = _no_tarjeta
		   and no_documento = _no_documento;

				
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
	end if
	
	call sp_sis21(_no_documento) returning _no_poliza;
	call sp_cob292(_no_documento) returning _cod_agente,_dir1,_dir2;

		select nombre
		  into _nom_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		select cod_pagador
		  into _cod_pagador
		  from emipomae where no_poliza = _no_poliza; 
 
		select nombre
		  into _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_pagador;
			

		return _nom_cliente,				--char(50);				
			   _no_documento,				--char(20);				
			   _motivo_rechazo,				--varchar(50);			
			   _monto,						--dec(16,2)				
			   _tipo_tran_char,				--varchar(30);
			   _nom_agente with resume;		--char(50);	     		

end foreach
end procedure 

			
