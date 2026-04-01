-- buscar ajustador

-- Creado: 07/12/2022 - Autor: Amado Perez Mendoza: Si la cobertura es Responsabilidad o Soda
-- Modificado: 10-05-2024 - Autor Amado Pérez M. - Se agrega la sucursal de La Chorrera 007 para que le caigan los terceros - SD 10308

drop procedure sp_rwf180;

create procedure "informix".sp_rwf180(a_sucursal CHAR(3))
returning  char(3),
           varchar(8), 
           varchar(40),
           varchar(30),
           integer,
		   varchar(30);	

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
define _sucursal3       char(3);
define _sucursal4       char(3);
define _descripcion     varchar(30);

let _error = 0;
let _cantidad = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf103.trc"; 
--trace on;

begin

ON EXCEPTION SET _error 
	RETURN null, null, null, null, _error, null; 
END EXCEPTION         

  

   let _sucursal1 = "003";    
   let _sucursal2 = "005";
   let _sucursal3 = "011"; -- Excluir a Abel Molina '011' del 01-12-2023 al 15-12-2023 volver a poner el 011 -- listo Amado 18-12-2023
   let _sucursal4 = "007";
  -- let _sucursal4 = "002"; -- Se excluye a Colón Victor

	select count(*)
	  into _cantidad
	  from recajust
	 where activo     = 1
	   and dist_equitativa = 1
	   and cod_sucursal in ('003','005','011','007'); --,'002'  --> volver a poner el 16-12-2023,'011' -- listo Amado 18-12-2023

	if _cantidad = 0 then
	   let _sucursal1 = "001";    
	   let _sucursal2 = "010";
	  -- let _sucursal3 = "007";
      -- let _sucursal4 = "007";
	end if

	foreach
		select usuario,
			   cod_ajustador
		  into _usuario,
			   _cod_ajustador
		  from recajust
		 where activo     = 1
		   and dist_equitativa = 1
		   and cod_sucursal in (_sucursal1,_sucursal2) --,_sucursal4,_sucursal3
		 order by ord_tercero

		select windows_user,
			   e_mail,
			   descripcion
		  into _windows_user,
			   _e_mail,
			   _descripcion			   
		  from insuser
		 where usuario = _usuario;

		if _e_mail is null then
			let _e_mail = "";
		end if

		select dominio_ultimus
		  into _dominio_ultimus
		  from parparam;

		set lock mode to wait;

		update recajust
		   set ord_tercero = ord_tercero + 1
		 where usuario    = _usuario;

	   exit foreach;

	end foreach

	return _cod_ajustador,
		   trim(_usuario),
		   trim(_dominio_ultimus)||trim(_windows_user),
		   trim(_e_mail),
		   _error,
		   trim(_descripcion);
end

end procedure
