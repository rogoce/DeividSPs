-- buscar ajustador

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza

drop procedure sp_yos14;

create procedure "informix".sp_yos14(a_sucursal CHAR(3), a_no_poliza CHAR(10) DEFAULT NULL)
returning  char(3) as cod_ajustador,
           varchar(8) as Usuario, 
           varchar(40) as dominio_usuario,
           varchar(30) as email,
           integer as cod_error,
		   varchar(30) as descripcion;	

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

let _error 				= 0;
let _cantidad 			= 0;
let _descripcion 		= "";
let _cod_ajustador 		= "";
let _usuario			= "";
let _dominio_ultimus	= "";
let _windows_user		= "";
let _e_mail             = "";

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_yos14.trc"; 
--trace on;

begin

ON EXCEPTION SET _error 
	RETURN null, null, null, null, _error, null; 
END EXCEPTION   

let _usuario = null;   

-- Asignaciones especiales a ajustadores
if a_no_poliza is not null and trim(a_no_poliza) <> "" then
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

    if _cod_ajustador is not null then
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
    select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = a_no_poliza;

    let _cod_ajustador = null;

    select cod_ajustador
	  into _cod_ajustador
	  from recclixaju
	 where cod_sucursal = a_sucursal
	   and tipo = 3;

    if _cod_ajustador is not null then
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

    -- Buscando ajustador asignado para un corredor especifico
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
	
    if _cod_ajustador is not null then
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
	if _cod_ajustador is null then
			return "",
		       "",
		       "",
		       "",
		       _error,
			   trim(_descripcion);
	end if
end

end procedure