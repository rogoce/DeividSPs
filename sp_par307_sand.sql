-- Actualizacion de la morosidad a la tabla emipoliza
-- Creado: 05/10/2010 - Autor: Armando Moreno
-- Modificado: 15/09/2011 - Autor: Roman Gordón	--Se puso en comentario el llamado al procedure sp_sis36 por diferencias en la morosidad entre deivid y la pagina web.
-- Modificado: 15/10/2014 - Autor: Román Gordón	--Actualizar los campos de morosidad para la tabla avisocanc.

drop procedure sp_par307_sand;
create procedure sp_par307_sand()
returning smallint, char(30);

define _motivo_rechazo		varchar(50);
define _descripcion  		char(30);
define _no_documento		char(20);
define _no_tarjeta			char(19);  
define _cod_pagador			char(10);
define _no_poliza			char(10);
define _fecha_exp			char(7);
define _periodo         	char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _ano_char			char(4);
define _cod_formapag		char(3);
define _cod_sucursal		char(3);
define _cod_subramo			char(3);
define _cant_pagos			char(3);
define _cod_pagos			char(3);
define _cod_zona			char(3);
define _valor1				char(3);
define _valor2				char(3);
define _valor3				char(3);
define _valor4				char(3);
define _valor5				char(3);
define _valor6				char(3);
define _valor7				char(3);		--valor: 000
define _mes_char			char(2);
define _prima_bruta			dec(16,2);
define _por_vencer  		dec(16,2);
define _corriente   		dec(16,2);
define _exigible    		dec(16,2);
define _monto_180    		dec(16,2);
define _monto_150    		dec(16,2);
define _monto_120    		dec(16,2);
define _monto_90    		dec(16,2);
define _monto_60    		dec(16,2);
define _monto_30    		dec(16,2);
define _impuesto       		dec(16,2);
define _saldo       		dec(16,2);
define _carta_aviso_canc	smallint;
define _estatus_poliza		smallint;
define _cnt_pago_fijo		smallint;
define _error_isam   		smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _cnt_gestion			smallint;
define _pago_fijo			smallint;
define _no_pagos			smallint;
define _error        		smallint;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha				date;

begin
on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception


set isolation to dirty read;

--set debug file to "sp_par307.trc";
--trace on;

let _cnt_gestion = 0;
let _pago_fijo = 0;
let _error = 0;
let _descripcion = 'actualizacion exitosa ...';

let _fecha = current;

if month(_fecha) < 10 then
	let _mes_char = '0'|| month(_fecha);
else
	let _mes_char = month(_fecha);
end if

let _ano_char = year(_fecha);
let _periodo  = _ano_char || "-" || _mes_char;

--Traer el ultimo día del periodo.
--let _fecha = sp_sis36(_periodo);

foreach with hold
	select no_documento
	  into _no_documento
	  from deivid_tmp:emipoliza_sand

	begin work;

	let _no_poliza = sp_sis21(_no_documento);

	select vigencia_inic,
	       vigencia_final,
		   cod_formapag,
		   cod_sucursal,
		   estatus_poliza,
		   cod_grupo,
		   dia_cobros1,
		   dia_cobros2,
		   cod_pagador,
		   prima_bruta,
		   carta_aviso_canc,
		   no_tarjeta,
		   no_pagos,
		   cod_subramo
	  into _vigencia_inic,
		   _vigencia_final,
		   _cod_formapag,
		   _cod_sucursal,
		   _estatus_poliza,
		   _cod_grupo,
		   _dia_cobros1,
		   _dia_cobros2,
		   _cod_pagador,
		   _prima_bruta,
		   _carta_aviso_canc,
		   _no_tarjeta,
		   _no_pagos,
		   _cod_subramo		   
	  from emipomae
	 where no_poliza = _no_poliza;

	if _no_pagos > 9 then
		let _cod_pagos = '0' || cast(_no_pagos as char(2));
	else
		let _cod_pagos = '00' || cast(_no_pagos as char(1));
	end if

	{select count(*)
	  into _cnt_gestion
	  from cobgesti
	 where no_poliza = _no_poliza;

	if _cnt_gestion = 0 then
		let _cnt_gestion = 1;
	else
		let _cnt_gestion = 0;
	end if}

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc
		exit foreach;
	end foreach

	select cod_cobrador
	  into _cod_zona
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _cod_zona is null then
		let _cod_zona = '';
	end if

	if _cod_zona = '' then
		select cod_cobrador
		  into _cod_zona
		  from agtagent
		 where cod_agente = _cod_agente;
	end if

	select fecha_exp
	  into _fecha_exp
	  from cobtahab
	 where no_tarjeta = _no_tarjeta;

	let _motivo_rechazo = '';

	{if _cod_formapag = '003' then
		foreach
			select motivo_rechazo
			  into _motivo_rechazo
			  from cobtatra
			 where no_documento = _no_documento
			 order by no_lote, renglon
		end foreach
	elif _cod_formapag = '005' then

		let _no_documento = trim(_no_documento);
		select motivo
		  into _motivo_rechazo
		  from cobcutmp
		 where no_documento = _no_documento;

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
	end if}

   	let _valor1 = '001';
	let _valor2 = '002';
	let _valor3 = '003';
	let _valor4 = '004';
	let _valor5 = '005';
	let _valor6 = '006';
	let _valor7 = '007';

   	call sp_cob245a_sand("001","001",_no_documento, _periodo,_fecha)
	returning	_por_vencer,      
				_exigible,         
				_corriente,        
				_monto_30,         
				_monto_60,         
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo;

	if _corriente = 0 then
	   let _valor1 = '000';
	end if
	if _monto_30 = 0 then
	   let _valor2 = '000';
	end if
	if _monto_60 = 0 then
	   let _valor3 = '000';
	end if
	if _monto_90 = 0 then
	   let _valor4 = '000';
	end if
	if _monto_120 = 0 then
	   let _valor5 = '000';
	end if
	if _monto_150 = 0 then
	   let _valor6 = '000';
	end if
	if _monto_180 = 0 then
	   let _valor7 = '000';
	end if

	select count(*)
	  into _cnt_pago_fijo
	  from cascliente
	 where cod_cliente	= _cod_pagador
	   and pago_fijo	= 1;

	if _cnt_pago_fijo > 1 then
		let _pago_fijo = 1;

		update cascliente
		   set pago_fijo = 1
		 where cod_cliente = _cod_pagador; 		 
	else
		let _pago_fijo = 0;
	end if

	let _cnt_pago_fijo = 0;	  

	--CALL sp_cob262(_no_documento) RETURNING _cod_pagos; --Se modifico la forma de calcular la cantidad de pagos hechos a una poliza, ahora saca el codigo directo con el procedure sp_cob262

	update deivid_tmp:emipoliza_sand
	   set vigencia_inic	  =	_vigencia_inic,
	   	   exigible   		  =	_exigible,
		   por_vencer 		  =	_por_vencer,  
		   corriente  		  =	_corriente, 
		   monto_30   		  =	_monto_30,  
		   monto_60   		  =	_monto_60,  
		   monto_90   		  =	_monto_90,
		   monto_120  		  =	_monto_120,
		   monto_150  		  =	_monto_150,
		   monto_180  		  =	_monto_180,
		   saldo 	  		  =	_saldo,
		   cod_corriente	  =	_valor1,
		   cod_monto_30 	  =	_valor2,
		   cod_monto_60 	  =	_valor3,
		   cod_monto_90 	  =	_valor4,
		   cod_monto_120	  =	_valor5,
		   cod_monto_150	  =	_valor6,
		   cod_monto_180	  =	_valor7,
		   vigencia_fin		  =	_vigencia_final,
		   cod_formapag 	  =	_cod_formapag,	
		   cod_sucursal 	  =	_cod_sucursal,	
		   cod_status		  =	_estatus_poliza,
		   cod_grupo 		  =	_cod_grupo,		
		   dia_cobros1		  =	_dia_cobros1,		
		   dia_cobros2		  =	_dia_cobros2,		
		   cod_pagador		  =	_cod_pagador,
		   cod_pagos		  = _cod_pagos,
		   prima_bruta		  = _prima_bruta,
		   carta_aviso_canc	  = _carta_aviso_canc,
		   fecha_exp		  = _fecha_exp,
		   motivo_rechazo	  = _motivo_rechazo,
		   cod_zona			  = _cod_zona,
		   cod_agente		  = _cod_agente,
		   cod_subramo		  = _cod_subramo,
		   sin_gestion		  = _cnt_gestion,
		   pago_fijo		  = _pago_fijo
	 where no_documento   	  = _no_documento;

	{update avisocanc
	   set exigible   		  =	_exigible,
		   por_vencer 		  =	_por_vencer,  
		   corriente  		  =	_corriente, 
		   dias_30   		  =	_monto_30,  
		   dias_60   		  =	_monto_60,  
		   dias_90   		  =	_monto_90,
		   dias_120  		  =	_monto_120,
		   dias_150  		  =	_monto_150,
		   dias_180  		  =	_monto_180,
		   saldo 	  		  =	_saldo
	 where no_documento = _no_documento
	   and estatus not in ('Y','Z');

	update emipomae
	   set saldo     = _saldo
	 where no_poliza = _no_poliza;}
	 
	commit work;
end foreach

return _error, _descripcion  with resume;
end
end procedure;