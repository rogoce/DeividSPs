-- Procedure que verifica los registros de planilla antes de poder actualizarlo a cheques

-- Creado    : 13/11/2009 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pla001;

create procedure sp_pla001(a_cod_payday char(10))
returning integer,
          char(100);

define _cuenta		char(25);
define _renglon		smallint;
define _no_cheque	char(10);
define _monto		dec(16,2);
define _monto_banco	dec(16,2);
define _cuenta_banc	char(25);
define _num_dist	smallint;
define _cantidad	smallint;
define _cod_auxil	char(5);

define _cta_cuenta	char(25);
define _cta_recibe	char(1);
define _cta_auxil	char(1);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(100);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Verificacion que las cuentas esten correctas

let _error = 0;

foreach
 select cuenta,
        renglon,
		cod_auxiliar
   into _cuenta,
        _renglon,
		_cod_auxil
   from plapayche
  where cod_payday = a_cod_payday
  order by renglon

	select cta_cuenta,
	       cta_recibe,
		   cta_auxiliar
	  into _cta_cuenta,
	       _cta_recibe
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	if _cta_cuenta is null then
		let _error = 1;
		return _renglon, "Cuenta " || trim(_cuenta) || " No Existe en Contabilidad" with resume;
		continue foreach;
	end if

	if _cta_recibe = "N" then
		let _error = 1;
		return _renglon, "Cuenta " || trim(_cuenta) || " No Recibe Movimiento" with resume;
	end if

	if _cta_auxiliar = "S" then

		if _cod_auxil is null then
			let _error = 1;
			return _renglon, "Cuenta " || trim(_cuenta) || " No Existe Auxiliar" with resume;
		end if

	end if

end foreach

-- Verificaciones para el Banco

foreach
 select no_cheque
   into _no_cheque
   from plapayche
  where cod_payday = a_cod_payday
  group by no_cheque
  order by no_cheque

	select sum(monto),
	       count(*)
	  into _monto,
	       _cantidad
	  from plapayche
     where cod_payday = a_cod_payday
	   and no_cheque  = _no_cheque;

	foreach
	 select monto_banco,
	        cuenta_banco,
			num_dist
	   into _monto_banco,
	        _cuenta_banc,
			_num_dist
	   from plapayche
      where cod_payday = a_cod_payday
	    and no_cheque  = _no_cheque
			exit foreach;
	end foreach

	if _monto <> _monto_banco then
		let _error = 1;
		return 1, "Cheque " || trim(_no_cheque) || " No Cuadra Montos con Monto del Banco" with resume;
	end if

	if _cantidad <> _num_dist then
		let _error = 1;
		return 1, "Cheque " || trim(_no_cheque) || " Cantidad de Registros Incorrecta" with resume;
	end if

	select cta_cuenta,
	       cta_recibe
	  into _cta_cuenta,
	       _cta_recibe
	  from cglcuentas
	 where cta_cuenta = _cuenta_banc;

	if _cta_cuenta is null then
		let _error = 1;
		return 1, "Cheque " || trim(_no_cheque) || " Cuenta Banco " || trim(_cuenta_banc) || " No Existe en Contabilidad" with resume;
		continue foreach;
	end if

	if _cta_recibe = "N" then
		let _error = 1;
		return 1, "Cheque " || trim(_no_cheque) || " Cuenta Banco " || trim(_cuenta_banc) || " No Recibe Movimiento" with resume;
	end if

	
end foreach

if _error <> 0 then
	return 1, "Proceso Finalizado por Errores";	
end if

update plapayday
   set sac_asientos = 1
 where cod_payday   = a_cod_payday;

end

return 0, "Actualizacion Exitosa";

end procedure
