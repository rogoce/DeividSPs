-- Procedimiento que valida que no se puedan usar las cuentas de gastos para pagar

-- Creado    : 16/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_che106;

create procedure "informix".sp_che106(
a_cuenta char(25),
a_monto	 dec(16,2),
a_fecha	 date	
) returning integer,
          char(50);

define _monto	dec(16,2);
define _ano		smallint;

if a_cuenta[1,3] = "600" then
	return 1, "No se puede utilizar la cuenta " || trim(a_cuenta) || " para pagar";
end if

if a_cuenta[1,5] = "26620" then

	let _ano = year(a_fecha);

	select sum(sldet_saldop)
	  into _monto
	  from cglsaldodet
	 where sldet_tipo    = "01"
	   and sldet_cuenta  = a_cuenta
	   and sldet_ano     = _ano
	   and sldet_periodo = 12;
	
	if _monto is null then
		let _monto = 0.00;
	end if

	let _monto = _monto * -1;

	if _monto  <= 0 or 
	   a_monto > _monto then
		return 1, "No hay fondos suficientes para realizar el pago";
	end if

end if

return 0, "Actualizacion Exitosa";

end procedure