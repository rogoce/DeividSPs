-- Polizas y Unidades Vigentes por Periodo para BO

-- Creado    : 27/04/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_bo001;

create procedure sp_bo001(a_periodo char(7))
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _fecha 			date;
define _cant_uni		integer;

define _no_unidad		char(5);
define _no_motor		char(30);

define _cod_ramo		char(3);
define _fecha_emision	date;
define _fecha_cancela	date;
define _activo			smallint;
define _no_activo_desde	date;
define _cantidad		integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

--set debug file to "sp_bo001.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc
	return _error,  trim(_no_documento) || " " || _error_isam || " " || trim(_error_desc);
end exception									

delete from emipolvi
 where periodo = a_periodo;

delete from emiunivi
 where periodo = a_periodo;

let _fecha = sp_sis36(a_periodo);

FOREACH
 SELECT no_poliza,
  		no_documento,
  		cod_ramo,
        fecha_cancelacion
   INTO _no_poliza,
     	_no_documento,
        _cod_ramo,
        _fecha_cancela
   FROM emipomae
  WHERE fecha_suscripcion <= _fecha
    AND vigencia_inic     <  _fecha
    AND actualizado        = 1
    AND (vigencia_final >= _fecha OR 
         vigencia_final IS NULL)

	LET _fecha_emision = null;

	IF _fecha_cancela <= _fecha THEN

		FOREACH
		 SELECT fecha_emision
		   INTO _fecha_emision
		   FROM endedmae
		  WHERE no_poliza     = _no_poliza
		    AND cod_endomov   = '002'
		    AND vigencia_inic = _fecha_cancela
		END FOREACH

	end if

	IF  _fecha_emision <= _fecha THEN
		CONTINUE FOREACH;
	END IF

--	update emiunivi
--	   set no_poliza    = _no_poliza
--	 where no_documento = _no_documento;

--	update emipolvi
--	   set no_poliza    = _no_poliza
--	 where no_documento = _no_documento;

	select count(*)
	  into _cantidad
	  from emipolvi
	 where no_documento = _no_documento
	   and periodo      = a_periodo;

	if _cantidad = 0 then

		insert into emipolvi (no_documento, periodo, cant_pol_vig, cant_uni_vig, no_poliza)
		values (_no_documento, a_periodo, 1, 0, _no_poliza);

	end if

	let _no_motor = null;

	if _cod_ramo = "002" then -- Validaciones para Automovil

		foreach	
		 select no_unidad
		   into _no_unidad
		   from emipouni
		  where no_poliza = _no_poliza

			select no_motor
			  into _no_motor
			  from emiauto
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			if _no_motor is null then
				let _no_motor = "12345";
			end if

			select count(*)
			  into _cantidad
			  from emiunivi
			 where no_documento = _no_documento
			   and no_unidad    = _no_unidad
			   and periodo      = a_periodo;

			if _cantidad = 0 then

				insert into emiunivi (no_documento, no_unidad, periodo, cant_uni_vig, no_poliza, no_motor) 
				values (_no_documento, _no_unidad, a_periodo, 1, _no_poliza, _no_motor); 

			end if

		end foreach

	elif _cod_ramo = "018" then -- Validaciones para Salud

		foreach	
		 select no_unidad,
				activo,
				no_activo_desde
		   into _no_unidad,
		        _activo,
				_no_activo_desde
		   from emipouni
		  where no_poliza = _no_poliza

			if _activo = 0 then
				
				if _no_activo_desde < _fecha then
					continue foreach;
				end if

			end if

			select count(*)
			  into _cantidad
			  from emiunivi
			 where no_documento = _no_documento
			   and no_unidad    = _no_unidad
			   and periodo      = a_periodo;

			if _cantidad = 0 then

				insert into emiunivi (no_documento, no_unidad, periodo, cant_uni_vig, no_poliza, no_motor)
				values (_no_documento, _no_unidad, a_periodo, 1, _no_poliza, _no_motor); 

			end if

		end foreach

	else

		foreach	
		 select no_unidad
		   into _no_unidad
		   from emipouni
		  where no_poliza = _no_poliza

			select count(*)
			  into _cantidad
			  from emiunivi
			 where no_documento = _no_documento
			   and no_unidad    = _no_unidad
			   and periodo      = a_periodo;

			if _cantidad = 0 then

				insert into emiunivi (no_documento, no_unidad, periodo, cant_uni_vig, no_poliza, no_motor)
				values (_no_documento, _no_unidad, a_periodo, 1, _no_poliza, _no_motor); 

			end if

		end foreach

	end if

end foreach

end

return 0, "Actualizacion Exitosa ";

end procedure
