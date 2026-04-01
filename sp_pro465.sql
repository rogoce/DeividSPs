--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES          ---
---  Armando Moreno M. 22/11/2001
---  Ref. Power Builder - sp_pro03
--------------------------------------------

DROP procedure sp_pr465;

CREATE procedure "informix".sp_pr465()
RETURNING integer;

define _no_poliza		CHAR(10);
define _no_unidad 		char(5);
define _cod_cobertura 	char(5);
define _tipo 			smallint;
define _cantidad		smallint;

define _ano				smallint;
define _periodo			char(7);
define _fecha			date;

set isolation to dirty read;

call sp_sac104() returning _ano, _periodo, _fecha;

foreach
 select e.no_poliza
   into _no_poliza
   from endedmae e, emipomae p
  where e.no_poliza = p.no_poliza
    and e.actualizado = 1
	and e.periodo     >= _periodo
    and p.cod_ramo    in ("002", "023", "020")

	 select count(*)
	   into _cantidad
	   from endeduni
	  where no_poliza = _no_poliza;

	if _cantidad = 0 then

		foreach
		 select no_unidad
		   into _no_unidad
		   from emipouni
		  where no_poliza = _no_poliza

			delete from sodatmp
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			   			
			let _tipo = 1;

			foreach
		     select cod_cobertura
			   into _cod_cobertura
			   from emipocob
			  where no_poliza = _no_poliza
			    and no_unidad = _no_unidad

				if _cod_cobertura = "00118" or 
				   _cod_cobertura = "00119" or 
				   _cod_cobertura = "00121" or
				   _cod_cobertura = "01306" or
				   _cod_cobertura = "01307" then

					let _tipo = 2;
					exit foreach;

				end if

			end foreach

	        INSERT INTO sodatmp(
			no_poliza,
			no_unidad,
			tipo)
	        VALUES(
	        _no_poliza,
	        _no_unidad,
			_tipo
	       );

		end foreach

	else

		foreach
		 select no_unidad
		   into _no_unidad
		   from endeduni
		  where no_poliza = _no_poliza
		  group by no_unidad

			delete from sodatmp
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			let _tipo = 1;

			foreach
		     select cod_cobertura
			   into _cod_cobertura
			   from endedcob
			  where no_poliza = _no_poliza
			    and no_unidad = _no_unidad
			  group by cod_cobertura

				if _cod_cobertura = "00118" or 
				   _cod_cobertura = "00119" or 
				   _cod_cobertura = "00121" or
				   _cod_cobertura = "01306" or
				   _cod_cobertura = "01307" then

					let _tipo = 2;
					exit foreach;

				end if

			end foreach

	        INSERT INTO sodatmp(
			no_poliza,
			no_unidad,
			tipo)
	        VALUES(
	        _no_poliza,
	        _no_unidad,
			_tipo
	       );

		end foreach

	end if

END FOREACH

RETURN 0;

END PROCEDURE







										  