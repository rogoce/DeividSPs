-- Procedimiento que Genera los Recibos Automaticos para una o varias polizas. 	
-- Creado    : 15/11/2010 - Autor: Roman Gordon

drop procedure sp_cob255;
create procedure "informix".sp_cob255(
a_compania char(3),
a_agencia  char(3),
a_remesa   char(10),
a_renglon  smallint,
a_fecha    date)
returning	char(50),   -- nombre del asegurado
			varchar(150),   -- e-mail
			char(10);   -- cod_cliente

define _nombre_cliente		char(50);
define _tarjeta				char(50);
define _email_contratante	char(50);
define _email				varchar(150);
define _movimiento			char(30); 
define _documento			char(30);
define _cod_contratante		char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _cod_ramo			char(3);
define _monto_descontado	dec(16,2);
define _monto_efectivo		dec(16,2);
define _monto_renglon		dec(16,2);
define _monto_chequeo		dec(16,2);
define _monto_tarjeta		dec(16,2);
define _monto_cheque		dec(16,2);
define _prima_bruta			dec(16,2);
define _monto_clave			dec(16,2);
define _monto_pago			dec(16,2);
define _monto_visa			dec(16,2);
define _calculo				dec(16,2);
define _importe				dec(16,2);
define _cambio				dec(16,2);
define _saldo				dec(16,2);
define _tipo_tarjeta		smallint;
define _tipo_pago			smallint;
define _ramo_sis			smallint;
define _renglon				smallint;
define _no_cheque			integer;
define _fecha_cubierta		date; 
define _vigencia_final		date;


set isolation to dirty read;
--set debug file to "sp_cob255.trc";

let _tarjeta        = "";
let _no_cheque 		= "";
let _monto_cheque   = 0.00;
let _monto_visa     = 0.00;
let _monto_clave    = 0.00;
let _monto_tarjeta  = 0.00;
let _monto_efectivo = 0.00;
let _cambio 		= 0.00;


-- Remesa
 Select monto_chequeo
   Into	_monto_chequeo
   From cobremae
  Where	no_remesa = a_remesa;

-- Forma de pago de los recibos
foreach
	select tipo_pago,
		   renglon,
		   tipo_tarjeta
	  into _tipo_pago,
		   _renglon,
		   _tipo_tarjeta
	  from cobrepag
	 where no_remesa = a_remesa
	   and renglon = a_renglon

	--Efectivo
	select sum (importe)
	  into _monto_efectivo
	  from cobrepag
	 where no_remesa = a_remesa
	   and renglon	= a_renglon
	   and tipo_pago = 1;

   --Clave
	select sum(importe)
	  into _monto_clave
	  from cobrepag
	 where no_remesa = a_remesa
	   and renglon = a_renglon
	   and tipo_pago = 3;
	
	if _monto_clave is null then
		let _monto_clave = 0.00;
	end if
    
	if _monto_clave <> 0.00 then
	   let _tarjeta = 'Clave';	
	end if

   --Tarjeta de Credito
	select sum(importe)
	  into _monto_visa
	  from cobrepag
	 where no_remesa = a_remesa
	   and renglon = a_renglon
	   and tipo_pago = 4;
 	 
 	if _monto_visa is null then
		let _monto_visa = 0.00;
	end if

	let _monto_tarjeta= _monto_visa + _monto_clave;

	if _tarjeta = "" then
		if _tipo_tarjeta = 1 then
			let _tarjeta = "Visa";
		elif _tipo_tarjeta = 2 then
			let _tarjeta = "MasterCard";
		elif _tipo_tarjeta = 3 then
			let _tarjeta = "Dinners Club";
		elif _tipo_tarjeta = 4 then
			let _tarjeta = "American Express";
		end if
	else
		if _tipo_tarjeta = 1 then
			let _tarjeta = trim(_tarjeta) ||  " / Visa";
		elif _tipo_tarjeta = 2 then
			let _tarjeta = trim(_tarjeta) ||  " / MasterCard";
		elif _tipo_tarjeta = 3 then
			let _tarjeta = trim(_tarjeta) ||  " / Dinners Club";
		elif _tipo_tarjeta = 4 then
			let _tarjeta = trim(_tarjeta) ||  " / American Express";
		end if
	end if

	--Cheque
	select sum(importe)
	  into _monto_cheque
	  from cobrepag
	 where no_remesa = a_remesa
	   and renglon = a_renglon
	   and tipo_pago = 2;
   

	if _tipo_pago = 2 then
		select no_cheque
		  into _no_cheque
		  from cobrepag
		 where no_remesa = a_remesa
		   and renglon	 = a_renglon;
	end if
end foreach

-- Recibos 
foreach
	select monto,
	       no_poliza,
		   saldo,
		   renglon,
		   monto_descontado,
		   doc_remesa
	  into _monto_pago,
		   _no_poliza,
		   _saldo,
		   _renglon,
		   _monto_descontado,
		   _documento
	  from cobredet
	 where no_remesa = a_remesa
	   and renglon	= a_renglon
	   and tipo_mov <> 'B'  --recibo anulado

	let _monto_chequeo = _monto_pago;
	let _no_poliza     = sp_sis21(_documento);	
	--let _saldo         = sp_cob115b(a_compania, a_agencia, _documento, a_remesa); 
	let _saldo         = _saldo - _monto_pago;
	let _monto_renglon = _monto_pago;

	--poliza
	select vigencia_final,
		   prima_bruta,
		   cod_pagador,
		   cod_contratante,
		   cod_ramo
   	  into _vigencia_final,
		   _prima_bruta,
		   _cod_cliente,
		   _cod_contratante,
		   _cod_ramo
   	  from emipomae
  	 where no_poliza = _no_poliza;

	select ramo_sis
	  into _ramo_sis
   	  from prdramo
  	 where cod_ramo = _cod_ramo;
	
	if a_remesa in ('1788202') then
		select uni.cod_asegurado,
			   cli.nombre,
			   'rgordon@asegurancon.com'
		  into _cod_cliente,
			   _nombre_cliente,
			   _email
		  from emipouni uni
		 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
		 where no_poliza = _no_poliza
		   and no_unidad = '00001';
	else
		--cliente
		select nombre,
			   e_mail
		  into _nombre_cliente,
			   _email
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _cod_contratante <> _cod_cliente then
			select e_mail
			  into _email_contratante
			  from cliclien
			 where cod_cliente = _cod_cliente;

			if _email_contratante is null then
				let _email_contratante = '';
			end if

			if _email <> _email_contratante then
				let _email = _email || ';' || _email_contratante;
			end if
		end if
	end if
end foreach

return _nombre_cliente,	  
	   _email,
	   _cod_cliente;
end procedure;