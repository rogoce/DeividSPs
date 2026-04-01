
drop procedure sp_par86;
create procedure sp_par86()
returning char(5),
          char(50);

define _cod_agente		char(5);
define _nombre			char(50);
define _cantidad    	smallint;
define _cod_agencia		char(3);

define _cod_vendedor	char(3);
define _cod_ramo		char(3);
define _cod_tiporamo	char(3);

define _vend_pend_per 	char(3);
define _vend_pend_dan 	char(3);
define _vend_ofic_per 	char(3);
define _vend_ofic_dan 	char(3);
define _vend_sucursal	char(3);
define _vend_fianzas	char(3);

define _vida			smallint;
define _general			smallint;

define _error			integer;
define _error_desc		char(50);

let _vend_pend_per = "031";
let _vend_pend_dan = "031";
let _vend_ofic_per = "018";
let _vend_ofic_dan = "018";

let _vend_fianzas  = "024";	-- Zona 8

-- Promotorias de Fianzas mal Asignadas
--se coloca en comentario ya que el ramo de fianzas ahora si tiene vendedores asignados.
{
foreach
 select cod_agente,
		cod_ramo,
		cod_agencia,
		cod_vendedor
   into _cod_agente,
		_cod_ramo,
		_cod_agencia,
		_cod_vendedor
   from parpromo
  where cod_vendedor <> _vend_fianzas
	and cod_ramo     = "008"

	select general
	  into _general
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _general = 0 then
		continue foreach;
	end if
		
	update parpromo
	   set cod_vendedor = _vend_fianzas
	 where cod_agente   = _cod_agente
	   and cod_agencia  = _cod_agencia
	   and cod_ramo     = _cod_ramo;

	return _cod_agente,
	       "Promotor Fianzas Incorrecto " || _cod_agencia || " Asignado " || _cod_vendedor 
	       with resume;

end foreach
}
-- Promotorias que no tienen vendedor asignado

foreach
 select cod_agente
   into _cod_agente
   from parpromo
  where cod_vendedor is null
 group by 1
 order by 1

	select nombre
	  into _nombre
	  from agtagent
	 where cod_agente = _cod_agente;

	return _cod_agente,
	       "1 - " || trim(_nombre)
		   with resume;

end foreach

-- Corredores que no tienen promotorias asignadas

foreach
 select cod_agente,
        nombre
   into _cod_agente,
        _nombre
   from agtagent

	select count(*)
	  into _cantidad
	  from parpromo
	 where cod_agente = _cod_agente;

	if _cantidad = 0 then

		return _cod_agente,
		       "2 - " || trim(_nombre)
			   with resume;

	end if

end foreach

-- Centro de costos que no tienen promotorias asignadas

foreach
 select cod_agente,
        nombre
   into _cod_agente,
        _nombre
   from agtagent

	foreach
	 select sucursal_promotoria
	   into _cod_agencia
	   from insagen
	  group by sucursal_promotoria
	  order by sucursal_promotoria  

		select count(*)
		  into _cantidad
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _cod_agencia;

		if _cantidad = 0 then

			call sp_par82(_cod_agente, "informix") returning _error, _error_desc;

			if _error = 0 then

				return _cod_agente,
				       "3 - " || _cod_agencia || " " || _nombre
					   with resume;
			else

				let _error_desc = _error || " " || trim(_error_desc);

				return _cod_agente,
				       _error_desc
					   with resume;

			end if

		end if

	end foreach

end foreach

-- Promotores No Activos Con Promotorias Asignadas

foreach
 select cod_vendedor,
        nombre
   into _cod_vendedor,
        _nombre
   from agtvende
  where activo = 0

	select count(*)
	  into _cantidad
	  from parpromo
	 where cod_vendedor = _cod_vendedor;

	if _cantidad <> 0 then

		return _cod_vendedor,
		       "4 - " || _nombre
			   with resume;

	end if

end foreach

-- Agentes Mal Asignados

foreach
 select cod_agente
   into _cod_agente
   from agtagent
  where cod_vendedor = _vend_pend_dan

	return _cod_agente,
	       "Vendedor Incorrecto Para Agente " || _cod_agente || " Vendedor " || _vend_pend_dan 
		   with resume;

end foreach

-- Agentes Con Licencia de Danos y Promotor Asignado es Pendiente Danos
{
foreach
 select cod_agente
   into _cod_agente
   from agtagent
  where general      = 1

	foreach
	 select	cod_agencia,
	        cod_ramo
	   into	_cod_agencia,
	        _cod_ramo
	   from parpromo
	  where cod_agente   = _cod_agente
	    and cod_vendedor = _vend_pend_dan

			update parpromo
			   set cod_vendedor = _vend_ofic_dan
		     where cod_agente   = _cod_agente
			   and cod_agencia  = _cod_agencia
			   and cod_ramo     = _cod_ramo;

			return _cod_agente,
			       "Vendedor Incorrecto Para Ramo " || _cod_ramo || " Agencia " || _cod_agencia 
				   with resume;

	end foreach

end foreach
}

-- Agentes Con Licencia de Personas y Promotor Asignado es Pendiente Vida
{
foreach
 select cod_agente
   into _cod_agente
   from agtagent
  where vida = 1

	foreach
	 select	cod_agencia,
	        cod_ramo
	   into	_cod_agencia,
	        _cod_ramo
	   from parpromo
	  where cod_agente   = _cod_agente
	    and cod_vendedor = _vend_pend_per

			update parpromo
			   set cod_vendedor = _vend_ofic_per
		     where cod_agente   = _cod_agente
			   and cod_agencia  = _cod_agencia
			   and cod_ramo     = _cod_ramo;

			return _cod_agente,
			       "Vendedor Incorrecto Para Ramo " || _cod_ramo || " Agencia " || _cod_agencia 
				   with resume;

	end foreach

end foreach
}

-- Promotores de Sucursales Mal Asignados
{
foreach
 select cod_sucursal,
        cod_vendedor
   into _cod_agencia,
        _vend_sucursal
   from agtvende
  where activo       = 1
    and cod_sucursal <> "001"
    and ramo_afecta  = 0

	foreach
	 select cod_vendedor,
	        cod_agente,
			cod_ramo
	   into _cod_vendedor,
	        _cod_agente,
			_cod_ramo
	   from parpromo
	  where cod_agencia  = _cod_agencia
	    and cod_vendedor <> _vend_sucursal
		and cod_ramo     <> "008"

		select cod_tiporamo
		  into _cod_tiporamo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _cod_tiporamo in ("002", "003") then

			select general
			  into _general
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			if _general = 1 then

				update parpromo
				   set cod_vendedor = _vend_sucursal
			     where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

				return _cod_agente,
				       "Promotor " || _vend_sucursal || " Ramo " || _cod_ramo || " Asignado " || _cod_vendedor 
				       with resume;

			end if
	
		else

			select vida
			  into _vida
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			if _vida = 1 then

				update parpromo
				   set cod_vendedor = _vend_sucursal
			     where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

				return _cod_agente,
				       "Promotor " || _vend_sucursal || " Ramo " || _cod_ramo || " Asignado " || _cod_vendedor 
				       with resume;

			end if

		end if
		
	end foreach

end foreach
}

-- Licencia Pendiente Danos Incorrecta

{
foreach
 select cod_agente 
   into _cod_agente
   from agtagent
  where general = 0

	foreach
	 select cod_agencia,
	        cod_ramo,
			cod_vendedor
	   into _cod_agencia,
	        _cod_ramo,
			_cod_vendedor
	   from parpromo
	  where cod_agente = _cod_agente

		select cod_tiporamo
		  into _cod_tiporamo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _cod_tiporamo in ("002", "003") then

			if _cod_vendedor <> _vend_pend_dan then

				update parpromo
				   set cod_vendedor = _vend_pend_dan	-- Pendientes Danos
			     where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

				return _cod_agente,
				       "Licencia Pendiente Danos Ramo " || _cod_ramo || " Agencia " || _cod_agencia 
					   with resume;

			end if

		end if

	end foreach

end foreach
}

-- Licencia Pendiente Personas Incorrecta

{
foreach
 select cod_agente 
   into _cod_agente
   from agtagent
  where vida = 0

	foreach
	 select cod_agencia,
	        cod_ramo,
			cod_vendedor
	   into _cod_agencia,
	        _cod_ramo,
			_cod_vendedor
	   from parpromo
	  where cod_agente = _cod_agente

		select cod_tiporamo
		  into _cod_tiporamo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _cod_tiporamo in ("001") then

			if _cod_vendedor <> _vend_pend_per then

				update parpromo
				   set cod_vendedor = _vend_pend_per	-- Pendientes Personas
			     where cod_agente   = _cod_agente
				   and cod_agencia  = _cod_agencia
				   and cod_ramo     = _cod_ramo;

				return _cod_agente,
				       "Licencia Pendiente Vida Ramo " || _cod_ramo || " Agencia " || _cod_agencia 
					   with resume;

			end if

		end if

	end foreach

end foreach
}

return 0, "Proceso Completado..";
       
end procedure 
                                                                                                                                                           
