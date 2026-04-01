
-- Creado:     24/02/2026 - Autor Armando Moreno M.

drop procedure sp_arregla_rectrrea_salud;
create procedure sp_arregla_rectrrea_salud(a_periodo char(7))
returning	integer;

define _error_desc						  char(100);
define _error,_no_cambio,_cantidad        integer;
define _error_isam,_cant_reg	          integer;
define _no_reclamo,_no_poliza,_no_tranrec char(10); 
define _no_unidad  						  char(5);
define _mensaje 						  varchar(250);

--set debug file to "sp_arregla_rectrrea_salud.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _cant_reg = 0;
--N/T DE RECLAMOS
foreach
	select r.no_reclamo,
	       r.no_tranrec
	  into _no_reclamo,
	       _no_tranrec
	  from rectrmae r, rectrrea c
	 where r.no_tranrec = c.no_tranrec
	   and r.actualizado = 1
	   and r.periodo = a_periodo
	   and r.numrecla[1,2] = '18'
	   and c.porc_partic_prima not in(30,70)
  order by r.no_tranrec
	   
	select count(*)
	  into _cantidad
	  from recreaco
	 where no_reclamo = _no_reclamo
   	   and porc_partic_prima in(30,70);
	   
	if _cantidad is null then
		let _cantidad = 0;
	end if
	
	if _cantidad = 0 then
		select no_poliza,
		       no_unidad
		  into _no_poliza,
		       _no_unidad
		  from recrcmae
		 where no_reclamo = _no_reclamo; 
		 
		let _cantidad = sp_arregla_emireaco_salud_1(_no_poliza, '00000', _no_unidad,1);
	    call sp_sis18(_no_reclamo) returning _cantidad, _error_desc;
	end if
	
    call sp_sis58(_no_tranrec) returning _cantidad, _error_desc;
	
	update sac999:reacomp
	   set sac_asientos = 0
	 where no_tranrec    = _no_tranrec
	   and periodo       = a_periodo
	   and tipo_registro = 3;

end foreach
return _cantidad;
end
end procedure;