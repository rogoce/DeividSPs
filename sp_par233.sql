-- Procedimiento que Verifica una Cuenta

-- Creado    : 05/01/2007 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/05/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par233;

create procedure "informix".sp_par233(
a_periodo char(7),
a_cuenta  char(25)
) returning char(10),
            char(5),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2);

define _no_poliza	char(10);
define _no_endoso	char(5);
define _debito_asi	dec(16,2);
define _credito_asi	dec(16,2);
define _debito_aux	dec(16,2);
define _credito_aux	dec(16,2);

foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where periodo     = a_periodo
	and actualizado = 1

	foreach
	 select debito,
	        credito
	   into _debito_asi,
	        _credito_asi
	   from endasien
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso
		and cuenta    = a_cuenta

		select sum(debito),
		       sum(credito)
		  into _debito_aux,
		       _credito_aux
		  from endasiau
	     where no_poliza = _no_poliza
	       and no_endoso = _no_endoso
		   and cuenta    = a_cuenta;

--		if (_debito_asi + _credito_asi) <> (_debito_aux + _credito_aux) then

			return _no_poliza,
			       _no_endoso,
				   _debito_asi, 
				   _credito_asi,
				   _debito_aux,
				   _credito_aux
				   with resume;

--		end if
		          
	end foreach

end foreach

end procedure

