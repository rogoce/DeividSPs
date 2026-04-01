-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo061;

create procedure "informix".sp_bo061()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _enlace 		char(10);
define _cuenta		char(12);
define _recibe  	char(1);

set isolation to dirty read;

begin 
on exception set _error, _error_isam
	return _error, _error_isam || " " || trim(_error_desc);
end exception

foreach with hold
 select cta_cuenta,
        cta_enlace,
	    cta_recibe
   into _cuenta,
        _enlace,
	    _recibe
   from ef_cglcuentas

	let _error_desc = "ef_saldodet - 1";

	update ef_saldodet
       set sldet_enlace = _enlace,
           sldet_recibe = _recibe
	 where sldet_cuenta = _cuenta;
   
	commit work;
	begin work;

	let _error_desc = "ef_cglpre02 - 1";

	update sac999:ef_cglpre02
       set pre2_enlace  = _enlace,
           pre2_recibe  = _recibe
	 where pre2_cuenta  = _cuenta;

	commit work;
	begin work;

end foreach

let _error_desc = "ef_saldodet - 2";

update ef_saldodet
   set sldet_enlace = "99999999",
       sldet_recibe = "N"
 where sldet_enlace is null;

commit work;
begin work;

let _error_desc = "ef_cglpre02 - 2";

update sac999:ef_cglpre02
   set pre2_enlace  = "99999999",
       pre2_recibe  = "N"
 where pre2_enlace  is null;

commit work;
begin work;

end

return 0, "Actualizacion Exitosa";

end procedure