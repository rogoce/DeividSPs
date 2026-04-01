-- Generación de Rehabilitación de Pólizas masivo
-- Creado    : 07/02/2018 -- Román Gordón
-- execute procedure sp_sis457('DEIVID')

drop procedure sp_sis457;
create procedure sp_sis457(a_usuario char(8))
returning	smallint	as code_error,
			varchar(30)	as error_desc,
			char(5)		as endoso;

define _descripcion			varchar(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _monto_rehab			dec(16,2);
define _error				smallint;
define _error_isam			smallint;

set isolation to dirty read;
begin
on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion,'00000';
end exception

--set debug file to "sp_sis455.trc";    BG17111708  
--trace on;

let _error       = 0;
let _descripcion = 'Actualizacion Exitosa ...';

foreach
	select no_documento,
		   monto
	  into _no_documento,
		   _monto_rehab
	  from deivid_tmp:rehab_metrocredit
	 where procesado = 0

	let _no_poliza = sp_sis21(_no_documento);
	call sp_par192(_no_poliza,a_usuario,_monto_rehab) returning _error, _descripcion, _no_endoso;

	if _error <> 0 then
		call sp_par27(_no_poliza,_no_endoso);
		return _error,_descripcion,_no_endoso with resume;
	end if
	
	call sp_pro43(_no_poliza,_no_endoso) returning _error, _descripcion;

	if _error <> 0 then
		--call sp_par27(_no_poliza,_no_endoso);
		return _error,_descripcion,_no_endoso with resume;
	end if
	
	update deivid_tmp:rehab_metrocredit
	   set procesado = 1
	 where no_documento = _no_documento;

	return _error, _descripcion, _no_endoso with resume;

end foreach
end
end procedure;