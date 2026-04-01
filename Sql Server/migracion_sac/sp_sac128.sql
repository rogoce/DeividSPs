-- Procedimiento que crea los registros para el presupuesto de gastos

-- Creado    : 28/08/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sac128;

create procedure "informix".sp_sac128(a_ano smallint)
returning integer,
          char(50);

define _cuenta		char(25);
define _monto_ene	dec(16,2);
define _monto_feb	dec(16,2);
define _monto_mar	dec(16,2);
define _monto_abr	dec(16,2);
define _monto_may	dec(16,2);
define _monto_jun	dec(16,2);
define _monto_jul	dec(16,2);
define _monto_ago	dec(16,2);
define _monto_sep	dec(16,2);
define _monto_oct	dec(16,2);
define _monto_nov	dec(16,2);
define _monto_dic	dec(16,2);

define _periodo		smallint;
define _monto_mes	dec(16,2);
define _monto_acu	dec(16,2);

define _error	integer;

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Actualizar Registros";
end exception

delete from sac:cglpre03 where pre3_ano = a_ano;

foreach
 select cuenta,
		ene,
		feb,
		mar,
		abr,
		may,
		jun,
		jul,
		ago,
		sep,
		oct,
		nov,
		dic
   into _cuenta,
        _monto_ene,
		_monto_feb,
		_monto_mar,
		_monto_abr,
		_monto_may,
		_monto_jun,
		_monto_jul,
		_monto_ago,
		_monto_sep,
		_monto_oct,
		_monto_nov,
		_monto_dic
  from deivid_tmp:cglpregas

	insert into sac:cglpre03 values (a_ano, _cuenta, 1,  _monto_ene, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 2,  _monto_feb, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 3,  _monto_mar, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 4,  _monto_abr, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 5,  _monto_may, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 6,  _monto_jun, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 7,  _monto_jul, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 8,  _monto_ago, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 9,  _monto_sep, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 10, _monto_oct, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 11, _monto_nov, 0.00);
	insert into sac:cglpre03 values (a_ano, _cuenta, 12, _monto_dic, 0.00);

	let _monto_acu = 0;
		     
	foreach
	 select pre3_periodo,
			pre3_montomes
	   into _periodo,
	        _monto_mes 
	   from sac:cglpre03
	  where pre3_ano    = a_ano
	    and pre3_cuenta = _cuenta
	  order by pre3_periodo
	
		let _monto_acu = _monto_acu + _monto_mes;

		update sac:cglpre03
		   set pre3_montoacu = _monto_acu
	     where pre3_ano      = a_ano
	       and pre3_cuenta   = _cuenta
		   and pre3_periodo  = _periodo;

	end foreach

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure