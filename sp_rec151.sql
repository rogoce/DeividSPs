-- Procedure que realiza el cambio automatico de la distribucion de reaseguro para los reclamos
-- que tienen excesos de perdida.

drop procedure sp_rec151;

create procedure sp_rec151(
a_transaccion	char(10),
a_tipo_cambio	char(1),
a_ib_trans		dec(16,2),
a_in_acum		dec(16,2),
a_prioridad		dec(16,2)
) returning integer,
            char(100);

define _no_tranrec		char(10);
define _cantidad		smallint;
define _sac_asientos	smallint;
define _serie			smallint;
define _cod_contrato	char(5);
define _orden			smallint;

define _porc_ret		dec(16,4);
define _monto_ret		dec(16,2);
define _porc_reas		dec(16,4);
define _monto_reas		dec(16,2);
define _calculo_ok		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Procesos de Verificacion

select count(*)
  into _cantidad
  from rectrmae
 where transaccion = a_transaccion;

if _cantidad = 0 then
	return 1, "No Hay Transaccion Para " || a_transaccion;
end if

if _cantidad > 1 then
	return 1, "Hay Mas de Una Transaccion Para " || a_transaccion;
end if

select no_tranrec,
       sac_asientos
  into _no_tranrec,
       _sac_asientos
  from rectrmae
 where transaccion = a_transaccion;

if _sac_asientos = 2 then
	return 1, "Ya se Generaron los Asientos para " || a_transaccion;
end if

select count(*)
  into _cantidad
  from rectrrea
 where no_tranrec    = _no_tranrec
   and tipo_contrato = 1;

if _cantidad = 0 then
	return 1, "No Hay Contrato de Retencion Para " || a_transaccion;
end if

if _cantidad > 1 then
	return 1, "Hay Mas de Un Contrato de Retencion Para " || a_transaccion;
end if

select count(*)
  into _cantidad
  from rectrrea
 where no_tranrec    = _no_tranrec
   and tipo_contrato = 6;

if _cantidad > 1 then
	return 1, "Hay Mas de Un Contrato de Exceso de Perdida Para " || a_transaccion;
end if

select cod_contrato
  into _cod_contrato
  from rectrrea
 where no_tranrec    = _no_tranrec
   and tipo_contrato = 1;

select serie
  into _serie
  from reacomae
 where cod_contrato = _cod_contrato;

select count(*)
  into _cantidad
  from reacomae
 where serie         = _serie
   and tipo_contrato = 6;

if _cantidad = 0 then
	return 1, "No Hay Contrato de Exceso de Perdida Para el Año" || _serie;
end if

if _cantidad > 1 then
	return 1, "Hay Mas de Un Contrato de Exceso de Perdida Para el Año " || _serie;
end if

let _calculo_ok = 0;

if a_tipo_cambio = "$" then

	-- a_ib_trans = Variacion de la Transaccion
	-- a_in_acum  = Variacion Acumulada Neto

	let _monto_ret  = a_ib_trans - a_in_acum;
	let _porc_ret   = _monto_ret / a_ib_trans * 100;
	let _monto_reas = a_ib_trans - _monto_ret;
	let _porc_reas  = _monto_reas / a_ib_trans * 100;
	let _calculo_ok = 1;

elif a_tipo_cambio = "*" then

	let _monto_ret  = a_ib_trans - (a_in_acum - a_prioridad);
	let _porc_ret   = _monto_ret / a_ib_trans * 100;
	let _monto_reas = a_ib_trans - _monto_ret;
	let _porc_reas  = _monto_reas / a_ib_trans * 100;
	let _calculo_ok = 1;

elif a_tipo_cambio = "?" then

	-- a_ib_trans = Variacion de la Transaccion
	-- a_in_acum  = Variacion Acumulada Exceso

	let a_ib_trans = abs(a_ib_trans);

	if a_in_acum >= a_ib_trans then

		let _monto_ret  = 0.00;
		let _porc_ret   = 0.00;
		let _monto_reas = a_ib_trans;
		let _porc_reas  = 100;
		let _calculo_ok = 1;
		
	else

		let _monto_reas = a_in_acum;
		let _porc_reas  = _monto_reas / a_ib_trans * 100;
		let _monto_ret  = a_ib_trans - _monto_reas;
		let _porc_ret   = _monto_ret / a_ib_trans * 100;
		let _calculo_ok = 1;

	end if

end if

if _calculo_ok = 1 then

	update rectrrea
	   set porc_partic_suma  = _porc_ret,
	       porc_partic_prima = _porc_ret
	 where no_tranrec        = _no_tranrec
	   and tipo_contrato     = 1;

	select cod_contrato
	  into _cod_contrato
	  from reacomae
	 where serie         = _serie
	   and tipo_contrato = 6;

	select count(*)
	  into _cantidad
	  from rectrrea
	 where no_tranrec    = _no_tranrec
	   and tipo_contrato = 6;

	if _cantidad = 0 then

		select max(orden)
		  into _orden
		  from rectrrea
		 where no_tranrec = _no_tranrec;

		let _orden = _orden + 1;

		insert into rectrrea (no_tranrec, orden, cod_contrato, porc_partic_suma, porc_partic_prima, tipo_contrato, subir_bo)
		values (_no_tranrec, _orden, _cod_contrato, _porc_reas, _porc_reas, 6, 1);
	
	else

		update rectrrea
		   set porc_partic_suma  = _porc_reas,
		       porc_partic_prima = _porc_reas
		 where no_tranrec        = _no_tranrec
		   and tipo_contrato     = 6;

	end if

end if

end 

return 0, "Actualizacion Exitosa";

end procedure
