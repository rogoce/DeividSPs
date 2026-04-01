-- Procedimiento que crea la distribucion de reaseguro para polizas que no lo tienen

-- Creado    : 10/02/2004 - Autor: Amado Perez  

drop procedure sp_pro159;

create procedure sp_pro159(a_no_poliza char(10))
returning smallint,
          char(50);

define _no_unidad		char(5);
define _no_unidad_1		char(5);
define _cantidad    	smallint;
define _no_cambio		smallint;
define a_no_endoso		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_cober_reas	char(3);

let _no_cambio  = 0;
let a_no_endoso = "00000";

select vigencia_inic,
       vigencia_final
  into _vigencia_inic,
       _vigencia_final
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into _cantidad
  from emireama
 where no_poliza = a_no_poliza;

if _cantidad <> 0 then

	select min(no_unidad)
	  into _no_unidad_1
	  from emireama
	 where no_poliza = a_no_poliza;

	foreach
	 select no_unidad
	   into _no_unidad
	   from emipouni
	  where no_poliza = a_no_poliza

		select count(*)
		  into _cantidad
		  from emireama
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;

		if _cantidad = 0 then

			insert into emireama
		    select no_poliza,
				   _no_unidad,
				   no_cambio,
				   cod_cober_reas,
				   vigencia_inic,
				   vigencia_final
			  from emireama
		     where no_poliza = a_no_poliza
		       and no_unidad = _no_unidad_1;

			insert into emireaco
			select no_poliza,
				   _no_unidad,
				   no_cambio,
				   cod_cober_reas,
				   orden,
				   cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima
			  from emireaco
		     where no_poliza = a_no_poliza
		       and no_unidad = _no_unidad_1;


		end if

	end foreach

else

	foreach
	 select no_unidad
	   into _no_unidad
	   from emipouni
	  where no_poliza = a_no_poliza

		FOREACH
		 SELECT	cod_cober_reas
		   INTO	_cod_cober_reas
		   FROM	emifacon
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso
			and no_unidad = _no_unidad
		  GROUP BY cod_cober_reas

			DELETE FROM emireafa
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			DELETE FROM emireaco
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			DELETE FROM emireama
			 WHERE no_poliza      = a_no_poliza
			   AND no_unidad      = _no_unidad
			   AND no_cambio      = _no_cambio
			   AND cod_cober_reas = _cod_cober_reas;

			INSERT INTO emireama(
			no_poliza,
			no_unidad,
			no_cambio,
			cod_cober_reas,
			vigencia_inic,
			vigencia_final
			)
			VALUES(
			a_no_poliza, 
			_no_unidad,
			_no_cambio,
			_cod_cober_reas,
			_vigencia_inic,
			_vigencia_final
			);

		END FOREACH

		INSERT INTO emireaco(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		)
		SELECT 
		a_no_poliza, 
		no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM emifacon
		WHERE no_poliza = a_no_poliza
		  AND no_endoso = a_no_endoso
		  and no_unidad = _no_unidad;

		INSERT INTO emireafa(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		porc_comis_fac,
		porc_impuesto
		)
		SELECT 
		a_no_poliza, 
		no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		porc_comis_fac,
		porc_impuesto
		FROM emifafac
		WHERE no_poliza = a_no_poliza
		  AND no_endoso = a_no_endoso
		  and no_unidad = _no_unidad;

	end foreach

end if

return 0, "Actualizacion Exitosa";

end procedure
