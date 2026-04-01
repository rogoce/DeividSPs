-- Procedimiento que crea los registros para la consolidacion de companias

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par190;

create procedure "informix".sp_par190()

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _cancelada		smallint;

foreach
 select poliza
   into _no_documento
   from coloncxc
   
	select saldo_deivid,
	       cancelada
	  into _prima_bruta,
	       _cancelada
	  from cobinc0512
	 where poliza = _no_documento;

	update coloncxc
	   set saldo_deivid = _prima_bruta,
	       cancelada    = _cancelada
     where poliza       =  _no_documento;	

end foreach    

end procedure

												  