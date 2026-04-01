-- POLIZAS VIGENTES 
--

DROP procedure sp_jean14;
CREATE procedure sp_jean14(a_fecha date)
RETURNING CHAR(50) as codproducto,
          char(50) as n_producto,
		  char(3)  as codsubramo,
		  char(50) as n_subramo,
		  char(3)  as codcarnet,
		  CHAR(50) as n_carnet;

DEFINE _no_poliza	 	CHAR(10);
DEFINE _no_documento    CHAR(20);
DEFINE _n_subramo,_n_producto,_n_carnet  	CHAR(50);
DEFINE _cod_producto    char(10);
define v_filtros        varchar(255);
define _no_unidad       char(5);
define _cod_subramo,_cod_carnet     char(3);

CALL sp_pro03("001","001",a_fecha,"018;") RETURNING v_filtros;

foreach
	select no_poliza,
		   cod_subramo
	  into _no_poliza,
		   _cod_subramo
	  from temp_perfil
	 where seleccionado = 1
	   and cod_subramo not in('012')
	   
	select nombre
	  into _n_subramo
	  from prdsubra
	 where cod_ramo = '018'
       and cod_subramo = _cod_subramo;
	   
	foreach
		select cod_producto
	      into _cod_producto
 	      from emipouni 
		 where no_poliza = _no_poliza
		
		select nombre,
		       cod_carnet
		  into _n_producto,
		       _cod_carnet
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		select nombre
		  into _n_carnet
		  from emicarnet
		 where cod_carnet = _cod_carnet; 
		 
		return _cod_producto,_n_producto,_cod_subramo,_n_subramo,_cod_carnet,_n_carnet with resume;
		
	end foreach	
		 
end foreach
END PROCEDURE;
