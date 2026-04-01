-- Procedure que Genera el Asiento de Diario en el Mayor General

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac82;

create procedure sp_sac82(
a_cuenta 	char(25), 
a_tipo_comp	smallint,
a_fecha		date
) returning char(10),
            smallint,
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2);

define _no_requis	char(10);
define _renglon 	smallint;
define _cantidad	smallint;
define _debito1		dec(16,2);
define _credito1	dec(16,2);
define _debito2		dec(16,2);
define _credito2	dec(16,2);
define _cod_auxiliar	char(5);

if a_tipo_comp = 2 then

	foreach
	 select c.no_requis,
	        c.renglon,
			c.debito,
			c.credito
	   into _no_requis,
	        _renglon,
			_debito1,
			_credito1
	   from chqchmae m, chqchcta c
	  where m.no_requis     = c.no_requis
	    and m.fecha_anulado = a_fecha
		and c.cuenta        = a_cuenta
		and c.tipo          = a_tipo_comp
	
		select count(*)
		  into _cantidad
		  from chqctaux
		 where no_requis = _no_requis
		   and renglon   = _renglon
		   and cuenta    = a_cuenta;
		
		let _debito2  = 0;
		let _credito2 = 0;

		if _cantidad = 0 then

			foreach
			 select debito,
			        credito,
					cod_auxiliar
			   into _credito2,
					_debito2,
			        _cod_auxiliar
			   from chqctaux
			  where no_requis = _no_requis
			    and cuenta    = a_cuenta
				and renglon   <> _renglon
								
				insert into chqctaux  (no_requis, renglon, cuenta, cod_auxiliar, debito, credito)
				values (_no_requis, _renglon, a_cuenta, _cod_auxiliar, _debito2, _credito2);					

			end foreach

			return _no_requis, 
			       _renglon,
				   _debito1,
				   _credito1,
				   _debito2,
				   _credito2
				   with resume;

		end if

	end foreach

end if

return "", "", 0, 0, 0, 0;

end procedure