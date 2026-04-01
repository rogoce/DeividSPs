-- Procedimiento que genera las cartas de Salud
-- Solicitud de Evidencia de Estudios	   
-- Carta para enviar cuando un hijo dependiente cumple 19 anos

-- Creado    : 03/10/2001 - Autor: Marquelda Valdelamar
-- Modificado: 10/10/2001 - Autor: Marquelda Valdelamar

DROP PROCEDURE "informix".sp_pr76a;

CREATE PROCEDURE "informix".sp_pr76a(
a_compania      CHAR(50),
a_sucursal      CHAR(50),
a_fecha         DATE,
a_periodo       CHAR(7)

)RETURNING CHAR(20),      -- No_documento
		   CHAR(50),      -- Nombre del cliente
		   CHAR(50),      -- Direccion_1
		   CHAR(50),      -- Direccion_2
		   DATE,   	      -- Fecha aniversario
		   CHAR(50),      -- Nombre del Agente
		   CHAR(50),      -- Nombre del hijo dependiente
		   DATE,          -- fecha
		   CHAR(50);      -- Nombre de la Compania
		  			  		         
DEFINE _no_poliza  		   CHAR(10);
DEFINE _nombre_dependiente CHAR(50);
DEFINE _cod_agente         CHAR(5);
DEFINE _cod_ramo           CHAR(3);
DEFINE _nombre_asegurado   CHAR(50);
DEFINE _nombre_corredor    CHAR(50);
DEFINE _direccion1		   CHAR(50);
DEFINE _direccion2         CHAR(50);
DEFINE _no_documento       CHAR(20);
DEFINE _cod_asegurado      CHAR(10);
DEFINE _fecha_aniversario  DATE;
DEFINE _vigencia_inic      DATE;
DEFINE _fecha_ani          DATE;
DEFINE _dia     		   SMALLINT;
DEFINE _mes	        	   SMALLINT;
DEFINE _ano		           SMALLINT;
DEFINE _dia2    		   SMALLINT;
DEFINE _mes2	    	   SMALLINT;
DEFINE _ano2		       SMALLINT;
DEFINE _ano3		       SMALLINT;
DEFINE _vigencia_final     DATE;   
DEFINE _fecha_cumpleanos   DATE;
DEFINE v_compania_nombre   CHAR(50);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

--Ramo de Salud
SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

--Seleccion de las polizas de salud actualizadas

FOREACH    
 SELECT no_poliza,
        vigencia_inic,
		no_documento
   INTO _no_poliza,
        _vigencia_inic,
		_no_documento
   FROM emipomae
  WHERE cod_ramo        = _cod_ramo 
	AND estatus_poliza  = 1        
	AND actualizado     = 1

-- Seleccion de los Asegurados de la Poliza
FOREACH
 SELECT cod_asegurado
   INTO	_cod_asegurado
   FROM emipouni
  WHERE no_poliza = _no_poliza

--Datos del Dependiente
  FOREACH
   SELECT c.nombre,
      	  c.fecha_aniversario
     INTO _nombre_dependiente,
          _fecha_aniversario
     FROM emidepen a, emiparen b, cliclien c
    WHERE a.no_poliza      = _no_poliza
      AND a.activo         = 1
      AND a.cod_parentesco = b.cod_parentesco
      AND a.cod_cliente    = c.cod_cliente
      AND b.tipo_pariente  = 2
      AND month(c.fecha_aniversario)                 = a_periodo[6,7] 
      AND a_periodo[1,4] - YEAR(c.fecha_aniversario) = 19

  --Seleccion de Datos del Cliente
   SELECT nombre, 
          direccion_1, 
          direccion_2
     INTO _nombre_asegurado,
          _direccion1,
    	  _direccion2
	 FROM cliclien
    WHERE cod_cliente = _cod_asegurado;

-- Calculo de la fecha de cumpleanos
    LET _ano = YEAR(a_fecha);
	LET _mes = MONTH(_fecha_aniversario);
	LET _dia = DAY(_fecha_aniversario);
    LET _fecha_cumpleanos = _dia || "/" || _mes || "/" || _ano;

-- Calculo de la Vigencia Final de la Poliza
	LET _dia2      		= DAY(_vigencia_inic);
	LET _mes2           = MONTH(_vigencia_inic);
   	LET _ano2      		= YEAR(_vigencia_inic) + 1;
	LET _vigencia_final = _dia2 || "/" || _mes2 || "/" || _ano2;

-- Calculo de la fecha de aniversario de la poliza
    LET _ano = YEAR(a_fecha);
	LET _mes = MONTH(_fecha_aniversario);
	LET _dia = DAY(_fecha_aniversario);

    LET _fecha_cumpleanos = _dia || "/" || _mes || "/" || _ano;

	IF _fecha_cumpleanos < _vigencia_final THEN
		LET _fecha_ani = _vigencia_final;
	ELSE
	    LET _ano3      = YEAR(_vigencia_final) + 1 ;
	    LET _fecha_ani = _dia2 || "/" || _mes2 || "/" || _ano3;
	END IF

-- Agente de la Poliza
	  IF _no_poliza IS NOT NULL THEN 
	  	FOREACH
	  	 SELECT cod_agente
	  	 INTO   _cod_agente
	  	 FROM   emipoagt
	  	 WHERE  no_poliza = _no_poliza
			 
	  	 SELECT nombre
	  	   INTO _nombre_corredor
	  	   FROM agtagent
	  	  WHERE cod_agente = _cod_agente;
	  	 EXIT FOREACH;
	  	 END FOREACH
	  END IF

		RETURN 
		 _no_documento,
		 _nombre_asegurado,
		 _direccion1,
		 _direccion2,
		 _fecha_ani,
		 _nombre_corredor,
		 _nombre_dependiente,
		 a_fecha,
  		 v_compania_nombre
		 WITH RESUME;
 END FOREACH;
 END FOREACH;
END FOREACH;
END PROCEDURE;



