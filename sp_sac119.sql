-- Procedure que elimina los presupuestos de fianzas

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac119;

create procedure sp_sac119(
a_cuenta char(25)
) returning integer,
            char(50);

define _ano			smallint;
define _ccosto		char(3);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

let _ano    = 2009;
let _ccosto = "017";

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

delete from cglpre02
 where pre2_ano    = _ano
   and pre2_ccosto <> _ccosto
   and pre2_cuenta = a_cuenta;

delete from cglpre01
 where pre1_ano    = _ano
   and pre1_ccosto <> _ccosto
   and pre1_cuenta = a_cuenta;

end 

return 0, "Actualizacion Exitosa"; 

end procedure