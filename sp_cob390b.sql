-- Carga de cobanula de Pólizas que no fueron anuladas luego de la transición del proceso de anulación
-- Creado    : 05/12/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_cob390b() 


drop procedure sp_cob390b;
create procedure sp_cob390b() 
returning	smallint,
			varchar(100);

define _error_desc			varchar(100);
define _no_documento		char(18);
define _cod_cliente			char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _cod_gestion			char(3);
define _estatus_poliza		char(1);
define _error_code			integer;
define _error_isam			integer;
define _renglon				integer;

set isolation to dirty read;

--set debug file to 'sp_cob390b.trc';
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc;
end exception

foreach
	select c.cod_campana,
		   c.cod_cliente,
		   c.no_documento
	  into _cod_campana,
		   _cod_cliente,
		   _no_documento
	  from caspoliza c
	 where cod_campana in (select cod_campana from cascampana where tipo_campana = 3)

	call sp_pro545(_no_documento) returning _error_code, _error_desc;
	call sp_cob346a(_no_documento) returning _error_code,_error_desc;
end foreach

return 0,'Proceso Exitoso';

end
end procedure;