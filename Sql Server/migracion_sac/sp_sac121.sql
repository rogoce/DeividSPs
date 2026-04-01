-- Procedimiento que crea los presupuestos de las tablas de presupuestos por ramo y por zona

-- Creado    : 07/08/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac121;

create procedure "informix".sp_sac121(a_ano smallint)
returning integer,
          char(50);

define _monto_ramo	dec(16,2);
define _monto_zona	dec(16,2);
define _monto_total	dec(16,2);
define _monto_mes	dec(16,2);

define _zona_8		char(3);
define _cuenta_8	char(25);
define _mes			smallint;
define _porc_mes	dec(16,8);
define _cantidad	smallint;
define _cuenta		char(25);
define _ccosto		char(3);

let _zona_8   = "017";
let _cuenta_8 = "411030104";

select sum(monto)
  into _monto_ramo
  from sac:cglprera
 where ano = a_ano;

select sum(monto)
  into _monto_zona
  from sac:cglprezo
 where ano = a_ano;

if _monto_ramo <> _monto_zona then
	return 1, "Los presupuestos de Ramo y de Zona No Cuadran";
end if

delete from sac:cglpre02 where pre2_ano = a_ano;
delete from sac:cglpre01 where pre1_ano = a_ano;

-- Sin Incluir Zona 8

select sum(monto)
  into _monto_total
  from sac:cglprera
 where ano    = a_ano
   and cuenta <> _cuenta_8;

foreach
 select monto,
        ccosto
   into _monto_zona,
        _ccosto
   from sac:cglprezo
  where ano     = a_ano
    and ccosto <> _zona_8

	foreach
	 select monto,
	        mes,
			cuenta
	   into _monto_ramo,
	        _mes,
			_cuenta
       from sac:cglprera
      where ano     = a_ano
   	    and cuenta <> _cuenta_8

		let _porc_mes  = _monto_ramo / _monto_total;
		let _monto_mes = _monto_zona * _porc_mes;

		select count(*)
		  into _cantidad
		  from sac:cglpre01
		 where pre1_ano	   = a_ano
		   and pre1_cuenta = _cuenta
		   and pre1_ccosto = _ccosto;

		if _cantidad = 0 then

			insert into sac:cglpre01
			values (a_ano, _cuenta, _ccosto, today, 0, "informix");

		end if

		insert into sac:cglpre02
		values (a_ano, _cuenta, _ccosto, _mes, _monto_mes, 0.00);

	end foreach

end foreach

-- Solo la Zona 8

select sum(monto)
  into _monto_total
  from sac:cglprera
 where ano    = a_ano
   and cuenta = _cuenta_8;

foreach
 select monto,
        ccosto
   into _monto_zona,
        _ccosto
   from sac:cglprezo
  where ano    = a_ano
    and ccosto = _zona_8

	foreach
	 select monto,
	        mes,
			cuenta
	   into _monto_ramo,
	        _mes,
			_cuenta
       from sac:cglprera
      where ano    = a_ano
   	    and cuenta = _cuenta_8

		let _porc_mes  = _monto_ramo / _monto_total;
		let _monto_mes = _monto_zona * _porc_mes;

		select count(*)
		  into _cantidad
		  from sac:cglpre01
		 where pre1_ano	   = a_ano
		   and pre1_cuenta = _cuenta
		   and pre1_ccosto = _ccosto;

		if _cantidad = 0 then

			insert into sac:cglpre01
			values (a_ano, _cuenta, _ccosto, today, 0, "informix");

		end if

		insert into sac:cglpre02
		values (a_ano, _cuenta, _ccosto, _mes, _monto_mes, 0.00);

	end foreach

end foreach

-- Cuadre de Cuentas

foreach
 select pre1_cuenta,
        pre1_ccosto
   into _cuenta,
        _ccosto
   from sac:cglpre01
  where pre1_ano = a_ano

	let _monto_total = 0.00;

	foreach
	 select pre2_montomes,
	        pre2_periodo
	   into _monto_mes,
	        _mes
	   from sac:cglpre02
	  where pre2_ano    = a_ano
	    and pre2_cuenta = _cuenta
		and pre2_ccosto = _ccosto
	  order by pre2_periodo

		let _monto_total = _monto_total + _monto_mes;

		update sac:cglpre02
		   set pre2_montoacu = _monto_total
	     where pre2_ano      = a_ano
	       and pre2_cuenta   = _cuenta
		   and pre2_ccosto   = _ccosto
		   and pre2_periodo  = _mes;
		   		
	end foreach

	update sac:cglpre01
	   set pre1_monto  = _monto_total
	 where pre1_ano    = a_ano
	   and pre1_cuenta = _cuenta
	   and pre1_ccosto = _ccosto;

end foreach


return 0, "Actualizacion Exitosa";

end procedure