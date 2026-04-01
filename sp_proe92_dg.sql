-- Reporte 2 de asegurados con preexcistencias de la poliza de la cooperativa deivid gestion
-- Creado    : 02/11/2022 - Autor: Armando Moreno.

DROP PROCEDURE sp_proe92_dg;
CREATE PROCEDURE sp_proe92_dg()
returning char(10),		 
		  varchar(100),			  
		  varchar(30),			    
		  char(5),
		  char(5),
		  varchar(50),
		  date,
		  date;

define _cod_cliente	     char(10);	 
define _cod_procedimiento char(5);	 
define _no_unidad   	 char(5);
define _n_proc   	     varchar(50);
define _fecha_revision	 date;
define _fecha_adicion	 date;
define _n_cliente        varchar(100);
define _cnt              integer;
define _cedula           varchar(30);

SET ISOLATION TO DIRTY READ;

let _cnt = 0;
FOREACH
	select c.cod_cliente,
	       c.nombre,
		   c.cedula,
		   e.no_unidad
	  into _cod_cliente,
           _n_cliente,
           _cedula,
           _no_unidad
	  from emipouni e, cliclien c
	 where e.cod_asegurado = c.cod_cliente
	   and e.no_poliza = '0001301129'
	   and e.activo = 1
	   
	select count(*)
	  into _cnt
	  from emipreas
	 where no_poliza = '0001301129'
       and no_unidad = _no_unidad;
    
    if _cnt is null then
		let _cnt = 0;
	end if
    if _cnt > 0 then
	    foreach
			select e.cod_procedimiento,
			       e.fecha,
				   e.date_added,
				   p.nombre
			  into _cod_procedimiento,
			       _fecha_revision,
				   _fecha_adicion,
				   _n_proc
			  from emipreas e, emiproce p
			 where e.cod_procedimiento = p.cod_procedimiento
			   and e.no_poliza = '0001301129'
               and e.no_unidad = _no_unidad
			   
			return _cod_cliente,_n_cliente,_cedula,_no_unidad,_cod_procedimiento,_n_proc,_fecha_revision,_fecha_adicion with resume;			   
		END FOREACH	 
	end if

END FOREACH
END PROCEDURE
