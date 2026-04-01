drop procedure sp_par183;

create procedure "informix".sp_par183()
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_unidad		char(5);
define _cod_acreedor	char(5);
define _no_endoso		char(5);

define _cantidad		integer;
define _error			integer;
define _descripcion		char(50);

--set debug file to "sp_par183.trc";
--trace on;

begin work;

let _descripcion = "";

begin
on exception set _error
	rollback work;
	return _error, _descripcion;
end exception

let _descripcion = "Seleccionando emipoacr";

{foreach
 select no_poliza,
        no_unidad,
		cod_acreedor
   into _no_poliza,
        _no_unidad,
		_cod_acreedor
   from emipoacr
  where cod_acreedor in ("00904", "00905", "00103", "00906", "00907", "00908", "00045", "00909", "00910", 
                         "00104", "00911", "00912", "00913", "00914", "00915", "00916", "00917", "00918", 
                         "00919", "00920", "00105", "00921", "00922", "00923", "00924", "00925", "00046", 
                         "00021", "00926", "00927", "00928", "00929", "00930", "00931", "00932", "00933", 
                         "00934", "00935", "00936", "00937", "01619", "00106")

	let _descripcion = "Contando emipoacr";

	select count(*)
	  into _cantidad
	  from emipoacr
	 where no_poliza    = _no_poliza
	   and no_unidad    = _no_unidad
	   and cod_acreedor = "00010";

	if _cantidad = 0 then

		let _descripcion = "Actualizando emipoacr";

		update emipoacr
		   set cod_acreedor = "00010"
    	 where no_poliza    = _no_poliza
	       and no_unidad    = _no_unidad
	       and cod_acreedor = _cod_acreedor;

	else

		let _descripcion = "Borrando emipoacr";

		delete from emipoacr
    	 where no_poliza    = _no_poliza
	       and no_unidad    = _no_unidad
	       and cod_acreedor = _cod_acreedor;

	end if

end foreach
  
let _descripcion = "Seleccionando endedacr";

foreach
 select no_poliza,
        no_unidad,
		no_endoso,
		cod_acreedor
   into _no_poliza,
        _no_unidad,
		_no_endoso,
		_cod_acreedor
   from endedacr
  where cod_acreedor in ("00904", "00905", "00103", "00906", "00907", "00908", "00045", "00909", "00910", 
                         "00104", "00911", "00912", "00913", "00914", "00915", "00916", "00917", "00918", 
                         "00919", "00920", "00105", "00921", "00922", "00923", "00924", "00925", "00046", 
                         "00021", "00926", "00927", "00928", "00929", "00930", "00931", "00932", "00933", 
                         "00934", "00935", "00936", "00937", "01619", "00106")

	let _descripcion = "Contando endedacr";

	select count(*)
	  into _cantidad
	  from endedacr
	 where no_poliza    = _no_poliza
	   and no_endoso    = _no_endoso
	   and no_unidad    = _no_unidad
	   and cod_acreedor = "00010";

	if _cantidad = 0 then

		let _descripcion = "Actualizando endedacr";

		update endedacr
		   set cod_acreedor = "00010"
    	 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso
	       and no_unidad    = _no_unidad
	       and cod_acreedor = _cod_acreedor;

	else

		let _descripcion = "Borrando endedacr " || _no_poliza || " " || _no_endoso;

		delete from endedacr
    	 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso
	       and no_unidad    = _no_unidad
	       and cod_acreedor = _cod_acreedor;

	end if

end foreach

let _descripcion = "Borrando emiacre";

delete from emiacre
  where cod_acreedor in ("00904", "00905", "00103", "00906", "00907", "00908", "00045", "00909", "00910", 
                         "00104", "00911", "00912", "00913", "00914", "00915", "00916", "00917", "00918", 
                         "00919", "00920", "00105", "00921", "00922", "00923", "00924", "00925", "00046", 
                         "00021", "00926", "00927", "00928", "00929", "00930", "00931", "00932", "00933", 
                         "00934", "00935", "00936", "00937", "01619", "00106");}

foreach
 select no_poliza,
        no_unidad,
		cod_acreedor
   into _no_poliza,
        _no_unidad,
		_cod_acreedor
   from emireacr
  where cod_acreedor in ("00904", "00905", "00103", "00906", "00907", "00908", "00045", "00909", "00910", 
                         "00104", "00911", "00912", "00913", "00914", "00915", "00916", "00917", "00918", 
                         "00919", "00920", "00105", "00921", "00922", "00923", "00924", "00925", "00046", 
                         "00021", "00926", "00927", "00928", "00929", "00930", "00931", "00932", "00933", 
                         "00934", "00935", "00936", "00937", "01619", "00106")

	let _descripcion = "Contando emireacr";

	select count(*)
	  into _cantidad
	  from emireacr
	 where no_poliza    = _no_poliza
	   and no_unidad    = _no_unidad
	   and cod_acreedor = "00010";

	if _cantidad = 0 then

		let _descripcion = "Actualizando emireacr";

		update emireacr
		   set cod_acreedor = "00010"
    	 where no_poliza    = _no_poliza
	       and no_unidad    = _no_unidad
	       and cod_acreedor = _cod_acreedor;

	else

		let _descripcion = "Borrando emipoacr";

		delete from emireacr
    	 where no_poliza    = _no_poliza
	       and no_unidad    = _no_unidad
	       and cod_acreedor = _cod_acreedor;

	end if

end foreach
end


commit work;

return 0, "Actualizacion Exitosa";

end procedure