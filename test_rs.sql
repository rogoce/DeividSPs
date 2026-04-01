-- Procedimiento para insertar el endoso de pronto pago al momento de recibir remesa
-- RS - 26/08/2009

DROP PROCEDURE test_rs;

CREATE PROCEDURE test_rs (a_no_poliza CHAR(10)) 
	RETURNING SMALLINT,
				CHAR(100);

DEFINE _no_endoso       	CHAR(5);
DEFINE _no_endoso_ext		CHAR(5);
DEFINE _no_endoso_ent		INTEGER;
DEFINE _cod_endomov     	CHAR(3);
DEFINE _prima_neta			DEC(16,2);
DEFINE _null            	CHAR(1);

DEFINE v_unidad          	CHAR(5);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_fecha_actual		DATE;
DEFINE v_factor 			DEC(9,6);
DEFINE v_cobertura       	CHAR(5);
DEFINE v_periodo			CHAR(7);

DEFINE _error     	    	SMALLINT;
DEFINE _error_desc			CHAR(30);

DEFINE	v_prima_suscrita	DEC(16,2);
DEFINE 	v_prima_retenida	DEC(16,2);
DEFINE	v_prima				DEC(16,2);
DEFINE	v_total_descto		DEC(16,2);
DEFINE 	v_porc_recargo		DEC(16,2);
DEFINE	v_prima_neta		DEC(16,2);
DEFINE	v_impuesto			DEC(16,2);
DEFINE	v_prima_br			DEC(16,2);
DEFINE  v_suma_asegurada   	DEC(16,2);
DEFINE  v_gastos			DEC(16,2);
DEFINE	v_existe_end		SMALLINT;
DEFINE	v_mes_actual		SMALLINT;
DEFINE	v_mes_string		CHAR(2);



SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error
 	RETURN _error, 'Error al Actualizar el Endoso ...';
END EXCEPTION


--REGRESA EL NUEVO NUMERO DE ENDOSO
LET _no_endoso = sp_sis90(a_no_poliza);
LET _no_endoso_ent = _no_endoso + 1;
LET _no_endoso = sp_set_codigo(5, _no_endoso_ent);

LET _cod_endomov = "024";
LET _no_endoso_ext  = _no_endoso;
LET v_fecha_actual = sp_sis26();

LET v_mes_string = MONTH(v_fecha_actual);
LET v_mes_actual =  LENGTH(v_mes_string);


IF v_mes_actual = 1 THEN
	LET v_mes_string = "0" || MONTH(v_fecha_actual);
ELSE	
	LET v_mes_string = MONTH(v_fecha_actual);
END IF



LET v_periodo = YEAR(v_fecha_actual) || "-" || v_mes_string;

LET _null      = NULL;

RETURN v_mes_actual, v_periodo;

END

END PROCEDURE;