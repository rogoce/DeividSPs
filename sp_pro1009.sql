-- 
DROP PROCEDURE sp_pro1009;
CREATE PROCEDURE "informix".sp_pro1009(a_poliza CHAR(10)) 
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
			decimal(16,2),
 			decimal(16,2),
			varchar(50),
			varchar(50),
			varchar(50),
			varchar(50),
			char(10);

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
DEFINE _fecha_viginic	 CHAR(100);
define _cnt              integer;
define _limite_1		 decimal(16,2);
define _limite_2		 decimal(16,2);
define _deducible	     varchar(50);
define _limite_3		 decimal(16,2);
define _cod_cobertura    char(5);
define _ded_inc			 varchar(50);
define _ded_rob			 varchar(50);
define _ded_col			 varchar(50);
define _placa			 char(10); 

SET ISOLATION TO DIRTY READ;
let _fecha  = current;
let _endoso = "00000";
let _corredor = "";
let _no_unidad = "";
let _n_ramo    = "";
let _deducible = "";
let _limite_3  = "";
let _limite_2  = "";
let _limite_1  = "";

select count(*)
  into _cnt
  from emipocob
 where no_poliza = a_poliza
   and cod_cobertura in("01145","01315"); --Cobertura ENDOSO DE NAVIERA

--and cod_cobertura in("01145",'01315'); --Cobertura ENDOSO DE NAVIERA   

if _cnt > 0 then
else
	return "1","","","","","","","","","","","","",0,0,0,"","","","","";
end if


call sp_sis20(_fecha) returning _fecha_actual;
call sp_sis20(_fecha) returning _fecha_apartir;

-- Lectura de emipomae
SELECT no_documento,cod_contratante,cod_ramo,vigencia_inic
  INTO _documento, _cod_contratante,_cod_ramo,_vig_inic
  FROM emipomae
 WHERE no_poliza = a_poliza 
   AND actualizado = 1;

call sp_sis20(_vig_inic) returning _fecha_viginic;

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

-- BUSCANDO UNIDADES CON ENDOSO DE NAVIERA -- AMADO 27-01-2025
FOREACH with hold
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emipouni
	 WHERE no_poliza = a_poliza
	 
	select count(*)
	  into _cnt
	  from emipocob
	 where no_poliza = a_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura in("01145","01315"); --Cobertura ENDOSO DE NAVIERA

	--and cod_cobertura in("01145",'01315'); --Cobertura ENDOSO DE NAVIERA   

	if _cnt > 0 then
	else
		continue foreach;
	end if	 
	 
	{FOREACH
		select c.cod_cobertura,
			   c.no_unidad
		  into _cod_cobertura,
			   _no_unidad
		  from emipocob c
		 where c.no_poliza = a_poliza
		   and c.cod_cobertura in('01145') --Cobertura ENDOSO DE NAVIERA
		   --and c.cod_cobertura in('01145','01315') --Cobertura ENDOSO DE NAVIERA
		 group by 1,2

		exit foreach;

	END FOREACH}

	foreach
			select limite_1,
				   limite_2
			  into _limite_1,
				   _limite_2
			  from emipocob
			 where no_poliza     = a_poliza
			   and no_unidad     = _no_unidad
			   --and cod_cobertura in ("00102")	 --Lesiones
			   and cod_cobertura in ("00102","01299")	 --Lesiones

			exit foreach;
	end foreach

	foreach
			select limite_1,
				   deducible
			  into _limite_3,
				   _deducible
			  from emipocob
			 where no_poliza     = a_poliza
			   and no_unidad     = _no_unidad
			   --and cod_cobertura in("00113")	 --Danos a la prop ajena
			   and cod_cobertura in("00113","01304")	 --Danos a la prop ajena

			exit foreach;
	end foreach

	let _ded_inc = "";
	{foreach
			select deducible
			  into _ded_inc
			  from emipocob
			 where no_poliza     = a_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = "00120"	 --Incendio

			exit foreach;
	end foreach
				 }
	let _ded_rob = "";
	{foreach
			select deducible
			  into _ded_rob
			  from emipocob
			 where no_poliza     = a_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura = "00103"	 --Robo

			exit foreach;
	end foreach	}

	let _ded_col = "";
	{foreach
			select deducible
			  into _ded_col
			  from emipocob
			 where no_poliza     = a_poliza
			   and no_unidad     = _no_unidad
			   and cod_cobertura in("00119","00121")	 --Colision

			exit foreach;
	end foreach	 }

		select a.placa
		  into _placa
		  from emivehic a, emiauto b
		 where a.no_motor = b.no_motor
		   and b.no_poliza = a_poliza
		   and b.no_unidad = _no_unidad;

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
		   _limite_1,
		   _limite_2,
		   _limite_3,
		   _deducible,
		   _ded_inc,
		   _ded_rob,
		   _ded_col,
		   _placa
		   WITH RESUME;
END FOREACH


END PROCEDURE			   