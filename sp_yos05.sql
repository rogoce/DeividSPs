-- Procedure para cargar en la pagina web las polizas que no tienen pagos por corredor

-- Creado: 20/09/2012 - Autor: Federico Coronado

drop procedure sp_yos05;

create procedure "informix".sp_yos05(a_fecha_ini date, a_fecha_fin date)
returning char(10),
		  char(18),
		  date,
		  date,
		  char(5),
		  decimal(16,2),
		  date;

define _no_reclamo			char(10);
define _numrecla     		char(18);
define _fecha_siniestro     date;
define _cod_cobertura       char(5);
define _reserva             decimal(16,2);
define _fecha_reclamo       date;
define _fecha_documentacion date;               

--set debug file to "sp_web18.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

	foreach
		select a.no_reclamo,
		       a.numrecla,
			   a.fecha_siniestro, 
			   a.fecha_reclamo, 
			   c.cod_cobertura, 
			   c.variacion, 
			   a.fecha_documento
		into  _no_reclamo,			
		      _numrecla,     		
		      _fecha_siniestro,
		      _fecha_reclamo,			  
		      _cod_cobertura,      
		      _reserva,                  
		      _fecha_documentacion
		from recrcmae a inner join rectrmae b on a.no_reclamo = b.no_reclamo
		inner join rectrcob c on b.no_tranrec = c.no_tranrec
		where fecha_reclamo between a_fecha_ini and a_fecha_fin
		  and a.actualizado = 1
		  and a.yoseguro = 1
     order by fecha_siniestro desc
		  
	return _no_reclamo,			
	       _numrecla,     		
	       _fecha_siniestro,
	       _fecha_reclamo,		
	       _cod_cobertura,      
	       _reserva,             
	       _fecha_documentacion
		   with resume;
		   
	end foreach
end procedure