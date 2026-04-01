-- Registros contables de cheques
--
-- Creado	 : 17/01/2007 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_par239;

CREATE PROCEDURE "informix".sp_par239() 
RETURNING INTEGER,
   		  CHAR(50);

define _no_requis	char(10);
define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

foreach
 select no_requis
   into _no_requis
   from chqchmae
  where periodo       = "2007-01"
    and origen_cheque = 6
	and pagado        = 1
--	and no_requis     = "193942"

	delete from chqchcta
	 where no_requis = _no_requis
	   and cuenta    not like "122%";

	call sp_par238(_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

end foreach

end

commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure