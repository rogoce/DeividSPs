-- Actualizacion de los Saldos de los Pagos de las Cobranzas Legales en Actualizacion de la remesa
-- Creado por: Amado Perez M - 11/01/2013
 													   
drop procedure sp_cob315;

create procedure sp_cob315(a_no_remesa char(10))
returning integer,
          char(100);

define _doc_remesa	char(20);
define _saldo       dec(16,2);
define _monto       dec(16,2);
define _renglon_rem	integer;
define _comis_desc     	 smallint;
define _monto_descontado dec(16,2);

define _error		integer;

begin
on exception set _error
	return _error, "Error Actualizando Pago Cobranza Externa";
end exception

foreach
 select doc_remesa,
		renglon,
		monto,
	    comis_desc,
	    monto_descontado
   into _doc_remesa,
        _renglon_rem,
		_monto,
	    _comis_desc,
	    _monto_descontado
   from cobredet
  where no_remesa = a_no_remesa
    and tipo_mov  = "L"

    -- Si tiene comision descontada se le resta del monto

    if _comis_desc = 1 then	
		let _monto = _monto - _monto_descontado;
	end if

	select saldo
	  into _saldo
	  from coboutleg
	 where no_documento = _doc_remesa;

	if _saldo is null then
		return 1, "La Cobranza Externa para esta Poliza no Existe, Renglon " || _renglon_rem;
	end if

	if _saldo < _monto then
		return 1, "El Pago para esta Poliza es Mayor al Saldo, Renglon " || _renglon_rem;
	end if

	update coboutleg
	   set saldo      = saldo - _monto, 
	       pagos      = pagos + _monto
	 where no_documento = _doc_remesa;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure