-- Actualiza el campo subir_bo a todas las tablas

-- Creado    : 10/07/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A

drop procedure sp_sis97;

create procedure sp_sis97()
returning integer,
          char(50);

define _no_poliza	char(10);
define _no_endoso	char(5);
define _no_remesa	char(10);
define _no_reclamo	char(10);
define _no_tranrec	char(10);
define _tipo		smallint;
define _cod_tipo	char(3);
define _limite		integer;
define _renglon		integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _limite  = 50000;
let _renglon = 0;

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
	and subir_bo    = 0

	if _renglon > _limite then
		exit foreach;
	end if

	let _renglon = _renglon + 1;

	call sp_sis94(_no_poliza, _no_endoso) returning _error, _error_desc;  

	if _error <> 0 then
		return _error, _error_desc;
	end if

end foreach

foreach
 select no_remesa
   into _no_remesa
   from cobremae
  where actualizado = 1
	and subir_bo    = 0

	if _renglon > _limite then
		exit foreach;
	end if

	let _renglon = _renglon + 1;

	call sp_sis95(_no_remesa) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if

end foreach

foreach
 select no_reclamo,
        no_tranrec,
		cod_tipotran
   into _no_reclamo,
        _no_tranrec,
		_cod_tipo
   from rectrmae
  where actualizado = 1
	and subir_bo    = 0

	if _renglon > _limite then
		exit foreach;
	end if

	let _renglon = _renglon + 1;

	if _cod_tipo = "001" then
		let _tipo = 1;
	else
		let _tipo = 2;
	end if

	call sp_sis96(_tipo, _no_reclamo, _no_tranrec) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if

end foreach

end

return 0, "Actualizacion Exitosa, " || _renglon || " Registros Procesados ..."; 

end procedure

