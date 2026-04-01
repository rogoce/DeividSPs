-- Procedimiento Para Actualizar los Datos de la tabla de cliclien desde cotizacion
-- 
-- Creado    : 25/03/2003 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_seg010;

create procedure "informix".sp_seg010()
returning integer,
          char(10);

define _nom_user		char(30);
define _tel_estension	char(10);
define _cia_depto		char(5);  


--set debug file to "sp_seg010.trc";  
--trace on;                                                                 

set isolation to dirty read;


foreach
	select descripcion,
		   cia_depto,
		   tel_entenci
	  into _nom_user,
		   _cia_depto,
		   _tel_estension
	  from insuser
	 where (status = 'A' or (status = 'I' and fvac_out is not null))
	   and fecha_inicio	<= today
	   and windows_user	is not null
	   and e_mail		is not null

	if _tel_estension is null  then
		let _tel_extension = '';
	end if

	return _nom_user,
		   _tel_estension,
		   _cia_depto	with resume;

	let _tel_extension = '';
end foreach
end procedure

	


