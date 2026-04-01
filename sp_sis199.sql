-- eliminar la informacion de la tarjeta de credito cuando se realiza
-- el cambio de plan de pago a una forma que no es tarjeta

-- creado    : 30/04/2001 - autor: demetrio hurtado almanza 
-- modificado: 30/04/2001 - autor: demetrio hurtado almanza
-- modificado: 10/02/2006 - autor: armando moreno. que no adicione el endoso descriptivo por orden del depto de cobros.

-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis199;

create procedure "informix".sp_sis199(
a_tipo			char(3),
a_no_tarjeta	char(19),
a_no_documento	char(21))

returning	integer,
			varchar(100); 

define _error_desc		varchar(100);
define _mail_secuencia	integer;
define _error_isam		integer;
define _error			integer;
define _vigencia_final	date;
define _vigencia_inic	date;
define _fecha_1_pago	date;

--set debug file to "sp_sis199.trc"; 
--trace on;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc;
end exception

let _mail_secuencia = 0;

if a_tipo = 'TCR' then
	foreach
		select mail_secuencia
		  into _secuencia
		  from parmailcomp
		 where asegurado = a_no_tarjeta
		   and no_documento = a_no_documento

		delete from parmailsend
		 where secuencia = _mail_secuencia;
	end foreach

	delete from parmailcomp
	 where asegurado = a_no_tarjeta
	   and no_documento = a_no_documento;
end if

end
end procedure;