-- Comaparacion entre la morosidad de cartera y la morosidad especial
-- 
-- Creado: 23/09/2002 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob7m;

CREATE PROCEDURE "informix".sp_cob7m(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_periodo    DATE,   
a_tipo_moros CHAR(1) DEFAULT '1' 
) RETURNING CHAR(20),   -- no_documento
			DEC(16,2),  -- saldo03	
			DEC(16,2);  -- saldo07	


DEFINE _no_documento    CHAR(20); 
DEFINE _doc_poliza		CHAR(20);
DEFINE _saldo03         DEC(16,2);
DEFINE _saldo07     	DEC(16,2);
DEFINE _saldo         	DEC(16,2);

CREATE TEMP TABLE tmp_prueba(
		no_documento    CHAR(20),	
		saldo03         DEC(16,2),
		saldo07         DEC(16,2)
		) WITH NO LOG;

--Morosidad de cartera
CALL sp_cob03(
	 a_compania,
	 a_agencia,
	 a_periodo,
	 a_tipo_moros
	 );

	 FOREACH
	  SELECT doc_poliza,
	         saldo
	    INTO _no_documento,
	         _saldo
	    FROM tmp_moros
	                	      
   	-- Actualizacion de la Tabla Temporal
	INSERT INTO tmp_prueba(
	no_documento,
	saldo03,
	saldo07
	)
	VALUES(
	_no_documento,
	_saldo,
	0.00 );

	END FOREACH;
	DROP TABLE tmp_moros;

--Morosidad Especial
CALL sp_cob07(
	 a_compania,
	 a_agencia,
	 a_periodo
	 );         

	 FOREACH
	  SELECT doc_poliza,
	         saldo
	    INTO _no_documento,
	         _saldo
	   FROM  tmp_moros
  
	 -- Actualizacion de la Tabla Temporal
	INSERT INTO tmp_prueba(
	no_documento,
	saldo03,
	saldo07
	)
	VALUES(
	_no_documento,
	0.00,
	_saldo);

	 END FOREACH;
	 DROP TABLE tmp_moros;   

FOREACH
 SELECT no_documento,
        sum(saldo03),
	    sum(saldo07)
   INTO _no_documento,
        _saldo03,
	    _saldo07
   FROM tmp_prueba
  GROUP BY no_documento

 IF _saldo03 <> _saldo07 THEN

	RETURN _no_documento,
		   _saldo03,  
		   _saldo07
    	 WITH RESUME;

 END IF

END FOREACH;

DROP TABLE tmp_prueba;

END PROCEDURE

