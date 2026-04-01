-- Resta un mes a un periodo
--
-- Creado    : 03/03/2015 - Autor: Jaime Chevalier

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro703;

CREATE PROCEDURE "informix".sp_pro703(a_periodo CHAR(7)) 
RETURNING CHAR(7),
          DEC(16,2);

DEFINE _periodo      	CHAR(7);
DEFINE _mes    		 	SMALLINT;
DEFINE _mes1         	CHAR(2);
DEFINE _ano    	     	SMALLINT;
DEFINE _prima_suscrita  DEC(16,2);

-- Descomponer los periodos en fechas

LET _ano = a_periodo[1,4];
LET _mes = a_periodo[6,7];



IF _mes = 1 THEN
   LET _mes = 12;
   LET _ano = _ano - 1;
ELSE
   LET _mes = _mes - 1;
END IF

IF _mes = '10' or _mes = '11' or _mes = '12' THEN
	LET _mes1 = _mes;
ELSE
	LET _mes1 = '0'||_mes;
END IF 

LET _periodo = _ano ||'-'||_mes1;

SELECT sum(prima_suscrita)
  INTO _prima_suscrita
  FROM endedmae
 WHERE actualizado = 1
   AND periodo = a_periodo

RETURN _periodo,
       _prima_suscrita;
  
END PROCEDURE;