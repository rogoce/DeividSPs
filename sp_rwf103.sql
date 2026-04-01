-- buscar ajustador de Terceros

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza
-- Modificado: 23/12/2019 - Autor: Amado Perez Mendoza
-- Modificado: 14/11/2022 - Autor: Amado Perez Mendoza ID de la solicitud	# 5007 
-- A solicitud de la Gerencia de Reclamos de Automóvil es necesario realizar los siguientes cambios:
-- La asignación de Terceros Afectados serán exclusivos para los siguientes ajustadores (más sus casos creados en sus respectivas sucursales que le caen a diario)
-- Lorena Madrid - Santiago
-- Zoraida Melendez - Chiriqui
-- David Rios - Chitre
-- Modificado: 10-05-2024 - Autor Amado Pérez M. - Se agrega la sucursal de La Chorrera 007 para que le caigan los terceros - SD 10308

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
define _sucursal4       char(3);
define _sucursal5       char(3);
define _descripcion     varchar(30);

define _no_poliza       char(10);
define _cod_cobertura   char(5);
define _tipo_cob        char(1);
define _cnt_tipoR       smallint;
define _cnt_tipoC       smallint;

let _error = 0;
let _cantidad = 0;
let _cnt_tipoR = 0;
let _cnt_tipoC = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf103.trc"; 
--trace on;

begin

ON EXCEPTION SET _error 
	RETURN null, null, null, null, _error, null; 
END EXCEPTION    

-- Se quita la distribución por tipo de cobertura Amado 13-04-2024
{select no_poliza
  into _no_poliza
  from recrcmae
 where no_reclamo = a_no_reclamo;  

FOREACH
	select cod_cobertura
	  into _cod_cobertura
	  from recrccob
	 where no_reclamo = a_no_reclamo
	 
	 let _tipo_cob = sp_rwf179(_no_poliza, _cod_cobertura);
	 
	 if _tipo_cob = "R" then
		let _cnt_tipoR = _cnt_tipoR + 1;
	 end if		 
	 
	 if _tipo_cob = "C" then
		let _cnt_tipoC = _cnt_tipoC + 1;
	 end if		 
	 
END FOREACH  

if _cnt_tipoR > 0 and _cnt_tipoC = 0 then
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
	 --  and cod_ajustador <> '245';  -- Quitar cuando regrese Abel Molina 04-12-2023 -- listo Amado 18-12-2023
	   
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
    end if
end if
}
if a_sucursal in ('003','005','011','002','007') then --ID de la solicitud	# 5007 -- Se agrega Colón Solicitud # 6097
	select ajust_interno
	  into _cod_ajustador
	  from recrcmae
	 where no_reclamo = a_no_reclamo;

	select count(*)
	  into _cantidad
	  from recajust
	 where activo     = 1
	   and dist_equitativa = 1
	   and cod_ajustador = _cod_ajustador
	   and cod_sucursal = a_sucursal;
	  -- and cod_ajustador <> '245'; -- Quitar cuando regrese Abel Molina 04-12-2023 -- listo Amado 18-12-2023

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
	   let _sucursal3 = "011"; -->,'011' volver a agregar a Abel Molina el 16-12-2023 -- listo Amado 18-12-2023
	   let _sucursal4 = "002";
	   let _sucursal5 = "007";

		select count(*)
		  into _cantidad
		  from recajust
		 where activo     = 1
		   and dist_equitativa = 1
		   and cod_sucursal = a_sucursal;
		   
        if _cantidad = 0 then
			select count(*)
			  into _cantidad
			  from recajust
			 where activo     = 1
			   and dist_equitativa = 1
			   and cod_sucursal in ('003','005','002','011','007'); -->,'011' volver a agregar a Abel Molina el 16-12-2023
 		else
		   let _sucursal1 = a_sucursal;    
		   let _sucursal2 = a_sucursal;
		   let _sucursal3 = a_sucursal;
		   let _sucursal4 = a_sucursal;		
		   let _sucursal5 = a_sucursal;
       end if
		
		if _cantidad = 0 then
		   let _sucursal1 = "001";    
		   let _sucursal2 = "010";
		   let _sucursal3 = "010";
           let _sucursal4 = "010";
		end if

		foreach
			select usuario,
				   cod_ajustador
			  into _usuario,
				   _cod_ajustador
			  from recajust
			 where activo     = 1
			   and dist_equitativa = 1
			   and cod_sucursal in (_sucursal1,_sucursal2,_sucursal3,_sucursal4)
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
		   and cod_sucursal in ('003','005','002','011','007') -->,'011' volver a agregar a Abel Molina el 16-12-2023
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
