-- Procedimiento que actualiza el presupuesto para la zona 1

-- Creado    : 10/03/2011 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par317;

create procedure "informix".sp_par317()
returning char(3),
          char(5),
		  char(3),
		  char(7),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _cod_agente		char(5);
define _cod_ramo		char(3);
define _cod_vendedor	char(3);
define _mensual			dec(16,2);
define _periodo			char(7);

define _ventas_nuevas	dec(16,2);
define _ventas_total	dec(16,2);
define _cantidad		integer;

let _cod_vendedor = "047";
 
foreach
 select agente,
        ramo,
		mensual
   into _cod_agente,
        _cod_ramo,
		_mensual
   from deivid_tmp:tmp_zona1_c

	{
	select count(*)
	  into _cantidad
	  from deivid_bo:preventas
	 where cod_vendedor = _cod_vendedor
	   and cod_agente   = _cod_agente
	   and cod_ramo     = _cod_ramo
	   and periodo      >= "2011-01";

	if _cantidad = 0 then

		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-01", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-02", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-03", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-04", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-05", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-06", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-07", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-08", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-09", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-10", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-11", 0, 0, 0, 0);
		insert into	deivid_bo:preventas	values (_cod_vendedor, _cod_agente, _cod_ramo, "2011-12", 0, 0, 0, 0);

		return _cod_vendedor,
		       _cod_agente,
			   _cod_ramo,
			   null,
			   null,
			   null,
			   _mensual	* 12
			   with resume;
	end if
	}

	foreach
	 select periodo,
	        ventas_nuevas,
			ventas_total
	   into _periodo,
	        _ventas_nuevas,
			_ventas_total
	   from deivid_bo:preventas
	  where cod_vendedor = _cod_vendedor
	    and cod_agente   = _cod_agente
		and cod_ramo     = _cod_ramo
		and periodo      >= "2011-01"

		--{
		update deivid_bo:preventas
		   set ventas_nuevas = ventas_nuevas + _mensual,
			   ventas_total  = ventas_total  + _mensual
		 where cod_vendedor  = _cod_vendedor
		   and cod_agente    = _cod_agente
		   and cod_ramo      = _cod_ramo
		   and periodo       = _periodo;
		--}

		return _cod_vendedor,
		       _cod_agente,
			   _cod_ramo,
			   _periodo,
			   _ventas_nuevas,
			   _ventas_total,
			   _mensual
			   with resume;

	end foreach

end foreach

return "000",
       "00000",
	   "000",
	   "0000-00",
	   null,
	   null,
	   null;

end procedure
