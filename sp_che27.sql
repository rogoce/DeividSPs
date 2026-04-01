-- Procedure que retorna los que firmas cartas declarativas

create procedure "informix".sp_che27()
returning integer,
          char(50),
	      char(50);

define _nombre	char(50);
define _cargo	char(50);

foreach
 select nombre,
        cargo
   into _nombre,
        _cargo
   from parfirca
  where carta_declarativa = 1

	return 0,
	       _nombre,
		   _cargo
		   with resume;

end foreach

end procedure