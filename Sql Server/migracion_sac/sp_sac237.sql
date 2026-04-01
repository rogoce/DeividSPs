-- Procedure que informa de los registros automaticos

drop procedure sp_sac237;

create procedure "informix".sp_sac237(a_periodo char(7))
returning char(3),
          char(3),
          char(25),
          char(50),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(7);
           
define _origen		char(3);
define _cuenta		char(25);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _neto		dec(16,2);
define _nombre_cta	char(50);
define _cta_aut		char(3);

foreach
 select	res_cuenta[1,3],
        res_origen,
        res_cuenta,
        sum(res_debito),
		sum(res_credito)
   into _cta_aut,
        _origen,
        _cuenta,
        _debito,
		_credito
   from cglresumen
  where year(res_fechatrx)  = a_periodo[1,4]
    and month(res_fechatrx) = a_periodo[6,7]
	and res_origen         <> "CGL"
  group by 1, 2, 3
  order by 1, 2, 3

	let _neto = _debito - _credito;

	select cta_nombre
	  into _nombre_cta
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	return _cta_aut,
	       _origen,
	       _cuenta,
		   _nombre_cta,
		   _debito,
		   _credito,
		   _neto,
		   a_periodo
		   with resume;

end foreach

end procedure
