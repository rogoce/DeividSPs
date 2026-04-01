-- Procedimiento que genera el cambio de plan de pagos (proceso de nueva ley de seguros)
-- 
-- Creado     : 13/05/2013 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis406;

create procedure sp_sis406(a_no_poliza char(10), a_no_endoso char(10))
returning integer,
          char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _descripcion		char(50);
define _periodo_ren     CHAR(7);
define _periodo_end     CHAR(7);
define _coboutleg, _gen_endcan SMALLINT;
define _nueva_renov     CHAR(1);
define _no_documento    char(20);  


--set debug file to "sp_cob253.trc";

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

select nueva_renov,
       periodo,
	   no_documento
  into _nueva_renov,
       _periodo_ren,
	   _no_documento
  from emipomae
 where no_poliza   = a_no_poliza
   and actualizado = 1;

select periodo
  into _periodo_end
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _nueva_renov = 'R' then --Si esta renovada

	if _periodo_end < _periodo_ren then	  --Si el periodo de la cancelacion es menor al periodo de la renovacion, poner el periodo de la renovacion
		update endedmae
		   set periodo   = _periodo_ren
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;

	end if
end if
--Colocar estatus de cancelada a la poliza en chqcomsa - 13/04/2015
update chqcomsa
   set estatus = '2'
 where no_documento = _no_documento;

end

RETURN 0, "";

end procedure