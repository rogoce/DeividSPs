create procedure sp_par42()

define _no_poliza	char(10);
define _no_unidad	char(5);
define _cod_proc	char(5);
define _user_added 	char(8);
define _cod_cliente	char(10);

foreach
 select no_poliza,
        no_unidad,
		cod_procedimiento
   into _no_poliza,
        _no_unidad,
		_cod_proc
   from emipreas

	select user_added
	  into _user_added
	  from emipomae
	 where no_poliza = _no_poliza;

	update emipreas
	   set user_added        = _user_added
     where no_poliza         = _no_poliza
       and no_unidad         = _no_unidad
	   and cod_procedimiento = _cod_proc;

end foreach

foreach
 select no_poliza,
        no_unidad,
		cod_procedimiento,
		cod_cliente
   into _no_poliza,
        _no_unidad,
		_cod_proc,
		_cod_cliente
   from emiprede

	select user_added
	  into _user_added
	  from emipomae
	 where no_poliza = _no_poliza;

	update emiprede
	   set user_added        = _user_added
     where no_poliza         = _no_poliza
       and no_unidad         = _no_unidad
	   and cod_procedimiento = _cod_proc
	   and cod_cliente		 = _cod_cliente;

end foreach

end procedure;