-- Generacion del Archivo para Banco General Especial

-- Creado    : 05/02/2018 - Autor: Román Gordón C.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob293_esp;
create procedure sp_cob293_esp()
returning smallint,
		  char(86);

define _campo			char(174);
define _nombre			char(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _id_terminal		char(15);
define _prima_neta_char	char(13);
define _impuesto_char	char(13);
define _monto_char		char(13);
define _afiliacion		char(13);
define _cod_cliente		char(10);
define _fecha_char		char(10);
define _fecha_exp		char(7);
define _no_lote_char	char(5);
define _cant_tran_char	char(5);
define _id_operador		char(3);
define _id_sucursal		char(3);
define _codigo			char(2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _monto			dec(16,2);
define _error_isam		smallint;
define _error_code		smallint;
define _cant_tran		integer;
define _valor			integer;
define _fecha			date;

--set debug file to "sp_cob203.trc";
--trace on;                                                                

begin
on exception set _error_code,_error_isam,_campo
 	return _error_code,_campo;
end exception           

-- selecciona los lotes
let _valor = 0;
let _impuesto = 0.00;
let _fecha = today;
let _codigo = '40';

{	select no_lote,
		   renglon,
		   no_tarjeta,
		   fecha_exp,
		   monto,
		   no_documento		   
	  into _no_lote_char,
		   _cant_tran,
		   _no_tarjeta,
		   _fecha_exp,
		   _monto,
		   _no_documento
	  from cobtatra
	 where no_lote = '00001'}
foreach
	select lote,
		   renglon,
		   no_tarjeta,
		   fecha_exp,
		   monto_cobrado,
		   no_documento		   
	  into _no_lote_char,
		   _cant_tran,
		   _no_tarjeta,
		   _fecha_exp,
		   _monto,
		   _no_documento
	  from red_care_cob
	 
	let _prima_neta = _monto;


	let _cant_tran_char = sp_set_codigo(5, _cant_tran);
	let _prima_neta_char = '0000000000000';
	let _impuesto_char = '0000000000000';
	let _monto_char = '0000000000000';

	if _monto > 999999999.99 then
		let _monto_char[1,13] = _monto;
	elif   _monto > 99999999.99 then
		let _monto_char[2,13] = _monto;
	elif _monto > 9999999.99 then
		let _monto_char[3,13] = _monto;
	elif _monto > 999999.99 then
		let _monto_char[4,13] = _monto;
	elif _monto > 99999.99 then
		let _monto_char[5,13] = _monto;
	elif _monto > 9999.99 then
		let _monto_char[6,13] = _monto;
	elif _monto > 999.99 then
		let _monto_char[7,13] = _monto;
	elif _monto > 99.99 then
		let _monto_char[8,13] = _monto;
	elif _monto > 9.99 then
		let _monto_char[9,13] = _monto;
	else
		let _monto_char[10,13] = _monto;
	end if

	if _prima_neta > 999999999.99 then
		let _prima_neta_char[1,13] = _prima_neta;
	elif _prima_neta > 99999999.99 then
		let _prima_neta_char[2,13] = _prima_neta;
	elif _prima_neta > 9999999.99 then
		let _prima_neta_char[3,13] = _prima_neta;
	elif _prima_neta > 999999.99 then
		let _prima_neta_char[4,13] = _prima_neta;
	elif _prima_neta > 99999.99 then
		let _prima_neta_char[5,13] = _prima_neta;
	elif _prima_neta > 9999.99 then
		let _prima_neta_char[6,13] = _prima_neta;
	elif _prima_neta > 999.99 then
		let _prima_neta_char[7,13] = _prima_neta;
	elif _prima_neta > 99.99 then
		let _prima_neta_char[8,13] = _prima_neta;
	elif _prima_neta > 9.99 then
		let _prima_neta_char[9,13] = _prima_neta;
	else
		let _prima_neta_char[10,13] = _prima_neta;
	end if

	if _impuesto > 999999999.99 then
		let _impuesto_char[1,13] = _impuesto;
	elif _impuesto > 99999999.99 then
		let _impuesto_char[2,13] = _impuesto;
	elif _impuesto > 9999999.99 then
		let _impuesto_char[3,13] = _impuesto;
	elif _impuesto > 999999.99 then
		let _impuesto_char[4,13] = _impuesto;
	elif _impuesto > 99999.99 then
		let _impuesto_char[5,13] = _impuesto;
	elif _impuesto > 9999.99 then
		let _impuesto_char[6,13] = _impuesto;
	elif _impuesto > 999.99 then
		let _impuesto_char[7,13] = _impuesto;
	elif _impuesto > 99.99 then
		let _impuesto_char[8,13] = _impuesto;
	elif _impuesto > 9.99 then
		let _impuesto_char[9,13] = _impuesto;
	else
		let _impuesto_char[10,13] = _impuesto;
	end if

	let _prima_neta_char = _prima_neta_char[1,10] || _prima_neta_char[12,13];
	let _impuesto_char = _impuesto_char[1,10] || _impuesto_char[12,13];
	let _monto_char = _monto_char[1,10] || _monto_char[12,13];

	let _campo = _no_tarjeta[1,4] || _no_tarjeta[6,9] || _no_tarjeta[11,14] || _no_tarjeta[16,19] || '   ' || _fecha_exp[1,2] || _fecha_exp[6,7] ||
				 trim(_prima_neta_char) || '      ' || _no_lote_char || _cant_tran_char || '         ' || trim(_impuesto_char) || trim(_monto_char) || '    ';

	return 0,_campo || '    ' with resume;
end foreach

return 0, 'Actualizacion Exitosa ...'; 

end
end procedure;