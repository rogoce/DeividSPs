-- buscar ajustador

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza
-- Modificado: 23/12/2019 - Autor: Amado Perez Mendoza

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

if a_sucursal in ('001','010') then --CASO: 33447 ASUNTO: DISTRIBUCIÓN DE RECLAMOS DE TERCEROS DEL CIA A NIVEL NACIONAL ENTRE LOS AJUSTADORES SIN TOMAR EN CUENTA EL AJUSTADOR DEL RECLAMO
	foreach
		select usuario,
			   cod_ajustador
		  into _usuario,
			   _cod_ajustador
		  from recajust
		 where activo     = 1
		   and dist_equitativa = 1
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
else
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
		if a_sucursal in ('001','010') then
		   let _sucursal1 = "001";    
		   let _sucursal2 = "010";
		else
		   let _sucursal1 = a_sucursal;
		   let _sucursal2 = a_sucursal;
		end if

		select count(*)
		  into _cantidad
		  from recajust
		 where activo     = 1
		   and dist_equitativa = 1
		   and cod_sucursal in (_sucursal1,_sucursal2);

		if _cantidad = 0 then
		   let _sucursal1 = "001";    
		   let _sucursal2 = "010";
		end if

		foreach
			select usuario,
				   cod_ajustador
			  into _usuario,
				   _cod_ajustador
			  from recajust
			 where activo     = 1
			   and dist_equitativa = 1
			   and cod_sucursal in (_sucursal1,_sucursal2)
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
end if
end

end procedure