-- Procedure que verifica quienes son los promotores asignados por ramo por sucursal

drop procedure sp_par226;

create procedure "informix".sp_par226()
returning char(50),
          char(50),
		  char(50),
		  char(50),
		  char(5),
		  char(50);

define _cod_agente		char(5);
define _nombre_agente	char(50);

define _cod_ramo		char(3);
define _cod_tiporamo	char(3);
define _nombre_ramo		char(50);
define _nombre_tiporamo	char(50);

define _cod_vendedor	char(3);
define _vendedor_cm		char(50);
define _vendedor_pe		char(50);

foreach
 select	cod_agente,
        nombre
   into	_cod_agente,
        _nombre_agente
   from agtagent 

	foreach
	 select cod_ramo,
	        cod_tiporamo,
			nombre
	   into _cod_ramo,
	        _cod_tiporamo,
			_nombre_ramo
	   from prdramo
	  where cod_ramo not in ("008", "080") -- Not Fianzas

		if _cod_tiporamo = "001" then
			let _nombre_tiporamo = "Personas";
		else
			let _nombre_tiporamo = "Danos";
		end if

		-- Vendedor en CM

		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente   = _cod_agente
		   and cod_agencia  = "001"    
		   and cod_ramo     = _cod_ramo;

		select nombre
		  into _vendedor_cm
		  from agtvende
		 where cod_vendedor = _cod_vendedor;

		-- Vendedor en PE

		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente   = _cod_agente
		   and cod_agencia  = "004"    
		   and cod_ramo     = _cod_ramo;

		select nombre
		  into _vendedor_pe
		  from agtvende
		 where cod_vendedor = _cod_vendedor;

		return _nombre_ramo,
		       _vendedor_cm,
			   _vendedor_pe,
			   _nombre_agente,
			   _cod_agente,
			   _nombre_tiporamo
			   with resume;

	end foreach		

end foreach

end procedure