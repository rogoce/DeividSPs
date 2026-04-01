-- Numero Interno de cheque para Workflow

-- Creado    : 21/12/2004 - Autor: Amado Perez Mendoza 

--drop procedure sp_sis71;

create procedure "informix".sp_sis71(
a_cod_compania	char(3)
) returning char(10);

define _no_cheque	char(10);
define _numero		integer;
define _error     	smallint; 

--begin work;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
--	rollback work;
	let _no_cheque = "00000";
 	RETURN _no_cheque;         
END EXCEPTION           

select valor_parametro
  into _numero
  from parcont
 where cod_compania  = a_cod_compania
   and aplicacion    = "CHE"
   and version       = "02"
   and cod_parametro = "par_cheque";

let _numero     = _numero + 1;
let _no_cheque  = _numero;

SET LOCK MODE TO WAIT 60;

update parcont
   set valor_parametro = _no_cheque
 where cod_compania    = a_cod_compania
   and aplicacion      = "CHE"
   and version         = "02"
   and cod_parametro   = "par_cheque";

end 

--commit work;
SET ISOLATION TO DIRTY READ;


return _no_cheque;

end procedure 
