drop procedure amado_comis;

create procedure "informix".amado_comis(a_fecha_desde DATE, a_fecha_hasta DATE)
returning char(10),
          dec(16,2),
          char(1),
          char(100);

define _no_requis, _no_requis_c	char(10);
define _monto		dec(16,2);
define _error		integer;
define _tipo_requis char(1);
define _error_desc  char(50);
define _cod_agente  char(5);
define _cantidad	integer;
define _a_nombre_de char(100);

set isolation to dirty read;

foreach
 select no_requis,
        tipo_requis,
        cod_agente,
		a_nombre_de
   into _no_requis,
        _tipo_requis,
        _cod_agente,
		_a_nombre_de
   from chqchmae
  where pagado = 1
    and fecha_impresion  = "17/07/2008"
	and no_requis = "250476"
--    and year(fecha_impresion)  = 2005
--    and year(fecha_impresion)  = year(today)
--    and month(fecha_impresion) = month(today)

	select sum(debito - credito)
	  into _monto
	  from chqchcta
	 where no_requis = _no_requis;
	
	if _monto is null then
		let _monto = 0.00;
	end if

	if _monto <> 0.00 then
	 {   FOREACH
			 select no_requis
			   into _no_requis_c
			   from chqchmae
			  where cod_agente = _cod_agente
			    and origen_cheque in (2, 7)
				and anulado = 1
				and no_requis is not null
				and no_requis <> _no_requis
				and fecha_anulado >= a_fecha_desde
				and fecha_anulado <= a_fecha_hasta

			 If _no_requis_c is not null And Trim(_no_requis_c) <> "" Then
				 update chqcomis
				    set no_requis = _no_requis
				  where no_requis = _no_requis_c;
			 End If
	    END FOREACH
	  }
	-- Registros Contables de Cheques de Comisiones

 		call sp_par205(_no_requis) returning _error, _error_desc;

 --	if _error <> 0 then
  --		return _error;
  --	end if
--		call sp_che32(_no_requis) returning	_error;

		return _no_requis,
		       _monto,
			   _tipo_requis,
			   _a_nombre_de
			   with resume;

	end if

{	select count(*)
	  into _cantidad
	  from chqchcta
	 where no_requis = _no_requis;

	if _cantidad = 0 then
	    FOREACH
			 select no_requis
			   into _no_requis_c
			   from chqchmae
			  where cod_agente = _cod_agente
			    and origen_cheque in (2, 7)
				and anulado = 1
				and no_requis is not null
				and no_requis <> _no_requis
				and fecha_anulado >= a_fecha_desde
				and fecha_anulado <= a_fecha_hasta

			 If _no_requis_c is not null And Trim(_no_requis_c) <> "" Then
				 update chqcomis
				    set no_requis = _no_requis
				  where no_requis = _no_requis_c;
			 End If
	    END FOREACH

		-- Registros Contables de Cheques de Comisiones

	 --	call sp_par205(_no_requis) returning _error, _error_desc;

		return _no_requis,
		       _monto,
			   _tipo_requis,
			   _a_nombre_de
			   with resume;

	end if }
	
end foreach

return "0",
        0.00,
        "",
        "";

end procedure
