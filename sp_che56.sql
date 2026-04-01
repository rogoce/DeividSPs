--actualizar el periodo de pago a un cliente en chqchmae y cliclien

--drop procedure sp_che56;

create procedure sp_che56(a_cod_cliente char(10), a_valor smallint
) returning char(100);

define _nombre			char(100);
define _cod_banco       char(3);
define _cod_chequera    char(3);

SET ISOLATION TO DIRTY READ;

foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '018'

	exit foreach;

end foreach

if a_valor = 0 or a_valor = 1 or a_valor = 2 then
else
	return 'Periodo de pago debe ser 0, 1 o 2';
end if

select nombre
  into _nombre
  from cliclien
 where cod_cliente = a_cod_cliente;

 update	cliclien
    set periodo_pago  = a_valor
  where cod_cliente   = a_cod_cliente;

 update	chqchmae
    set periodo_pago  = a_valor
  where cod_cliente   = a_cod_cliente
    and cod_banco     = _cod_banco
    and cod_chequera  = _cod_chequera;

return _nombre;

end procedure
