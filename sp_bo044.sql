
drop procedure sp_bo044;

create procedure sp_bo044()
returning char(10),
          date,
		  dec(16,2),
		  dec(16,2),
		  char(10);

define _no_requis	char(10);
define _monto_che	dec(16,2);
define _monto_com	dec(16,2);
define _fecha		date;
define _cod_agente	char(10);

foreach
 select no_requis,
        monto,
		fecha_impresion,
		cod_agente
   into	_no_requis,
        _monto_che,
		_fecha,
		_cod_agente
   from chqchmae
  where fecha_impresion >= "01/01/2006"
    and fecha_impresion <= "04/12/2007"
    and origen_cheque   = 2
    and pagado          = 1
    and anulado         = 0

	 select sum(comision)
	   into _monto_com
	   from chqcomis
	  where no_requis = _no_requis;

	if _monto_com is null then
		let _monto_com = 0;
	end if

	if _monto_che <> _monto_com then
		
	 --	if _monto_com = 0 then

			return _no_requis,
			       _fecha,
				   _monto_che,
				   _monto_com,
				   _cod_agente
				   with resume;
	--	end if

	end if
	
end foreach

end procedure 