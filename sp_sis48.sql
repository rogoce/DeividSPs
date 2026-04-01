-- Numero Interno de Reclamo para Workflow

-- Creado    : 10/03/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis48;

create procedure "informix".sp_sis48(
a_cod_compania	char(3)
) returning char(10);

define _no_reclamo	char(10);
define _numero		integer;
define _error     	smallint; 

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error 
	rollback work;
	let _no_reclamo = "000000";
 	RETURN _no_reclamo;         
END EXCEPTION           

select valor_parametro
  into _numero
  from parcont
 where cod_compania  = a_cod_compania
   and aplicacion    = "REC"
   and version       = "02"
   and cod_parametro = "par_reclamo";

let _numero     = _numero + 1;
let _no_reclamo = _numero;

update parcont
   set valor_parametro = _no_reclamo
 where cod_compania    = a_cod_compania
   and aplicacion      = "REC"
   and version         = "02"
   and cod_parametro   = "par_reclamo";

END 

SET ISOLATION TO DIRTY READ;

return _no_reclamo;

end procedure 
