-- Procedimiento que busca si se imprime el finiquito

-- Creado    : 29/03/2011 - Autor: Amado Perez
-- Copia del sp_che67

 drop procedure sp_cob328;

create procedure sp_cob328(a_mail_secuencia integer)
 returning varchar(100), dec(16,2), varchar(50), varchar(20);

define _no_devleg   char(10);
define _no_requis   char(10);
define _monto_tot   dec(16,2);
define _monto       dec(16,2);
define _a_nombre_de	varchar(100);
define _tipo_requis char(1);
define _descrip     varchar(50);
define _no_documento varchar(20);

SET ISOLATION TO DIRTY READ;

let _monto = 0;
let _monto_tot = 0;

foreach
	select no_remesa
	  into _no_devleg
	  from parmailcomp
	 where mail_secuencia = a_mail_secuencia

    select no_requis, 
	       no_documento
	  into _no_requis,
	       _no_documento
	  from cobdevleg
	 where no_devleg = _no_devleg;

	select a_nombre_de,
	       monto,
		   tipo_requis
	  into _a_nombre_de,
	       _monto,
		   _tipo_requis
	  from chqchmae
	 where no_requis = _no_requis;

    if _monto is null then
		let _monto = 0;
    end if

    let _monto_tot = _monto_tot + _monto;

    if _tipo_requis = "A" then
    	let _descrip = "SE LE HA ACREDITADO A SU CUENTA";
	else
    	let _descrip = "SE LE HA CONFECCIONADO UN CHEQUE";
	end if
end foreach

return _a_nombre_de, _monto_tot, trim(_descrip), trim(_no_documento);

end procedure
