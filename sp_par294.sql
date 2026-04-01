-- INSERTA REGISTROS EN CLICLIEN CUANDO SE CREA UN PROVEEDOR EN ORDEN DE PAGO

-- Creado    : 22/12/2009 - Autor: Amado Perez

drop procedure sp_par294;

create procedure "informix".sp_par294(as_user char(8)) RETURNING CHAR(20);

define	_windows_user	char(20);

set isolation to dirty read;

  SELECT windows_user
	into _windows_user
    FROM insuser
   WHERE usuario =  as_user
     AND status  = 'A' ;

RETURN _windows_user;
end procedure;