-- Procedimiento que Genera el Cheque para Un Corredor

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_periodo_poliza;

CREATE PROCEDURE sp_periodo_poliza()

DEFINE _no_poliza      INTEGER; 
DEFINE _no_poliza_char CHAR(10);
DEFINE _periodo        CHAR(7); 
DEFINE _actualizado    SMALLINT;

DEFINE _mes SMALLINT;
DEFINE _ano SMALLINT;

FOREACH
 SELECT	no_poliza,
        MONTH(mes_contable),
		YEAR(ano_contable),
		actualizada
   INTO	_no_poliza,
        _mes,
		_ano,
		_actualizado
   FROM	poliza

	LET _no_poliza_char = sp_set_codigo(10, no_poliza);

	IF _mes	< 10 THEN
		LET _periodo = _ano || '-0' || _mes;
	ELSE
		LET _periodo = _ano || '-' || _mes;
	END IF

	UPDATE emipomae
	   SET periodo     = _periodo,
	       actualizado = _actualizado
	 WHERE no_poliza   = _no_poliza_char;

END FOREACH

END PROCEDURE