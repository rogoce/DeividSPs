-- Procedimiento que trae los resumenes

-- Creado    : 4/04/2003 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cob107;

create procedure sp_cob107(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_cobrador CHAR(3),
a_dia INT
)
returning int,
          int,
          int;

define _cte_total int;

set isolation to dirty read;

 select	count(*)
   into _cte_total
   from	cascliente
--  where	cod_cobrador = a_cobrador
    where (dia_cobros1  = a_dia
       or  dia_cobros2  = a_dia);



return _cte_total,
	   0,
	   0;
end procedure;
