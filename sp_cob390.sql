-- Carga de cobanula de Pólizas que no fueron anuladas luego de la transición del proceso de anulación
-- Creado    : 05/12/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob390;
create procedure 'informix'.sp_cob390() 
returning	smallint,
			varchar(100);

define _error_desc			varchar(100);
define _no_documento		char(18);
define _cod_cliente			char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _cod_gestion			char(3);
define _estatus_poliza		char(1);
define _cnt_anula			smallint;
define _error_code			integer;
define _error_isam			integer;
define _renglon				integer;

set isolation to dirty read;

--set debug file to 'sp_cob390.trc';
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc;
end exception

foreach
	select c.cod_campana,
		   c.cod_cliente,
		   g.cod_gestion,
		   c.no_documento
	  into _cod_campana,
		   _cod_cliente,
		   _cod_gestion,
		   _no_documento
	  from caspoliza c, cobgesti g
	 where c.no_documento = g.no_documento
	   and cod_campana in (select cod_campana from cascampana where tipo_campana = 3)
	   and g.cod_gestion in (select cod_gestion from cobcages where tipo_accion = 12)
	   and c.no_documento not in (select c.no_documento
									from caspoliza c, cobgesti g, emipomae e
								   where c.no_documento = g.no_documento
								     and e.no_documento = c.no_documento
									 and e.estatus_poliza in (4,2)
									 and cod_campana in (select cod_campana from cascampana where tipo_campana = 3)
									 and g.cod_gestion in (select cod_gestion from cobcages where tipo_accion = 12))

	let _no_poliza = sp_sis21(_no_documento);

	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza in (2,4) then
		continue foreach;
	end if
	
	select nvl(count(*),0)
	  into _cnt_anula
	  from cobanula
	 where no_documento = _no_documento;

	if _cnt_anula = 0 then
		insert into cobanula(
				cod_campana,
				cod_cliente,
				cod_gestion,
				no_documento,
				date_added)
		values(	_cod_campana,
				_cod_cliente,
				_cod_gestion,
				_no_documento,
				current + 2 units day);

		return 1,'Inserción Cobanula' with resume;
	end if
end foreach

return 0,'Proceso Exitoso';

end
end procedure;