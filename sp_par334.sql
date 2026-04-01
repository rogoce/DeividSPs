-- Procedimiento que reversa los asientos para las cuentas 800 y 900 de las cancelacaliones a prorrata
-- 
-- Creado     : 22/05/2013 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par334;

create procedure "informix".sp_par334()
returning char(10),
          char(10), 
          char(7), 
          char(25), 
          dec(16,2), 
          dec(16,2),
		  char(10),
		  char(5);

define _no_poliza	char(10);
define _no_endoso	char(5);
define _cuenta		char(25);

define _periodo 	char(7);

define _no_documento	char(20);
define _no_factura		char(10); 
define _debito			dec(16,2); 
define _credito			dec(16,2);

let _periodo = "2013-05";

foreach
 select e.no_documento,
        e.no_factura, 
        e.periodo, 
        a.cuenta, 
        a.debito, 
        a.credito,
		e.no_poliza,
		e.no_endoso
   into _no_documento,
        _no_factura, 
        _periodo, 
        _cuenta, 
        _debito, 
        _credito,
		_no_poliza,
		_no_endoso
   from endedmae e, endasien a
  where e.no_poliza    = a.no_poliza
    and e.no_endoso    = a.no_endoso
    and a.cuenta[1,3]  in ("800", "900")
    and e.periodo      =  _periodo
    and e.cod_tipocalc = "001"
--	and e.no_documento = "0107-00589-01"
  order by 1

	--{
	delete from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and cuenta    = _cuenta;
	--}

	return _no_documento,
           _no_factura, 
           _periodo, 
           _cuenta, 
           _debito, 
           _credito,
		   _no_poliza,
		   _no_endoso
		   with resume;

end foreach

return "",
       "", 
       "", 
       "", 
       0, 
       0,
	   "",
	   "";

end procedure