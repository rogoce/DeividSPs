-- PBI 
-- Devuelve Información para la tabla dimProductosPlanes
-- Creado    : 27/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi06;
CREATE PROCEDURE sp_pbi06()
RETURNING  varchar(50)     as ProductoPlan,
           varchar(50)     as Producto,
		   varchar(50)     as ProductoVersion,
		   varchar(100)    as Cobertura,
		   varchar(100)    as CaracteristicaCobertura,
		   char(5)         as CodProducto,
		   char(5)         as CodCobertura;
		   

define _cod_prod,_cod_cobertura     char(5);
define _n_prod,_n_ramo,_n_subramo   varchar(50);
define _n_cober             		varchar(100);

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi06.trc";	
 -- trace on;

FOREACH
	select p.cod_producto,
	       p.nombre,
		   r.nombre,
		   b.nombre,
		   d.nombre,
		   c.cod_cobertura
	  into _cod_prod,
           _n_prod,
           _n_ramo,
           _n_subramo,
           _n_cober,
		   _cod_cobertura
	  from prdprod p, prdcobpd c, prdramo r, prdsubra b, prdcober d
	 where p.cod_producto = c.cod_producto
	   and p.cod_ramo = r.cod_ramo
	   and r.cod_ramo = b.cod_ramo
	   and p.cod_subramo = b.cod_subramo
	   and c.cod_cobertura = d.cod_cobertura
	   --and p.activo = 1
	 order by p.cod_producto,p.nombre,r.nombre,b.nombre, d.nombre

	RETURN _n_prod, _n_ramo, _n_subramo,_n_cober,_n_cober,_cod_prod,_cod_cobertura WITH RESUME;

END FOREACH
END PROCEDURE	  