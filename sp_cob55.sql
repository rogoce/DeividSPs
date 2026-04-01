-- Procedimiento para la consulta de Recibos
-- 
-- Creado    : 10/01/2001 - Autor: Armando Moreno
-- Modificado: 10/01/2001 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob55;

CREATE PROCEDURE "informix".sp_cob55(a_recibo CHAR(10), a_monto DEC(16,2), a_cual CHAR(1))
RETURNING DATE,CHAR(10),SMALLINT,CHAR(10),CHAR(30),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(8),CHAR(50);


DEFINE _fecha             DATE;
DEFINE _no_remesa         CHAR(10);
DEFINE _renglon           SMALLINT;
DEFINE _no_recibo         CHAR(10);
DEFINE _doc_remesa        CHAR(30);
DEFINE _monto    	  	  DEC(16,2);
DEFINE _prima_neta	 	  DEC(16,2);
DEFINE _monto_descontado  DEC(16,2);
DEFINE _impuesto          DEC(16,2);
DEFINE _nombre_agente     CHAR(50);
DEFINE _cod_agente        CHAR(5);
DEFINE _user_added        CHAR(8);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_arreglo;

CREATE TEMP TABLE tmp_arreglo(
		fecha		  	DATE,
		no_remesa       CHAR(10),
		renglon	        SMALLINT,
		no_recibo       CHAR(10),
		doc_remesa	  	CHAR(30),
		monto		    DEC(16,2),
		prima_neta	    DEC(16,2),
		impuesto	    DEC(16,2),
		monto_descontado DEC(16,2),
		user_added      CHAR(8),
		nombre_agente   CHAR(50)
		) WITH NO LOG; 

 -- Lectura de remesas cobredet	

IF a_cual = "*" THEN
  FOREACH
	SELECT x.fecha,
	       x.no_remesa,
		   x.renglon,
		   x.no_recibo,
		   x.doc_remesa,
		   x.monto,
		   x.prima_neta,
		   x.impuesto,
		   x.monto_descontado,
		   v.user_added
	  INTO _fecha,
	       _no_remesa,
	       _renglon,
		   _no_recibo,
		   _doc_remesa,
		   _monto,
		   _prima_neta,
		   _impuesto,
		   _monto_descontado,
		   _user_added
	  FROM cobredet x, cobremae v
	 WHERE x.no_remesa = v.no_remesa
	   AND x.no_recibo   MATCHES a_recibo
	   AND x.actualizado = 1

	LET _cod_agente    = NULL;
	LET _nombre_agente = NULL;

   FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM cobreagt
		 WHERE no_remesa = _no_remesa
		 AND   renglon = _renglon
		EXIT FOREACH;
   END FOREACH

	IF _cod_agente IS NOT NULL THEN

		SELECT 	nombre
	  	  INTO  _nombre_agente
	      FROM  agtagent
	     WHERE  cod_agente = _cod_agente;

	END IF

	INSERT INTO tmp_arreglo(
	fecha,
	no_remesa,
	renglon,
	no_recibo,
	doc_remesa,
	monto,
	prima_neta,
	impuesto,
	monto_descontado,
	user_added,
	nombre_agente
	)
	VALUES(
	_fecha,
	_no_remesa,
	_renglon,	
	_no_recibo,
	_doc_remesa,
	_monto,
	_prima_neta,
	_impuesto,
	_monto_descontado,
	_user_added,
	_nombre_agente
    );

  END FOREACH;
ELSE
  FOREACH
	SELECT x.fecha,
	       x.no_remesa,
		   x.renglon,
		   x.no_recibo,
		   x.doc_remesa,
		   x.monto,
		   x.prima_neta,
		   x.impuesto,
		   x.monto_descontado,
		   v.user_added
	  INTO _fecha,
	       _no_remesa,
	       _renglon,
		   _no_recibo,
		   _doc_remesa,
		   _monto,
		   _prima_neta,
		   _impuesto,
		   _monto_descontado,
		   _user_added
	  FROM cobredet x, cobremae v
	 WHERE x.no_remesa = v.no_remesa
	   AND x.no_recibo   MATCHES a_recibo
	   AND x.monto       = a_monto
	   AND x.actualizado = 1

	LET _cod_agente    = NULL;
	LET _nombre_agente = NULL;

   FOREACH WITH HOLD
		SELECT cod_agente
		  INTO _cod_agente
		  FROM cobreagt
		 WHERE no_remesa = _no_remesa
		 AND   renglon = _renglon
		EXIT FOREACH;
   END FOREACH

	SELECT nombre
  	  INTO _nombre_agente
        FROM   agtagent
        WHERE  cod_agente = _cod_agente;

	INSERT INTO tmp_arreglo(
	fecha,
	no_remesa,	
	renglon,
	no_recibo,
	doc_remesa,
	monto,
	prima_neta,
	impuesto,
	monto_descontado,
	user_added,
	nombre_agente
	)
	VALUES(
	_fecha,
	_no_remesa,
	_renglon,	
	_no_recibo,
	_doc_remesa,
	_monto,
	_prima_neta,
	_impuesto,
	_monto_descontado,
	_user_added,
	_nombre_agente
    );

  END FOREACH;
END IF

FOREACH WITH HOLD
      SELECT fecha,
             no_remesa,
             renglon, 
             no_recibo,
             doc_remesa, 
			 monto,
			 prima_neta,
			 impuesto,
			 monto_descontado,
			 user_added,
			 nombre_agente
	    INTO _fecha,
	         _no_remesa,
			 _renglon,	
			 _no_recibo,
			 _doc_remesa,
			 _monto,
			 _prima_neta,
			 _impuesto,
			 _monto_descontado,
			 _user_added,
			 _nombre_agente
        FROM tmp_arreglo
		ORDER BY fecha

		IF _nombre_agente IS NULL THEN
			LET _nombre_agente = '';
		END IF

		RETURN _fecha,	
			   _no_remesa,
			   _renglon,
			   _no_recibo,
			   _doc_remesa, 
			   _monto,
			   _prima_neta, 
			   _impuesto, 
			   _monto_descontado,
			   _user_added,
			   _nombre_agente
			   WITH RESUME;

END FOREACH

DROP TABLE tmp_arreglo;

END PROCEDURE;
