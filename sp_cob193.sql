-- Procedimiento que retorna las polizas que han tenido pronto pago

-- Creado    : 27/01/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sis100 Cierres Diarios - DEIVID, S.A.

drop procedure sp_cob193;

create procedure sp_cob193()
returning char(20),
          dec(16,2),
		  dec(16,2),
		  date,
		  char(50);

define _no_documento	char(20);
define _monto			dec(16,2);
define _saldo		    dec(16,2);
define _fecha			date;
define _asegurado		char(50);

foreach
 select no_documento,
		monto,
		saldo,
		fecha,
		asegurado
   into _no_documento,
		_monto,
		_saldo,
		_fecha,
		_asegurado
   from cobpropa
  where email_send = 0

	return _no_documento,
		   _monto,
		   _saldo,
		   _fecha,
		   _asegurado
		   with resume;

end foreach

update cobpropa
   set email_send = 1;

end procedure