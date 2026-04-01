-- Creado    : 28/03/2005 - Autor:Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.


--drop procedure sp_pro149b;

create procedure sp_pro149b()
returning char(8),char(30);

define _usuario			char(8);
define _descripcion		char(30);
define _codigo_agencia  char(30);

let _codigo_agencia = null;

foreach
 select	usuario
   into	_usuario
   from emireusu
  group by 1
  order by 1

  foreach

	select codigo_agencia
	  into _codigo_agencia
	  from insusco
	 where usuario = _usuario

	exit foreach;

  end foreach

   foreach
	select descripcion
	  into _descripcion
	  from insagen
	 where codigo_agencia = _codigo_agencia

	exit foreach;

   end foreach

	return _usuario,
		   _descripcion
			with resume;
end foreach

end procedure
