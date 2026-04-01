-- buscar ajustador

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza

drop procedure ap_rwf86b;

create procedure "informix".ap_rwf86b(a_sucursal CHAR(3), a_no_poliza CHAR(10) DEFAULT NULL)
returning  char(10), varchar(50);	

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
define _salida          varchar(50);

let _error = 0;
let _cantidad = 0;

SET ISOLATION TO DIRTY READ;

--if a_no_poliza = '1747181' then
--  SET DEBUG FILE TO "sp_rwf86.trc"; 
--  trace on;
--end if

begin

ON EXCEPTION SET _error 
	RETURN null, null; 
END EXCEPTION   

let _usuario = null;   

-- Asignaciones especiales a ajustadores
if a_no_poliza is not null and trim(a_no_poliza) <> "" then
	
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

                select nombre
                  into _salida
                  from agtagent
                 where cod_agente = '00035';
                 
                let _salida = '00035' || " - " || trim(_salida); 
                 
				return 'CORREDOR', _salida;
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

            select nombre
              into _salida
              from agtagent
             where cod_agente = '00180';
             
            let _salida = '00180' || " - " || trim(_salida); 


			return 'CORREDOR', _salida;
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

            select nombre
              into _salida
              from agtagent
             where cod_agente = '00048';
             
            let _salida = '00048' || " - " || trim(_salida); 

			return 'CORREDOR', _salida;
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

            select nombre
              into _salida
              from agtagent
             where cod_agente = '01926';
             
            let _salida = '01926' || " - " || trim(_salida); 

			return 'CORREDOR', _salida;
		 end if
	end if

	
	foreach
		select b.agente_agrupado
		  into _cod_contratante
		  from emipoagt a, agtagent b
		 where a.cod_agente = b.cod_agente
		   and a.no_poliza = a_no_poliza

		let _cod_ajustador = null;

		select cod_ajustador
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

        select nombre
          into _salida
          from agtagent
         where cod_agente = _cod_contratante;
         
        let _salida = _cod_contratante || " - " || trim(_salida); 

	return 'CORREDOR', _salida;
    end if
	

    -- Buscando ajustador asignado para un grupo economico
    select cod_grupo
	  into _cod_contratante
	  from emipomae
	 where no_poliza = a_no_poliza;

    let _cod_ajustador = null;

    select cod_ajustador
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

        select nombre
          into _salida
          from cligrupo
         where cod_grupo = _cod_contratante;
         
        let _salida = _cod_contratante || " - " || trim(_salida); 


		return 'G. ECO.', _salida;
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
          
        select descripcion
          into _salida
          from insagen
         where codigo_agencia = a_sucursal;
         
		return 'SUCURSAL', _salida;
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


        select nombre
          into _salida
          from cliclien
        where cod_cliente = _cod_contratante;
        
        let _salida = _cod_contratante || " - " || trim(_salida);
        
		return 'CLIENTE', _salida;
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

		return 'POLIZA', _no_documento;
    end if
end if    
	
  ------  

if a_sucursal in ('001','010') then
   let _sucursal1 = "001";    
   let _sucursal2 = "010";
   let _sucursal3 = "007";  --Se agrega a Gilberto Aizprua
else
   let _sucursal1 = a_sucursal;
   let _sucursal2 = a_sucursal;
   let _sucursal3 = a_sucursal;  
end if

select count(*)
  into _cantidad
  from recajust
 where activo     = 1
   and dist_equitativa = 1
   and cod_sucursal in (_sucursal1,_sucursal2,_sucursal3);

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
	   and cod_sucursal in (_sucursal1,_sucursal2,_sucursal3)
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



   exit foreach;

end foreach

select descripcion
  into _descripcion
  from insuser
 where usuario = _usuario;

return 'EQUI. ASEG', null;
end

end procedure
