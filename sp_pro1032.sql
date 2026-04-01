-- Procedimiento acreedor Hipotecario SD#5797-MJARAMILLO.
-- Creado: 06/03/2023 - Autor: HGIRON
DROP PROCEDURE sp_pro1032;
CREATE PROCEDURE "informix".sp_pro1032(a_poliza CHAR(10)) 
RETURNING   CHAR(10),   -- v_no_poliza 
 			CHAR(20),	-- v_no_documento  
 			CHAR(100),	-- asegurado  
			DATE,		-- fecha
			CHAR(100), 	-- fecha_actual
 			CHAR(100),	-- fecha_apartir
 			CHAR(5),	-- endoso 
 			CHAR(100),	-- corredor
			CHAR(50),   -- ACREEDOR
			decimal(16,2), --suma asegurada de la primera unidad
			char(5),
			varchar(50),
			char(100),
			decimal(16,2),
			VARCHAR(250);
 

DEFINE _documento		 CHAR(20);
DEFINE _cod_contratante	 CHAR(10);
DEFINE _asegurado		 CHAR(100);
DEFINE _fecha		     DATE;
DEFINE _fecha_actual	 CHAR(100);
DEFINE _fecha_apartir	 CHAR(100);
DEFINE _endoso      	 CHAR(5);
DEFINE _cod_agente       CHAR(5);
DEFINE _corredor		 CHAR(100);
define _cod_acreedor     char(5);
define _acreedor         char(50);
define _suma_asegurada   decimal(16,2);
define _cod_ramo         char(3);
define _no_unidad        char(5);
define _n_ramo           varchar(50);
define _vig_inic         date;
define _fecha_suscripcion  date;
DEFINE _fecha_viginic	 CHAR(100);
define _limite           dec(16,2);
define _cant             int;
DEFINE v_monto_letras    VARCHAR(250);    
define _monto_ltr        varchar(25);


SET ISOLATION TO DIRTY READ;
let _fecha  = current;
let _endoso = "00000";
let _corredor = "";
let _no_unidad = "";
let _n_ramo    = "";
let _limite    = 0;
let _cant    = 0;
let v_monto_letras = '';

--call sp_sis20(_fecha) returning _fecha_actual;  --SD#5999JEPEREZ 24/03/2023
call sp_sis20(_fecha) returning _fecha_apartir;

-- Lectura de emipomae
SELECT no_documento,cod_contratante,cod_ramo,vigencia_inic, fecha_suscripcion
  INTO _documento, _cod_contratante,_cod_ramo,_vig_inic, _fecha_suscripcion
  FROM emipomae
 WHERE no_poliza = a_poliza 
   AND actualizado = 1;

call sp_sis20(_vig_inic) returning _fecha_viginic;

call sp_sis20(_fecha_suscripcion) returning _fecha_actual;  --SD#5999 JEPEREZ 24/03/2023

select nombre
  into _n_ramo
  from prdramo
 where cod_ramo = _cod_ramo;

   FOREACH
		 SELECT cod_agente
		   INTO _cod_agente
		   FROM emipoagt
		  WHERE no_poliza = a_poliza

		 SELECT trim(upper(nombre))
		   INTO _corredor
		   FROM agtagent
		  WHERE cod_agente = _cod_agente;
		   EXIT FOREACH;
   END FOREACH

	SELECT trim(upper(nombre))
	  INTO _asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	let _acreedor = '';
	let _suma_asegurada = 0;

	SELECT COUNT(*)
	  INTO _cant
	  FROM emipoacr
	 WHERE no_poliza = a_poliza;
	 
	IF _cant > 0 THEN
		FOREACH
			 SELECT cod_acreedor,limite,no_unidad
			   INTO _cod_acreedor,_suma_asegurada,_no_unidad
			   FROM emipoacr
			  WHERE no_poliza = a_poliza

			 SELECT trim(upper(nombre))
			   INTO _acreedor
			   FROM emiacre
			  WHERE cod_acreedor = _cod_acreedor;

			 FOREACH
				SELECT suma_asegurada
				  INTO _limite
				  FROM emipouni
				 WHERE no_poliza = a_poliza

				  EXIT FOREACH;
			  END FOREACH
			  
			  --LET v_monto_letras = sp_sis11(_suma_asegurada);
              LET v_monto_letras = sp_sis11(_suma_asegurada);
			  
			  call sp_html02(_suma_asegurada) returning _monto_ltr;
	          LET v_monto_letras = trim(_monto_ltr) ||' ('||trim(v_monto_letras) ||')'; --SD#5999 JEPEREZ 24/03/2023			  


		    RETURN a_poliza,
			       _documento,
			       _asegurado,
			       _fecha,
			       _fecha_actual,
			       _fecha_apartir,
			       _endoso,
			       _corredor,
			       _acreedor,
			       _suma_asegurada,
			       _no_unidad,
			       _n_ramo,
			       _fecha_viginic,
			       _limite,
				   v_monto_letras
			       WITH RESUME;   	

		END FOREACH
	ELSE

	   FOREACH
			 SELECT suma_asegurada
			   INTO _limite
			   FROM emipouni
			  WHERE no_poliza = a_poliza

			   EXIT FOREACH;
	   END FOREACH
	   
	   LET v_monto_letras = sp_sis11(_limite);
	   call sp_html02(_limite) returning _monto_ltr;
	   LET v_monto_letras = trim(_monto_ltr) ||' ('||trim(v_monto_letras) ||')'; --SD#5999 JEPEREZ 24/03/2023


		RETURN a_poliza,
			   _documento,
			   _asegurado,
			   _fecha,
			   _fecha_actual,
			   _fecha_apartir,
			   _endoso,
			   _corredor,
			   _acreedor,
			   _suma_asegurada,
			   _no_unidad,
			   _n_ramo,
			   _fecha_viginic,
			   _limite,
			   v_monto_letras
			   WITH RESUME;   	
    END IF

END PROCEDURE			                                                                        
