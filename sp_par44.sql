-- Arreglar los productos de Salud para que se puedan utilizar
-- en los reclamos automaticos

drop procedure sp_par44;

create procedure sp_par44(a_cod_producto char(5))
returning char(5),
		  char(50),	
          char(5),
          char(50),
          char(1);

define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cod_producto	char(5);
define _cod_cobertura	char(5);

define _cantidad		smallint;
define _nombre_cober	char(50);
define _nombre_produc	char(50);
define _tipo_error		char(1);

define _maneja_tipo_cob smallint;

select cod_ramo,
       cod_subramo
  into _cod_ramo,
       _cod_subramo
  from prdprod
 where cod_producto = a_cod_producto;

-- Falta en Producto Comparado con
-- Producto Piloto

let _tipo_error = "1";

foreach
 select	cod_producto
   into	_cod_producto
   from	prdprod
  where	cod_ramo    = _cod_ramo
    and cod_subramo = _cod_subramo

	select nombre
	  into _nombre_produc
	  from prdprod
	 where cod_producto = _cod_producto;

	foreach
	 select	cod_cobertura
	   into	_cod_cobertura
	   from	prdcobpd
	  where cod_producto = a_cod_producto
  
		 select count(*)
		   into _cantidad
		   from prdcobpd
		  where cod_producto  = _cod_producto
		    and cod_cobertura = _cod_cobertura;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad = 0 then

				{
				insert into prdcobpd(
				cod_producto, 
				cod_cobertura,
				orden
				)
				values(
				_cod_producto, 
				_cod_cobertura,
				0
				);
				--}

				select nombre
				  into _nombre_cober
				  from prdcober
				 where cod_cobertura = _cod_cobertura;

				return _cod_cobertura,
					   _nombre_cober,
					   _cod_producto,
					   _nombre_produc,
					   _tipo_error	
				       with resume;
			end if

	end foreach

end foreach

-- Esta de Mas en el Producto

let _tipo_error = "2";

foreach
 select	cod_producto
   into	_cod_producto
   from	prdprod
  where	cod_ramo    = _cod_ramo
    and cod_subramo = _cod_subramo

	select nombre
	  into _nombre_produc
	  from prdprod
	 where cod_producto = _cod_producto;

	foreach
	 select	cod_cobertura
	   into	_cod_cobertura
	   from	prdcobpd
	  where cod_producto = _cod_producto
  
		 select count(*)
		   into _cantidad
		   from prdcobpd
		  where cod_producto  = a_cod_producto
		    and cod_cobertura = _cod_cobertura;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad = 0 then
				
			 {
			 delete from prdcobpd
			  where cod_producto  = _cod_producto
			    and cod_cobertura = _cod_cobertura;
			  --}

				select nombre
				  into _nombre_cober
				  from prdcober
				 where cod_cobertura = _cod_cobertura;

				return _cod_cobertura,
					   _nombre_cober,
					   _cod_producto,
					   _nombre_produc,
					   _tipo_error	
				       with resume;
			end if

	end foreach

end foreach

end procedure 


