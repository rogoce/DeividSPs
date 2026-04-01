
drop procedure sp_rea058;

create procedure sp_rea058()
returning smallint,
          char(50);

{
returning char(20),
          char(10),
          char(10),
		  char(7),
		  char(5),
		  dec(16,2),
		  dec(16,2);
}

define _no_registro		char(10);
define _cod_auxiliar	char(5);
define _periodo			char(7);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _tipo_registro	smallint;
define _char_registro	char(10);
define _no_documento	char(20);
define _transaccion		char(10);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_remesa		char(10);
define _renglon			smallint;

delete from sac999:table2550101m;

foreach	
 select	no_registro,
       	cod_auxiliar,
		periodo,
		debito,
		credito
   into _no_registro,
        _cod_auxiliar,
		_periodo,
		_debito,
		_credito
   from sac999:reacompasiau
  where cuenta = "2550101"
    and periodo = "2013-01"
--    and cod_auxiliar = "BQ089"

	select tipo_registro,
	       no_poliza,
		   no_endoso,
		   no_remesa,
		   renglon,
		   no_documento
	  into _tipo_registro,
	       _no_poliza,
		   _no_endoso,
		   _no_remesa,
		   _renglon,
		   _no_documento
	  from sac999:reacomp
	 where no_registro = _no_registro;

	if _tipo_registro = 1 then

		let _char_registro = "Factura";

		select no_factura
		  into _transaccion
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

	else

		let _char_registro = "Recibo";

		select no_recibo
		  into _transaccion
		  from cobredet
		 where no_remesa = _no_remesa
		   and renglon   = _renglon;
		 
	 end if

	if _credito > 0 then
		let _credito = _credito * -1;
	end if
		
	insert into sac999:table2550101m(no_documento, tipo_trans, transaccion, periodo, cod_auxiliar, debito, credito)
	values (_no_documento, _char_registro, _transaccion, _periodo, _cod_auxiliar, _debito, _credito);

 {
 	return _no_documento,
	       _char_registro,
		   _transaccion,
		   _periodo,
		   _cod_auxiliar,
		   _debito,
		   _credito
		   with resume;
 }

end foreach

return 0, "Actualizacion Exitosa";

end procedure