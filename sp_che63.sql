-- Verificacion de Cuentas Vs Auxiliar de Cheques

-- Creado    : 22/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_che63;

create procedure sp_che63(a_periodo char(7))
returning char(10),
          char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_requis		char(10);
define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _debito_aux		dec(16,2);
define _credito_aux		dec(16,2);
define _cod_aux			char(5);
define _cta_auxiliar 	char(1);
define _renglon			smallint;
define _origen_cheque	smallint;
define _cantidad		smallint;

set isolation to dirty read;


foreach
 select no_requis,
        origen_cheque
   into _no_requis,
        _origen_cheque
   from chqchmae
  where year(fecha_impresion)  = a_periodo[1,4]
    and month(fecha_impresion) = a_periodo[6,7]
	and pagado                 = 1

	foreach
	 select cuenta,
	        debito,
			credito,
			cod_auxiliar,
			renglon
	   into _cuenta,
	        _debito,
			_credito,
			_cod_aux,
			_renglon
	   from chqchcta
	  where no_requis = _no_requis
	    and cuenta like ("26410%")

		select sum(debito),
		       sum(credito)
		  into _debito_aux,
		       _credito_aux
		  from chqctaux
		 where no_requis = _no_requis
		   and cuenta    = _cuenta
		   and renglon   = _renglon;

		if _debito_aux is null then
			let _debito_aux = 0.00;
		end if

		if _credito_aux is null then
			let _credito_aux = 0.00;
		end if
		 

{		if _cod_aux is not null then
			
			let _debito_aux  = _debito_aux  + _debito;
			let _credito_aux = _credito_aux + _credito;
			
		end if  
}

		SELECT cta_auxiliar
		  INTO _cta_auxiliar 
		  FROM cglcuentas
		 WHERE cta_cuenta = _cuenta;

		if _cta_auxiliar = "S" Then		

			select count(*)
			  into _cantidad
			  from chqctaux
			 where no_requis = _no_requis
			   and cuenta    = _cuenta
		       and renglon   = _renglon;

{
			if _cantidad = 0 then

				insert into chqctaux (no_requis, renglon, cuenta, cod_auxiliar, debito, credito) 
				values (_no_requis, _renglon, _cuenta, _cod_aux, _debito, _credito);

			end if
}

{
			if _cantidad = 1 then

				update chqctaux
				   set debito    = _debito,
				       credito   = _credito
				 where no_requis = _no_requis
				   and cuenta    = _cuenta;

			end if
}			  																				

			if _cantidad <> 0 and
			   _cod_aux  is not null then

				if _origen_cheque = 1 then
			
					delete from chqctaux
					 where no_requis = _no_requis
					   and cuenta    = _cuenta
				       and renglon   = _renglon;

				end if

				return _no_requis,
				       _cuenta,
					   _debito,
					   _credito,
					   _debito_aux,
					   _credito_aux
					   with resume;

			end if
{
			if (_debito  - _debito_aux)  <> 0.00 or
			   (_credito - _credito_aux) <> 0.00 then

				return _no_requis,
				       _cuenta,
					   _debito,
					   _credito,
					   _debito_aux,
					   _credito_aux
					   with resume;

			end if
}
		end if

	end foreach

end foreach

end procedure







															