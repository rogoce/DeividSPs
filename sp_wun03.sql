-- Procedimiento que Genera los Recibos Automaticos para una o varias polizas. 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

drop procedure sp_wun03;
create procedure sp_wun03(
a_compania char(3),
a_agencia  char(3),
a_remesa   char(10),
a_renglon  smallint,
a_fecha    date
)returning dec(16,2),  -- monto de la remesa
           char(50),   -- recibi de
		   char(30),   -- movimiento
		   char(255),  -- monto en letras
		   char(20),   -- documento
		   char(50),   -- nombre agente
		   dec(16,2),  -- saldo pendiente
		   date,       -- fecha cubierta
		   dec(16,2),  -- monto_efectivo
		   dec(16,2),  -- monto cheque
		   dec(16,2),  -- monto del pago
		   char(50),   -- nombre del asegurado
		   char(50),   -- tarjeta de credito
		   dec(16,2),  -- monto tarjeta
		   dec(16,2),  -- cambio
		   char(10),   -- no_recibo
		   int,        -- no_cheque
		   char(50),   -- nombre_banco
		   char(8),
		   dec(16,2),  -- cambio
		   dec(16,2),
		   char(50),   --e-mail
		   char(50),   --forma de pago
		   char(50),   --desc_unidad	
		   char(10),
		   char(15),
		   char(50),
		   char(10),
		   char(3),
		   smallint;

define _monto_letras		char(255);
define _descripcion			char(100);
define _desc_remesa			char(100);
define _nombre_tipoauto		char(50);
define _nombre_cliente		char(50);
define _nombre_agente		char(50);
define _nombre_modelo		char(50);
define _nombre_marca		char(50);
define _nombre_banco		char(50);
define _nombre_ramo			char(50);
define _recibi_de			char(50);
define _coaseguro			char(50); 
define _tarjeta				char(50);
define _ramo				char(50);
define _email				char(50);
define _formapag			char(50);
define _movimiento			char(30);
define _documento			char(30);
define _no_documento 		char(30);
define _no_motor			char(30);
define _color				char(15);
define _no_poliza			char(10);
define _no_poliza2     	    char(10);
define _no_reclamo			char(10);
define _no_requis			char(10);
define _cod_cliente			char(10);
define _no_recibo			char(10);
define _placa				char(10);
define _user_added			char(8);
define _cod_agente_reclamo	char(5);
define _cod_modelo			char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_unidad			char(5);
define _cod_marca			char(5);
define _cod_formapag		char(3);
define _cod_tiporamo		char(3);
define _cod_tipoauto		char(3);
define _cod_color			char(3);
define _cod_banco			char(3);
define _cod_ramo			char(3);
define _tipo_mov			char(1); 
define _tipo_agente			char(1);
define _prima_bruta			dec(16,2);
define _saldo				dec(16,2);
define _monto_pago			dec(16,2);
define _monto_descontado	dec(16,2);
define _monto_efectivo		dec(16,2);
define _monto_cobrepag		dec(16,2);
define _monto_chequeo		dec(16,2);
define _monto_renglon		dec(16,2);
define _monto_tarjeta		dec(16,2);
define _monto_cheque		dec(16,2);
define _monto_clave			dec(16,2);
define _monto_visa			dec(16,2);
define _calculo				dec(16,2);
define _importe				dec(16,2);
define _cambio				dec(16,2);
define _status_poliza		smallint;
define _tipo_tarjeta		smallint;
define _tipo_pago			smallint;
define _ano_auto			smallint;
define _ramo_sis			smallint;
define _renglon				smallint;
define _fecha_cubierta		date; 
define _vigencia_final		date;
define _no_cheque			integer;
define _cnt_unidad          integer;
Define _habilitar		    smallint;


set isolation to dirty read;
--set debug file to "sp_wun03.trc";
--trace on;
let _descripcion	= "";
let _movimiento     = "";
let _tarjeta        = "";
let _monto_cheque   = 0.00;
let _monto_visa     = 0.00;
let _monto_clave    = 0.00;
let _monto_tarjeta  = 0.00;
let _monto_efectivo = 0.00;
let _cambio 		= 0.00;
let _monto_cobrepag	= 0.00;
let _nombre_banco 	= null;
let _no_cheque 		= "";
let _placa			= "";
let _color			= "";
let _habilitar      = 0;
let _cod_agente_reclamo = "";
-- Remesa
 Select monto_chequeo,
        recibi_de,
        user_added 
   Into	_monto_chequeo,
        _recibi_de,
		_user_added
   From cobremae
  Where	no_remesa = a_remesa;

-- Monto de la remesa en letras
	Let _monto_letras = sp_sis11(_monto_chequeo);

-- Forma de pago de los recibos
 Foreach
   Select tipo_pago,
          renglon,
		  tipo_tarjeta,
		  cod_banco
	 Into _tipo_pago,
	      _renglon,
		  _tipo_tarjeta,
		  _cod_banco
	 From cobrepag
	Where no_remesa = a_remesa
	  and renglon	= a_renglon

   --Efectivo
   Select sum (importe)
     Into _monto_efectivo
	 From cobrepag
	Where no_remesa = a_remesa
	  and renglon	= a_renglon
	  and tipo_pago = 1;

   --Clave
   Select Sum(importe)
	 Into _monto_clave
	 From cobrepag
	Where no_remesa = a_remesa
	  and renglon	= a_renglon
	  and tipo_pago = 3;
	
	If _monto_clave is null then
		Let _monto_clave = 0.00;
	End if
    
	If _monto_clave <> 0.00 Then
	   let _tarjeta = 'Clave';	
	End If

   --Tarjeta de Credito
   Select Sum(importe)
	 Into _monto_visa
	 From cobrepag
	Where no_remesa = a_remesa
	  and renglon	= a_renglon
	  and tipo_pago = 4;
 	 
 	If _monto_visa is null then
		Let _monto_visa = 0.00;
	End if

   Let _monto_tarjeta= _monto_visa + _monto_clave;

   If _tarjeta = "" Then
	  If _tipo_tarjeta = 1 then
    	 Let _tarjeta = "Visa";
	  Elif _tipo_tarjeta = 2 then
		 Let _tarjeta = "MasterCard";
	  Elif _tipo_tarjeta = 3 then
	 	 Let _tarjeta = "Dinners Club";
	  Elif _tipo_tarjeta = 4 then
		 Let _tarjeta = "American Express";
	  End if
   Else
	  If _tipo_tarjeta = 1 then
    	 Let _tarjeta = trim(_tarjeta) ||  " / Visa";
	  Elif _tipo_tarjeta = 2 then
		 Let _tarjeta = trim(_tarjeta) ||  " / MasterCard";
	  Elif _tipo_tarjeta = 3 then
	 	 Let _tarjeta = trim(_tarjeta) ||  " / Dinners Club";
	  Elif _tipo_tarjeta = 4 Then
		 Let _tarjeta = trim(_tarjeta) ||  " / American Express";
	  End if
   End IF

  --Cheque
   Select sum(importe)
     Into _monto_cheque
     From cobrepag
    Where no_remesa = a_remesa
	  and renglon	= a_renglon
      and tipo_pago = 2;
   

   If _tipo_pago = 2 Then
    Select no_cheque
	  Into _no_cheque
	  From cobrepag
	 Where no_remesa = a_remesa
	   and renglon	= a_renglon
	   and renglon = _renglon;

	Select nombre 
	  Into _nombre_banco
	  From chqbanco
	 Where cod_banco = _cod_banco;
   End If
	let _monto_cobrepag = _monto_cheque + _monto_tarjeta;
End Foreach

-- Recibos 
Foreach
 Select	tipo_mov,
        monto,
        no_poliza,
		saldo,
		no_reclamo,
		renglon,
		doc_remesa,
		no_recibo,
		desc_remesa,
		monto_descontado
   Into	_tipo_mov,
        _monto_pago,
		_no_poliza,
		_saldo,
		_no_reclamo,
		_renglon,
		_documento,
		_no_recibo,
		_desc_remesa,
		_monto_descontado
   From cobredet
  Where	no_remesa = a_remesa
	and renglon	= a_renglon
	and tipo_mov <> 'B'  --recibo anulado

 if _monto_cobrepag <> _monto_pago then
	let _monto_cheque = 0;
	let _monto_tarjeta = 0;
 end if

 Let _monto_chequeo = _monto_pago;
 Let _monto_letras  = sp_sis11(_monto_chequeo);
 Let _no_poliza     = sp_sis21(_documento);	
 Let _saldo         = sp_cob115d(a_compania, a_agencia, _documento, a_remesa,a_renglon); 
 Let _saldo         = _saldo - _monto_pago;
 Let _monto_renglon = _monto_pago;

{if a_remesa = '1233684' and a_renglon = 96 then	
	let _saldo = 0;
end if}
-- Poliza
 Select vigencia_final,
        prima_bruta,
		cod_pagador,
		cod_ramo,
		cod_formapag,
		cod_grupo,
		estatus_poliza
   Into _vigencia_final,
		_prima_bruta,
		_cod_cliente,
		_cod_ramo,
		_cod_formapag,
		_cod_grupo,
		_status_poliza
   From emipomae
  Where no_poliza = _no_poliza;
  
  if _no_poliza = '2838222' then --se coloca por caso 12156
	let _cod_formapag = '003';
  end If

 Select nombre
   into _formapag
   from cobforpa
  where cod_formapag = _cod_formapag;

 Select nombre,
 		ramo_sis,
		cod_tiporamo
   Into _nombre_ramo,
   		_ramo_sis,
		_cod_tiporamo
   From prdramo
  Where cod_ramo = _cod_ramo;

-- Cliente
 Select nombre,
		e_mail
   Into _nombre_cliente,
		_email
   From cliclien
  Where cod_cliente = _cod_cliente;

if _cod_grupo = '77960'  then -- Colectivo Banisi
	let _saldo = 0;
	
elif _cod_grupo = '00068' and _cod_cliente = '699702' then --Serafin Niño|
	select uni.cod_asegurado,
		   cli.nombre
	  into _cod_cliente,
		   _nombre_cliente
	  from emipouni uni
	 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
	 where no_poliza = _no_poliza
	   and no_unidad = '00001';
end if
 
 if _ramo_sis = '1' then
 	foreach
	 	Select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	Select no_motor
	  into _no_motor
	  from emiauto
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	Select cod_marca,
		   cod_modelo,
		   placa,
		   cod_color,
		   ano_auto
	  into _cod_marca,
	  	   _cod_modelo,									 
	  	   _placa,										 
	  	   _cod_color,								 
	  	   _ano_auto								 
	  from emivehic									 
	 where no_motor = _no_motor;					 
													 
	select nombre										 
  	  into _nombre_marca								 
  	  from emimarca										 
   	 where cod_marca = _cod_marca;						 

  	select nombre,
           cod_tipoauto
      into _nombre_modelo,
           _cod_tipoauto
      from emimodel
   	 where cod_modelo = _cod_modelo;

	select nombre
	  into _nombre_tipoauto
	  from emitiaut
	 where cod_tipoauto = _cod_tipoauto;
	
	select nombre
	  into _color
	  from emicolor
	 where cod_color = _cod_color;

  let _descripcion = trim(_nombre_marca) || " " || trim(_nombre_modelo) || " - " || _nombre_tipoauto || " - " ||_ano_auto; 
 
 elif _ramo_sis = '2' or _ramo_sis = '8' then
 

			foreach
				select desc_unidad
				  into _descripcion
				  from emipouni
				 where no_poliza = _no_poliza
				exit foreach;
			end foreach;
			

	
 end if
 
	select count(*)
	  into _cnt_unidad
	  from emipouni
	 where no_poliza = _no_poliza
	   and activo = 1;
	   
	if _cnt_unidad is null then
		let _cnt_unidad = 0;
	end if	   
	 
	 if _cnt_unidad > 1 then
		let _descripcion = "";  -- CASO: 32146 USER: FGARCIA 20/07/19
		let _placa		 = "";
		let _color		 = "";		
	end if
		 

-- Agente
let _tipo_agente = '';
let _cod_agente = '';
let _nombre_agente = '';

foreach
 select cod_agente
   into _cod_agente
   from cobreagt
  where no_remesa = a_remesa
    and renglon   = _renglon
  exit foreach;
end foreach

 Select nombre,
        tipo_agente
   Into _nombre_agente,
	    _tipo_agente
   From agtagent
  Where cod_agente = _cod_agente; 

 If trim(_tipo_agente) <> 'A' Then     
	Let _nombre_agente = 'OFICINA';
 End If
  
-- Tipos de Movimientos
   If _tipo_mov =  'P' then
      Let _movimiento = 'Pago de Poliza';
   elif _tipo_mov       = 'D' then
      Let _movimiento = 'Pago de Deducible';
	  Let _nombre_agente = trim(_desc_remesa);
   elif _tipo_mov       = 'S' then
      Let _movimiento = 'Pago de Salvamento';
	  Let _nombre_agente = trim(_desc_remesa);
   elif _tipo_mov       = 'R' then
      Let _movimiento = 'Pago de Recupero';	 
	  Let _nombre_agente = trim(_desc_remesa);
   elif _tipo_mov       = 'N' then
      Let _movimiento = 'Nota de Credito';	 
   elif _tipo_mov       = 'M' then
      Let _movimiento = 'Afectacion al Catalogo';	 
	  If _monto_descontado <> 0 Then
		Let _monto_renglon = 0;
	  End If
   elif _tipo_mov       = 'C' then
      Let _movimiento = 'Comision Descontada';	 
   elif _tipo_mov       = 'E' then
      Let _movimiento = 'Prima';
	  Select coaseguro,
		     ramo
		Into _coaseguro,
		     _ramo       
	    From cobsuspe
	   Where doc_suspenso = _documento;
	  If _coaseguro IS NULL Then
		Let  _coaseguro = '';
	  End If
	  If _ramo IS NULL Then
		Let  _ramo = '';
	  End If
--	  Let _nombre_agente = trim(_coaseguro)||'/'||trim(_ramo);
	  Let _nombre_agente = trim(_ramo);
   elif _tipo_mov       = 'A' then
      Let _movimiento = 'Aplicar Prima';	 
   elif _tipo_mov       = 'T' then
      Let _movimiento = 'Aplicar Reclamo';	 
   elif _tipo_mov       = 'B' then
      Let _movimiento = 'Recibo Anulado';	 
   else
      continue foreach;
   End if	   
	     
-- Validacion para el cambio 
  Select sum(importe)
    Into _importe
    From cobrepag
   Where no_remesa = a_remesa
   	 and renglon   = a_renglon;  
   
   If _importe > _monto_chequeo Then
   	Let _cambio = _importe - _monto_chequeo;
   End If

--  select cod_endomov
--    into _cod_endomov
--   where no_poliza
   
--trace  _documento;
--trace on;
let _prima_bruta    = _prima_bruta;
let _vigencia_final = _vigencia_final;

  	 
--Calculo de la Fecha Cubierta
  if _prima_bruta is not null and _prima_bruta <> 0 then
  	if _ramo_sis = 5 then
  		let _calculo = (_saldo * 30) / _prima_bruta;
	else
  		let _calculo = (_saldo * 365) / _prima_bruta;
	end if
    let _fecha_cubierta = _vigencia_final - _calculo;
	
	if month(_fecha_cubierta) = 2 then
		let _fecha_cubierta = _fecha_cubierta + 2;
	end if
  else
	let _fecha_cubierta = null;
  end if




	-- JEPEREZ #1659# Habilitar el proceso de generación de comprobantes de pago, para los tipos de Remesa COMPROBANTES, Movimientos: Pago de Deducible / Pago de Recupero / Pago de Salvamento. 
		Select count(*)
		  into _habilitar
		  from cobremae a,cobredet b
		 where b.doc_remesa = _documento
           and a.no_remesa = b.no_remesa
		   and b.no_remesa =  a_remesa
		   and b.renglon   = a_renglon
           and a.tipo_remesa in ('C')
           and b.tipo_mov in ('D','S','R');
		   
		if _habilitar > 0 then	   
			let _cod_agente_reclamo = '';
			let _nombre_agente = '';
			let _no_poliza2 = '';
			Let _nombre_cliente = trim(_desc_remesa);	
			--Let _nombre_agente = trim(_desc_remesa);			 			
			
			select no_documento ,no_poliza
			  Into _no_documento, _no_poliza2
			  from recrcmae
			 where no_reclamo = _no_reclamo;
			
			Select cod_pagador
			  Into _cod_cliente
			  From emipomae
			 Where no_poliza = _no_poliza2;			
			{
			Select nombre
			  Into _nombre_cliente
			  From cliclien
			 Where cod_cliente = _cod_cliente; 			
}
			foreach
			 	 select cod_agente
				   into _cod_agente_reclamo
				   from emipoagt
				  where no_poliza = _no_poliza2
				   exit foreach;
			end foreach	

			Select nombre
			  Into _nombre_agente
			  From agtagent
			 Where cod_agente = _cod_agente_reclamo; 
			
		end if	
	
	if _nombre_cliente is null or trim(_nombre_cliente) = '' then
		let _nombre_cliente = _recibi_de;
	end if
--trace off;
Return _monto_chequeo,	  
       _recibi_de,		  
 	   _movimiento,		  
 	   _monto_letras,	  
 	   _documento,		  
 	   _nombre_agente,	  
 	   _saldo,			  
 	   _fecha_cubierta,	  
 	   _monto_efectivo,	  
 	   _monto_cheque,	  
 	   _monto_pago,		  
 	   _nombre_cliente,	  
 	   _tarjeta,		  
 	   _monto_tarjeta,	  
	   _cambio,			  
	   _no_recibo,		  
	   _no_cheque,		  
	   _nombre_banco,	  
	   _user_added,		  
	   _monto_renglon,	  
	   _monto_descontado, 
	   _email,			  
	   _formapag,		  
	   _descripcion,	  
	   _placa,			  
	   _color,			  
	   _nombre_ramo,
	   _cod_cliente,
	   _cod_tiporamo,
	   _status_poliza		  
 	   WITH RESUME;

End Foreach

END PROCEDURE
