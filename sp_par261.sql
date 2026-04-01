drop procedure sp_par261;

create procedure sp_par261()
returning smallint,
          char(50);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_cober_reas	char(3);
define _orden			smallint;
define _prima			dec(16,2);

foreach
 select no_poliza,
		no_endoso,
		no_unidad,
		cod_cober_reas,
		orden,
		prima
   into _no_poliza,
		_no_endoso,
		_no_unidad,
		_cod_cober_reas,
		_orden,
		_prima
   from deivid_tmp:bo_emifacon

	update emifacon
	   set prima          = _prima
	 where no_poliza      = _no_poliza
	   and no_endoso      = _no_endoso
	   and no_unidad      = _no_unidad
	   and cod_cober_reas = _cod_cober_reas
	   and orden          = _orden;

end foreach

return 0, "Actualizacion Exitosa";

end procedure
