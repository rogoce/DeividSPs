DROP PROCEDURE sp_prima;

CREATE PROCEDURE sp_prima(a_no_documento CHAR(20))


DEFINE _cod_ramo           CHAR(2);
DEFINE _porc_descuento     DEC(5,2);
DEFINE _porc_recargo       DEC(5,2);
DEFINE _porcentaje         DEC(5,2);
DEFINE _prima_restante     DEC(16,2);

DEFINE _no_poliza_char     CHAR(10);
DEFINE _no_endoso_char     CHAR(5);
DEFINE _no_unidad_char     CHAR(5); 
DEFINE _monto_descuento    DEC(16,2);
DEFINE _monto_recargo      DEC(16,2);
DEFINE _prima_sin_descto   DEC(16,2);
DEFINE _monto              DEC(16,2);
DEFINE _orden              SMALLINT;
DEFINE _suma               DEC(16,2);

DEFINE _prima_anual        DEC(16,2);
DEFINE _prima              DEC(16,2);
DEFINE _prima_neta         DEC(16,2);
DEFINE _impuesto           DEC(16,2);
DEFINE _prima_bruta        DEC(16,2);

DEFINE _cod_impuesto_char  CHAR(3);

FOREACH
 SELECT no_poliza
   INTO	_no_poliza_char
   FROM	emipomae
  WHERE no_documento = a_no_documento

	FOREACH
	 SELECT	no_unidad,
			SUM(descuento),
			SUM(recargo),
			SUM(prima_anual),
			SUM(prima),
			SUM(prima_neta)
	   INTO	_no_unidad_char,
			_monto_descuento,
			_monto_recargo,
			_prima_anual,
			_prima,
			_prima_neta
	   FROM	emipocob
	  WHERE no_poliza = _no_poliza_char
	  GROUP BY no_unidad

		SELECT SUM(factor_impuesto)
		  INTO _porcentaje
		  FROM emipolim, prdimpue			 
		 WHERE emipolim.cod_impuesto = prdimpue.cod_impuesto
		   AND emipolim.no_poliza    = _no_poliza_char;   	

		IF _porcentaje IS NULL THEN
			LET _porcentaje = 0;
		END IF

		LET _impuesto    = _prima_neta / 100 * _porcentaje;	
		LET _prima_bruta = _prima_neta + _impuesto;

		UPDATE emipouni
		   SET prima       = _prima,
		       descuento   = _monto_descuento,
			   recargo     = _monto_recargo,
			   prima_neta  = _prima_neta,
			   impuesto    = _impuesto,
			   prima_bruta = _prima_bruta
		 WHERE no_poliza   = _no_poliza_char
		   AND no_unidad   = _no_unidad_char;

	END	FOREACH

	 SELECT	SUM(descuento),
			SUM(recargo),
			SUM(prima),
			SUM(suma_asegurada)
	   INTO	_monto_descuento,
			_monto_recargo,
			_prima_neta,
			_suma
	   FROM	emipouni
	  WHERE no_poliza = _no_poliza_char;

		UPDATE emipomae
		   SET prima          = _prima_neta,
		       descuento      = _monto_descuento,
			   recargo        = _monto_recargo,
			   suma_asegurada = _suma
		 WHERE no_poliza   = _no_poliza_char;

END FOREACH

END PROCEDURE
