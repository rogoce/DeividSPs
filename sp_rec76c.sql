-- (Proceso diario) para buscar las requisiciones de firma electronica
-- Para poder agregar mas transacciones de reclamos a una misma 

-- Modificado: 14/06/2006 - Autor: Armando Moreno Montenegro

drop procedure sp_rec76c;

create procedure sp_rec76c(a_transaccion char(10))
 returning  char(10),	--no_requis
			smallint;

define _no_requis		  char(10);
define _no_reclamo		  char(10);
define _no_poliza         char(10);
define _cod_ramo          char(3);
define _firma_electronica smallint;
define _cant,_cant2       integer;
define _cod_banco         char(3);
define _cod_chequera      char(3);
define _mon				  decimal(16,2);

SET ISOLATION TO DIRTY READ;

let _mon = 0;

foreach
	select no_reclamo
	  into _no_reclamo
	  from rectrmae
	 where transaccion = a_transaccion
	   and actualizado = 1
	exit foreach;
end foreach

select no_poliza
  into _no_poliza
  from recrcmae
 where actualizado = 1
   and no_reclamo  = _no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where actualizado = 1
   and no_poliza   = _no_poliza;

if _cod_ramo in ("018", "002", "020", "004", "023", "016", "019") then	-- Se agrego automovil, no existia esta validacion Amado 9/3/2010

	select count(*)
	  into _cant
	  from chqchrec c, chqchmae e
	 where c.no_requis   = e.no_requis
	   and c.transaccion = a_transaccion
	   and e.anulado     = 0;

	if _cant > 0 then

	  foreach
		select c.no_requis,
		       c.monto
		  into _no_requis,
		       _mon
		  from chqchrec c, chqchmae e
		 where c.no_requis   = e.no_requis
		   and c.transaccion = a_transaccion
		   and e.anulado     = 0

		  exit foreach;

	  end foreach

	 -- if _mon = 0 then
	--	return "",0;
	 -- end if

	  foreach
			select cod_banco,
			       cod_chequera
			  into _cod_banco,
				   _cod_chequera
			  from chqbanch
			 where cod_ramo = _cod_ramo

			select firma_electronica
			  into _firma_electronica
			  from chqchequ
			 where cod_banco    = _cod_banco
			   and cod_chequera	= _cod_chequera;

			let _cant = 0;

			if _firma_electronica = 1 then	--es chequera de firma electronica
				 select	count(*)
				   into	_cant
				   from	chqchmae
				  where no_requis     = _no_requis
					and anulado       = 0
					and origen_cheque = "3"
					and cod_banco     = _cod_banco
					and cod_chequera  = _cod_chequera
					and en_firma	  in (0, 4, 5); -- Se agrego automovil, no existia esta validacion Amado 9/3/2010

	 --			  where autorizado    = 1

				 select	count(*)
				   into	_cant2
				   from	chqchmae
				  where no_requis     = _no_requis
					and anulado       = 1
					and origen_cheque = "3"
					and cod_banco     = _cod_banco
					and cod_chequera  = _cod_chequera;
  --				  where autorizado    = 1

				 if _cant > 0 then	--no esta en firma, si se puede anular la nt.
					return _no_requis,0;
				 else
					if _cant2 > 0 then
						return _no_requis,0;
					end if
					return _no_requis,1;
				 end if
			end if

	  end foreach

	end if

end if
return "",0;
end procedure
