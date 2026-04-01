-- Procedimiento para Insertar Transacciones de Pago Control de Reclamos Autos
-- 
-- creado: 17/03/2005 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf47;
DROP PROCEDURE sp_rwf116;
CREATE PROCEDURE "informix".sp_rwf116()
			RETURNING CHAR(10);  

DEFINE _no_tranrec			CHAR(10);
DEFINE _no_tranrec2			CHAR(10);
DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _fecha				DATE;
DEFINE _transaccion			CHAR(10);
DEFINE _periodo			    CHAR(7);
DEFINE _cod_cliente			CHAR(10);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_tipopago		CHAR(3);
DEFINE _no_requis			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _variacion        	DEC(16,2);
DEFINE _reserva_actual     	DEC(16,2);
DEFINE _user_added			CHAR(8);
DEFINE _numrecla            CHAR(18);
DEFINE _no_poliza           CHAR(10);
DEFINE _cod_concepto        CHAR(3);

DEFINE _error   			SMALLINT;
DEFINE _mes_char			CHAR(2);
DEFINE _ano_char			CHAR(4);

DEFINE _fecha_recl_default	CHAR(20);
DEFINE _fecha_recl_valor	CHAR(20);
DEFINE _null			    CHAR(1);
DEFINE _desc_transaccion_1  CHAR(60);
DEFINE _desc_transaccion_2  CHAR(60);
DEFINE _desc_transaccion_3  CHAR(60);
DEFINE _desc_transaccion_4  CHAR(60);

DEFINE _perdida				DEC(16,2);
DEFINE _deducible			DEC(16,2);
DEFINE _salvamento			DEC(16,2);
DEFINE _prima_pend			DEC(16,2);
DEFINE _cod_cobertura		CHAR(5);

DEFINE _deducible_s			VARCHAR(16);
DEFINE _salvamento_s		VARCHAR(16);
DEFINE _prima_pend_s		VARCHAR(16);


LET _null = NULL;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf102.trc";
--trace on;

--begin work;

	 SELECT valor_parametro 
	   INTO _fecha_recl_default 
	   FROM inspaag
	  WHERE codigo_compania  = '001'
	    AND aplicacion       = "REC"
	    AND version          = "02"
	    AND codigo_parametro = "fecha_recl_default";

	 IF TRIM(_fecha_recl_default) = "1" THEN
		IF  MONTH(current) < 10 THEN
			LET _mes_char = '0'|| MONTH(current);
		ELSE
			LET _mes_char = MONTH(current);
		END IF

		LET _ano_char = YEAR(current);
		LET _periodo  = _ano_char || "-" || _mes_char;
		LET _fecha_recl_valor = date(current);
	 ELSE
		SELECT valor_parametro 
		  INTO _fecha_recl_valor 
		  FROM inspaag
		 WHERE codigo_compania  = '001'
		   AND aplicacion       = "REC"
		   AND version          = "02"
		   AND codigo_parametro = "fecha_recl_valor";

		LET _fecha_recl_valor = trim(_fecha_recl_valor);
	    LET _periodo = trim(_fecha_recl_valor[7,10]) || "-" || trim(_fecha_recl_valor[4,5]);
	 END IF	 

 RETURN _fecha_recl_valor;
END PROCEDURE