-- Consulta de Cobertura de un Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf31;

CREATE PROCEDURE sp_rwf31(a_no_tramite CHAR(10) default "%", a_no_unidad CHAR(5) default "%")
RETURNING varchar(60),
          char(5),
      	  varchar(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
      	  varchar(50);

define v_cod_cobertura		char(5);
define v_desc_cobertura		varchar(50);
define v_limite_1			dec(16,2);
define v_limite_2			dec(16,2);
define v_prima				dec(16,2);
define v_deducible			varchar(50);
define v_descrip         	varchar(60);

define _fecha               date;
define _no_poliza           char(10);
define _no_endoso           char(5);
define _contador            smallint;
define _no_reclamo          char(10);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

foreach
	SELECT no_poliza,
	       no_reclamo,
	       fecha_siniestro
	  INTO _no_poliza,
	       _no_reclamo,
	       _fecha
	  FROM recrcmae
	 WHERE no_tramite = a_no_tramite
  order by no_poliza desc
     exit foreach;

end foreach

LET _contador = 0;

FOREACH
  SELECT cod_cobertura,   
         limite_1,   
         limite_2,   
         prima,   
         deducible
    INTO v_cod_cobertura,
    	 v_limite_1,	
    	 v_limite_2,
    	 v_prima,		
         v_deducible  
    FROM emipocob  
   WHERE no_poliza = _no_poliza 
     AND no_unidad = a_no_unidad
     AND cod_cobertura not in (SELECT cod_cobertura FROM recrccob WHERE no_reclamo = _no_reclamo)   
ORDER BY cod_cobertura ASC   

SELECT nombre
  INTO v_desc_cobertura
  FROM prdcober
 WHERE cod_cobertura = v_cod_cobertura;

LET _contador = _contador + 1;

RETURN v_cod_cobertura || " - " || v_desc_cobertura,
       v_cod_cobertura, 
       v_desc_cobertura,
	   v_limite_1,
	   v_limite_2,
	   v_prima,	
	   v_deducible
 	   WITH RESUME;

END FOREACH

IF _contador = 0 THEN
	SELECT	y.no_endoso
	  INTO	_no_endoso
	  FROM	endedmae x, endeduni y 
	 WHERE x.no_poliza = _no_poliza
	   AND y.no_poliza = x.no_poliza
	   AND y.no_endoso = x.no_endoso
	   AND y.no_unidad = a_no_unidad
	   AND x.cod_endomov = '005'
	   AND (x.vigencia_inic > _fecha
	    OR (x.vigencia_inic <= _fecha AND x.fecha_emision > _fecha));

	FOREACH
		  SELECT cod_cobertura,   
		         limite_1,   
		         limite_2,   
		         prima,   
		         deducible 
		    INTO v_cod_cobertura,
		    	 v_limite_1,	
		    	 v_limite_2,
		    	 v_prima,		
		    	 v_deducible  
		    FROM endedcob  
		   WHERE no_poliza = _no_poliza 
		     AND no_unidad = a_no_unidad
		     AND no_endoso = _no_endoso
             AND cod_cobertura not in (SELECT cod_cobertura FROM recrccob WHERE no_reclamo = _no_reclamo)   
		     
	SELECT nombre
	  INTO v_desc_cobertura
	  FROM prdcober
	 WHERE cod_cobertura = v_cod_cobertura;

	RETURN v_cod_cobertura || " - " || v_desc_cobertura,
	       v_cod_cobertura, 
	       v_desc_cobertura,
		   v_limite_1,
		   v_limite_2,
		   v_prima,	
		   v_deducible
	 	   WITH RESUME;

	END FOREACH
END IF
END PROCEDURE;