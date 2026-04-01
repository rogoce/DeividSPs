drop procedure sp_atc001;

create procedure "informix".sp_atc001()
returning char(10),
          smallint,
		  smallint,
		  dec(16,2),
		  dec(16,2);

define _cant_registros	smallint;
define _cantidad		smallint;
define _cod_entrada		char(10);
define _monto_ma		dec(16,2);
define _monto_de		dec(16,2);

set isolation to dirty read;

foreach
 select cant_registros,
        cod_entrada,
		monto
   into _cant_registros,
        _cod_entrada,
		_monto_ma
   from atcdocma
  where completado = 1

	select count(*),
	       sum(monto)
	  into _cantidad,
	       _monto_de
	  from atcdocde
	 where cod_entrada = _cod_entrada;

	if _cant_registros <> _cantidad or
	   _monto_ma       <> _monto_de then

--{
		update atcdocma
		   set cant_registros = _cantidad,
		       monto          = _monto_de
		 where cod_entrada    = _cod_entrada;
--}

		return  _cod_entrada,
		        _cant_registros,
				_cantidad,
				_monto_ma,
				_monto_de
				with resume;

	end if

end foreach

end procedure