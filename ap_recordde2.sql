-- Procedure que llena los nuevos campos en recordma

-- Creado    : 03/10/2014 - Autor: Amado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_recordde2;

create procedure ap_recordde2() returning char(10), integer, char(5), char(50), char(5); 

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
	return null,_error, null, _error_desc, null;
end exception

-- 

let _valor = 0.00;
let _cantidad = 0;


foreach	with hold
  SELECT recordde.no_orden,   
         recordde.renglon,   
         recordde.no_parte,   
         recordde.desc_orden   
    INTO _no_orden,
    	 _renglon,	
    	 _no_parte_mal,
    	 _desc_orden
    FROM recordde   
--   WHERE ( recordde.desc_orden = recparte.desc_parte ) and  ( recordde.no_parte = recparte.no_parte[1,3]) --and
 --        ( ( recordde.no_orden = '28675' ) ) ;


 foreach
	select no_parte
	  into _no_parte_bien
	  from recparte
	 where no_parte[1,3] = _no_parte_mal 
	   and desc_parte = _desc_orden
	   and activo = 1 
	 order by 1


	 if _no_parte_mal <> _no_parte_bien then
	    return _no_orden,
			   _renglon,	
			   _no_parte_mal,
			   _desc_orden,
			   _no_parte_bien with resume;
	 end if

    exit foreach;
 end foreach





 {select a.no_orden,
        a.renglon,
        a.valor,
		a.cantidad
   into	_no_orden,	
        _renglon,	
		_valor,
		_cantidad		
   from	recordde a, recordma b
  where a.no_orden = b.no_orden
    and b.tipo_ord_comp = 'R'
	and b.fecha_orden >= '01-01-2013'
    and  b.fecha_orden < '31-12-2013'
    and a.cantidad > 1

	update recordde
	   set valor = _valor * _cantidad
	 where no_orden = _no_orden
	   and renglon  = _renglon;}

    

end foreach

--}

end

--return 0, "Actualizacion Exitosa";

end procedure
