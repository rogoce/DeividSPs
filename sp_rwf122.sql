-- Procedimiento que verifica si cambia el evento de un reclamo desde el paso de digitalizacion en WF

-- Creado    : 04/04/2014 - Autor: Amado Perez  

--drop procedure sp_rwf122;

create procedure sp_rwf122(a_no_reclamo char(10), a_cod_evento CHAR(3), a_usuario varchar(20)) 
returning int, char(50) ;

define _no_poliza               CHAR(10);
define _cod_ramo                CHAR(3);
define _periodo_rec             CHAR(7);
define _no_documento			char(20);
define _cod_evento				CHAR(3);
define _cont                    int;
define _error                   int;
define _error_desc			    char(50);
define _usuario                 char(8);

--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

let _cont = 0;

begin work;

--set isolation to dirty read;

select no_poliza,
	   cod_evento 
  into _no_poliza,
	   _cod_evento
  from recrcmae
 where no_reclamo = a_no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

select count(*)
  into _cont
  from recreeve
 where cod_ramo = _cod_ramo;

if _cont = 0 Or _cod_evento = a_cod_evento then
    rollback work;
	return 0, "No necesita Cambios";
end if

update recrcmae 
   set cod_evento = a_cod_evento
 where no_reclamo = a_no_reclamo;

select usuario
  into _usuario
  from insuser
 where windows_user = trim(a_usuario);

-- Dismunir la reserva a 0

call sp_rwf120(a_no_reclamo, _usuario) returning _error, _error_desc;  

if _error <> 0 then
    rollback work;
	return _error, _error_desc;
end if

-- Aumentar la nueva reserva

call sp_rwf121(a_no_reclamo, _usuario) returning _error, _error_desc; 

if _error <> 0 then
    rollback work;
	return _error, _error_desc;
end if
 
commit work;

return 0, "cambio exitoso";

end procedure