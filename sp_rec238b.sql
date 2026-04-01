-- Procedure para reporte de piezas pendientes por proveedor 													   
-- Creado por: Amado Perez 07/10/2014

drop procedure sp_rec238b;

create procedure sp_rec238b()
returning char(10),varchar(100);


define _cod_proveedor   char(10);
define _proveedor       varchar(100);

--SET DEBUG FILE TO "sp_rec238.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;


foreach with hold
	select a.cod_proveedor, b.nombre
	  into _cod_proveedor, _proveedor
	  from recordma	a, cliclien b
	 where a.cod_proveedor = b.cod_cliente
	   and a.pagado <> 1
	 group by 1, 2
	 order by 2
		    
	return _cod_proveedor,
	       _proveedor 
	       with resume;

end foreach


end procedure