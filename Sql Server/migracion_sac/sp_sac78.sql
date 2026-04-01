-- Procedure que facturas mayorizadas sin asientos

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac78;

create procedure sp_sac78()
returning char(10),
       	  char(5),
	      char(10),
	      char(20),
	      dec(16,2),
	      date,
	      char(8);

define _no_poliza		char(10);	
define _no_endoso		char(5);
define _no_factura		char(10);
define _no_documento	char(20);
define _fecha_emision	date;
define _user_added		char(8);
define _prima_suscrita	dec(16,2);
define _cantidad		smallint;

foreach
 select no_poliza,
        no_endoso,
		no_factura,
		no_documento,
		fecha_emision,
		user_added,
		prima_suscrita
   into _no_poliza,
        _no_endoso,
		_no_factura,
		_no_documento,
		_fecha_emision,
		_user_added,
		_prima_suscrita
   from endedmae
  where actualizado     = 1
    and sac_asientos    = 2
	and prima_suscrita	<> 0.00
	and periodo         >= "2008-01"

	select count(*)
	  into _cantidad
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	   
	if _cantidad = 0 then
	
		return _no_poliza,
		       _no_endoso,
		       _no_factura,
		       _no_documento,
			   _prima_suscrita,
		       _fecha_emision,
			   _user_added
			   with resume;

	end if

end foreach

return "0",
       "0",
       "0",
       "0",
	   0,
       "",
	   "";

end procedure