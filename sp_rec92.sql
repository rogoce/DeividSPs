-- Convertir los reaseguros de reclamos a nivel de transacciones

-- Creado    : 04/08/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec92;

create procedure sp_rec92()
returning integer,
          char(50);

define _no_tranrec	char(10);
define _no_reclamo	char(10);
define _error		integer;

set isolation to dirty read;

delete from rectrref;
delete from rectrrea;

begin 
on exception set _error
	return _error, "Error en la Transaccion " || _no_reclamo;
end exception

foreach
 select no_tranrec,
 		no_reclamo
   into _no_tranrec,
   		_no_reclamo
   from rectrmae
  where actualizado = 1
--  and no_tranrec  = "02844"
--	and periodo     = "2004-07"

	delete from rectrref where no_tranrec = _no_tranrec;
	delete from rectrrea where no_tranrec = _no_tranrec;

	insert into rectrrea(
	no_tranrec,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima,
	tipo_contrato
	)
	select
	_no_tranrec,
	r.orden,
	r.cod_contrato,
	r.porc_partic_suma,
	r.porc_partic_prima,
	c.tipo_contrato
	 from recreaco r, reacomae c
	where r.no_reclamo   = _no_reclamo
	  and r.cod_contrato = c.cod_contrato;	 

	insert into rectrref(
	no_tranrec,
	orden,
	cod_coasegur,
	cod_contrato,
	porc_partic_reas
	)
	select
	_no_tranrec,
	orden,
	cod_coasegur,
	cod_contrato,
	porc_partic_reas
	from recreafa
	where no_reclamo = _no_reclamo;	 

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
