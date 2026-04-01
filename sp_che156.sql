-- Procedimiento que busca si se imprime el finiquito

-- Creado    : 29/03/2011 - Autor: Amado Perez
-- Copia del sp_che67

 drop procedure sp_che156;

create procedure sp_che156(a_mail_secuencia integer)
 returning varchar(100), dec(16,2), char(10);

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

	select a_nombre_de,
	       monto, 
	       no_cheque
	  into _a_nombre_de,
	       _monto,
		   _no_cheque
	  from chqchmae
	 where no_requis = _no_requis;

 
    if _monto is null then
		let _monto = 0;
    end if

	return _a_nombre_de, _monto, _no_requis with resume;	
 --   let _monto_tot = _monto_tot + _monto;
end foreach

--return _a_nombre_de, _monto, _no_requis;
end procedure
