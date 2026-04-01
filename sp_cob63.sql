-- Armar ruta (AREA)
-- 
-- Creado    : 13/03/2001 - Autor: Armando Moreno M.
-- Modificado: 13/03/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob63;

CREATE PROCEDURE "informix".sp_cob63(a_cobrador CHAR(3), a_dia INT,a_ruta_nvo INT) 
       RETURNING	    CHAR(30),   -- nombre dtto
						CHAR(100),	-- nombre area
						SMALLINT,  	-- Orden1
						CHAR(3),  	-- code_pais
						CHAR(2),  	-- code_provincia
						CHAR(2),  	-- code_ciudad
						CHAR(2),  	-- code_distrito
						CHAR(5),  	-- code_area
						INT;


DEFINE v_nom_distrito    CHAR(30);	   
DEFINE v_nom_area        CHAR(100);
DEFINE v_code_pais  	 CHAR(3);
DEFINE v_code_provincia	 CHAR(2);
DEFINE v_code_ciudad     CHAR(2);
DEFINE v_code_distrito	 CHAR(2);
DEFINE v_code_correg	 CHAR(5);
DEFINE v_orden           SMALLINT;
--DEFINE _fecha            DATETIME YEAR TO FRACTION(5);
--DEFINE _activo			 SMALLINT;

If a_ruta_nvo = 0 Then
	FOREACH
	 -- Lectura de Cobruter	
			SELECT code_pais,
				   code_provincia,
				   code_ciudad,
				   code_distrito,
				   code_correg
			  INTO v_code_pais,
				   v_code_provincia,
				   v_code_ciudad,     
				   v_code_distrito,
				   v_code_correg
			  FROM cobruter
			 WHERE cod_cobrador = a_cobrador
			   AND (dia_cobros1 = a_dia
			   OR  dia_cobros2 = a_dia)
			 GROUP BY code_pais,code_provincia,code_ciudad,code_distrito,code_correg
			 ORDER BY code_pais,code_provincia,code_ciudad,code_distrito,code_correg

		SELECT nombre
		  INTO v_nom_distrito
		  FROM gendtto
		 WHERE code_pais = v_code_pais
		   AND code_provincia = v_code_provincia
		   AND code_ciudad = v_code_ciudad
		   AND code_distrito = v_code_distrito;

		SELECT nombre,
		       orden
		  INTO v_nom_area,
			   v_orden	
		  FROM gencorr
		 WHERE code_pais = v_code_pais
		   AND code_provincia = v_code_provincia
		   AND code_ciudad = v_code_ciudad
		   AND code_distrito = v_code_distrito
		   AND code_correg = v_code_correg;

			IF v_orden IS NULL THEN
				LET v_orden = 0;
			END IF

		RETURN v_nom_distrito,	   
			   v_nom_area,      
			   v_orden,
		       v_code_pais,
			   v_code_provincia,
			   v_code_ciudad,     
			   v_code_distrito,
			   v_code_correg,
			   a_ruta_nvo
			   WITH RESUME;

	END FOREACH;
Else
	FOREACH
	 -- Lectura de Cobruter1	
			SELECT code_pais,
				   code_provincia,
				   code_ciudad,
				   code_distrito,
				   code_correg
				   --fecha,
				   --activo,
				   --cod_pagador
			  INTO v_code_pais,
				   v_code_provincia,
				   v_code_ciudad,     
				   v_code_distrito,
				   v_code_correg
				   --_fecha,
				   --_activo,
				   --_cod_pagador
			  FROM cobruter1
			 WHERE cod_cobrador = a_cobrador
			   AND (dia_cobros1 = a_dia
			   OR  dia_cobros2 = a_dia)
			 GROUP BY code_pais,code_provincia,code_ciudad,code_distrito,code_correg
			 ORDER BY code_pais,code_provincia,code_ciudad,code_distrito,code_correg

		{SELECT pago_fijo
		  INTO _pago_fijo
		  FROM cascliente
		 WHERE cod_cliente = _cod_pagador;}

		{if _pago_fijo = 1 then	--cte. es de pago fijo
			if _activo = 0 then --cte. esta inactivo por que pago en otra fecha que no es la establecida
				if month(date(_fecha)) = month(Today) then
					continue foreach;
				end if
			end if
		end if}

		SELECT nombre
		  INTO v_nom_distrito
		  FROM gendtto
		 WHERE code_pais = v_code_pais
		   AND code_provincia = v_code_provincia
		   AND code_ciudad = v_code_ciudad
		   AND code_distrito = v_code_distrito;

		SELECT nombre,
		       orden
		  INTO v_nom_area,
			   v_orden	
		  FROM gencorr
		 WHERE code_pais = v_code_pais
		   AND code_provincia = v_code_provincia
		   AND code_ciudad = v_code_ciudad
		   AND code_distrito = v_code_distrito
		   AND code_correg = v_code_correg;

			IF v_orden IS NULL THEN
				LET v_orden = 0;
			END IF

		RETURN v_nom_distrito,	   
			   v_nom_area,      
			   v_orden,
		       v_code_pais,
			   v_code_provincia,
			   v_code_ciudad,     
			   v_code_distrito,
			   v_code_correg,
			   a_ruta_nvo		
			   WITH RESUME;

	END FOREACH;
End If
END PROCEDURE