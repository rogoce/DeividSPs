-- Procedimiento que genera remesas de pagos en suspenso y la poliza fue creada
-- 
-- Creado     : 27/10/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob295;

create procedure "informix".sp_cob295()
returning char(50),
          dec(16,2),
          char(50),
          char(50),
          char(50);


define a_no_documento	char(50);
define _doc_remesa		char(50);
define _no_poliza		char(10);
define _saldo			dec(16,2);
define _cantidad		integer;

define _ramo			char(50);
define _poliza			char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_cob295.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, 0, _error_desc, "", "";
end exception

let _cantidad = 0;

foreach	
 select ramo,
        poliza,
        doc_suspenso
   into _ramo,
        _poliza,
        _doc_remesa
   from cobsuspe
  where actualizado = 1

	-- Determinar el Numero de Poliza (Poliza Ancon)

	let _no_poliza     = sp_sis21(_ramo);
	let a_no_documento = _ramo;

	if _no_poliza is null then

		let _no_poliza     = sp_sis21(_poliza);
		let a_no_documento = _poliza;

	end if

	-- Determinar el Numero de Poliza (Poliza Coaseguro)

	if _no_poliza is null then

		call sp_sis162(_ramo) returning _no_poliza, a_no_documento;

		if _no_poliza is null then

			call sp_sis162(_poliza) returning _no_poliza, a_no_documento;

			if _no_poliza is null then
				continue foreach;
			end if
		
		end if

	end if

	let _cantidad  = _cantidad + 1;
	let _saldo     = sp_cob174(a_no_documento);

	if _saldo = 0 then
		continue foreach;
	end if

	return a_no_documento,
		   _saldo,
		   _doc_remesa,
		   _poliza,
		   _ramo
		   with resume;

end foreach

end 

return "", 0, "", "", ""; 

end procedure