-- Procedimiento que crea los registros para la consolidacion de companias

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par194;

create procedure "informix".sp_par194()

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _cancelada		smallint;
define _cantidad		smallint;

foreach
 select poliza
   into _no_documento
   from cobinc0512_2
   
	update cobinc0512_2
	   set cancelada = 0
     where poliza    = _no_documento;	

	select count(*)
	  into _cantidad
	  from cobinc0512_no
	 where poliza = _no_documento;

	if _cantidad = 1 then

		update cobinc0512_2
		   set cancelada = 1
	     where poliza    = _no_documento;	

	end if

end foreach    

end procedure
