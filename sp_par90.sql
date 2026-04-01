drop procedure sp_par90;

create procedure "informix".sp_par90()
returning char(50),
          char(50),
		  char(20),
		  char(10),
		  char(50),
		  dec(16,2),
		  dec(16,2);

define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _no_documento	char(20);
define _no_unidad		char(5);
define _tipo			char(1);
define _prima			dec(16,2);
define _suma			dec(16,2);

define _nombre_ramo		char(50);
define _nombre_subramo	char(50);
define _tipo_nombre		char(50);

foreach
 select p.cod_ramo, 
        p.cod_subramo, 
        p.no_documento, 
        u.no_unidad, 
        u.tipo_incendio, 
        c.suma_incendio, 
		u.prima_suscrita
   into _cod_ramo, 
        _cod_subramo, 
        _no_documento, 
        _no_unidad, 
        _tipo, 
        _suma, 
		_prima
   from emipomae p, emipouni u, emicupol c
  where p.no_poliza      = u.no_poliza
    and u.no_poliza      = c.no_poliza
    and u.no_unidad      = c.no_unidad
    and c.cod_ubica      = "002"
    and p.actualizado    = 1
    and p.cod_ramo       in ("001", "003")
    and p.estatus_poliza = 1

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	if _tipo = "1" then
		let _tipo_nombre = "Edificio";
	elif _tipo = "2" then
		let _tipo_nombre = "Contenido";
	elif _tipo = "3" then
		let _tipo_nombre = "Lucro Cesante";
	else
		let _tipo_nombre = "";
	end if

	return _nombre_ramo,
	       _nombre_subramo,
		   _no_documento,
		   _no_unidad,
		   _tipo_nombre,
		   _suma,
		   _prima
		   with resume;

end foreach

end procedure