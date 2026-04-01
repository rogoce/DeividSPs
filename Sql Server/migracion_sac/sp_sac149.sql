-- Procedure que limpia los registros de mayor y auxiliar para
-- volver a pasar los datos del 2010

-- Creado    : 18/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac149;

create procedure sp_sac149() 
returning integer,
          char(100);

define _periodo		char(7);
define _fecha		date;
define _notrx		integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50); 

let _periodo = "2010-01";
let _fecha   = mdy(_periodo[6,7], 1, _periodo[1,4]);

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

--{
begin work;

update rectrmae
   set sac_asientos = 0
 where periodo     >= _periodo
   and actualizado = 1;

commit work;
--rollback work;

begin work;

foreach
 select res_notrx
   into _notrx
   from cglresumen
  where res_origen    = "REC"
    and res_fechatrx >= _fecha
  group by res_notrx
  order by res_notrx

	call sp_sac105(_notrx) returning _error, _error_desc; 	

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

end foreach

commit work;
--rollback work;
--}

{
begin work;

update endedmae
   set sac_asientos = 0
 where periodo     >= _periodo
   and actualizado = 1;

commit work;
--rollback work;

begin work;

foreach
 select res_notrx
   into _notrx
   from cglresumen
  where res_origen    = "PRO"
    and res_fechatrx >= _fecha
  group by res_notrx
  order by res_notrx

	call sp_sac105(_notrx) returning _error, _error_desc; 	

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

end foreach

commit work;
--rollback work;
--}

{
begin work;

update cobredet
   set sac_asientos = 0
 where periodo     >= _periodo
   and actualizado = 1;

commit work;
--rollback work;

begin work;

foreach
 select res_notrx
   into _notrx
   from cglresumen
  where res_origen    = "COB"
    and res_fechatrx >= _fecha
  group by res_notrx
  order by res_notrx

	call sp_sac105(_notrx) returning _error, _error_desc; 	

	if _error <> 0 then
		rollback work;
		return _error, _error_desc;
	end if

end foreach

commit work;
--rollback work;
--}

end

return 0, "Actualizacion Exitosa";

end procedure
