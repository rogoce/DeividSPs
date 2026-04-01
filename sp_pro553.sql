-- Carta de Salud Vital y Panama

-- Creado: 17/08/2011 - Autor: Amado Perez M.

drop procedure sp_pro553;

create procedure "informix".sp_pro553(a_periodo char(7), a_tipo smallint default 1)
returning varchar(100),
		  varchar(100),
		  char(10),
		  char(10),
		  char(10),
		  char(20),
		  char(50);

define _no_requis		char(10);
define _incidente       integer;
define _nombre_cliente	varchar(100);
define _direccion   	varchar(100);
define _telefono1   	char(10);
define _telefono2   	char(10);
define _celular   		char(10);
define _no_documento 	char(20);
define _cod_subramo  	char(3);
define _cod_formapag 	char(3);
define _cod_perpago  	char(3);
define _fecha_aniv   	date;
define _nombre_agente	char(50);
define _cod_producto 	char(5);
define _prima   		dec(16,2);
define _periodo			char(7);
define _nombre   		varchar(100);
define _prima_nueva     dec(16,2);
define _direccion_1     varchar(50);
define _direccion_2     varchar(50);

SET ISOLATION TO DIRTY READ;

let _direccion_1 = "";
let	_direccion_2 = "";


begin

If a_tipo = 1 then

 FOREACH

  SELECT emicartasal2.telefono1,   
         emicartasal2.telefono2,   
         emicartasal2.celular,   
         emicartasal2.no_documento,   
         emicartasal2.nombre_agente,   
         cliclien.nombre,
		 cliclien.direccion_1,
		 cliclien.direccion_2
    INTO _telefono1,   
		 _telefono2,   
		 _celular,   
		 _no_documento, 
		 _nombre_agente,
    	 _nombre,
		 _direccion_1,
		 _direccion_2
    FROM emicartasal2,   
         cliclien,   
         emipomae  
   WHERE emicartasal2.no_documento = emipomae.no_documento   
     and emipomae.cod_contratante = cliclien.cod_cliente    
     and emicartasal2.periodo = a_periodo    
     and emicartasal2.cod_subramo in ('007','009','016')  
ORDER BY emicartasal2.nombre_agente ASC,   
         emicartasal2.no_documento ASC
		 
 --        emicartasal2.cod_grupo not in ('01007','983', '11111', '22222') AND  

let _direccion = "";

if _direccion_2 is not null or _direccion_2 <> "" then
	let _direccion = _direccion_1 || " " || _direccion_2;
else
	let _direccion = _direccion_1;
end if
         
RETURN _nombre,   
	   _direccion,   
	   _telefono1,   
	   _telefono2,   
	   _celular,   
	   _no_documento, 
	   _nombre_agente
	   WITH RESUME;
         

END FOREACH

else
 FOREACH

  SELECT emicartasal2.telefono1,   
         emicartasal2.telefono2,   
         emicartasal2.celular,   
         emicartasal2.no_documento,   
         emicartasal2.nombre_agente,   
         cliclien.nombre,
		 cliclien.direccion_1,
		 cliclien.direccion_2
    INTO _telefono1,   
		 _telefono2,   
		 _celular,   
		 _no_documento, 
		 _nombre_agente,
    	 _nombre,
		 _direccion_1,
		 _direccion_2
    FROM emicartasal2,   
         cliclien,   
         emipomae  
   WHERE emicartasal2.no_documento = emipomae.no_documento   
     and emipomae.cod_contratante = cliclien.cod_cliente    
     and emicartasal2.periodo = a_periodo    
     and emicartasal2.cod_subramo in ('008','018')  
ORDER BY emicartasal2.nombre_agente ASC,   
         emicartasal2.no_documento ASC
		 
 --        emicartasal2.cod_grupo not in ('01007','983', '11111', '22222') AND  
let _direccion = "";

if _direccion_2 is not null or _direccion_2 <> "" then
	let _direccion = _direccion_1 || " " || _direccion_2;
else
	let _direccion = _direccion_1;
end if
         
RETURN _nombre,   
	   _direccion,   
	   _telefono1,   
	   _telefono2,   
	   _celular,   
	   _no_documento, 
	   _nombre_agente
	   WITH RESUME;
         

END FOREACH
end if
end

end procedure
