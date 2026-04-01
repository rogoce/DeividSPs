-- Numero Interno de atencion

-- Creado    : 21/12/2004 - Autor: Amado Perez Mendoza 

--drop procedure sp_sis75;

create procedure "informix".sp_sis75(
a_cod_compania	char(3)
) returning char(10);

define _no_orden	char(10);
define _numero		integer;
define _error     	smallint; 

--begin work;

BEGIN

ON EXCEPTION SET _error 
	rollback work;
	let _no_orden = "000000";
 	RETURN _no_orden;         
END EXCEPTION           

select valor_parametro
  into _numero
  from parcont
 where cod_compania  = a_cod_compania
   and aplicacion    = "REC"
   and version       = "02"
   and cod_parametro = "par_atencion";

let _numero     = _numero + 1;
LET _no_orden   = '000000';

IF _numero > 99999 THEN
	LET _no_orden = _numero;
ELIF _numero > 9999 THEN
	LET _no_orden[2,6] = _numero;
ELIF _numero > 999 THEN
	LET _no_orden[3,6] = _numero;
ELIF _numero > 99  THEN
	LET _no_orden[4,6] = _numero;
ELIF _numero > 9  THEN
	LET _no_orden[5,6] = _numero;
ELSE
	LET _no_orden[6,6] = _numero;
END IF

--let _no_orden   = _numero;

update parcont
   set valor_parametro = _no_orden
 where cod_compania    = a_cod_compania
   and aplicacion      = "REC"
   and version         = "02"
   and cod_parametro   = "par_atencion";

end 

--commit work;

return _no_orden;

end procedure 
