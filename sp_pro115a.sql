-- Procedimiento para traer a los corredores
--
-- Creado    : 07/05/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 07/05/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro115a;

CREATE PROCEDURE "informix".sp_pro115a()
  RETURNING CHAR(20),  
   			CHAR(30);

  DEFINE v_retorno		CHAR(10);
  DEFINE v_error         INTEGER;
  DEFINE _no_documento  CHAR(20);
  DEFINE _nombre        CHAR(100);
  DEFINE _placa         CHAR(10);
  DEFINE _no_motor      CHAR(30);
  DEFINE _cod_sucursal  CHAR(3);

CREATE TEMP TABLE tmp_carnets(
		no_documento        CHAR(20)  NOT NULL,
		motor               CHAR(30)  NOT NULL,
PRIMARY KEY (no_documento,motor)) WITH NO LOG;

CREATE TEMP TABLE tmp_duplicado(
		no_documento        CHAR(20)  NOT NULL,
		motor               CHAR(30)  NOT NULL
		)WITH NO LOG;

  SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec32a.trc"; 
--trace on;

FOREACH
	SELECT polifact, num_moto 
	  INTO _no_documento, _no_motor
	  FROM fox_hechos 	 

	BEGIN
		ON EXCEPTION IN(-239)
	  	INSERT INTO tmp_duplicado(
		   no_documento,
		   motor
		   )
	  	   VALUES(
	  	   _no_documento,
	  	   _no_motor
	  	   );
		END EXCEPTION
	  	INSERT INTO tmp_carnets(
		   no_documento,
		   motor
		   )
	  	   VALUES(
	  	   _no_documento,
	  	   _no_motor
	  	   );
	END

END FOREACH


FOREACH	WITH HOLD
	SELECT no_documento, motor 
	  INTO _no_documento, _no_motor
	  FROM tmp_duplicado 

RETURN _no_documento,
       _no_motor
   WITH RESUME;


END FOREACH

DROP TABLE tmp_carnets;
DROP TABLE tmp_duplicado;


END PROCEDURE

