-- Carta para levantar exclusion a los dependientes

DROP PROCEDURE "informix".sp_pr76e;
CREATE PROCEDURE "informix".sp_pr76e(
a_compania      CHAR(50),
a_sucursal      CHAR(50),
a_fecha         DATE,
a_periodo       CHAR(7)

)RETURNING CHAR(20), -- no_documento     
		   CHAR(50), -- nombre_asegurado     
		   CHAR(50), -- direccion 1     
		   CHAR(50), -- direccion 2     
		   CHAR(50), -- aplica
		   CHAR(50), -- nombre exclusion
		   CHAR(50), -- corredor de la poliza
		   DATE;     -- fecha_carta
		  			  		         
DEFINE _no_poliza  		        CHAR(10);
DEFINE _cod_agente              CHAR(5);
DEFINE _no_documento            CHAR(20);
DEFINE _nombre_asegurado        CHAR(50);
DEFINE _nombre_dependiente      CHAR(50);
DEFINE _nombre_corredor         CHAR(50);
DEFINE _direccion1		        CHAR(50);
DEFINE _direccion2              CHAR(50);
DEFINE _cod_asegurado           CHAR(10);
DEFINE _cod_dependiente         CHAR(10);
DEFINE _cod_procedimiento_depen CHAR(5);
DEFINE _nombre_procedimiento    CHAR(50);
DEFINE _aplica                  CHAR(50);
DEFINE _fecha_revision          DATE;
DEFINE v_compania_nombre        CHAR(50);

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT a.cod_procedimiento,
	    a.fecha,
		a.no_poliza,
		b.cod_cliente,
		c.cod_asegurado
   INTO _cod_procedimiento_depen,
     	_fecha_revision,
		_no_poliza,
		_cod_dependiente,
		_cod_asegurado
   FROM emiprede a, emidepen b , emipouni c
  WHERE a.fecha     = a_fecha
    AND a.no_poliza = b.no_poliza
	AND a.no_unidad = b.no_unidad
	AND c.no_poliza = c.no_poliza

  SELECT no_documento
    INTO _no_documento
    FROM emipomae
   WHERE no_poliza = _no_poliza
     AND vigencia_final >= a_fecha        
	 AND actualizado     = 1;

  SELECT nombre
    INTO _nombre_dependiente
    FROM cliclien
   WHERE cod_cliente = _cod_dependiente;

  SELECT nombre, 
         direccion_1, 
    	 direccion_2
    INTO _nombre_asegurado,
         _direccion1,
   	     _direccion2
    FROM cliclien
   WHERE cod_cliente = _cod_asegurado;

  SELECT nombre
    INTO _nombre_procedimiento
	FROM emiproce
   WHERE cod_procedimiento = _cod_procedimiento_depen;

 LET _aplica = _nombre_dependiente;
 
 -- Agente de la Poliza
FOREACH
 SELECT cod_agente
   INTO _cod_agente
   FROM emipoagt
  WHERE no_poliza = _no_poliza
			 
 SELECT nombre
   INTO _nombre_corredor
   FROM agtagent
  WHERE cod_agente = _cod_agente;
 EXIT FOREACH;
 END FOREACH 
	
		RETURN 
		 _no_documento,
		 _nombre_asegurado,
		 _direccion1,
		 _direccion2,
		 _aplica,
		 _nombre_procedimiento,
		 _nombre_corredor,
  		 a_fecha
		 WITH RESUME;

    END FOREACH;
END PROCEDURE;






























