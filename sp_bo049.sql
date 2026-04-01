-- Fecha del Ultimo Pago para Subir a BO 
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

drop procedure sp_bo049;

create procedure "informix".sp_bo049(a_periodo char(7))
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_documento	char(20);
define _prima_bruta		dec(16,2);

foreach
 select no_poliza,
        no_documento
   into _no_poliza,
        _no_documento
   from cobmoros
  where periodo = a_periodo

	select prima_bruta
	  into _prima_bruta
	  from emipomae
	 where no_poliza = _no_poliza;

	update cobmoros
	   set prima_bruta  = _prima_bruta,
	       subir_bo     = 1
	 where no_documento = _no_documento
	   and periodo      = a_periodo;

end foreach

return 0, "Actualizacion Exitosa";

end procedure