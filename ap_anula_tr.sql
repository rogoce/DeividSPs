-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure ap_anula_tr;

create procedure "informix".ap_anula_tr(a_transaccion char(10))
returning integer,char(80);

define _anular_nt		char(10);
define _transaccion     char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _user_anulo_nt   char(8);
DEFINE _fecha_anulo_nt	DATE;


define _cnt             integer;

--SET LOCK MODE TO WAIT;

--set debug file to "aa.trc";
--trace on;
set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cnt = 0;
let _anular_nt = null;
LET _fecha_anulo_nt = current;


select count(*) 
  into _cnt
  from rectrmae 
 where anular_nt = a_transaccion;
 
if _cnt is null then
	let _cnt = 0;
end if
 
if _cnt = 0 then
	return 1, 'Utilizar el proceso en Deivid';
else	
	select transaccion
	  into _transaccion
	  from rectrmae
	 where anular_nt = a_transaccion;
end if
 
select anular_nt,
       user_added
  into _anular_nt,
       _user_anulo_nt
  from rectrmae
 where transaccion = a_transaccion;  

if _anular_nt is null or trim(_anular_nt) = "" then
		UPDATE rectrmae 
		   SET pagado         = 1,
		       user_anulo     = _user_anulo_nt,
		       fecha_anulo    = _fecha_anulo_nt,
		       anular_nt      = _transaccion,
		       no_requis      = null,
		       generar_cheque = 0
		 WHERE transaccion    = a_transaccion;


    return 0, 'Actualizacion exitosa';
else
	return 1, 'Ya fue anulado con la transaccion ' || trim(_anular_nt);
end if

--end foreach
end
return 0,"";

end procedure
