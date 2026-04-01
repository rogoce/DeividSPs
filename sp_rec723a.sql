-- Procedimiento para saber si el reclamo tiene pago a abogado

-- Creado     :	23/07/2014 - Autor: Angel Tello

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_rec723a;		

create procedure "informix".sp_rec723a(a_numrec char(18))
			returning integer, char(100);


define _mensaje		char(100);
define _retun,_cnt		INTEGER;
define _variacion   dec(16,2);

set isolation to dirty read;

	let _retun = 0;
	let _mensaje = 'No hay Reserva';
	let _variacion = 0;
	
	select sum(variacion)
	  into _variacion
	  from rectrmae
	 where numrecla    = a_numrec
       and actualizado = 1;
	
	if _variacion <> 0 then
		select count(*)
		  into _cnt
		  from legdeman
		 where numrecla = a_numrec;
		if _cnt > 0 then
			let _mensaje = 'El Reclamo tiene reserva y esta en Legal, No lo puede cerrar, consultar en Legal';
		end if	
	end if
	
	
return _retun, _mensaje;	

end procedure
