-- Actualizacion de Deuda de Agentes en Actualizacion de la remesa
 													   
--drop procedure rv_agtdeuda;

create procedure rv_agtdeuda(a_no_remesa char(10))
returning integer,
          char(100);

define _cod_agente	char(10);
define _renglon		integer;
define _saldo       dec(16,2);
define _monto       dec(16,2);
define _renglon_rem	integer;
define _cant        integer;

define _error		integer;

begin
on exception set _error
	return _error, "Error Actualizando Deuda de Agentes";
end exception

foreach
 select cod_agente,
		no_unidad,
		renglon,
		monto
   into _cod_agente,
        _renglon,
		_renglon_rem,
		_monto
   from cobredet
  where no_remesa = a_no_remesa
    and tipo_mov  = "O"

{	select saldo
	  into _saldo
	  from agtdeuda
	 where cod_agente = _cod_agente
	   and renglon    = _renglon;

	if _saldo is null then
		return 1, "La Deuda para este Agente no Existe, Renglon " || _renglon_rem;
	end if

	if _saldo < _monto then
		return 1, "El Pago para este Agente es Mayor al Saldo, Renglon " || _renglon_rem;
	end if
}
	let _cant = 0;

    select count(*)
	  into _cant
	  from agtdeuda
	 where cod_agente = _cod_agente
	   and renglon    = _renglon;

    if _cant = 0 Then
		return 1, "La Deuda para este Agente no Existe, Renglon " || _renglon_rem;
	end if
   
	update agtdeuda
	   set saldo      = saldo + _monto
	 where cod_agente = _cod_agente
	   and renglon    = _renglon;

end foreach

--DELETE FROM cobasiau WHERE no_remesa = a_no_remesa;
--DELETE FROM cobasien WHERE no_remesa = a_no_remesa;
--DELETE FROM cobreagt WHERE no_remesa = a_no_remesa;
--DELETE FROM cobredet WHERE no_remesa = a_no_remesa;
--DELETE FROM cobremae WHERE no_remesa = a_no_remesa;


end

return 0, "Actualizacion Exitosa";

end procedure