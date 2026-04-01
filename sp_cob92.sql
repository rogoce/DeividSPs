-- Procedimiento que Genera la Morosidad Especial de Cartera
-- 
-- Creado    : 11/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/03/2001 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob92;

CREATE PROCEDURE "informix".sp_cob92(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
) RETURNING	CHAR(20),
            INTEGER,
            INTEGER,
            INTEGER,
            dec(16,2);   -- no_documento

DEFINE _doc_poliza1       CHAR(20); 
DEFINE _doc_poliza2       CHAR(20); 
DEFINE _doc_poliza        CHAR(20); 
DEFINE _periodo           CHAR(7);
DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _saldo_tot         DEC(16,2);
DEFINE _incobrable        INTEGER;
DEFINE _cod_formapag      CHAR(3);

DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE _todas			  INTEGER;
DEFINE _algunas			  INTEGER;
DEFINE _otras			  INTEGER;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_prueba(
		doc_poliza1     CHAR(20),
		todas			smallint,
		algunas			smallint,
		otras			smallint
		) WITH NO LOG;

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;	-- Coaseguro Mayoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Sin Coaseguro

-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

SET ISOLATION TO DIRTY READ;

-- Todas

FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
  GROUP BY no_documento		

	FOREACH 
	 SELECT no_documento,
	        incobrable,
			cod_formapag
	   INTO	_doc_poliza1,
	        _incobrable,
			_cod_formapag
       FROM emipomae 
	  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
	    AND actualizado        = 1			   	   -- Poliza este actualizada
		AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
		     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
		AND no_documento       = _doc_poliza
		EXIT FOREACH;
	END FOREACH

	INSERT INTO tmp_prueba(
	   doc_poliza1,
	   todas,
	   algunas,
	   otras)
	VALUES(
       _doc_poliza1,
       1,
       0,
       0
       );

END FOREACH


-- Algunas

FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
  GROUP BY no_documento		

	FOREACH 
	 SELECT no_documento,
	        incobrable,
			cod_formapag
	   INTO	_doc_poliza1,
	        _incobrable,
			_cod_formapag
       FROM emipomae 
	  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
	    AND actualizado        = 1			   	   -- Poliza este actualizada
		AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
		     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
		AND no_documento       = _doc_poliza
		EXIT FOREACH;
	END FOREACH

   	IF _incobrable     =   0    AND
   	    _cod_formapag <> "046"  THEN -- No Incluye las Incobrables
		CONTINUE FOREACH;
 	END IF                                      

	INSERT INTO tmp_prueba(
	   doc_poliza1,
	   todas,
	   algunas,
	   otras)
	VALUES(
       _doc_poliza1,
       0,
       1,
       0
       );

END FOREACH

FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
  GROUP BY no_documento		

	FOREACH 
	 SELECT no_documento,
	        incobrable,
			cod_formapag
	   INTO	_doc_poliza1,
	        _incobrable,
			_cod_formapag
       FROM emipomae 
	  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
	    AND actualizado        = 1			   	   -- Poliza este actualizada
		AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
		     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
		AND no_documento       = _doc_poliza
		EXIT FOREACH;
	END FOREACH

   	IF _incobrable = 1  THEN -- No Incluye las Incobrables 
		CONTINUE FOREACH;
 	END IF                                      

    IF _cod_formapag = "046" THEN -- No Incluye las Cuentas en Abogado
		CONTINUE FOREACH;
 	END IF                                      
		 	   	
	INSERT INTO tmp_prueba(
	   doc_poliza1,
	   todas,
	   algunas,
	   otras)
	VALUES(
       _doc_poliza1,
       0,
       0,
       1
       );

END FOREACH


FOREACH
 SELECT doc_poliza1,
 		sum(todas),
		sum(algunas),
		sum(otras)
   INTO	_doc_poliza2,
        _todas,
		_algunas,
		_otras
   FROM tmp_prueba
  GROUP BY 1


	if _todas   = 1 and
	   _algunas = 0 and
	   _otras   = 1 then
	   continue foreach;
	end if	

	if _todas   = 1 and
	   _algunas = 1 and
	   _otras   = 0 then
	   continue foreach;
	end if	


	CALL sp_cob06(
		 _doc_poliza2,
		 _periodo,
		 a_fecha
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;            
	      				 
 	IF _saldo_tot = 0 THEN                   
		CONTINUE FOREACH;
 	END IF                                      

	RETURN
	_doc_poliza2,
	_todas,
	_algunas,
	_otras,
	_saldo_tot
	With Resume;

END FOREACH

DROP TABLE tmp_prueba;

END PROCEDURE;

