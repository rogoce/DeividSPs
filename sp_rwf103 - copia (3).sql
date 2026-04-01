-- buscar ajustador

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza
-- Modificado: 23/12/2019 - Autor: Amado Perez Mendoza
-- Modificado: 14/11/2022 - Autor: Amado Perez Mendoza ID de la solicitud	# 5007 
-- A solicitud de la Gerencia de Reclamos de Automóvil es necesario realizar los siguientes cambios:
-- La asignación de Terceros Afectados serán exclusivos para los siguientes ajustadores (más sus casos creados en sus respectivas sucursales que le caen a diario)
-- Lorena Madrid - Santiago
-- Zoraida Melendez - Chiriqui
-- David Rios - Chitre

drop procedure sp_rwf103;

create procedure "informix".sp_rwf103(a_sucursal CHAR(3), a_no_reclamo CHAR(10))
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

  

if a_sucursal in ('003','005','011') then --ID de la solicitud	# 5007 
	select ajust_interno
	  into _cod_ajustador
	  from recrcmae
	 where no_reclamo = a_no_reclamo;

	select count(*)
	  into _cantidad
	  from recajust
	 where activo     = 1
	   and dist_equitativa = 1
	   and cod_ajustador = _cod_ajustador;

	if _cantidad > 0 then
		foreach
			select usuario
			  into _usuario
			  from recajust
			 where cod_ajustador   = _cod_ajustador

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
	else
	   let _sucursal1 = "003";    
	   let _sucursal2 = "005";
       let _sucursal3 = "011";

		select count(*)
		  into _cantidad
		  from recajust
		 where activo     = 1
		   and dist_equitativa = 1
		   and cod_sucursal in ('003','005','011');

		if _cantidad = 0 then
		   let _sucursal1 = "001";    
		   let _sucursal2 = "010";
           let _sucursal3 = "007";
		end if

		foreach
			select usuario,
				   cod_ajustador
			  into _usuario,
				   _cod_ajustador
			  from recajust
			 where activo     = 1
			   and dist_equitativa = 1
			   and cod_sucursal in (_sucursal1,_sucursal2,_sucursal3)
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
	end if

else
	foreach
		select usuario,
			   cod_ajustador
		  into _usuario,
			   _cod_ajustador
		  from recajust
		 where activo     = 1
		   and dist_equitativa = 1
           and cod_sucursal in ('003','005','011')
		 --  and usuario not in ('DRIOS')
		 --  and cod_sucursal not in ('001','010') se distruibuira entre todos por igual a nivel nacional 3-12-2020
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
end if
end

end procedure