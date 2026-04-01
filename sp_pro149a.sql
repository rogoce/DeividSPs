-- Creado    : 28/03/2005 - Autor:Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_pro149a;

create procedure sp_pro149a()
returning char(8),integer,char(30);

define _usuario			char(8);
define _cantidad		integer;
define _descripcion     char(30);
define _codigo_agencia  char(3);

let _codigo_agencia = null;

foreach

 select	user_added,
 		count(*)
   into	_usuario,
		_cantidad
   from emirepol
  group by 1
  order by 2 desc

  foreach

	select codigo_agencia
	  into _codigo_agencia
	  from insusco
	 where usuario = _usuario

	exit foreach;

  end foreach

  if _codigo_agencia is null then
  	  continue foreach;
  end if

   foreach

	select descripcion
	  into _descripcion
	  from insagen
	 where codigo_agencia = _codigo_agencia

	exit foreach;

   end foreach

	return _usuario,
		   _cantidad,
		   _descripcion
			with resume;
end foreach

end procedure
