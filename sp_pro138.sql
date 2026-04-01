-- Polizas para Cartas de Aumento de Primas
--
-- Creado    : 11/07/2002 - Autor: Armando Moreno

-- SIS v.2.0 - - DEIVID, S.A.

--DROP PROCEDURE sp_pro138;

CREATE PROCEDURE "informix".sp_pro138(a_cia CHAR(3), a_agencia CHAR(3), a_fecha date)
RETURNING char(100),
		  date,
		  smallint,
		  char(1),
		  char(20),
          date,
		  date,
		  dec(16,2),
		  dec(16,2);

DEFINE _nombre_asegurado  	CHAR(100); 
DEFINE _fecha				DATE;
DEFINE _edad				smallint;
DEFINE _sexo				CHAR(1);
DEFINE _no_documento    	CHAR(20);
DEFINE _vigencia_inic   	DATE;
DEFINE _vigencia_final  	DATE;
DEFINE _suma_asegurada		DEC(16,2);
DEFINE _prima				DEC(16,2);

DEFINE _no_poliza       	CHAR(10); 
DEFINE _cod_asegurado   	CHAR(10); 

DEFINE v_descr_cia      	CHAR(50);
DEFINE v_filtros        	CHAR(255);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\demrep41.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

LET v_descr_cia = sp_sis01(a_cia);

--polizas vigentes a la fecha

CALL sp_pro03(a_cia, a_agencia, a_fecha, '019;') RETURNING v_filtros;    

FOREACH
 SELECT no_poliza,
		no_documento
   INTO _no_poliza,
		_no_documento
   FROM temp_perfil
  WHERE seleccionado = 1

   FOREACH	
	SELECT cod_asegurado,
	       vigencia_inic,
		   vigencia_final,
		   suma_asegurada,
		   prima_bruta
	  INTO _cod_asegurado,
	       _vigencia_inic,
		   _vigencia_final,
		   _suma_asegurada,
		   _prima
	  FROM emipouni
	 WHERE no_poliza = _no_poliza

		SELECT nombre,
			   fecha_aniversario,
			   sexo
		  INTO _nombre_asegurado,
			   _fecha,
			   _sexo
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		LET _edad = YEAR(TODAY) - YEAR(_fecha);

		IF MONTH(TODAY) < MONTH(_fecha) THEN
			LET _edad = _edad - 1;
		ELIF MONTH(_fecha) = MONTH(TODAY) THEN
			IF DAY(TODAY) < DAY(_fecha) THEN
				LET _edad = _edad - 1;
			END IF
		END IF
		
		RETURN _nombre_asegurado,  
			   _fecha,	
			   _edad,
			   _sexo,				
			   _no_documento,    	
			   _vigencia_inic,   	
			   _vigencia_final,  	
			   _suma_asegurada,
			   _prima
			   WITH RESUME;

	END FOREACH

END FOREACH

DROP TABLE temp_perfil;

END PROCEDURE;
