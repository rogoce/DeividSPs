-- Procedure que actualiza centro costo 017 para chqchcta

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac118;

create procedure sp_sac118()
returning char(10),
          smallint,
		  char(25),
		  dec(16,2),
		  dec(16,2),
          smallint,
		  char(25),
		  dec(16,2),
		  dec(16,2);

define _no_requis	char(10);
define _renglon		smallint;
define _cuenta		char(25);
define _debito		dec(16,2);
define _credito		dec(16,2);

define _renglon2	smallint;
define _cuenta2		char(25);
define _debito2		dec(16,2);
define _credito2	dec(16,2);

define _ccosto		char(3);

let _ccosto = "017";

foreach 
 select no_requis
   into	_no_requis
   from chqchcta
  where fecha       >= "01/01/2009"
    and centro_costo = _ccosto
  group by no_requis
 having	sum(debito - credito) <> 0

	foreach
	 select renglon,
			cuenta,
			debito,
			credito
	   into _renglon,
			_cuenta,
			_debito,
			_credito
	   from chqchcta
	  where no_requis    = _no_requis
	    and centro_costo = _ccosto  

		let _renglon2 = _renglon + 1;

		 select renglon,
				cuenta,
				debito,
				credito
		   into _renglon2,
				_cuenta2,
				_debito2,
				_credito2
		   from chqchcta
		  where no_requis = _no_requis
		    and renglon   = _renglon2;

		if _debito  <> _credito2 or
		   _credito <> _debito2  then

{	
			update chqchcta
			   set centro_costo = _ccosto
		     where no_requis    = _no_requis
		       and renglon      = _renglon2;

}

			return _no_requis,
			       _renglon,
				   _cuenta,
				   _debito,
				   _credito,
				   _renglon2,
				   _cuenta2,
				   _debito2,
				   _credito2
				   with resume;

		end if

	end foreach

end foreach

return "0",
       0,
	   "",
	   0.00,
	   0.00,
	   0,
	   "",
	   0.00,
	   0.00;

end procedure
