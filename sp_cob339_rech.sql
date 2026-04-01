-- Procedimiento que determina los días pendientes por procesar para T
-- Creado    : 21/01/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob339_rech;
create procedure "informix".sp_cob339_rech(a_no_remesa char(10)) 
returning	smallint,
			char(100);
			
define _motivo_rechazo	varchar(50);
define _error_desc		char(100);
define _nombre			char(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _fecha_exp		char(7);
define _cod_banco		char(3);
define _tipo_tarjeta	char(1);
define _modificado		char(1);
define _monto			dec(16,2);
define _cargo_especial	dec(16,2);
define _dia_especial	smallint;
define _cnt_existe		smallint;
define _excepcion		smallint;
define _rechazada		smallint;
define _cnt_cobtacre	smallint;
define _dia				smallint;
define _error_code		integer;
define _error_isam		integer;
define _fecha_inicio	date;
define _fecha_hasta		date;

set isolation to dirty read;

--set debug file to "sp_cob339.trc";
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
 	return _error_code,_error_desc;
end exception



foreach
	select no_tarjeta,
		   no_documento,
		   motivo_rechazo
	  into _no_tarjeta,
		   _no_documento,
		   _motivo_rechazo
	  from cobtatra
	 --where procesar = 0
	
	select count(*)
	  into _cnt_existe
	  from cobredet
	 where no_remesa = a_no_remesa
	   and doc_remesa = _no_documento;
	
	if _cnt_existe is null then
		let _cnt_existe = 0;
	end if
		
	if _cnt_existe = 0 then
		continue foreach;
	end if

	update cobtahab
	   set rechazada  = 0
	 where no_tarjeta = _no_tarjeta;

	update cobtacre
	   set rechazada = 0
	 where no_documento = _no_documento;
	
	update cobtatra
	   set procesar = 1,
	       motivo_rechazo = null
	 where no_documento = _no_documento;
end foreach

return 0,'Carga Exitosa';
end
end procedure
