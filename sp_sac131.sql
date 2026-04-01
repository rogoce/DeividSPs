-- Procedure que actualiza el campo de no_poliza en las cuentas de los cheques de devolucion de primas

-- Creado    : 10/10/2009 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac131;

create procedure sp_sac131() 
returning integer,
          char(100);

define _no_requis	char(10);
define _no_poliza	char(10);
define _prima_neta	dec(16,2);
define _monto		dec(16,2);

define _renglon		integer;
define _renglon2	integer;
define _renglon3	integer;
define _cuenta		char(25);
define _fecha		date;
define _periodo		char(7);

foreach
 select no_requis,
        no_poliza,
		prima_neta,
		monto
   into _no_requis,
        _no_poliza,
		_prima_neta,
		_monto
   from chqchpol
--  where no_requis = "53295"

	foreach
	 select renglon
	   into _renglon
	   from chqchcta
	  where no_requis   = _no_requis
	    and cuenta[1,3] = "131"
		and no_poliza   is null
		and (debito     = _prima_neta or
		     debito     = _monto)    
	  order by renglon

		update chqchcta
		   set no_poliza = _no_poliza
		 where no_requis = _no_requis
		   and renglon   = _renglon;
		   
		   let _renglon2 = _renglon + 1;
		   
		   foreach
		    select renglon,
		           cuenta
		      into _renglon3,
			       _cuenta
			  from chqchcta
			 where no_requis = _no_requis
			   and renglon   > _renglon2
			 order by renglon

				if _cuenta[1,3] = "131" then
					exit foreach;
				end if

				update chqchcta
				   set no_poliza = _no_poliza
				 where no_requis = _no_requis
				   and renglon   = _renglon3;

			end foreach
	  
	end foreach	        		

end foreach

return 0, "Actualizacion Exitosa";

end procedure