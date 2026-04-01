-- insercion a tabla temporal de la poliza pronto pago para luego al actualizar la remesa,
-- mandar a crear el endoso de pronto pago.

-- creado    :11/01/2012 - autor: Armando Moreno

drop procedure sp_cob50c;

create procedure "informix".sp_cob50c(a_no_documento char(20),a_user char(8))
returning	smallint,char(100);

define _fecha1			date;
define _error			integer;
define _error_isam		integer;
define _cont			smallint;
define _error_desc		char(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _no_pagos        integer;
define _letra           dec(16,2);
define _prima_bruta     dec(16,2);
define _vigencia_inic   date;									 

on exception set _error, _error_isam, _error_desc
	return _error,_error_desc;
end exception


set isolation to dirty read;
begin

--SET DEBUG FILE TO "sp_cob50c.trc"; 
--TRACE ON;

let _fecha1 = today;
	
let _letra  = 0;
--let _no_poliza = sp_sis21(a_no_documento);

foreach
	 select	no_poliza,
			vigencia_inic
	   into	_no_poliza,
			_vigencia_inic
	   from	emipomae
	  where no_documento       = a_no_documento
		and actualizado        = 1
	  order by vigencia_final desc
		if _vigencia_inic <= _fecha1 then
			exit foreach;
		end if
end foreach

Select prima_bruta
  into _prima_bruta
  from emipomae
 where no_poliza = _no_poliza;

select count(*)
  into _cont
  from cobpronde
 where no_poliza = _no_poliza;

if _cont is null then
	let _cont = 0;
end if 
if _cont = 0 then

	let _letra = _prima_bruta * 0.05;

	insert into cobpronde(no_poliza,no_documento,prima_bruta,monto_descuento,fecha,procesado,user_added)
	values (_no_poliza,a_no_documento,_prima_bruta,_letra,_fecha1,0,a_user);

end if


return 0,"Actualizacion exitosa";	
end
end procedure 
