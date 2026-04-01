--Creado por Armando Moreno 24/04/2002

DROP PROCEDURE sp_con1;
CREATE PROCEDURE "informix".sp_con1(a_no_motor CHAR(30))
       RETURNING CHAR(20),	 --documento
       			 SMALLINT,	 --estatus
       			 CHAR(5),	 --unidad
       			 CHAR(100),	 --aseg.
       			 CHAR(50),	 --marca
       			 SMALLINT,	 --ano
       			 SMALLINT,	 --error
				 CHAR(30),	 --no motor
       			 CHAR(50);	 --modelo

DEFINE _no_poliza,_cod_contratante      CHAR(10);
DEFINE v_cod_marca  					CHAR(5);
DEFINE _cod_modelo  					CHAR(5);
DEFINE _no_documento  					CHAR(20);
DEFINE _no_unidad       				CHAR(05);
DEFINE v_desc_marca      				CHAR(50);
DEFINE _nombre_modelo     				CHAR(50);
DEFINE _ano_auto		 				INTEGER;
DEFINE _error,_estatus_poliza    		SMALLINT;
DEFINE v_desc_asegurado 				CHAR(100);

SET ISOLATION TO DIRTY READ;

LET _error = 0;
LET _no_poliza = null;

FOREACH
	SELECT no_poliza, 
	       no_unidad
	  INTO _no_poliza,
	  	   _no_unidad
	  FROM emiauto
	 WHERE no_motor = a_no_motor
	 ORDER BY no_poliza DESC
		EXIT FOREACH;
END FOREACH

IF _no_poliza IS NULL THEN
	LET _error = 1;
	LET _ano_auto = null;
	RETURN "",
		   "",
		   "",    
		   "",          
		   "",     
		   _ano_auto,       
		   _error,
		   a_no_motor,
		   "";
END IF

 SELECT ano_auto,
		cod_marca,
		cod_modelo
   INTO _ano_auto,
		v_cod_marca,
		_cod_modelo
   FROM emivehic
  WHERE no_motor = a_no_motor;

 SELECT cod_contratante,
		no_documento,
		estatus_poliza
   INTO _cod_contratante,
		_no_documento,
		_estatus_poliza
   FROM emipomae
  WHERE no_poliza = _no_poliza
    AND actualizado = 1;

	IF _estatus_poliza IS NULL THEN
	   LET _error = 2;
	RETURN "",
		   "",
		   "",    
		   "",          
		   "",     
		   _ano_auto,       
		   _error,
		   a_no_motor,
		   "";
	END IF

SELECT nombre
  INTO v_desc_marca
  FROM emimarca
 WHERE cod_marca = v_cod_marca;

SELECT nombre
  INTO _nombre_modelo
  FROM emimodel
 WHERE cod_marca  = v_cod_marca
   AND cod_modelo = _cod_modelo;

SELECT nombre
  INTO v_desc_asegurado
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;

RETURN 	_no_documento,
		_estatus_poliza,
		_no_unidad,    
		v_desc_asegurado,          
		v_desc_marca,     
		_ano_auto,       
		_error,
		a_no_motor,
		_nombre_modelo;

END PROCEDURE;