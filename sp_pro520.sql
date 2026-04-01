-- Procedimiento que genera el cambio de plan de pagos (proceso de nueva ley de seguros)
-- 
-- Creado     : 08/01/2013 - Autor: Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro520;

create procedure sp_pro520(
a_no_poliza		char(10)
) returning integer,
            char(50);

define _error_desc	char(50);
define _descripcion	char(50);
define _no_doc		CHAR(20);   
define _gen_endcan	SMALLINT;  
define _coboutleg	SMALLINT;  
define _estatus_p	SMALLINT;  
define _error_isam	integer;
define _error		integer;


--set debug file to "sp_pro520.trc";

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

select no_documento,
	   estatus_poliza
  into _no_doc,
	   _estatus_p
  from emipomae
 where no_poliza = a_no_poliza;

select count(*) 
  into _coboutleg 
  from coboutleg
 where no_documento = _no_doc;

if _coboutleg > 0 then
	select gen_endcan
	  into _gen_endcan
	  from coboutleg
	 where no_documento = _no_doc;
	 
	if _estatus_p in (2,4) and _gen_endcan = 1 then --esta vigencia ya esta cancelada
		let _descripcion = 'La poliza Ya esta cancelada, por favor verifique...';
		return 1, _descripcion;
	end if 
else
	-- armando, para que no cancelen la misma vigencia varias veces. 02/11/2010
	if _estatus_p in (2,4) then --esta vigencia ya esta cancelada
		let _descripcion = 'La poliza Ya esta cancelada, por favor verifique...';
		return 1, _descripcion;
	end if 
end if

end

return 0, "";

end procedure 