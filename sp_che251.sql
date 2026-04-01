-- Procedimiento que busca si se imprime el finiquito

-- Creado    : 29/03/2011 - Autor: Amado Perez
-- Copia del sp_che67

 drop procedure sp_che251;

create procedure sp_che251(a_mail_secuencia integer)
 returning varchar(100), dec(16,2), date, char(10);

define _a_nombre_de		varchar(100);
define _no_requis		char(10);
define _no_cheque_char	char(5);
define _monto_tot		dec(16,2);
define _monto			dec(16,2);
define _no_cheque		integer;
define _fecha_sub		date;

set isolation to dirty read;

let _monto_tot = 0;
let _monto = 0;

foreach
	select no_remesa
	  into _no_requis
	  from parmailcomp
	 where mail_secuencia = a_mail_secuencia
	group by no_remesa

	select a_nombre_de,
	       monto, 
	       no_cheque
	  into _a_nombre_de,
	       _monto,
		   _no_cheque
	  from chqchmae
	 where no_requis = _no_requis;

	-- Numero de Transaccion
	let _no_cheque_char  = '00000';

	if _no_cheque > 9999 then
		let _no_cheque_char = _no_cheque;
	elif _no_cheque > 999 then
		let _no_cheque_char[2,5] = _no_cheque;
	elif _no_cheque > 99  then
		let _no_cheque_char[3,5] = _no_cheque;
	elif _no_cheque > 9  then
		let _no_cheque_char[4,5] = _no_cheque;
	else
		let _no_cheque_char[5,5] = _no_cheque;
	end if

    select fecha_sub
	  into _fecha_sub
	  from chqachma
	 where no_ach = _no_cheque_char;

    let _fecha_sub = _fecha_sub + 1 units day;

    if _monto is null then
		let _monto = 0;
    end if

    let _monto_tot = _monto_tot + _monto;
end foreach

return _a_nombre_de, 
       _monto_tot, 
	   _fecha_sub, 
	   _no_requis;
end procedure
