-- Procedimiento que 
-- Creado    : 14/10/2015 - Autor: Armando Moreno
--

DROP PROCEDURE sp_ver_emireama;

CREATE PROCEDURE "informix".sp_ver_emireama(a_no_poliza char(10)) 
RETURNING char(5);
		  
DEFINE _no_unidad        CHAR(5);
DEFINE _cnt           smallint;
define _cod_cober_reas  char(3);

let _cod_cober_reas = null;

foreach
	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	order by no_unidad 


	 select count(*)
	   into _cnt
	   from emireama
	  where no_poliza = a_no_poliza
	    and no_unidad = _no_unidad;

	if _cnt is null then
		let _cnt = 0;
	end if	

	if _cnt = 0 then
	
	{	FOREACH
			 SELECT	no_unidad,
					cod_cober_reas
			   INTO	_no_unidad,
					_cod_cober_reas
			   FROM	emifacon
			  WHERE	no_poliza = a_no_poliza
				AND no_endoso = '00000'
				AND no_unidad = _no_unidad
			  GROUP BY no_unidad, cod_cober_reas

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
				0,
				_cod_cober_reas,
				'01/03/2015',
				'01/03/2016'
				);
		END FOREACH

		if _cod_cober_reas is null then
			continue foreach;
		end if	
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
		0,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM emifacon
		WHERE no_poliza = a_no_poliza
		  AND no_endoso = '00000'
		  AND no_unidad = _no_unidad;}
		  
		return _no_unidad with resume;
	end if	
end foreach

return 0;
END PROCEDURE;