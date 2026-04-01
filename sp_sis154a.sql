-- Procedimiento para seleccionar Agente, Zona, Supervisor, Gestor de Cobros
-- Creado    : 07/06/2011 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis154a;
create procedure "informix".sp_sis154a(a_usuario char(8),a_poliza char(10))
	   returning char(5),   -- agente
	             char(100),	-- nom_agente
	             char(3),	-- forma_pago
	             char(50),	-- nom_forma
	             char(3),	-- division
	             char(50),	-- nom_division
	             char(3),	-- zona
	             char(50),	-- nom_zona
	             char(3),	-- Supervisor
	             char(50),	-- nom_supervisor
	             char(8),	-- usuario_supervisor
	             char(3),	-- Gestor
	             char(50),	-- nom_gestor
	             char(8);	-- usuario_gestor

define _cod_agente			 char(5);  
define _nom_agente			 char(100);
define _cod_formapag		 char(3);	
define _nom_formapag		 char(50);	
define _cod_division		 char(3);	
define _nom_division		 char(50);
define _cod_zona			 char(3);	
define _nom_zona			 char(50);	
define _cod_Supervisor		 char(3);	
define _nom_supervisor		 char(50);	
define _usuario_supervisor	 char(8);	
define _cod_Gestor			 char(3);	
define _nom_gestor			 char(50);	
define _usuario_gestor		 char(8);		
define _nombre_agente	     char(100);
   	
set isolation to dirty read;
-- set debug file to "sp_sis154.trc";
-- trace on;   

let _cod_agente		  	 = "" ;
let _nom_agente		  	 = "" ;
let _cod_formapag     	 = "" ;
let _nom_formapag	  	 = "" ;
let _cod_division	  	 = "" ;
let _nom_division	  	 = "" ;
let _cod_zona		  	 = "" ;
let _nom_zona		  	 = "" ;
let _cod_Supervisor	  	 = "" ;
let _nom_supervisor	  	 = "" ;
let _usuario_supervisor  = "" ;	
let _cod_Gestor		  	 = "" ;
let _nom_gestor		  	 = "" ;
let _usuario_gestor	  	 = "" ;
let _nombre_agente    	 = "" ;

-- Agente
foreach
 select cod_agente
   into _cod_agente
   from emipoagt
  where no_poliza = a_poliza
	select nombre
      into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	   let _nombre_agente = trim(_nombre_agente) || trim(_nom_agente) || " \ ";
end foreach
let _nom_agente = _nombre_agente;

-- Forma de Pago
select cod_formapag
  into _cod_formapag
  from emipomae
 where no_poliza = a_poliza;

-- Division
select nombre,
       cod_cobrador
  into _nom_formapag,
       _cod_division  -- v_cod_cobrador
  from cobforpa
 where cod_formapag = _cod_formapag;

select nombre 
  into _nom_division
  from cobcobra
 where cod_cobrador = _cod_division and activo = 1;

--if _cod_division is null then
--	let _nom_division = _nombre_formapag ; 
--	let _cod_division = _cod_formapag ;
--end if

--if v_cod_cobrador is null then
--else
--	let v_cobrador     = _nombre_formapag ; 
--	let v_cod_cobrador = _cod_formapag ;
--end if

-- Zona de Cobros
select cod_cobrador
  into _cod_zona
  from agtagent
 where cod_agente = _cod_agente;

select nombre,cod_supervisor,usuario 
  into _nom_zona,_cod_supervisor,_usuario_gestor
  from cobcobra
 where cod_cobrador = _cod_zona  and activo = 1;

-- Supervisor
select nombre,usuario
  into _nom_supervisor,_usuario_supervisor
  from cobcobra
 where cod_cobrador = _cod_supervisor  and activo = 1;

-- Gestor
foreach
select cod_cobrador,nombre 
  into _cod_Gestor,_nom_gestor 
  from cobcobra
 where usuario = _usuario_gestor  
   and activo = 1 
   and tipo_cobrador <> "13"	  -- cod_cobrador <> v_cod_cobrador and 
 order by date_added desc
  exit foreach;
   end foreach

return _cod_agente,		
	   _nom_agente,		
	   _cod_formapag,   	
	   _nom_formapag,		
	   _cod_division,		
	   _nom_division,		
	   _cod_zona,			
	   _nom_zona,			
	   _cod_Supervisor,	
	   _nom_supervisor,	
	   _usuario_supervisor,
	   _cod_Gestor,		
	   _nom_gestor,		
	   _usuario_gestor;	   	   

end procedure  

 