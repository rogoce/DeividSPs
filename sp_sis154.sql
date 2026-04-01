-- Procedimiento para seleccionar Agente, Zona, Supervisor, Gestor de Cobros
-- execute procedure sp_sis154("LPEREZ")
-- Creado    : 07/06/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis154;
create procedure "informix".sp_sis154(a_usuario char(8))
returning	char(3),	-- Supervisor
			char(50),	-- nom_supervisor
			char(8),	-- usuario_supervisor
			char(50),	-- cargo_supervisor
			char(3),	-- Gestor
			char(50),	-- nom_gestor
			char(8),	-- usuario_gestor
			char(50);	-- cargo_gestor

define _cargo_supervisor	 char(50);	
define _nom_supervisor		 char(50);	
define _cargo_gestor		 char(50);	
define _nom_gestor			 char(50);	
define _usuario_supervisor	 char(8);	
define _usuario_gestor		 char(8);		
define _cod_supervisor		 char(3);	
define _cod_gestor			 char(3);	
   	
set isolation to dirty read;

--set debug file to "sp_sis154.trc";
--trace on;   

let _usuario_supervisor = "" ;	
let _cargo_supervisor = "" ;
let _cod_supervisor = "" ;
let _nom_supervisor = "" ;
let _usuario_gestor = "" ;
let _cargo_gestor = "" ;
let _cod_gestor = "" ;
let _nom_gestor = "" ;

foreach
	select nombre,
		   cod_supervisor,
		   usuario,
		   cod_cobrador 
	  into _nom_gestor,
		   _cod_supervisor,
		   _usuario_gestor,
		   _cod_gestor
	  from cobcobra
	 where usuario = a_usuario
	   and activo = 1
	   and tipo_cobrador <> 13 
	exit foreach;
end foreach

-- Supervisor
select nombre,
	   usuario
  into _nom_supervisor,
	   _usuario_supervisor
  from cobcobra
 where cod_cobrador = _cod_supervisor
   and activo = 1;

select trim(nombre),
	   trim(cargo) 
  into _nom_gestor,
	   _cargo_gestor
  from parfirca
 where usuario = _usuario_gestor
   and activo = 1 ;

select trim(nombre),
	   trim(cargo) 
  into _nom_supervisor,
	   _cargo_supervisor
  from parfirca
 where usuario = _usuario_supervisor
   and activo = 1 ;

return _cod_supervisor,	
	   _nom_supervisor,	
	   _usuario_supervisor,
	   _cargo_supervisor,
	   _cod_gestor,		
	   _nom_gestor,		
	   _usuario_gestor,
	   _cargo_gestor;
end procedure;