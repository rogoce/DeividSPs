-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_recreaco_salud;
create procedure sp_arregla_recreaco_salud(a_periodo char(7))
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio		        integer;
define _error_isam,_cant_reg	        integer;
define _no_reclamo,_no_poliza        char(10); 
define _no_unidad  char(5);
define _cantidad            integer;
define _no_documento char(20);
define _mensaje 			varchar(250);
define _fecha_reclamo     		date;

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _cant_reg = 0;
--RECLAMOS
foreach
	select r.no_reclamo,
	       r.no_poliza, 
	       r.no_unidad,
		   r.fecha_reclamo
	  into _no_reclamo,
	       _no_poliza,
	       _no_unidad,
		   _fecha_reclamo
      from recrcmae r, recreaco c
     where r.no_reclamo = c.no_reclamo
       and r.actualizado = 1
       and r.periodo = a_periodo
       and r.numrecla[1,2] = '18'
       and c.porc_partic_prima not in(30,70)
  order by r.no_reclamo
  
   let _cantidad = sp_arregla_emireaco_salud_1(_no_poliza, '00000', _no_unidad,1);
   call sp_sis18(_no_reclamo) returning _cantidad, _error_desc;
   
end foreach
return _cantidad;
end
end procedure;