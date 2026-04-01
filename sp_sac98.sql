-- Consulta de Saldos de Cuentas Sac 
-- Creado    : 05/01/2009 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac98;
CREATE PROCEDURE sp_sac98(a_tipo char(2),a_cuenta char(12),a_aux char(5),a_anio char(4)) 
RETURNING	CHAR(100),  --  Periodo 
			DEC(15,2),  --  Monto Debito 
			DEC(15,2),  --  Monto Credito 
			DEC(15,2),  --  Monto Acumuladox Periodo 
			DEC(15,2);  --  Monto total Acumulado			

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_monto            DEC(15,2);
DEFINE v_monto_a          DEC(15,2);
DEFINE v_saldo            DEC(15,2);
DEFINE v_saldo_ant        DEC(15,2);
DEFINE v_saldo_acum       DEC(15,2);
DEFINE v_anio_ant         SMALLINT;
DEFINE v_periodo          CHAR(100);
DEFINE v_speriodo         CHAR(2);
DEFINE v_valor            SMALLINT;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_sac98.trc";
--trace on;

--DROP TABLE tmp_saldosac98;
CREATE TEMP TABLE tmp_saldosac98(
	    periodo         CHAR(100),
		debito          DEC(15,2)	default 0,
		credito         DEC(15,2)	default 0,
		acumulado       DEC(15,2)	default 0,
		total        	DEC(15,2)	default 0
		) WITH NO LOG; 	

      CREATE INDEX isac1_tmp_saldosac98 ON tmp_saldosac98(periodo);

LET v_saldo = 0;
LET v_saldo_ant = 0;
LET v_saldo_acum = 0;
LET v_anio_ant = a_anio;

  SELECT cglsaldoaux.sld_incioano
    INTO v_saldo_ant
    FROM cglsaldoaux
   WHERE  ( cglsaldoaux.sld_tipo = a_tipo ) AND
	 ( cglsaldoaux.sld_cuenta = a_cuenta ) AND
	 ( cglsaldoaux.sld_tercero = a_aux ) AND
	 ( cglsaldoaux.sld_ano = v_anio_ant )  ;


LET v_saldo = v_saldo_ant;

FOREACH
  SELECT sld1_debitos,
         sld1_creditos,
         sld1_saldo,
         sld1_periodo
	INTO v_debito,
	     v_credito,
	     v_monto,
		 v_valor
    FROM cglsaldoaux1
   WHERE sld1_tipo = a_tipo  AND
         sld1_cuenta = a_cuenta  AND
         sld1_tercero = a_aux  AND
         sld1_ano = a_anio


if v_valor < 10 then
	let  v_speriodo = "0" || v_valor;
else 
	let  v_speriodo = v_valor;
end if

  SELECT per_descrip  
    INTO v_periodo
    FROM cglperiodo  
   WHERE per_ano = a_anio AND  
         per_mes = v_speriodo;

  LET v_saldo = v_saldo + v_debito + v_credito;

INSERT INTO tmp_saldosac98(
	    periodo,
		debito,
		credito,
		acumulado,
		total )
	VALUES(	v_periodo,
		 v_debito,
	     v_credito,
		 v_saldo,
		 v_saldo_ant) ;

END FOREACH;

--update  tmp_saldosac98
--set total  = v_saldo ;

FOREACH	
  SELECT periodo,
		debito,
		credito,
		acumulado,
		total
	INTO v_periodo,
	     v_debito,
	     v_credito,
	     v_monto,
		 v_saldo
    FROM tmp_saldosac98

  RETURN v_periodo,
  		 v_debito,
	     v_credito,
	     v_monto,
         v_saldo
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_saldosac98;
END PROCEDURE	