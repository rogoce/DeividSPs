-- Procedure que actualiza los montos del detalle recordde 													   
-- Creado por: Amado Perez 10/10/2014

drop procedure sp_rec234;

create procedure sp_rec234(a_ajus_orden char(10))
returning integer, varchar(50);

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


--SET DEBUG FILE TO "sp_rec233.trc"; 
--TRACE ON;   
set isolation to dirty read;
                                                             

begin

ON EXCEPTION SET _error 
 	RETURN _error, "Error al actualizar las ordenes";         
END EXCEPTION

let _error = 0;
let _descripcion = "Verificacion exitosa";

foreach	with hold
	select no_orden,  
	       renglon2,
	       despachado,           
	       cnt_despachado,       
	       valor_ajust          
	  into _no_orden,  
		   _renglon2,
		   _despachado,    
		   _cnt_despachado,
		   _valor_ajust    
	  from recordadd
	 where no_ajus_orden = a_ajus_orden

	update recordde
	   set despachado = _despachado,
	       cnt_despachado = cnt_despachado + _cnt_despachado,
		   valor_ajust = valor_ajust + _valor_ajust
	 where no_orden = _no_orden
	   and renglon = _renglon2;

end foreach

end
return _error, _descripcion;
end procedure