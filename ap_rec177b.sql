-- Procedimiento que verifica las reservas de reclamos de un periodo vs el periodo anterior
 
-- Creado     :	04/12/2010 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_rec177b;		

create procedure "informix".ap_rec177b(a_transaccion char(10),a_flag smallint,a_monto dec(16,2))
returning	smallint,
			char(50);

define _error_desc	char(50);
define _no_tranrec	char(10);
define _variacion	dec(16,2);
define _error		integer;
define _error_isam	integer;

begin
--set debug file to "sp_rec177.trc";
--trace on;

set isolation to dirty read;


let _variacion = a_monto * -1;

select no_tranrec
  into _no_tranrec
  from rectrmae
 where transaccion = a_transaccion
   and actualizado = 1;

if a_flag = 1 then
	update rectrcob
	   set monto     = a_monto,
		   variacion = _variacion
	 where no_tranrec = _no_tranrec
	   and variacion <> 0;

	update rectrmae
	   set monto     = a_monto,
		   variacion = _variacion
	 where no_tranrec = _no_tranrec;
else
	update rectrcob
	   set variacion = _variacion
	 where no_tranrec = _no_tranrec
	   and variacion <> 0;

	update rectrmae
	   set variacion = _variacion
	 where no_tranrec = _no_tranrec;
end if

return 0,'Modificación Exitosa';
end
end procedure
