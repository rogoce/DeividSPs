-- Comaparacion entre la morosidad por corredor totales y la morosidad total por ramo
-- 
-- Creado: 23/09/2002 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob7x;

CREATE PROCEDURE "informix".sp_cob7x(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_periodo    DATE,   
a_tipo_moros CHAR(1) DEFAULT '1' 
) RETURNING CHAR(20),   -- no_documento
			DEC(16,2),  -- saldo poliza	
			DEC(16,2);  -- saldo corredor	

DEFINE _no_documento    CHAR(20); 
DEFINE _saldo_corredor  DEC(16,2);
DEFINE _saldo_poliza   	DEC(16,2);


CREATE TEMP TABLE tmp_prueba(
		no_documento    CHAR(20),	
		saldo_poliza    DEC(16,2),
		saldo_corredor  DEC(16,2)
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
	         _saldo_poliza
        FROM tmp_moros
	                	      
   	-- Actualizacion de la Tabla Temporal
	INSERT INTO tmp_prueba(
	no_documento,
	saldo_poliza,
	saldo_corredor
	)
	VALUES(
	_no_documento,
	_saldo_poliza,
	0.00 );

	END FOREACH;
	DROP TABLE tmp_moros;

--Morosidad Especial
CALL sp_cob05(
	 a_compania,
	 a_agencia,
	 a_periodo
	 );         

	 FOREACH
	  SELECT doc_poliza,
	         saldo
	    INTO _no_documento,
	         _saldo_corredor
	   FROM  tmp_moros
  
	 -- Actualizacion de la Tabla Temporal
	INSERT INTO tmp_prueba(
	no_documento,
	saldo_poliza,
	saldo_corredor
	)
	VALUES(
	_no_documento,
	0.00,
	_saldo_corredor);

	 END FOREACH;
	 DROP TABLE tmp_moros;   

FOREACH
 SELECT no_documento,
        sum(saldo_poliza),
	    sum(saldo_corredor)
   INTO _no_documento,
        _saldo_poliza,
	    _saldo_corredor
   FROM tmp_prueba
  GROUP BY no_documento

 IF _saldo_poliza <> _saldo_corredor THEN

	RETURN _no_documento,
		   _saldo_poliza,  
		   _saldo_corredor
    	 WITH RESUME;

 END IF

END FOREACH;

DROP TABLE tmp_prueba;

END PROCEDURE

