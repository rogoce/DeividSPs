-- Carta de Salud Vital y Panama

-- Creado: 17/08/2011 - Autor: Amado Perez M.

drop procedure sp_pro512;

create procedure "informix".sp_pro512(a_periodo char(7), impr1 smallint default 0, impr2 smallint default 1, envi1 smallint default 0, envi2 smallint default 1,envi3 smallint default 2,envi4 smallint default 3, a_no_documento varchar(20) default "%")
returning varchar(100),
		  varchar(100),
		  char(10),
		  char(10),
		  char(10),
		  char(20),
		  char(3),
		  char(3),
		  char(3),
		  date,
		  char(50),
		  char(5),
		  dec(16,2),
		  char(7),
		  varchar(100),
		  dec(16,2);

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
 FOREACH

  SELECT DISTINCT emicartasal.nombre_cliente,   
         emicartasal.direccion,   
         emicartasal.telefono1,   
         emicartasal.telefono2,   
         emicartasal.celular,   
         emicartasal.no_documento,   
         emicartasal.cod_subramo,   
         emicartasal.cod_formapag,   
         emicartasal.cod_perpago,   
         emicartasal.fecha_aniv,   
         emicartasal.nombre_agente,   
         emicartasal.cod_producto,   
         emicartasal.prima,   
         emicartasal.periodo,
         cliclien.nombre,
		 cliclien.direccion_1,
		 cliclien.direccion_2
    INTO _nombre_cliente,
		 _direccion,   
		 _telefono1,   
		 _telefono2,   
		 _celular,   
		 _no_documento, 
		 _cod_subramo,  
		 _cod_formapag, 
		 _cod_perpago,  
		 _fecha_aniv,   
		 _nombre_agente,
		 _cod_producto, 
		 _prima,   
    	 _periodo,
    	 _nombre,
		 _direccion_1,
		 _direccion_2
    FROM emicartasal,   
         cliclien,   
         emipomae  
   WHERE ( emicartasal.no_documento = emipomae.no_documento ) and  
         ( emipomae.cod_contratante = cliclien.cod_cliente ) and  
         ( ( emicartasal.periodo = a_periodo ) AND  
         (emicartasal.impreso = impr1 OR  
         emicartasal.impreso = impr2) AND  
         emicartasal.enviado_a in (envi1,envi2,envi3,envi4) AND  
         emicartasal.cod_subramo in ('008','018') AND  
         emicartasal.cod_grupo not in ('01007','983', '11111', '22222') AND  
         emicartasal.no_documento like a_no_documento )   
ORDER BY emicartasal.nombre_agente ASC,   
         emicartasal.no_documento ASC

if _direccion is null or _direccion = "" then
    if _direccion_2 is not null or _direccion_2 <> "" then
		let _direccion = _direccion_1 || _direccion_2;
	else
		let _direccion = _direccion_1;
	end if
end if

LET _prima_nueva = sp_pro503(_no_documento, a_periodo);
         
RETURN _nombre_cliente,   
	   _direccion,   
	   _telefono1,   
	   _telefono2,   
	   _celular,   
	   _no_documento, 
	   _cod_subramo,  
	   _cod_formapag, 
	   _cod_perpago,  
	   _fecha_aniv,   
	   _nombre_agente,
	   _cod_producto, 
	   _prima,   
	   _periodo,
	   _nombre,
	   _prima_nueva   
	   WITH RESUME;
         

END FOREACH
end

end procedure
