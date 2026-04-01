-- Verificacion de cuenta de mayor vs cuenta de auxiliar

-- creado: 

drop procedure sp_sac50;

create procedure "informix".sp_sac50()
returning char(10),
          smallint,
		  char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(5),
		  char(1),
		  smallint,
		  char(5),
		  date;

define _no_requis		char(10);
define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _cta_auxiliar	char(1);
define _debito2			dec(16,2);
define _credito2		dec(16,2);
define _renglon			smallint;
define _cod_auxiliar	char(5);
define _anulado			smallint;
define _cantidad		smallint;
define _cod_agente		char(5);
define _fecha_cheque	date;

define _ano_actual		smallint;
define _fecha_evaluar	date;

define _error			smallint;
define _error_desc		char(50);

-- Creacion de los registros de la cuenta auxiliar

call sp_sac74() returning _error, _error_desc;

set isolation to dirty read;

let _ano_actual = year(today);

let _fecha_evaluar = MDY(1, 1, _ano_actual);

foreach
 select no_requis,
        anulado,
		cod_agente,
		fecha_impresion
   into _no_requis,
        _anulado,
		_cod_agente,
		_fecha_cheque
   from chqchmae
  where pagado       = 1
	and sac_asientos <> 2
	
	foreach
	 select cuenta,
	        debito,
	        credito,
			renglon,
			cod_auxiliar
	   into _cuenta,
	        _debito,
	        _credito,
			_renglon,
			_cod_auxiliar
	   from chqchcta
	  where no_requis = _no_requis
	    
		select cta_auxiliar
		  into _cta_auxiliar
		  from cglcuentas
		 where cta_cuenta = _cuenta;
				
		if _cta_auxiliar = "S" then

			select count(*)
			  into _cantidad
			  from chqctaux
			 where no_requis = _no_requis
			   and renglon   = _renglon;

			if _cantidad = 0 then

				if _cod_auxiliar is null then

					if _cod_agente is not null then
					
						let _cod_agente = "A" || _cod_agente[2,5];

--{
						insert into chqctaux (no_requis, renglon, cuenta, cod_auxiliar, debito, credito)
						values (_no_requis, _renglon, _cuenta, _cod_agente, _debito, _credito);
--}
					end if

				
					return _no_requis,
					       _renglon,
						   _cuenta,
						   _debito,
						   _credito,
						   null,
						   null,
						   _cod_auxiliar,
						   _cta_auxiliar,
						   _anulado,
						   _cod_agente,
						   _fecha_cheque
						   with resume;


				else
					insert into chqctaux (no_requis, renglon, cuenta, cod_auxiliar, debito, credito)
					values (_no_requis, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

				end if

			else

				select sum(debito),
				       sum(credito)
				  into _debito2,
				       _credito2
				  from chqctaux
				 where no_requis = _no_requis
				   and renglon   = _renglon;

				if _debito2 is null then
					let _debito2 = 0.00;
				end if

				if _credito2 is null then
					let _credito2 = 0.00;
				end if

				if (_debito - _credito) <> (_debito2 - _credito2) then

{
					if _cantidad = 1 then
					
						update chqctaux
						   set debito    = _debito,
						       credito   = _credito
					     where no_requis = _no_requis
					       and renglon   = _renglon;
					       
					end if										
--}

					return _no_requis,
					       _renglon,
						   _cuenta,
						   _debito,
						   _credito,
						   _debito2,
						   _credito2,
						   _cod_auxiliar,
						   _cta_auxiliar,
						   _anulado,
						   _cod_agente,
						   _fecha_cheque
						   with resume;

				end if

			end if

		end if
	  
	end foreach
		              
end foreach

foreach
 select no_requis,
        anulado,
		cod_agente,
		fecha_anulado
   into _no_requis,
        _anulado,
		_cod_agente,
		_fecha_cheque
   from chqchmae
  where anulado       = 1
	and pagado        = 1
	and sac_anulados  <> 2

	foreach
	 select cuenta,
	        debito,
	        credito,
			renglon,
			cod_auxiliar
	   into _cuenta,
	        _debito,
	        _credito,
			_renglon,
			_cod_auxiliar
	   from chqchcta
	  where no_requis = _no_requis
	    
		select cta_auxiliar
		  into _cta_auxiliar
		  from cglcuentas
		 where cta_cuenta = _cuenta;
				
		if _cta_auxiliar = "S" then

			select count(*)
			  into _cantidad
			  from chqctaux
			 where no_requis = _no_requis
			   and renglon   = _renglon;

			if _cantidad = 0 then

				if _cod_auxiliar is null then

					if _cod_agente is not null then
					
						let _cod_agente = "A" || _cod_agente[2,5];

						insert into chqctaux (no_requis, renglon, cuenta, cod_auxiliar, debito, credito)
						values (_no_requis, _renglon, _cuenta, _cod_agente, _debito, _credito);

					end if
				
					return _no_requis,
					       _renglon,
						   _cuenta,
						   _debito,
						   _credito,
						   null,
						   null,
						   _cod_auxiliar,
						   _cta_auxiliar,
						   _anulado,
						   _cod_agente,
						   _fecha_cheque
						   with resume;

				end if

			else

				select sum(debito),
				       sum(credito)
				  into _debito2,
				       _credito2
				  from chqctaux
				 where no_requis = _no_requis
				   and renglon   = _renglon;

				if _debito2 is null then
					let _debito2 = 0.00;
				end if

				if _credito2 is null then
					let _credito2 = 0.00;
				end if

				if (_debito - _credito) <> (_debito2 - _credito2) then

{
					if _cantidad = 1 then
					
						update chqctaux
						   set debito    = _debito,
						       credito   = _credito
					     where no_requis = _no_requis
					       and renglon   = _renglon;
					       
					end if										
}

					return _no_requis,
					       _renglon,
						   _cuenta,
						   _debito,
						   _credito,
						   _debito2,
						   _credito2,
						   _cod_auxiliar,
						   _cta_auxiliar,
						   _anulado,
						   _cod_agente,
						   _fecha_cheque
						   with resume;

				end if

			end if

			-- Verificacion de que Exista el Auxiliar en SAC

		   foreach
			select cod_auxiliar
			  into _cod_auxiliar
			  from chqctaux
			 where no_requis = _no_requis
			   and renglon   = _renglon

				select count(*)
				  into _cantidad
				  from cglauxiliar
				 where aux_cuenta  = _cuenta
				   and aux_tercero = _cod_auxiliar;

				if _cantidad = 0 then

					return _no_requis,
					       _renglon,
						   _cuenta,
						   _debito,
						   _credito,
						   null,
						   null,
						   _cod_auxiliar,
						   _cta_auxiliar,
						   _anulado,
						   _cod_agente,
						   _fecha_cheque
						   with resume;

				end if

			end foreach

		end if
	  
	end foreach
		              
end foreach

return "0",
       0,
	   "",
	   0,
	   0,
	   0,
	   0,
	   "",
	   "",
	   0,
	   "",
	   "";

end procedure