-- Procedure que determina los 


drop procedure sp_aut001;

create procedure "informix".sp_aut001()
returning char(20),
          dec(16,2),
		  char(50),
		  char(10);

define _numrecla 	char(20);
define _cod_abogado	char(3);
define _nom_abogado	char(50);
define _cantidad	smallint;
define _no_reclamo	char(10);
define _variacion	dec(16,2);
define _terceros	char(10);

foreach
 select numrecla,
        variacion
   into _numrecla,
        _variacion
   from deivid_tmp:tmp_pend_rc
--   from deivid_tmp:temp_reclamo_pen_rc

	select cod_abogado,
	       no_reclamo
	  into _cod_abogado,
	       _no_reclamo
	  from recrcmae
	 where numrecla = _numrecla;

	if _cod_abogado is null then

		let _nom_abogado = "SIN ABOGADO";

	else

		select nombre_abogado
		  into _nom_abogado
		  from recaboga
		 where cod_abogado = _cod_abogado;

	end if

	select count(*)
	  into _cantidad
	  from recterce
	 where no_reclamo = _no_reclamo;

	if _cantidad = 0 then
		let _terceros = "No Tiene";
	else
		let _terceros = "Si Tiene";
	end if

	return _numrecla,
	       _variacion,
		   _nom_abogado,
		   _terceros
		   with resume;

end foreach

end procedure 