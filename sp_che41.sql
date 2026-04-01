

--drop procedure sp_che41;

create procedure "informix".sp_che41()

define _a_nombre_de	char(100);

foreach
 select a_nombre_de
   into _a_nombre_de
   from marcar

	update chqchmae
	   set marcar = 1
	 where a_nombre_de = _a_nombre_de;

end foreach

end procedure
