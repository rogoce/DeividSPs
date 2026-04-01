-- Actualizacion de los registros de morosidad y cobros para BO
-- Modificacion del sp_bo032 para actualizar la morosidad del nuevo periodo
-- Modificado    : 12/09/2011 

drop procedure sp_sis499; 

create procedure "informix".sp_sis499()
returning integer;
          

define _cod_agente			char(10);
define _cod_ramo			char(3);
define _no_poliza			char(10);
define _no_documento        char(20);

define _prima_suscrita		dec(16,2);

set isolation to dirty read;

begin 

let _prima_suscrita = 0;

foreach

	select poliza
	  into _no_documento
	  from bonibita2

    let _no_poliza = sp_sis21(_no_documento);

    select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach

		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

       exit foreach;

    end foreach

	 select sum(prima_suscrita)
	   into _prima_suscrita
	   from endedmae
	  where actualizado  = 1
		and periodo      >= '2014-01'
		and periodo  	 <= '2014-06'
		and no_documento = _no_documento;


	 update bonibita2
	    set cod_agente     = _cod_agente,
		    cod_ramo       = _cod_ramo,
			prima_suscrita = _prima_suscrita
	  where poliza         = _no_documento;
		 

end foreach

return 0;

end

end procedure