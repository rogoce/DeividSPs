-- buscar ajustador casco y responsabilidad civil

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza
-- Modificado: 10-05-2024 - Autor Amado Pérez M. - Se excluye la sucursal de La Chorrera 007 para que le caigan los asegurados - SD 10308

drop procedure sp_rwf86;

create procedure "informix".sp_rwf86(a_sucursal CHAR(3), a_no_poliza CHAR(10) DEFAULT NULL)
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
define _cod_contratante char(10);
define _status          char(1);
define _descripcion     varchar(30);
define _no_documento    char(20);
define _sucursal3       char(3);

let _error = 0;
let _cantidad = 0;

SET ISOLATION TO DIRTY READ;

if a_no_poliza = '2897989' then
  SET DEBUG FILE TO "sp_rwf86.trc"; 
  trace on;
end if

begin

ON EXCEPTION SET _error 
	RETURN null, null, null, null, _error, null; 
END EXCEPTION   

let _usuario = null;   

-- Asignaciones especiales a ajustadores
if a_no_poliza is not null and trim(a_no_poliza) <> "" then
	
	--Prioridad de Asignación de Reclamos -- ID de la solicitud	# 4667 -- Amado 06-10-2022 
	--Orden
	--1. Póliza
	--2. Cliente
	--3. Sucursal
	--4. Agente
	--5. Grupo Económico 	
	
	-- Cambio en la Prioridad de Asignación de Reclamos -- ID de la solicitud	#  -- Amado 13-03-2024 
	--Orden
	--1. Agente
	--2. Grupo Económico 	
	--3. Sucursal
	--4. Cliente
	--5. Póliza
	
    
    -- Buscando ajustador asignado para un corredor especifico

    --Buscando ajustador para el corredor Ducruet
	select count(*) 
	  into _cantidad
	  from emipoagt
	 where no_poliza  = a_no_poliza
	   and cod_agente = '00035'; --> Ducruet 

    if _cantidad > 0 then
		select valor_parametro
		  into _usuario
		  from inspaag
		 where codigo_compania = '001'
		   and codigo_agencia  = '001'
		   and aplicacion = 'REC'
		   and version = '02'
		   and codigo_parametro = 'ajust_ducruet';

		if trim(_usuario) <> "" and _usuario is not null then		  
			select status
			  into _status
			  from insuser
			 where usuario = _usuario; 

			if trim(_usuario) <> "" and _usuario is not null and _status = 'A' then
				select cod_ajustador
				  into _cod_ajustador
				  from recajust
				 where usuario     = _usuario;

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
				   set orden      = orden + 1
				 where usuario    = _usuario;

				return _cod_ajustador,
					   trim(_usuario),
					   trim(_dominio_ultimus)||trim(_windows_user),
					   trim(_e_mail),
					   _error,
					   _descripcion;
			 end if
		end if
	end if

    --Buscando ajustador para el corredor Tecnica de Seguros
	select count(*) 
	  into _cantidad
	  from emipoagt
	 where no_poliza  = a_no_poliza
	   and cod_agente = '00180'; --> Tecnica de Seguros

    if _cantidad > 0 then
		select valor_parametro
		  into _usuario
		  from inspaag
		 where codigo_compania = '001'
		   and codigo_agencia  = '001'
		   and aplicacion = 'REC'
		   and version = '02'
		   and codigo_parametro = 'ajust_tecnica';

        select status
          into _status
          from insuser
         where usuario = _usuario; 


        if trim(_usuario) <> "" and _usuario is not null and _status = 'A' then
			select cod_ajustador
			  into _cod_ajustador
			  from recajust
			 where usuario     = _usuario;

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
			   set orden      = orden + 1
			 where usuario    = _usuario;

			return _cod_ajustador,
			       trim(_usuario),
			       trim(_dominio_ultimus)||trim(_windows_user),
			       trim(_e_mail),
			       _error,
				   trim(_descripcion);
		 end if
	end if

    --Buscando ajustador para el corredor Seguros Luvaro
	select count(*) 
	  into _cantidad
	  from emipoagt
	 where no_poliza  = a_no_poliza
	   and cod_agente in (select cod_agente from agtagent where agente_agrupado = '00048'); --> Seguros

    if _cantidad > 0 then
		select valor_parametro
		  into _usuario
		  from inspaag
		 where codigo_compania = '001'
		   and codigo_agencia  = '001'
		   and aplicacion = 'REC'
		   and version = '02'
		   and codigo_parametro = 'ajust_luvaro';

        select status
          into _status
          from insuser
         where usuario = _usuario; 


        if trim(_usuario) <> "" and _usuario is not null and _status = 'A' then
			select cod_ajustador
			  into _cod_ajustador
			  from recajust
			 where usuario     = _usuario;

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
			   set orden      = orden + 1
			 where usuario    = _usuario;

			return _cod_ajustador,
			       trim(_usuario),
			       trim(_dominio_ultimus)||trim(_windows_user),
			       trim(_e_mail),
			       _error,
				   trim(_descripcion);
		 end if
	end if
	
    --Buscando ajustador para el corredor Seguros Genesis
	select count(*) 
	  into _cantidad
	  from emipoagt
	 where no_poliza  = a_no_poliza
	   and cod_agente in (select cod_agente from agtagent where agente_agrupado = '01926'); --> Seguros

    if _cantidad > 0 then
		select valor_parametro
		  into _usuario
		  from inspaag
		 where codigo_compania = '001'
		   and codigo_agencia  = '001'
		   and aplicacion = 'REC'
		   and version = '02'
		   and codigo_parametro = 'ajust_genesis';

        select status
          into _status
          from insuser
         where usuario = _usuario; 


        if trim(_usuario) <> "" and _usuario is not null and _status = 'A' then
			select cod_ajustador
			  into _cod_ajustador
			  from recajust
			 where usuario     = _usuario;

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
			   set orden      = orden + 1
			 where usuario    = _usuario;

			return _cod_ajustador,
			       trim(_usuario),
			       trim(_dominio_ultimus)||trim(_windows_user),
			       trim(_e_mail),
			       _error,
				   trim(_descripcion);
		 end if
	end if

	
	foreach
		select b.cod_agente					--Se buscará el cod_agente en vez del agente agrupado -- SD # 10791 -- Amado 26-06-2024
		  into _cod_contratante
		  from emipoagt a, agtagent b
		 where a.cod_agente = b.cod_agente
		   and a.no_poliza = a_no_poliza
    
	--	select b.agente_agrupado
	--	  into _cod_contratante
	--	  from emipoagt a, agtagent b
	--	 where a.cod_agente = b.cod_agente
	--	   and a.no_poliza = a_no_poliza

		let _cod_ajustador = null;

		select first 1 cod_ajustador
		  into _cod_ajustador
		  from recclixaju
		 where cod_cliente = _cod_contratante
		   and tipo = 2;
		   
	   if _cod_ajustador is not null then
			exit foreach;
	   end if
   
    end foreach
	
	select usuario
	  into _usuario
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select status
	  into _status
	  from insuser
	 where usuario = _usuario; 

    if trim(_cod_ajustador) <> "" and _cod_ajustador is not null and _status = 'A' then
		select usuario
		  into _usuario
		  from recajust
		 where cod_ajustador = _cod_ajustador;
         
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
		   set orden      = orden + 1
		 where usuario    = _usuario;

		return _cod_ajustador,
		       trim(_usuario),
		       trim(_dominio_ultimus)||trim(_windows_user),
		       trim(_e_mail),
		       _error,
			   trim(_descripcion);
    end if

    -- Buscando ajustador asignado para un grupo economico
    select cod_grupo
	  into _cod_contratante
	  from emipomae
	 where no_poliza = a_no_poliza;

    let _cod_ajustador = null;

    select first 1 cod_ajustador
	  into _cod_ajustador
	  from recclixaju
	 where cod_sucursal = _cod_contratante
	   and tipo = 5;

	select usuario
	  into _usuario
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select status
	  into _status
	  from insuser
	 where usuario = _usuario; 

    if trim(_cod_ajustador) <> "" and _cod_ajustador is not null and _status = 'A' then
		select usuario
		  into _usuario
		  from recajust
		 where cod_ajustador = _cod_ajustador;
         
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
		   set orden      = orden + 1
		 where usuario    = _usuario;

		return _cod_ajustador,
		       trim(_usuario),
		       trim(_dominio_ultimus)||trim(_windows_user),
		       trim(_e_mail),
		       _error,
			   trim(_descripcion);
    end if
	
    -- Buscando ajustador asignado para una sucursal especifica
    let _cod_ajustador = null;

    select cod_ajustador
	  into _cod_ajustador
	  from recclixaju
	 where cod_sucursal = a_sucursal
	   and tipo = 3;

	select usuario
	  into _usuario
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select status
	  into _status
	  from insuser
	 where usuario = _usuario; 

    if trim(_cod_ajustador) <> "" and _cod_ajustador is not null and _status = 'A' then
		select usuario
		  into _usuario
		  from recajust
		 where cod_ajustador = _cod_ajustador;
         
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
		   set orden      = orden + 1
		 where usuario    = _usuario;

		return _cod_ajustador,
		       trim(_usuario),
		       trim(_dominio_ultimus)||trim(_windows_user),
		       trim(_e_mail),
		       _error,
			   trim(_descripcion);
    end if

	
    -- Buscando ajustador asignado para un cliente especifico
    select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = a_no_poliza;

    let _cod_ajustador = null;

    select cod_ajustador
	  into _cod_ajustador
	  from recclixaju
	 where cod_cliente = _cod_contratante
	   and tipo = 1;

	select usuario
	  into _usuario
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select status
	  into _status
	  from insuser
	 where usuario = _usuario; 

    if trim(_cod_ajustador) <> "" and _cod_ajustador is not null and _status = 'A' then
		select usuario
		  into _usuario
		  from recajust
		 where cod_ajustador = _cod_ajustador;
         
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
		   set orden      = orden + 1
		 where usuario    = _usuario;

		return _cod_ajustador,
		       trim(_usuario),
		       trim(_dominio_ultimus)||trim(_windows_user),
		       trim(_e_mail),
		       _error,
			   trim(_descripcion);
    end if


    -- Buscando ajustador asignado para una poliza especifica
    select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = a_no_poliza;

    let _cod_ajustador = null;

    select cod_ajustador
	  into _cod_ajustador
	  from recclixaju
	 where no_documento = _no_documento
	   and tipo = 4;

	select usuario
	  into _usuario
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select status
	  into _status
	  from insuser
	 where usuario = _usuario; 

    if trim(_cod_ajustador) <> "" and _cod_ajustador is not null and _status = 'A' then
		select usuario
		  into _usuario
		  from recajust
		 where cod_ajustador = _cod_ajustador;
         
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
		   set orden      = orden + 1
		 where usuario    = _usuario;

		return _cod_ajustador,
		       trim(_usuario),
		       trim(_dominio_ultimus)||trim(_windows_user),
		       trim(_e_mail),
		       _error,
			   trim(_descripcion);
    end if

end if    
	
------  



if a_sucursal in ('001','010') then
   let _sucursal1 = "001";    
   let _sucursal2 = "010";
 --  let _sucursal3 = "007";  --Se agrega a Gilberto Aizprua
else
   let _sucursal1 = a_sucursal;
   let _sucursal2 = a_sucursal;
  -- let _sucursal3 = a_sucursal;  
end if

select count(*)
  into _cantidad
  from recajust
 where activo     = 1
   and dist_equitativa = 1
   and cod_sucursal in (_sucursal1,_sucursal2) --,_sucursal3
   and cod_ajustador <> '207'; -- Victor De Leon no se le asignará reclamos de asegurados

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
	   and cod_sucursal in (_sucursal1,_sucursal2) --,_sucursal3
	   and cod_ajustador <> '207' -- Victor De Leon no se le asignará reclamos de asegurados
	 order by orden

    select windows_user,
	       e_mail
	  into _windows_user,
		   _e_mail      
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
	   set orden      = orden + 1
	 where usuario    = _usuario;

   exit foreach;

end foreach

select descripcion
  into _descripcion
  from insuser
 where usuario = _usuario;

return _cod_ajustador,
       trim(_usuario),
       trim(_dominio_ultimus)||trim(_windows_user),
       trim(_e_mail),
       _error,
	   trim(_descripcion);
end

end procedure