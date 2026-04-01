-- Porcedure que controla la cantidad de registros 

-- Creado:	19/09/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_bo035;

create procedure sp_bo035()
returning char(10),
          char(50);

define _cod_entrada char(10);
define _cantidad	integer;
define _registros	integer;

define _auditado	smallint;
define _escaneado	smallint;
define _completado	smallint;

foreach
 select cod_entrada,
        cant_registros,
		auditado,
		procesado,
		completado
   into _cod_entrada,
        _registros,
		_auditado,
		_escaneado,
		_completado
   from atcdocma
  where procesado = 0

	select count(*)
	  into _cantidad
	  from atcdocde
	 where cod_entrada = _cod_entrada;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad <> _registros then

		continue foreach;

	end if			   	

	select count(*)
	  into _cantidad
	  from atcdocde
	 where cod_entrada = _cod_entrada
	   and auditado    = 1;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad = _registros and
	   _auditado = 0          then

		return _cod_entrada,
		       "Todos Auditados"
			   with resume;
			   
	end if			   	

	select count(*)
	  into _cantidad
	  from atcdocde
	 where cod_entrada = _cod_entrada
	   and escaneado   = 1;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad  = _registros and
	   _escaneado = 0          then

		return _cod_entrada,
		       "Todos Scaneados"
			   with resume;
			   
	end if			   	

	select count(*)
	  into _cantidad
	  from atcdocde
	 where cod_entrada = _cod_entrada
	   and completado   = 1;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad   = _registros and
	   _completado = 0          then

		return _cod_entrada,
		       "Todos Completados"
			   with resume;
			   
	end if			   	

end foreach

return "0",
       "Proceso Completado";

end procedure