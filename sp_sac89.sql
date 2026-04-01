-- Procedure que verifica los montos debitos y credito de cglresumen

-- Creado    : 22/10/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac89;

create procedure sp_sac89()
returning integer,
          char(25),
		  dec(16,2),
		  dec(16,2),
		  date,
		  char(10),
		  date,
		  integer;

define _no_registro		integer;
define _cuenta			char(25);
define _fecha_trx		date;
define _comprobante		char(10);
define _fecha_cap		date;
define _no_trx			integer;
define _debito1			dec(16,2);
define _credito1		dec(16,2);

set isolation to dirty read;

foreach
 select res_noregistro,
        res_cuenta,
		res_debito,
		res_credito,
		res_fechatrx,
		res_comprobante,
		res_fechacap,
		res_notrx
   into _no_registro,
        _cuenta,
		_debito1,
		_credito1,
		_fecha_trx,
		_comprobante,
		_fecha_cap,
		_no_trx
   from cglresumen
--  where res_fechatrx = "21/10/2008"
  order by res_fechatrx, res_comprobante

	if _debito1  < 0 or
	   _credito1 < 0 then 

		return _no_registro,
		       _cuenta,
			   _debito1,
			   _credito1,
			   _fecha_trx,
			   _comprobante,
			   _fecha_cap,
			   _no_trx
			   with resume;

	end if

end foreach

return 0,
       "",
	   0,
	   0,
	   null,
	   "",
	   null,
	   0
	   with resume;

end procedure