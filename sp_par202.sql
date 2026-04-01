
create procedure "informix".sp_par202()

define _fecha_aniversario	date;
define _cod_cliente			char(10);

foreach
 select cod_cliente,
        fecha_aniversario
   into _cod_cliente,
        _fecha_aniversario
   from clibitacora
  where fecha_aniversario is not null

	update cliclien
	   set fecha_aniversario = _fecha_aniversario
	 where cod_cliente       = _cod_cliente
	   and fecha_aniversario is null;
  
end foreach
  
end procedure















