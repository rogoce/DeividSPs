-- Procedure que verifica si es posible perdida total													   
-- Creado por: Amado Perez 05/05/2015

drop procedure sp_rwf138;

create procedure sp_rwf138()
returning char(5), varchar(50), char(1), varchar(20), dec(16,2), dec(16,2), dec(16,2), smallint;

DEFINE _no_parte 		char(5);
DEFINE _desc_parte 		varchar(50);
DEFINE _trabajo    		char(1);
DEFINE _trabajo_desc 	varchar(20);
DEFINE _precio_chico  	dec(16,2);
DEFINE _precio_mediano  dec(16,2);
DEFINE _precio_grande  	dec(16,2);
DEFINE _activo 			smallint;

define _error           integer;
define _descripcion		varchar(50);
define _monto           dec(16,2);
define _retorno         integer;

--SET DEBUG FILE TO "sp_rwf137.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin

ON EXCEPTION SET _error 
 --	RETURN _error, "Error al buscar las piezas";         
END EXCEPTION

let _error = 0;
let _retorno = 0;

let _descripcion = "Verificacion exitosa";

FOREACH
  SELECT recparte.no_parte,   
         recparte.desc_parte,   
         recprec.trabajo,   
         recprec.precio_chico,   
         recprec.precio_mediano,   
         recprec.precio_grande,   
         recparte.activo 
    INTO _no_parte,
       	 _desc_parte,
		 _trabajo,
		 _precio_chico,
		 _precio_mediano,
		 _precio_grande,
		 _activo
    FROM recparte,   
         recprec  
   WHERE ( recparte.no_parte = recprec.no_parte )   
ORDER BY recparte.desc_parte ASC,   
         recprec.trabajo ASC   
	
	IF _trabajo = '1' THEN
		LET _trabajo_desc = "REPARAR";
	ELIF _trabajo = '2' THEN
		LET _trabajo_desc = "CAMBIAR";
	ELIF _trabajo = '3' THEN
		LET _trabajo_desc = "PINTAR";
	ELSE
		LET _trabajo_desc = "REPARAR / PINTAR";
	END IF
		 
return _no_parte,
       	 _desc_parte,
		 _trabajo,
		 _trabajo_desc,
		 _precio_chico,
		 _precio_mediano,
		 _precio_grande,
		 _activo WITH RESUME;
END FOREACH
END
end procedure