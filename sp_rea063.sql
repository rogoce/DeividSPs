--Procedimiento para crear tabla con los reclamos con reserva pendiente a junio 2015 y cuya vigencia en la poliza es menor
--al 01/07/2015 para matarle la reserva con los contratos actuales y luego aumentarle la reserva con los contratos cambiados 40%retencion 60% cuota


drop procedure sp_rea063;
create procedure "informix".sp_rea063()
returning integer, char(250);

define _mensaje			char(250);
define _error		    integer;

define _no_reclamo      char(10);
define _no_poliza       char(10);
define _periodo         char(7);
define _no_unidad       char(5);
define _renglon         smallint;
define _error_isam		integer;
define _reserva         dec(16,2);
define _vigencia_inic   date;



set isolation to dirty read;

--set debug file to "sp_sis171g.trc";
--trace on;
let _reserva = 0;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || 'Verificar el Reclamo: ' || trim(_no_reclamo);
	--rollback work;
 	return _error,_mensaje;
end exception

foreach
	select no_reclamo,
		   sum(reserva_bruto)
	  into _no_reclamo,
	       _reserva   
      from contrato1
	 where seleccionado = 1
	 group by no_reclamo
	 order by no_reclamo

	--begin work;

	foreach
		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo
		 
		select vigencia_inic
          into _vigencia_inic
          from emipomae
         where no_poliza = _no_poliza;

		--if _vigencia_inic < '01/07/2015' then
			insert into rec_pen(
			no_poliza,no_reclamo,reserva,vig_ini,flag)
			values(_no_poliza,_no_reclamo,_reserva,_vigencia_inic,0);
		{else	
			insert into rec_pen(
			no_poliza,no_reclamo,reserva,vig_ini,flag)
			values(_no_poliza,_no_reclamo,_reserva,_vigencia_inic,1);
		end if}

	end foreach

	--commit work;
end foreach

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end

end procedure;