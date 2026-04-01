-- Procedimiento para seleccionar Agente, Zona, Supervisor, Gestor de Cobros
-- execute procedure sp_sis155("LPEREZ")
-- Creado    : 07/06/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
drop procedure sp_sis155;
create procedure "informix".sp_sis155(a_usuario char(8))
returning	smallint,
			char(8),
			char(50);	-- Retrieve argumento visible en el filtro

define _ver         		 char(255);
define _nombre               char(50);
define _subalterno      	 char(8);
define _user_vista			 char(8);
define _cod_supervisor		 char(3);
define _tipo_cobrador		 char(1);
define _contador	 		 smallint;
define _renglon	 		     smallint;
define _error		 		 smallint;

create temp table tmp_usuario(usuario char(8),
primary key(usuario)) with no log;

-- 0 Satisfactoria
-- 1 Error

--on exception set _error
--	return _error, "Error al Verificar Usuario.";
--end exception

set isolation to dirty read;

-- set debug file to "sp_sis155.trc";
-- trace on;

-- Tipo_Cobrador:
-- Gestor					1/
-- Cajero					2/
-- Rutero					3/
-- Electronico				4/
-- Ejecutivo Cuenta			5/
-- Incobrable				6/
-- Investigador				7/
-- Supervisor de Gestores	8/
-- Jefe de Cobros			9/
-- Coaseguro				10/
-- Vencidas y Canceladas	11/
-- 90 Días y Mas			12/
-- Zona						13/

let _contador = 0;
let _ver = "";

insert into tmp_usuario(usuario)
values (a_usuario);

if trim(a_usuario) = 'HGIRON' or trim(a_usuario) = 'MNAJARRO' then
   let a_usuario = 'ENILDA'; --'JMILLER';
end if

foreach
	select count(*)
	  into _contador
	  from cobcobra
	 where usuario = a_usuario 
	   and activo = 1
	   and tipo_cobrador in (8)
	   and usuario is not null
	exit foreach;
end foreach

if _contador > 0 then
	foreach
		select distinct cod_cobrador
		  into _cod_supervisor
		  from cobcobra
		 where usuario = a_usuario
		   and activo = 1
		   and tipo_cobrador in (8)
		   and usuario is not null
		exit foreach;
	end foreach

	foreach
		select distinct usuario
		  into _subalterno
		  from cobcobra
		 where cod_supervisor = _cod_supervisor
		--   and activo = 1
		   and usuario is not null
		   and tipo_cobrador in(1,4,5,8)
	   	
		begin
			on exception in(-239)
			end exception
			insert into tmp_usuario(usuario) values (_subalterno);
		end
	 end foreach
	 
    -- Si esta de vacasiones asignar vista al supervisor activo	 -- 12/01/2017: NSOLIS
	foreach
		select distinct usuario
		  into _subalterno
		  from cobcobra
		 where cod_supervisor in (
				select distinct cod_cobrador 
				  from cobcobra
				 where tipo_cobrador = 8 and activo = 0 and
					   usuario in (select usuario from insuser
					   where today between date(fvac_out) and date(fvac_duein))		 
		 )
		 --  and activo = 1
		   and usuario is not null
		   and tipo_cobrador in(1,4,5,8)
	   	
		begin
			on exception in(-239)
			end exception
			insert into tmp_usuario(usuario) values (_subalterno);
		end
	 end foreach			      
	 
end if

foreach
	select count(*)
	  into _contador
	  from cobcobra
	 where usuario = a_usuario
	   and activo = 1
	   and tipo_cobrador in (9) 
	   and usuario is not null
	exit foreach;
end foreach

if _contador > 0 then
	foreach
		select distinct cod_cobrador
		  into _cod_supervisor
		  from cobcobra
		 where usuario = a_usuario
		   and activo = 1
		   and tipo_cobrador in (9)
		   and usuario is not null
		exit foreach;
	end foreach

	foreach
		select distinct usuario
		  into _subalterno
		  from cobcobra
		 where cod_supervisor = _cod_supervisor
		 --  and activo = 1
		   and usuario is not null
		   and tipo_cobrador in(1,4,5,8)
	   	begin
			on exception in(-239)
			end exception
			insert into tmp_usuario(usuario) values (_subalterno);
		end
	end foreach

	foreach
		select usuario
		  into _subalterno
		  from cobcobra
		 where usuario is not null
		--   and activo = 1
		   and tipo_cobrador in(1,4,5,8)

	   	begin
			on exception in(-239)
			end exception
			insert into tmp_usuario(usuario) values (_subalterno);
		end
	end foreach
end if

let _nombre = "";

foreach
	select distinct usuario
	  into _user_vista
	  from tmp_usuario
	  order by 1

	select descripcion 
	  into _nombre
	  from segv05:insuser 
	 where usuario = _user_vista;

	return 0,
	       _user_vista,
		   _nombre
		   with resume;
end foreach

drop table tmp_usuario;
--return 0,_ver;
end procedure;