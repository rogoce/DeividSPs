-- Actualizacion de la morosidad a la tabla emipoliza
-- Creado: 05/10/2010 - Autor: Armando Moreno
-- Modificado: 15/09/2011 - Autor: Roman Gordón	--Se puso en comentario el llamado al procedure sp_sis36 por diferencias en la morosidad entre deivid y la pagina web.
-- Modificado: 15/10/2014 - Autor: Román Gordón	--Actualizar los campos de morosidad para la tabla avisocanc.

drop procedure sp_par307_test;
create procedure sp_par307_test()
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
	rollback work;
 	return _error, _descripcion;
end exception


set isolation to dirty read;

--set debug file to "sp_par307.trc";
--trace on;

let _error       = 0;
let _descripcion = 'actualizacion exitosa ...';

let _fecha = current -1 units day;

if month(_fecha) < 10 then
	let _mes_char = '0'|| month(_fecha);
else
	let _mes_char = month(_fecha);
end if

let _ano_char = year(_fecha);
let _periodo  = _ano_char || "-" || _mes_char;

--Traer el ultimo día del periodo.
--let _fecha = sp_sis36(_periodo);

drop table if exists temipoliza;
select *
  from emipoliza
 where saldo <> 0
  into temp temipoliza;

foreach with hold
	select no_documento
	  into _no_documento
	  from temipoliza

	begin work;

   	let _valor1 = '001';
	let _valor2 = '002';
	let _valor3 = '003';
	let _valor4 = '004';
	let _valor5 = '005';
	let _valor6 = '006';
	let _valor7 = '007';

   	call sp_cob245b("001","001",_no_documento, _periodo,_fecha)
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

	
	--CALL sp_cob262(_no_documento) RETURNING _cod_pagos; --Se modifico la forma de calcular la cantidad de pagos hechos a una poliza, ahora saca el codigo directo con el procedure sp_cob262

	update temipoliza
	   set exigible   		  =	_exigible,
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
		   cod_monto_180	  =	_valor7
	 where no_documento   	  = _no_documento;

	commit work;
end foreach

return _error, _descripcion  with resume;
end
end procedure;