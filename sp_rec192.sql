-- Procedimiento que Carga el Incurrido de Reclamos en un Periodo Dado

DROP PROCEDURE sp_rec192;

CREATE PROCEDURE "informix".sp_rec192(a_periodo1 CHAR(7), a_periodo2 CHAR(7))
       returning CHAR(18), DATE, CHAR(10), DATE, VARCHAR(100), CHAR(20), DATE, DATE, CHAR(5), VARCHAR(50), DATE, DATE;  


DEFINE _no_reclamo      CHAR(10);
DEFINE _no_tranrec      CHAR(10);
DEFINE _transaccion     CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo         CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _fecha_siniestro, _fecha DATE;
DEFINE _cod_asegurado   CHAR(10);
DEFINE _asegurado       VARCHAR(100);
DEFINE _cod_contrato    CHAR(5); 
DEFINE _contrato        VARCHAR(50); 
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final,_vig_inic_pol, vig_final_pol	DATE;

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;
DEFINE _variacion       DECIMAL(16,2);
DEFINE _salvado_neto,_deducible_neto   DECIMAL(16,2);


SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

--SET DEBUG FILE TO 'sp_rec704.trc';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT a.no_reclamo,
        a.transaccion,
		a.no_tranrec,
		a.fecha
   INTO _no_reclamo,
        _transaccion,
		_no_tranrec,
		_fecha
   FROM rectrmae a, rectitra b
  WHERE a.actualizado  = 1
    AND a.cod_tipotran = b.cod_tipotran
    AND b.tipo_transaccion IN (4,5,6,7)
    AND a.periodo >= a_periodo1
	AND a.periodo <= a_periodo2
    AND a.monto   <> 0
--   	and a.no_reclamo = "142811" --"172813" --"178163"
 
	-- Lectura de la Tablas de Reclamos

	SELECT numrecla,
		   fecha_siniestro,
		   cod_asegurado,
		   no_poliza
	  INTO _numrecla,
	       _fecha_siniestro,
		   _cod_asegurado,
		   _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

    SELECT nombre
	  INTO _asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

    SELECT no_documento, vigencia_inic, vigencia_final
	  INTO _doc_poliza, _vig_inic_pol, vig_final_pol
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Informacion de Reaseguro

    FOREACH
	  SELECT cod_contrato
	    INTO _cod_contrato
	    FROM rectrrea
	   WHERE no_tranrec = _no_tranrec

	    SELECT nombre,
	           vigencia_inic,
		       vigencia_final
		  INTO _contrato,
		       _vigencia_inic,
			   _vigencia_final
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato; 

		RETURN _numrecla, _fecha_siniestro, _transaccion, _fecha, _asegurado, _doc_poliza, _vig_inic_pol, vig_final_pol, _cod_contrato, _contrato, _vigencia_inic, _vigencia_final WITH RESUME;
	  
	  --EXIT FOREACH;
	END FOREACH




END FOREACH



END PROCEDURE;
  