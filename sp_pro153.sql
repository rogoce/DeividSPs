-- Tarifas por Producto

-- Creado    : 27/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro153_dw1 - DEIVID, S.A.


DROP PROCEDURE sp_pro153;

CREATE PROCEDURE "informix".sp_pro153()
returning smallint,
          smallint,
          dec(16,2),
		  dec(16,2),
		  char(5),
		  char(50),
		  char(50);

define _cod_producto	char(5);
define _nombre			char(50);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_subra	char(50);
define _edad_desde      smallint;
define _edad_hasta      smallint;
define _prima           dec(16,2);
define _prima_vida      dec(16,2);

foreach
 select cod_producto,
        nombre,
		cod_ramo,
		cod_subramo
   into _cod_producto,
        _nombre,
		_cod_ramo,
		_cod_subramo
   from prdprod
  where cod_ramo    = "018"
    and cod_subramo in ("007", "008")

	select nombre
	  into _nombre_subra
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	    
	foreach
	 select edad_desde,
			edad_hasta,
			prima,
			prima_vida
	   into _edad_desde,
			_edad_hasta,
			_prima,
			_prima_vida 	 
	   from prdtaeda
	  where cod_producto = _cod_producto
	  order by 1, 2

		return _edad_desde,
			   _edad_hasta,
			   _prima,
			   _prima_vida,
			   _cod_producto,
			   _nombre,
			   _nombre_subra
			   with resume;

	end foreach

end foreach

end procedure;

