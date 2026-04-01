-- Actualizacion de los registros de morosidad y cobros para BO

-- Creado    : 28/08/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par235; 

create procedure "informix".sp_par235()
returning char(10),
          char(3),
          dec(16,2),
          dec(16,2);

define _no_poliza	char(10);
define _no_endoso	char(5);
define _no_factura	char(10);
define _monto1		dec(16,2);
define _monto2		dec(16,2);
define _cod_tipoprod	char(3);

foreach
 select no_poliza,
        no_endoso,
        no_factura,
		prima_neta
   into _no_poliza,
        _no_endoso,
        _no_factura,
		_monto1
   from endedmae
  where actualizado = 1
    and periodo     >= "2006-10"
	and periodo     <= "2006-10"

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod <> "002" then
		continue foreach;
	end if

	select sum(debito + credito)
	  into _monto2
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and cuenta like "144%";

--	if _monto1 <> _monto2 then

		return _no_factura,
		       _cod_tipoprod,
			   _monto1,
			   _monto2
			   with resume;

--	end if

end foreach

end procedure
