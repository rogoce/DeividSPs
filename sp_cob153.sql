-- Comparacion Produccion - Cobros - Devolucion de Primas por cada Poliza
-- 
-- Creado    : 25/11/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 18/01/2002 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_sp_cob32_dw1 DEIVID, S.A.

DROP PROCEDURE sp_cob153;

CREATE PROCEDURE "informix".sp_cob153(a_periodo CHAR(7)) 

DEFINE _no_documento     CHAR(20); 
DEFINE _no_poliza        CHAR(10); 
DEFINE _prima_bruta      DEC(16,2);
DEFINE _cod_tipoprod     CHAR(3);  

DEFINE _no_requis 		 CHAR(10);
DEFINE _fecha_anulado1	 DATE;
DEFINE _fecha_anulado2	 DATE;
DEFINE _tipo			 char(10); 
define _cantidad		 smallint;

--SET DEBUG FILE TO "sp_cob32.trc"; 
-- trace on;                                                                

SET ISOLATION TO DIRTY READ;

-- Facturas

foreach
 SELECT prima_bruta,
		no_poliza
   INTO _prima_bruta,
		_no_poliza
   FROM endedmae
  WHERE periodo      = a_periodo
	AND actualizado  = 1
	AND prima_bruta  <> 0 

	SELECT cod_tipoprod,
	       no_documento
	  INTO _cod_tipoprod,
	       _no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_tipoprod = "004" THEN
	 	CONTINUE FOREACH;
	END IF 	

	update cobcuasa
	   set facturas     = facturas + _prima_bruta
	 where no_documento = _no_documento
	   and periodo      = a_periodo;

END FOREACH	

-- Recibos 

FOREACH
 SELECT	monto,
        no_poliza
   INTO	_prima_bruta,
        _no_poliza
   FROM	cobredet
  WHERE actualizado = 1
	AND tipo_mov   IN ('P', 'N')
    AND periodo     = a_periodo
	AND monto       <> 0

	SELECT no_documento,
		   cod_tipoprod
	  INTO _no_documento,
	       _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_tipoprod = "004" THEN
	 	CONTINUE FOREACH;
	END IF 	

	update cobcuasa
	   set cobros       = cobros + _prima_bruta
	 where no_documento = _no_documento
	   and periodo      = a_periodo;

END FOREACH

--{
-- Cheques Pagados

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.periodo       = a_periodo
	AND m.origen_cheque = "6"

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _prima_bruta
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_tipoprod
		  INTO _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _cod_tipoprod = "004" THEN
		 	CONTINUE FOREACH;
		END IF 	

		update cobcuasa
		   set cheques      = cheques + _prima_bruta
		 where no_documento = _no_documento
		   and periodo      = a_periodo;

	END FOREACH

END FOREACH

-- Cheques Anulados

LET _fecha_anulado1 = MDY(a_periodo[6,7], 1, a_periodo[1,4]);

IF a_periodo[6,7] = 12 THEN
	LET _fecha_anulado2 = MDY(1, 1, a_periodo[1,4] + 1);
ELSE
	LET _fecha_anulado2 = MDY(a_periodo[6,7] + 1, 1, a_periodo[1,4]);
END IF

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.fecha_anulado >= _fecha_anulado1
    AND m.fecha_anulado < _fecha_anulado2
	AND m.origen_cheque = "6"
	AND m.anulado       = 1

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _prima_bruta
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_tipoprod
		  INTO _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		IF _cod_tipoprod = "004" THEN
		 	CONTINUE FOREACH;
		END IF 	

		update cobcuasa
		   set cheques      = cheques + _prima_bruta
		 where no_documento = _no_documento
		   and periodo      = a_periodo;

	END FOREACH

END FOREACH
--}

END PROCEDURE;

