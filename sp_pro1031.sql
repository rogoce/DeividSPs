-- Procedimiento unidades -- 
-- Creado    : 06/09/2022 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_pro1031;
CREATE PROCEDURE "informix".sp_pro1031(a_poliza CHAR(10)) 
RETURNING   CHAR(10),   -- v_no_poliza 
 			CHAR(20),   -- v_no_documento
            char(100),	-- vig inicial
			char(100),	-- vig final
			char(100),  -- aseg.
			char(100),  -- fecha actual
		 varchar(100),
		 decimal(16,2),
		 decimal(16,2),
		 decimal(16,2),
		 CHAR(50),
		 CHAR(5),
		 CHAR(10),varchar(50);

DEFINE _documento		 CHAR(20);
define _vig_ini			 date;
define _vig_fin			 date;
define _fecha_ini        char(100);
define _fecha_fin		 char(100);
define _cod_contratante  char(10);
define _cod_asegurado    char(10);
DEFINE _asegurado		 CHAR(100);
define _fecha_actual     char(100);
define _fecha            date;
define _direccion		 varchar(100);
define _direccion_1      varchar(50);
define _prima_neta		 decimal(16,2);
define _impuesto		 decimal(16,2);
define _prima_bruta		 decimal(16,2);
define _direccion_2      varchar(50);
DEFINE v_placa		   	 CHAR(10);
DEFINE v_motor        	 CHAR(30);
DEFINE v_cod_ramo		 CHAR(3);	
DEFINE v_desc_ramo       CHAR(50);
DEFINE _no_unidad      	 CHAR(5);
DEFINE _cod_grupo			varchar(5); 
define _nombre_grupo        varchar(50);

let _fecha = current;
let v_desc_ramo = '';
let _nombre_grupo	  = '';	

SET ISOLATION TO DIRTY READ;

let _fecha_actual = "";
-- Lectura de emipomae
SELECT no_documento,
	   vigencia_inic,
	   vigencia_final,
	   cod_contratante,
	   prima_neta,
	   impuesto,
	   prima_bruta,
	   cod_ramo, 
	   cod_grupo
  INTO _documento,
	   _vig_ini,
	   _vig_fin,
	   _cod_contratante,
	   _prima_neta,
	   _impuesto,
	   _prima_bruta,
	   v_cod_ramo, 
	   _cod_grupo
  FROM emipomae
 WHERE no_poliza = a_poliza 
   AND actualizado = 1;
   
SELECT trim(upper(nombre))
  INTO v_desc_ramo 
  FROM prdramo a 
 WHERE a.cod_ramo  = v_cod_ramo; 
   
-- Lectura de emipouni
foreach

	SELECT no_unidad, cod_asegurado
	  INTO _no_unidad, _cod_asegurado
	  FROM emipouni
	 WHERE no_poliza = a_poliza
	 and activo = 1

		let _asegurado = "";

		SELECT trim(upper(nombre)),
			   trim(direccion_1),
			   trim(direccion_2)
		  INTO _asegurado,
			   _direccion_1,
			   _direccion_2
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		if _direccion_1 is null then
			let _direccion_1 = "";
		end if

		if _direccion_2 is null then
			let _direccion_2 = "";
		end if

		let _direccion = _direccion_1 || _direccion_2;
	
		LET v_motor = '';

			SELECT no_motor
			  INTO v_motor
			  FROM emiauto
			 WHERE no_poliza = a_poliza
			   AND no_unidad = _no_unidad;

			IF v_motor IS NULL OR v_motor = '' THEN
				FOREACH
					SELECT no_motor
					  INTO v_motor
					  FROM endmoaut
					 WHERE no_poliza = a_poliza
					   AND no_unidad = _no_unidad
				  ORDER BY no_endoso DESC
				  EXIT FOREACH;
				END FOREACH
			END IF

		-- Placa del Vehiculo
			SELECT placa
			  INTO v_placa
			  FROM emivehic
			 WHERE no_motor = v_motor;
			 
	    IF v_placa IS NULL THEN
			LET v_placa = "";
		END IF		 
		 

		call sp_sis20(_vig_ini) returning _fecha_ini;
		call sp_sis20(_vig_fin) returning _fecha_fin;
		call sp_sis20(_fecha)   returning _fecha_actual;
		
		select nombre 
		  into _nombre_grupo
		  from deivid:cligrupo 
		 where cod_grupo = _cod_grupo;
		 
		if _cod_grupo = '00001' then
			let _nombre_grupo = " --- ";
		end if		 

			RETURN a_poliza,
				   _documento,
				   _fecha_ini,
				   _fecha_fin,
				   _asegurado,
				   _fecha_actual,
				   _direccion,
				   _prima_neta,
				   _impuesto,
				   _prima_bruta,
				   v_desc_ramo,
				   _no_unidad,
				   v_placa,_nombre_grupo
				   WITH RESUME;   	

end foreach

END PROCEDURE			                                                  


		   