--- Actualizar el codigo de tipo de tarifa a las nuevas y renovadas
--- Creado 28/07/2014 por Armando Moreno

drop procedure sp_sis416a;

create procedure "informix".sp_sis416a(ai_pool smallint)
returning integer;

begin

define _no_documento  	char(20);
define _no_poliza       char(10);
define _valor           smallint;


--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;

--1=Pool Automatico, Aplicarle rutina de reclamo de evento de colision para llevarla al pool de excepciones si tiene reclamos.

--2=Pool Manual, Aplicarle rutina de reclamo de evento de colision para llevarla al pool de excepciones si tiene reclamos. 

if ai_pool = 1 then	--Pool Automatico

	foreach

		select no_poliza,
		       no_documento
		  into _no_poliza,
			   _no_documento
		  from emirepo
		 where no_documento[1,2] = '02'
		   and estatus not in(5,9)
		   and user_added in('AUTOMATI')

		let _valor = sp_pro316d(_no_poliza);

	end foreach

elif ai_pool = 2 then

	foreach

		select no_poliza,
		       no_documento
		  into _no_poliza,
			   _no_documento
		  from emirepol
		 where no_documento[1,2] = '02'
		   and no_poliza2 is null

		let _valor = sp_pro316b(_no_poliza);

	end foreach


end if

end 
return 0;

end procedure;
