drop procedure sp_pro151;

create procedure "informix".sp_pro151()
returning char(20),
          integer,
          integer,
          char(50),
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cantidad		integer;
define _cantidad_dep	integer;

define _nombre_subra	char(50);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cod_cliente		char(10);
define _nombre_cliente	char(50);

foreach
 select no_documento,
        no_poliza,
		cod_ramo,
		cod_subramo,
		cod_contratante
   into	_no_documento,
        _no_poliza,
		_cod_ramo,
		_cod_subramo,
		_cod_cliente
   from emipomae
  where estatus_poliza = 1
    and actualizado    = 1
    and cod_ramo       = "018"
	and cod_subramo in ("007", "008")

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _nombre_subra
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	   	  
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza
	   and activo    = 1;
	 	  
	select count(*)
	  into _cantidad_dep
	  from emidepen
	 where no_poliza = _no_poliza
	   and activo    = 1;

	return _no_documento,
	       _cantidad,
		   _cantidad_dep,
		   _nombre_subra,
		   _nombre_cliente
		   with resume;
	  
end foreach


end procedure