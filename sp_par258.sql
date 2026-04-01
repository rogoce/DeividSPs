-- Procedure que valida que la informacion entre los cheques de deivid y los comprobantes de sac

drop procedure sp_par258;

create procedure "informix".sp_par258()
returning char(10),
          integer,
		  char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50);	

define _tipo		smallint;
define _fecha		date;
define _monto		dec(16,2);
define _cuenta		char(25);
define _cheques		dec(16,2);
define _sac			dec(16,2);
define _nombre		char(50);
define _fecha_eval	date;

define _no_requis	char(10);
define _tipo_desc	char(10);
define _notrx		integer;

set isolation to dirty read;

let _fecha_eval = "29/12/2008";

create temp table tmp_validar(
tipo	smallint,
notrx	integer,
cuenta	char(25),
cheques	dec(16,2),
sac		dec(16,2)
) with no log;

-- Verificacion de Cheques Pagados

let _tipo = 1;

foreach
 select sac_notrx,
        cuenta,
        (debito - credito)
   into _notrx,
        _cuenta,
        _monto
   from chqchcta
  where tipo      = _tipo
	and fecha     >= _fecha_eval
	and fecha     < TODAY

	insert into tmp_validar
	values (_tipo, _notrx, _cuenta, _monto, 0);

end foreach

foreach
 select res_notrx,
        res_cuenta,
		(res_debito - res_credito)
   into _notrx,
        _cuenta,
		_monto
   from cglresumen
  where res_fechatrx         >= _fecha_eval
    and res_fechatrx         < TODAY
    and res_comprobante      like "CHE%"
	and res_comprobante[8,8] = 1

	insert into tmp_validar
	values (_tipo, _notrx, _cuenta, 0, _monto);

end foreach

-- Verificacion de Cheques Anulados

let _tipo = 2;

foreach
 select sac_notrx,
        cuenta,
        (debito - credito)
   into _notrx,
        _cuenta,
        _monto
   from chqchcta
  where tipo      = _tipo
	and fecha     >= _fecha_eval
	and fecha     < TODAY

	insert into tmp_validar
	values (_tipo, _notrx, _cuenta, _monto, 0);

end foreach

foreach
 select res_notrx,
        res_cuenta,
		(res_debito - res_credito)
   into _notrx,
        _cuenta,
		_monto
   from cglresumen
  where res_fechatrx         >= _fecha_eval
    and res_fechatrx         < TODAY
    and res_comprobante      like "CHE%"
	and res_comprobante[8,8] = 2

	insert into tmp_validar
	values (_tipo, _notrx, _cuenta, 0, _monto);

end foreach

foreach
 select tipo,
        notrx,
        cuenta,
        sum(cheques),
        sum(sac)
   into _tipo,
        _notrx,
        _cuenta,
        _cheques,
        _sac
   from tmp_validar
  group by 1, 2, 3
  order by 1, 2, 3

	if _tipo = 1 then
		let _tipo_desc = "PAGADOS";
	else
		let _tipo_desc = "ANULADOS";
	end if
   
	if _cheques <> _sac then

		select cta_nombre
		  into _nombre
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		return _tipo_desc,
		       _notrx,
		       _cuenta,
		       _cheques,
		       _sac,
			   (_cheques - _sac),
			   _nombre
		       with resume;                     

	end if

end foreach

drop table tmp_validar;
 
return "",
       null,
       "",
       0.00,
       0.00,
	   0.00,
	   ""
       with resume;                     

end procedure
