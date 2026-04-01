--  Chequeo de las Primas para los Excesos de Perdida por Producto

--  Creado:	06/05/2005 - Autor: Demetrio Hurtado Almanza

--  SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par155;

create procedure "informix".sp_par155()
returning char(5),
          char(50),
		  char(50),
		  char(1),
		  char(7),
		  dec(16,2),
		  char(1);

define _cantidad		smallint;
define _cod_producto	char(5);
define _periodo			char(7);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_sub		char(50);
define _nombre_pro		char(50);
define _tipo_suscrip	char(1);
define _prima_exec		dec(16,2);
define _asterix			char(1);

foreach
 select cod_producto,
        cod_ramo,
		cod_subramo,
		nombre,
		tipo_suscripcion
   into _cod_producto,
        _cod_ramo,
		_cod_subramo,
		_nombre_pro,
		_tipo_suscrip
   from prdprod
  where cod_ramo = "018"
    and cod_subramo not in ("003", "005", "001", "004", "006", "015", "002")
--    and cod_subramo = ""

	select nombre
	  into _nombre_sub
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	let _asterix = "";

	select count(*)
	  into _cantidad
	  from prdpriex
	 where cod_producto = _cod_producto; 	
	
	if _cantidad = 0 then
		let _asterix = "*";
	end if

	select max(periodo)
	  into _periodo
	  from prdpriex
	 where cod_producto = _cod_producto; 	

	select prima_exc_perd
	  into _prima_exec
	  from prdpriex
	 where cod_producto     = _cod_producto
	   and tipo_suscripcion = _tipo_suscrip
	   and periodo          = _periodo; 	

	return _cod_producto,
	       _nombre_pro,
		   trim(_nombre_sub) || " - " || _cod_subramo,
		   _tipo_suscrip,
		   _periodo,
		   _prima_exec,
		   _asterix
		   with resume;
	

end foreach


end procedure