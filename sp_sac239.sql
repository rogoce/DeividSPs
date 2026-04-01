-- Verificaciones contables de las cuentas tecnicas

drop procedure sp_sac239;

create procedure sp_sac239(a_periodo char(7))
returning char(20),
           char(3),
		   char(25),
		   dec(16,2),
		   dec(16,2),
		   dec(16,2);
		   
define _cuenta		char(25);
define _origen		char(3);
define _tipo		char(20);
define _debito		dec(16,2);
define _credito	dec(16,2);
define _neto		dec(16,2);

let _tipo = "Proveedores Reclamos";

foreach
 select res_cuenta[1,5],
		 res_origen,
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into _cuenta,
        _origen,
		_debito,
		_credito,
		_neto
   from cglresumen
  where year(res_fechatrx) 	= a_periodo[1,4]
    and month(res_fechatrx)	= a_periodo[6,7]  
	and res_origen 			<> "CGL"
	and res_cuenta[1,5]		in ("26612")
  group by 1, 2
  order by 1, 2  
	
		return _tipo,
		        _origen,
				_cuenta,
				_debito,
				_credito,
				_neto
				with resume;
	
end foreach

{
return "",
		"",
		"",
		0,
		0,
		0;
}

-- Cuadre Reclamos

let _tipo = "Reclamos";

foreach
 select res_cuenta[1,3],
		 res_origen,
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into _cuenta,
        _origen,
		_debito,
		_credito,
		_neto
   from cglresumen
  where year(res_fechatrx) 	= a_periodo[1,4]
    and month(res_fechatrx)	= a_periodo[6,7]  
	and res_origen 			<> "CGL"
	and res_cuenta[1,3]		in ("541", "419", "221", "222", "553")
  group by 1, 2
  order by 1, 2  
	
		return _tipo,
		        _origen,
				_cuenta,
				_debito,
				_credito,
				_neto
				with resume;
	
end foreach
	
let _tipo = "Reaseguro";

foreach
 select res_cuenta[1,3],
		 res_origen,
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into _cuenta,
        _origen,
		_debito,
		_credito,
		_neto
   from cglresumen
  where year(res_fechatrx) 	= a_periodo[1,4]
    and month(res_fechatrx)	= a_periodo[6,7]  
	and res_origen 			<> "CGL"
	and res_cuenta[1,3]		in ("511")
  group by 1, 2
  order by 1, 2  
	
		return _tipo,
		        _origen,
				_cuenta,
				_debito,
				_credito,
				_neto
				with resume;
	
end foreach

let _tipo = "Primas por Cobrar";

foreach
 select res_cuenta[1,3],
		 res_origen,
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into _cuenta,
        _origen,
		_debito,
		_credito,
		_neto
   from cglresumen
  where year(res_fechatrx) 	= a_periodo[1,4]
    and month(res_fechatrx)	= a_periodo[6,7]  
	and res_origen 			<> "CGL"
	and res_cuenta[1,3]		in ("131", "144")
  group by 1, 2
  order by 1, 2  
	
		return _tipo,
		        _origen,
				_cuenta,
				_debito,
				_credito,
				_neto
				with resume;
	
end foreach

let _tipo = "Primas Suscrita";

foreach
 select res_cuenta[1,3],
		 res_origen,
		sum(res_debito),
		sum(res_credito),
		sum(res_debito - res_credito)
   into _cuenta,
        _origen,
		_debito,
		_credito,
		_neto
   from cglresumen
  where year(res_fechatrx) 	= a_periodo[1,4]
    and month(res_fechatrx)	= a_periodo[6,7]  
	and res_origen 			<> "CGL"
	and res_cuenta[1,3]		in ("411")
  group by 1, 2
  order by 1, 2  
	
		return _tipo,
		        _origen,
				_cuenta,
				_debito,
				_credito,
				_neto
				with resume;
	
end foreach

end procedure
