-- buscar usuario ecopy para panama asistencia

-- Creado: 24/01/2014 - Autor: Amado Perez Mendoza

--drop procedure sp_rwf117;

create procedure "informix".sp_rwf117()
returning  varchar(40),
           varchar(30),
           integer;	

define _usuario			varchar(8);
define _cantidad		smallint;
define _orden			integer;
define _windows_user	varchar(20);
define _e_mail          varchar(30);
define _dominio_ultimus varchar(20);
define _cod_ajustador   char(3);
define _error           integer;
define _sucursal1       char(3);
define _sucursal2       char(3);
define _cod_contratante char(10);
define _status          char(1);

let _error = 0;
let _cantidad = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf86.trc"; 
--trace on;

begin

ON EXCEPTION SET _error 
	RETURN null, null, _error; 
END EXCEPTION   


foreach
    select usuario,
           windows_user,
	       e_mail
	  into _usuario,
	       _windows_user,
		   _e_mail      
	  from insuser
	 where status = "A"
	   and pma_asistencia = 1
	 order by orden_pma_asist

    if _e_mail is null then
		let _e_mail = "";
	end if

    select dominio_ultimus
	  into _dominio_ultimus
	  from parparam;

--    set lock mode to wait;

	update insuser
	   set orden_pma_asist = orden_pma_asist + 1
	 where usuario    = _usuario;

   exit foreach;

end foreach

return trim(_dominio_ultimus)||trim(_windows_user),
       trim(_e_mail),
       _error;
end

end procedure