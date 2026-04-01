-- procedimiento para insertar registros en emicupol
-- Creado    : 26/09/2001 - Autor: Armando Moreno M.

--DROP PROCEDURE sp_amm6;

--a_cob_rea_inc = 001 cobertura de reaseguro incendio para el ramo de INCENDIO
--a_cob_rea_inc = 021 cobertura de reaseguro terremoto para el ramo de INCENDIO
--a_cob_rea_inc = 003 cobertura de reaseguro incendio para el ramo de MULTIRIESGOS
--a_cob_rea_inc = 022 cobertura de reaseguro terremoto para el ramo de MULTIRIESGOS

CREATE PROCEDURE sp_amm6(
a_no_poliza 	CHAR(10)
)

DEFINE _cod_ramo        CHAR(3);  
define a_cob_rea_inc    CHAR(3);  
define a_cob_rea_ter    CHAR(3);  

DEFINE v_no_poliza      CHAR(10); 
DEFINE v_no_unidad      CHAR(5);  
DEFINE _sucursal_origen CHAR(3);  
DEFINE _cod_ubica       CHAR(3);  
DEFINE _suma_incendio   DEC(16,2);
DEFINE _suma_terremoto  DEC(16,2);
DEFINE _prima_incendio  DEC(16,2);
DEFINE _prima_terremoto DEC(16,2);

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_pro67.trc";-- Nombre de la Compania
--TRACE ON;

SET ISOLATION TO DIRTY READ;

 SELECT	no_poliza,
		cod_ramo,
		sucursal_origen
		INTO
		v_no_poliza,
		_cod_ramo,
		_sucursal_origen
   FROM	emipomae
  WHERE no_poliza = a_no_poliza;

		 IF _sucursal_origen <> "001" AND _sucursal_origen <> "002" AND _sucursal_origen <> "003" THEN
			LET _sucursal_origen = "004";
		 END IF

	if _cod_ramo = "001" then
		let a_cob_rea_inc = "001"; -- cobertura de reaseguro incendio para el ramo de INCENDIO
		let a_cob_rea_ter = "021"; -- cobertura de reaseguro terremoto para el ramo de INCENDIO
	else
		let a_cob_rea_inc = "003"; -- cobertura de reaseguro incendio para el ramo de MULTIRIESGOS
		let a_cob_rea_ter = "022"; -- cobertura de reaseguro terremoto para el ramo de MULTIRIESGOS
	end if

	-- UNIDADES
	FOREACH
		SELECT	no_unidad
		  INTO	v_no_unidad
		  FROM	emipouni
		 WHERE	no_poliza = v_no_poliza
	  	 
		SELECT cod_ubica
		  INTO _cod_ubica
		  FROM emicupol
		 WHERE no_poliza = v_no_poliza
		   AND no_unidad = v_no_unidad;

			IF _cod_ubica IS NULL THEN
	 								  
				 SELECT	SUM(suma_asegurada),
						SUM(prima)
			       INTO _suma_incendio,
						_prima_incendio
				   FROM	emifacon
				  WHERE no_poliza = v_no_poliza
				    AND no_unidad = v_no_unidad
					AND cod_cober_reas = a_cob_rea_inc;

				 SELECT	SUM(suma_asegurada),
						SUM(prima)
			       INTO _suma_terremoto,
						_prima_terremoto
				   FROM	emifacon
				  WHERE no_poliza = v_no_poliza
				    AND no_unidad =	v_no_unidad
					AND cod_cober_reas = a_cob_rea_ter;

					IF _suma_incendio IS NULL THEN
						LET _suma_incendio = 0.00;
					END IF
					IF _prima_incendio IS NULL THEN
						LET _prima_incendio = 0.00;
					END IF
					IF _suma_terremoto IS NULL THEN
						LET _suma_terremoto = 0.00;
					END IF
					IF _prima_terremoto IS NULL THEN
						LET _prima_terremoto = 0.00;
					END IF

					INSERT INTO emicupol(
					no_poliza,
					no_unidad,
					cod_ubica,
					suma_incendio,
					suma_terremoto,
					prima_incendio,
					prima_terremoto
					)
					VALUES(
					v_no_poliza,
					v_no_unidad,
					_sucursal_origen,
					_suma_incendio,
					_suma_terremoto,
					_prima_incendio,
					_prima_terremoto
					);
		    END IF
	END FOREACH

END PROCEDURE;