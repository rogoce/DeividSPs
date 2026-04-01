-- Borrar transaccion de chqchrec, ya que la anularon.
-- Proyecto Unificacion de los Cheques de Salud
-- Creado: 11/05/2005 - Autor: Armando Moreno M.

drop procedure sp_rec95bk;

create procedure "informix".sp_rec95bk(_no_requis char(10))

define _transaccion		char(10);
define _anular_nt		char(10);
define _periodo			char(7);
define _monto			dec(16,2);
define _pagado			smallint;
define _cantidad		smallint;
define _no_cheque		integer;
define _anulado			smallint;
define _control_flujo   smallint;
define _error			integer;
define _cod_banco       char(3);
define _cod_chequera    char(3);

--set debug file to "sp_rec95.trc";
--trace on;
set isolation to dirty read;

-- Borrar todo en cascada (requisicion)

		update rectrmae
		   set no_requis = null
		 where no_requis = _no_requis;

		delete from chqchpoa
		 where no_requis = _no_requis;

		delete from chqchpol
		 where no_requis = _no_requis;

		delete from chqchdes
		 where no_requis = _no_requis;

		delete from chqchrec
		 where no_requis = _no_requis;

		delete from chqchcta
		 where no_requis = _no_requis;

		delete from chqchmae
		 where no_requis = _no_requis;

{foreach

	select transaccion,
	 	   anular_nt,
	 	   monto,
	 	   no_requis,
	 	   periodo
	 into  _transaccion,
		   _anular_nt,
		   _monto,
		   _no_requis,
		   _periodo	
	 from rectrmae
	where (anular_nt is not null
	   or anular_nt <> "")
	  and actualizado = 1
	  and (no_requis is not null
	   or no_requis <> "")
	  and numrecla[1,2] = "18"
	order by 1

	  and periodo between "2005-05" and "2005-12"
	update rectrmae
	   set no_requis = null
	 where transaccion = _transaccion;

       RETURN _transaccion,
			  _anular_nt,
			  _monto,
			  _no_requis,
			  _periodo	with resume;

end foreach


select contro_anular_nt,l_flujo
  into _contro_monto,l_flujo
  from chqcheq_no_requis,u
 where cod_ban_periodo	co    = _cod_banco
   and cod_chequera	= _cod_chequera;

if _pagado = 0 then

	select count(*)
	  into _cantidad
	  from chqchrec
	 where no_requis = _no_requis;

	select monto
	  into _monto
	  from chqchrec
	 where no_requis   = _no_requis
	   and transaccion = a_transaccion;

	if _cantidad > 1 then

		update rectrmae
		   set no_requis = null
		 where no_requis = _no_requis
		   and no_requis = a_transaccion;

		delete from chqchrec
		 where no_requis   = _no_requis
		   and transaccion = a_transaccion;

		update chqchmae
		   set monto     = monto - _monto
		 where no_requis = _no_requis;

	else
		-- Borrar todo en cascada (requisicion)

		update rectrmae
		   set no_requis = null
		 where no_requis = _no_requis;

		delete from chqchpoa
		 where no_requis = _no_requis;

		delete from chqchpol
		 where no_requis = _no_requis;

		delete from chqchdes
		 where no_requis = _no_requis;

		delete from chqchrec
		 where no_requis = _no_requis;

		delete from chqchcta
		 where no_requis = _no_requis;

		delete from chqchmae
		 where no_requis = _no_requis;

	end if

	if _control_flujo = 1 then
		update chqchequ
		   set monto_disponible = monto_disponible - _monto
		 where cod_banco 	= _cod_banco
		   and cod_chequera = _cod_chequera;
	end if

elif _pagado = 1 and _anulado = 1 then
	return 0,"";

elif _pagado = 1 then

	return 1, "No Puede anular esta Transaccion por que esta pagada en el cheque: " || _no_cheque;

end if

return 0,"";}

end procedure
