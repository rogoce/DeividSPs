-- Procedure que llena los nuevos campos en recordma

-- Creado    : 03/10/2014 - Autor: Amado

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure ap_recordde3;

create procedure ap_recordde3() returning integer, char(50); 

--integer,
--            char(100);

define _no_orden		char(10);
define _renglon		    integer;
define _no_parte_mal, _no_parte_bien char(5);
 
define _valor		    dec(16,2);
define _cantidad        integer;

define _error			integer;
define _error_isam		integer;
define _error_desc, _desc_orden		char(50);

--set debug file to "sp_ttc11.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- 

let _valor = 0.00;
let _cantidad = 0;


foreach	with hold
  SELECT no_orden,   
         renglon,   
         no_parte_buena    
    INTO _no_orden,
    	 _renglon,	
    	 _no_parte_bien
    FROM tmp_recparte   

	update recordde
	   set no_parte = _no_parte_bien
	 where no_orden = _no_orden
	   and renglon  = _renglon;

	update recordadd
	   set no_parte = _no_parte_bien
	 where no_orden = _no_orden
	   and renglon2 = _renglon;
    

end foreach

--}

end

return 0, "Actualizacion Exitosa";

end procedure
