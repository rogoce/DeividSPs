-- Procedimiento que genera las cartas de Salud
-- Aviso de Cambio de Prima por Cambio de Edad	   
-- Carta para enviar cuando un asegurado principal cumple 30, 40, 45, 50, 55, 60, 65 o 70 anos

-- Creado    : 03/10/2001 - Autor: Marquelda Valdelamar
-- Modificado: 15/10/2001 - Autor: Marquelda Valdelamar

DROP PROCEDURE "informix".sp_pr76cbk;

CREATE PROCEDURE "informix".sp_pr76cbk(
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
		   DECIMAL(16,2), -- Nueva prima
		   DATE,          -- fecha
		   SMALLINT,      -- edad
		   CHAR(50),      -- Nombre de la Compania
		   char(10),			  		         
		   char(10),			  		         
		   char(10);
		   			  		    
DEFINE _no_poliza  		   CHAR(10);
DEFINE _cod_agente         CHAR(5);
DEFINE _cod_ramo           CHAR(3);
DEFINE _nombre_cliente     CHAR(50);
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
DEFINE _ano4		       SMALLINT;
DEFINE _edad               SMALLINT;
DEFINE _prima              DECIMAL(16,2);
DEFINE _vigencia_final     DATE;   
DEFINE _fecha_cumpleanos   DATE;
DEFINE _cod_producto       CHAR(5);
DEFINE v_compania_nombre   CHAR(50);
define _telefono1		   char(10);
define _telefono2		   char(10);
define _telefono3		   char(10);
 	
DEFINE _producto_nuevo     CHAR(5);
DEFINE _vigencia_fin       DATE;   

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

--Ramo de Salud
SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;


FOREACH    
  SELECT no_poliza,
         vigencia_inic,
    	 no_documento,
		 vigencia_final
    INTO _no_poliza,
	     _vigencia_inic,
	     _no_documento,
		 _vigencia_fin
    FROM emipomae
   WHERE cod_ramo        = _cod_ramo 	 
	 AND vigencia_final >= a_fecha        
	 AND actualizado     = 1
	 and colectiva       = "I"

	-- Agente de la Poliza
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

	--Seleccion de los Asegurados
	FOREACH
	 SELECT cod_asegurado,
	        cod_producto
	   INTO	_cod_asegurado,
	        _cod_producto
	   FROM emipouni
	  WHERE no_poliza = _no_poliza
	   AND  activo    = 1

--Datos del Asegurado
       SELECT nombre, 
    	      direccion_1, 
        	  direccion_2,
		 	  fecha_aniversario,
			  telefono1,
			  telefono2,
			  celular
     	INTO _nombre_cliente,
        	 _direccion1,
	    	 _direccion2,
			 _fecha_aniversario,
			  _telefono1,
			  _telefono2,
			  _telefono3
    	FROM cliclien 
	   WHERE cod_cliente = _cod_asegurado;

        IF month(_fecha_aniversario) = a_periodo[6,7]  THEN
		   IF a_periodo[1,4] - YEAR(_fecha_aniversario) = 30 OR
              a_periodo[1,4] - YEAR(_fecha_aniversario) = 40 OR 
              a_periodo[1,4] - YEAR(_fecha_aniversario) = 45 OR
              a_periodo[1,4] - YEAR(_fecha_aniversario) = 50 OR  
              a_periodo[1,4] - YEAR(_fecha_aniversario) = 55 OR
              a_periodo[1,4] - YEAR(_fecha_aniversario) = 60 OR              
              a_periodo[1,4] - YEAR(_fecha_aniversario) = 65 OR
              a_periodo[1,4] - YEAR(_fecha_aniversario) = 70 THEN
                               
				LET _edad= a_periodo[1,4] - YEAR(_fecha_aniversario); 

				-- Este cambio es solo por un ano (01/09/2005 al 31/08/2006)

				if _vigencia_fin <= "31/08/2006" then

					select producto_nuevo
					  into _producto_nuevo
					  from prdnewpro
					 where cod_producto = _cod_producto;

					-- Tarifas Nuevas

					if _producto_nuevo is not null then
						let _cod_producto = _producto_nuevo;
					end if

				end if

	 		  	SELECT prima
			      INTO _prima
			      FROM prdtaeda
			     WHERE cod_producto = _cod_producto
			       AND edad_desde   <= _edad
			       AND edad_hasta   >= _edad;

				-- Calculo de la fecha de aniversario
				    LET _ano = YEAR(a_fecha);
					LET _mes = MONTH(_fecha_aniversario);
					LET _dia = DAY(_fecha_aniversario);

				    --LET _fecha_cumpleanos = _dia || "/" || _mes || "/" || _ano;
					LET _fecha_cumpleanos = mdy(_mes,_dia,_ano);
					
					
				-- Vigencia inicial y Final
					LET _dia2      		= DAY(_vigencia_inic);
					LET _mes2           = MONTH(_vigencia_inic);
				   	LET _ano2      		= YEAR(_vigencia_inic) + 1;
					--LET _vigencia_final = _dia2 || "/" || _mes2 || "/" || _ano2;
					LET _vigencia_final = mdy(_mes2,_dia2,_ano2);

					IF _fecha_cumpleanos < _vigencia_final THEN
					  	LET _fecha_ani = _vigencia_final;
					ELSE
					    LET _ano3      = YEAR(current) + 1 ;
					    --LET _fecha_ani = _dia2 || "/" || _mes2 || "/" || _ano3;
						LET _fecha_ani = mdy(_mes2,_dia2,_ano3);
					END IF
		 	   
		RETURN 
		 _no_documento,
		 _nombre_cliente,
		 _direccion1,
		 _direccion2,
		 _fecha_ani,
		 _nombre_corredor,
		 _prima,
		 a_fecha,
		 _edad,
		 v_compania_nombre,
		_telefono1,
		_telefono2,
		_telefono3
		 WITH RESUME;

	END IF;

END IF;

END FOREACH;

END FOREACH;

END PROCEDURE;







