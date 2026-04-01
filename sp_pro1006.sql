-- Endosos especiales
-- Creado    : 22/08/2011 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_pro1006;
CREATE PROCEDURE "informix".sp_pro1006(a_poliza CHAR(10))
RETURNING   dec(16,2),  -- suma aseg unidad
 			CHAR(5);	-- _no_unidad

define _limite_1       dec(16,2);
define _no_unidad	   char(5);
define _cod_cober      char(5);
define _cnt            smallint;


SET ISOLATION TO DIRTY READ;

-- Lectura de emipouni
foreach

	SELECT no_unidad
	  INTO _no_unidad
	  FROM emipouni
	 WHERE no_poliza = a_poliza

	select count(*)
	  into _cnt
	  from emipocob
	 where no_poliza     = a_poliza
	   and cod_cobertura = "00101";


	if _cnt	> 0 then  --tiene la cobertura dano a instalaciones electricas
		
		foreach
			select limite_1,
			       cod_cobertura
			  into _limite_1,
			       _cod_cober
			  from emipocob
			 where no_poliza = a_poliza
			   and no_unidad = _no_unidad

			if _cod_cober = "00101" then 

				RETURN _limite_1,_no_unidad  WITH RESUME;

			end if

		end foreach

	end if


end foreach

END PROCEDURE			   