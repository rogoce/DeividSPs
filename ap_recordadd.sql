-- Procedure que actualiza los montos del detalle recordde 													   
-- Creado por: Amado Perez 10/10/2014

--drop procedure ap_recordadd;

create procedure ap_recordadd()
returning char(10), smallint, char(10), smallint, smallint, smallint, decimal(16,2);

define _error           integer;
define _descripcion		varchar(50);

define _renglon             smallint;
define _renglon_str         varchar(5);
define _no_orden            char(10);
define _renglon2             smallint;
define _no_parte             char(5);
define _despachado           smallint;
define _cnt_despachado       smallint;
define _valor_ajust          decimal(16,2);
define _ajus_orden           char(10);
define _cant                 smallint;


--SET DEBUG FILE TO "sp_rec233.trc"; 
--TRACE ON;   
set isolation to dirty read;
                                                             

begin

ON EXCEPTION SET _error 
 --	RETURN _error, "Error al actualizar las ordenes";         
END EXCEPTION

let _error = 0;
let _descripcion = "Verificacion exitosa";

foreach	with hold
	select no_ajus_orden,
	       renglon,
	       no_orden,  
	       renglon2,
	       despachado,           
	       cnt_despachado,       
	       valor_ajust          
	  into _ajus_orden,
	       _renglon,
	       _no_orden,  
		   _renglon2,
		   _despachado,    
		   _cnt_despachado,
		   _valor_ajust    
	  from recordadd

	select count(*)
	  into _cant
	  from recordad
	 where no_ajus_orden = _ajus_orden
	   and renglon = _renglon;

	if _cant = 0 then
	   return _ajus_orden,
			   _renglon,
			   _no_orden,  
			   _renglon2,
			   _despachado,    
			   _cnt_despachado,
			   _valor_ajust with resume;
	end if		   
  
end foreach

end
--return _error, _descripcion;
end procedure