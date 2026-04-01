-- Proceso de cierre del flujo de caja -- 
-- Creado    : 29/05/2001 - Autor: Armando Moreno
-- Modificado: 29/05/2001 - Autor: Armando Moreno

DROP PROCEDURE sp_che15c;

CREATE PROCEDURE "informix".sp_che15c(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha DATE)
RETURNING INTEGER,
		  CHAR(100)	;

DEFINE v_cod_banco	  		CHAR(3);
DEFINE v_debito  	  		DEC(16,2);
DEFINE v_credito	  		DEC(16,2);
DEFINE v_saldo	  			DEC(16,2);
DEFINE v_flujo_monto_actual	DEC(16,2);
DEFINE _error 		        INTEGER;
DEFINE _mensaje				CHAR(100);
DEFINE _cod_flujo			CHAR(3);
DEFINE _periodo				CHAR(7);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che15c.trc";

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,'Error al Actualizar los Saldos de los Bancos';
END EXCEPTION           

-- Flujo de Caja del Dia

CALL sp_che15(
a_compania,
a_sucursal,
a_fecha,
a_fecha
);

-- Actualizacion de Tipos
IF MONTH(a_fecha) < 10 THEN
	LET _periodo = YEAR(a_fecha) || '-0' || MONTH(a_fecha);
ELSE
	LET _periodo = YEAR(a_fecha) || '-' || MONTH(a_fecha);
END IF

FOREACH
 SELECT cod_flujo,
        SUM(monto)
   INTO _cod_flujo,
        v_debito
   FROM tmp_flujo
  GROUP BY cod_flujo
  ORDER BY cod_flujo

	IF v_debito IS NULL THEN
		LET v_debito = 0;
	END IF

	SELECT monto
	  INTO v_credito
	  FROM chqfluac
	 WHERE cod_flujo = _cod_flujo
	   AND periodo   = _periodo;

	IF v_credito IS NULL THEN
		INSERT INTO chqfluac
		VALUES(_cod_flujo, _periodo, 0);
	END IF

   { LET v_debito  = v_debito  * -1; 
    LET v_credito = v_credito * -1; }

	UPDATE chqfluac
	   SET monto     = monto + v_debito
	 WHERE cod_flujo = _cod_flujo
	   AND periodo   = _periodo;
	    
END FOREACH

-- Actualizacion de Bancos
FOREACH
 SELECT banco,
        SUM(db),
    	SUM(cr)
   INTO v_cod_banco,
        v_debito,
		v_credito
   FROM tmp_flujo
  GROUP BY banco
  ORDER BY banco

  LET v_saldo = 0;

	SELECT flujo_monto_act	
	  INTO v_flujo_monto_actual
	  FROM chqbanco
	 WHERE cod_banco = v_cod_banco;

	   IF v_flujo_monto_actual IS NULL  THEN
		   LET v_flujo_monto_actual = 0;
	   END IF

	   IF v_debito IS NULL  THEN
		   LET v_debito = 0;
	   END IF

	   IF v_credito IS NULL  THEN
		   LET v_credito = 0;
	   END IF

	   {LET v_debito  = v_debito  * -1;
	   LET v_credito = v_credito * -1;}

	   LET v_saldo   = v_flujo_monto_actual + v_debito + v_credito;

	   UPDATE chqbanco
	      SET flujo_monto_act = v_saldo
	    WHERE cod_banco       = v_cod_banco; 
	    
END FOREACH
	
LET _mensaje = "Actualizacion Exitosa ...";

DROP TABLE tmp_flujo;
RETURN 0, _mensaje;
END		
END PROCEDURE;