-- Esquema de Asegurados del Ramo de Salud

-- Creado    : 12/04/2004 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_pro140;

create procedure  "informix".sp_pro140(a_fecha date)
returning char(50),
          integer,
		  integer,
		  integer,
		  integer,
		  integer,
		  integer;

define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_subramo	char(50);

define _cant_ase_0		integer;
define _cant_ase_1		integer;
define _cant_dep_1		integer;
define _cant_ase_2		integer;
define _cant_dep_2		integer;

define _no_poliza		char(10);
define _no_unidad		char(5);
define _activo			smallint;
define _no_activo_desde	date;
define _cantidad		integer;
define _cod_producto	char(5);
define _cod_subramo2	char(3);

define v_filtros        char(255);

create temp table tmp_salud(
	cod_ramo		char(3),
	cod_subramo		char(3),
	cant_ase_0		integer,
	cant_ase_1		integer,
	cant_dep_1		integer,
	cant_ase_2		integer,
	cant_dep_2		integer
	) with no log;

call sp_pro03("001", "001", a_fecha, "018;") returning v_filtros;

foreach
 select cod_ramo,
        cod_subramo,
		no_poliza
   into	_cod_ramo,
        _cod_subramo,
		_no_poliza
   from temp_perfil

	foreach
	 select no_unidad,
			activo,
			no_activo_desde,
			cod_producto
	   into _no_unidad,
	        _activo,
			_no_activo_desde,
			_cod_producto
	   from emipouni
	  where no_poliza = _no_poliza

		let _cod_subramo2 = _cod_subramo;

		if _cod_subramo = "012" then

			if _cod_producto = "00392" or
			   _cod_producto = "00393" or
			   _cod_producto = "00394" then

				let _cod_subramo2 = "007";

			elif _cod_producto = "00395" or
			     _cod_producto = "00396" or
			     _cod_producto = "00397" then

				let _cod_subramo2 = "008";

			elif _cod_producto = "00412" or
			     _cod_producto = "00413" or
			     _cod_producto = "00414" then

				let _cod_subramo2 = "014";

			end if

		end if

		if _activo = 0 then
			
			if _no_activo_desde < a_fecha then
				continue foreach;
			end if

		end if

		let _cantidad = 0;

	   foreach	
		select activo,
		       no_activo_desde
		  into _activo,
		       _no_activo_desde
		  from emidepen
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad

			if _activo = 0 then
				
				if _no_activo_desde < a_fecha then
					continue foreach;
				end if

			end if
			
			let _cantidad = _cantidad + 1;

		end foreach

		let _cant_ase_0 = 0;
		let _cant_ase_1 = 0;
		let _cant_dep_1 = 0;
		let _cant_ase_2 = 0;
		let _cant_dep_2 = 0;

		if _cantidad = 0 then
			let _cant_ase_0 = 1;
		elif _cantidad = 1 then
			let _cant_ase_1 = 1;
			let _cant_dep_1 = _cantidad;
		else
			let _cant_ase_2 = 1;
			let _cant_dep_2 = _cantidad;
		end if

		insert into tmp_salud
		values(
		_cod_ramo,
		_cod_subramo2,
		_cant_ase_0,
		_cant_ase_1,
		_cant_dep_1,
		_cant_ase_2,
		_cant_dep_2
		);

	end foreach

end foreach

foreach
 select cod_ramo,
        cod_subramo,
		sum(cant_ase_0),
		sum(cant_ase_1),
		sum(cant_dep_1),
		sum(cant_ase_2),
		sum(cant_dep_2)
   into _cod_ramo,
        _cod_subramo,
		_cant_ase_0,
		_cant_ase_1,
		_cant_dep_1,
		_cant_ase_2,
		_cant_dep_2
   from tmp_salud
  where cod_subramo not in("001","002","003","004","005", "006")
  group by 1, 2

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

		return _nombre_subramo,
		       (_cant_ase_0 + _cant_ase_1 + _cant_ase_2),
			   _cant_ase_0,
			   _cant_ase_1,
			   _cant_dep_1,
			   _cant_ase_2,
			   _cant_dep_2
			   with resume;

end foreach

drop table tmp_salud;
drop table temp_perfil;
 
end procedure

