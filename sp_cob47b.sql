CREATE PROCEDURE "informix".sp_cob47a() RETURNING CHAR(10),CHAR(100),CHAR(20),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(50),integer,CHAR(50);

DEFINE _monto_visa       DEC(16,2);
DEFINE _monto_ach        DEC(16,2);
DEFINE _monto_pol        DEC(16,2);
DEFINE _no_documento     CHAR(20); 
DEFINE _nombre           CHAR(100);
DEFINE _cod_cliente      CHAR(10); 
DEFINE _cod_agente		 CHAR(5);
define _cod_perpago      CHAR(3);
DEFINE _cod_formapag	 CHAR(3);
DEFINE _tipo_forma       SMALLINT;
DEFINE _no_poliza		 CHAR(10);
DEFINE _nombre_agente	 CHAR(50);
define _nombre_fpg		 CHAR(50);
	
-- Nombre de la Compania


SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_pol(
	cod_cliente		CHAR(10),
	no_documento	CHAR(20),
	monto_visa		DEC(16,2),
	monto_ach		DEC(16,2),
	monto_pol	    DEC(16,2),
	cod_agente      CHAR(5),
	nombre_fpg		CHAR(50),
	tipo_forma      integer)
	WITH NO LOG;

	FOREACH                 
	 SELECT p.no_documento    
	   INTO	_no_documento  
	   FROM emipomae p, cobforpa f       
	  WHERE	p.actualizado     = 1
	    AND p.cod_formapag    = f.cod_formapag
		AND f.tipo_forma   in (2,3,4)          --tarjeta credito, descto directo y ach
		and p.vigencia_final  >= "12/04/2006"
		and p.cod_ramo        = "018"		   --salud	
	  GROUP BY p.no_documento 

		FOREACH
		 SELECT no_poliza,
				cod_contratante,
				cod_formapag,
				cod_perpago
		   INTO	_no_poliza,
				_cod_cliente,
				_cod_formapag,
				_cod_perpago
		   FROM	emipomae
		  WHERE	no_documento = _no_documento
		    AND actualizado  = 1
		  ORDER BY vigencia_final DESC
			EXIT FOREACH;
		END FOREACH

		SELECT tipo_forma
		  INTO _tipo_forma
		  FROM cobforpa
		 WHERE cod_formapag = _cod_formapag;

		SELECT nombre
		  INTO _nombre_fpg
		  FROM cobperpa
		 WHERE cod_perpago = _cod_perpago;

		LET _monto_visa = NULL;
		LET _monto_ach  = NULL;
		LET _monto_pol  = NULL;

	   if _tipo_forma = 2 then
		   FOREACH	
			SELECT monto
			  INTO _monto_visa
			  FROM cobtacre
			 WHERE no_documento = _no_documento
				EXIT FOREACH;
		   END FOREACH

			IF _monto_visa IS NULL THEN
				LET _monto_visa = 0;
			END IF
	   end if
	   if _tipo_forma = 4 then
		   FOREACH	
			SELECT monto
			  INTO _monto_ach
			  FROM cobcutas
			 WHERE no_documento = _no_documento
				EXIT FOREACH;
		   END FOREACH

			IF _monto_ach IS NULL THEN
				LET _monto_ach = 0;
			END IF
	   end if
	   if _tipo_forma = 3 then
			let _monto_visa = 0;
			let _monto_ach  = 0;
	   end if

	   FOREACH
	   	 SELECT cod_agente
	   	   INTO _cod_agente
	   	   FROM emipoagt
	   	  WHERE no_poliza = _no_poliza
	   		EXIT FOREACH;
	   END FOREACH

	   SELECT sum(prima_bruta)
	     INTO _monto_pol
	   	 FROM emipouni
	   	WHERE no_poliza = _no_poliza;

		BEGIN
--		ON EXCEPTION IN(-239)
--		END EXCEPTION
			INSERT INTO tmp_pol
			VALUES(
			_cod_cliente,
			_no_documento,
			_monto_visa,
			_monto_ach,
			_monto_pol,
			_cod_agente,
			_nombre_fpg,
			_tipo_forma
			);
		END

	END FOREACH             

FOREACH
	 SELECT cod_cliente,
			no_documento,
			monto_visa,
			monto_ach,
			monto_pol,
			cod_agente,
			tipo_forma,
			nombre_fpg
	   INTO _cod_cliente,
			_no_documento,
			_monto_visa,
			_monto_ach,
			_monto_pol,
			_cod_agente,
			_tipo_forma,
			_nombre_fpg
	   FROM tmp_pol
	  ORDER BY tipo_forma,no_documento

	if _tipo_forma = 2 then
	   if _monto_visa <> _monto_pol then
	   else
	   	continue foreach;
	   end if
	end if

	if _tipo_forma = 4 then
		if _monto_ach <> _monto_pol then
		else
			continue foreach;
		end if
	end if

	SELECT nombre
	  INTO _nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	SELECT nombre
	  INTO _nombre_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	RETURN _cod_cliente,
		   _nombre,
		   _no_documento,
		   _monto_visa,
		   _monto_ach,
		   _monto_pol,
		   _nombre_agente,
		   _tipo_forma,
		   _nombre_fpg
		   WITH RESUME;
    
END FOREACH

DROP TABLE tmp_pol;

END PROCEDURE                                                                                                                                                                                                     
