-- Procedure que verifica la Integridad del Catalogo

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac16;

create procedure "informix".sp_sac16()
returning char(12),
          char(12),
		  char(50);

define _cta_cuenta	char(12);
define _cta_recibe	char(1);

define _cta_cuenta2	char(12);
define _cta_recibe2	char(1);

define _cta_cuenta_	char(12);
define _no_reciben	smallint;

foreach
 select cta_cuenta,
        cta_recibe
   into _cta_cuenta,
        _cta_recibe
   from cglcuentas
  order by cta_cuenta

	if _cta_recibe = "S" then

		let _cta_cuenta_ = trim(_cta_cuenta) || "%";		

		foreach
		 select cta_recibe,
				cta_cuenta
		   into _cta_recibe2,
				_cta_cuenta2
		   from cglcuentas
		  where cta_cuenta like _cta_cuenta_
		    and cta_cuenta <>   _cta_cuenta

			if _cta_recibe2 = "N" then

				return _cta_cuenta,
					   _cta_cuenta2,
					   "Ambas Cuentas Reciben Movimiento"
					   with resume;
			end if

		end foreach

	elif _cta_recibe = "N" then

		let _cta_cuenta_ = trim(_cta_cuenta) || "%";		
		let _no_reciben  = 0;

		foreach
		 select cta_recibe,
				cta_cuenta
		   into _cta_recibe2,
				_cta_cuenta2
		   from cglcuentas
		  where cta_cuenta like _cta_cuenta_
		    and cta_cuenta <>   _cta_cuenta

			if _cta_recibe2 = "S" then
				let _no_reciben = 1;
				exit foreach;
			end if

		end foreach

		if _no_reciben = 0 then

			return _cta_cuenta,
				   "",
				   "Ninguna Cuenta Recibe Movimiento"
				   with resume;

			foreach
			 select cta_cuenta
			   into _cta_cuenta2
			   from cglcuentas
			  where cta_cuenta like _cta_cuenta_
			    and cta_cuenta <>   _cta_cuenta

				return _cta_cuenta,
					   _cta_cuenta2,
					   "Ninguna Cuenta Recibe Movimiento"
					   with resume;

			end foreach

		end if

	end if

end foreach

end procedure