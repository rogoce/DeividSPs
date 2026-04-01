-- Procedimiento que analizas toda la informacion de una caja
--
-- Creado    : 26/04/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob278;

create procedure sp_cob278(a_no_caja char(10))
returning char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _cod_chequera	char(3);
define _fecha			date;
define _no_remesa 		char(10);
define _tipo_mov		char(1);

define _monto_chequeo	dec(16,2);
define _monto_detalle	dec(16,2);
define _monto_pago		dec(16,2);
define _monto_banco		dec(16,2);
define _monto			dec(16,2);
define _monto_descon	dec(16,2);

select cod_chequera,
       fecha
  into _cod_chequera,
       _fecha
  from cobcieca
 where no_caja = a_no_caja;

foreach
 select	monto_chequeo,
        no_remesa
   into _monto_chequeo,
        _no_remesa
   from cobremae
  where fecha        = _fecha
    and cod_chequera = _cod_chequera
	and actualizado  = 1

	let _monto_detalle = 0.00;

   foreach	
	select monto,
	       monto_descontado,
		   tipo_mov
	  into _monto_banco,
	       _monto_descon,
		   _tipo_mov
	  from cobredet
	 where no_remesa = _no_remesa

		if _tipo_mov   = 'M'  and
		   _monto_descon <> 0 then
			let _monto = 0;
		else
			let _monto = _monto_banco;
		end if

		let _monto_banco   = _monto - _monto_descon;
		let _monto_detalle = _monto_detalle +  _monto_banco;

	end foreach

	select sum(importe)
	  into _monto_pago
	  from cobrepag
	 where no_remesa = _no_remesa;

	if _monto_chequeo <> _monto_detalle or
	   _monto_chequeo <> _monto_pago    or
	   _monto_detalle <> _monto_pago    then

		return _no_remesa,
		       _monto_chequeo,
			   _monto_detalle,
			   _monto_pago
			   with resume;

	end if

end foreach

return "0",
        0,
		0,
		0;

end procedure

