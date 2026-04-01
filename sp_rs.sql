DROP PROCEDURE sp_rs;

CREATE PROCEDURE sp_rs()
RETURNING DEC(16,6),
		  DEC(16,6);

	DEFINE v_factor		DEC(16,6);
	DEFINE v_result 	DEC(20,2);
	DEFINE v_prima_up DEC(20,6);

LET v_prima_up = 89.00;
LET v_factor = -0.412995;

LET v_result = v_prima_up * v_factor;

RETURN v_factor, v_result;

END PROCEDURE;