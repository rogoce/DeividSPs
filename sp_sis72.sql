-- Numero Interno de orden de compra o reparacion

-- Creado    : 21/12/2004 - Autor: Amado Perez Mendoza 

drop procedure sp_sis72;

create procedure "informix".sp_sis72(
a_cod_compania	char(3)
) returning char(10);

define _no_orden	char(10);
define _numero		integer;
define _error     	smallint; 

--begin work;

set isolation to dirty read;

BEGIN

ON EXCEPTION SET _error 
	rollback work;
	let _no_orden = "00000";
 	RETURN _no_orden;         
END EXCEPTION           

select valor_parametro
  into _numero
  from parcont
 where cod_compania  = a_cod_compania
   and aplicacion    = "REC"
   and version       = "02"
   and cod_parametro = "par_orden_compr";

let _numero     = _numero + 1;
LET _no_orden   = '00000';

IF _numero > 9999 THEN
	LET _no_orden = _numero;
ELIF _numero > 999 THEN
	LET _no_orden[2,5] = _numero;
ELIF _numero > 99  THEN
	LET _no_orden[3,5] = _numero;
ELIF _numero > 9  THEN
	LET _no_orden[4,5] = _numero;
ELSE
	LET _no_orden[5,5] = _numero;
END IF

--let _no_orden   = _numero;

set lock mode to wait 60;

update parcont
   set valor_parametro = _no_orden
 where cod_compania    = a_cod_compania
   and aplicacion      = "REC"
   and version         = "02"
   and cod_parametro   = "par_orden_compr";

end 

set isolation to dirty read;

--commit work;

return _no_orden;

end procedure 
