-- Consulta de Saldos de Cuentas Sac 
-- Creado    : 24/11/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac90;

CREATE PROCEDURE sp_sac90(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_anio char(4)) 
RETURNING	CHAR(100),  --  Periodo 
			DEC(15,2),  --  Monto Debito 
			DEC(15,2),  --  Monto Credito 
			DEC(15,2),  --  Monto Acumuladox Periodo 
			DEC(15,2);  --  Monto total Acumulado			

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_monto            DEC(15,2);
DEFINE v_saldo            DEC(15,2);
DEFINE v_periodo          CHAR(100);
DEFINE v_speriodo         CHAR(2);
DEFINE v_valor            SMALLINT;
DEFINE v_saldo_inicial	  DEC(15,2);
DEFINE v_leido			  DEC(15,2);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldosac90;
CREATE TEMP TABLE tmp_saldosac90(
	    periodo         CHAR(100),
		debito          DEC(15,2)	default 0,
		credito         DEC(15,2)	default 0,
		acumulado       DEC(15,2)	default 0,
		total        	DEC(15,2)	default 0
		) WITH NO LOG; 	

LET v_saldo = 0;
{
	select sld_incioano
	into   v_saldo
	from   cglsaldoctrl  
	where  ( sld_tipo  = a_tipo ) AND  
	 ( sld_cuenta = a_cuenta ) AND  
	 ( sld_ccosto = a_ccosto  ) AND  
	 ( sld_ano  = a_anio  )  ;	
}
--set debug file to "sp_sac90.trc";
--trace on;


let  v_saldo_inicial = 0;
if a_ccosto = "%" then							 
		FOREACH	
		    SELECT cglsaldoctrl.sld_incioano
		    INTO v_leido
			FROM cglsaldoctrl  
			WHERE  ( cglsaldoctrl.sld_tipo like a_tipo ) AND  
				 ( cglsaldoctrl.sld_cuenta = a_cuenta ) AND  
				 ( cglsaldoctrl.sld_ccosto like a_ccosto ) AND  
				 ( cglsaldoctrl.sld_ano = a_anio )			 

			IF v_leido IS NULL THEN
				LET v_leido = 0;
			END IF

			let  v_saldo_inicial = v_saldo_inicial + v_leido	;
		END FOREACH;
else
  SELECT cglsaldoctrl.sld_incioano
    INTO v_saldo_inicial
	FROM cglsaldoctrl  
	WHERE  ( cglsaldoctrl.sld_tipo like a_tipo ) AND  
		 ( cglsaldoctrl.sld_cuenta = a_cuenta ) AND  
		 ( cglsaldoctrl.sld_ccosto like a_ccosto ) AND  
		 ( cglsaldoctrl.sld_ano = a_anio ) ;
end if

IF v_saldo_inicial  IS NULL THEN
	LET v_saldo_inicial = 0 ;
END IF

LET v_saldo = v_saldo_inicial ;

FOREACH
  SELECT sldet_periodo,
		 sum(sldet_debtop),   
         sum(sldet_cretop),   
         sum(sldet_saldop)
   	INTO v_valor,
   	     v_debito,
	     v_credito,
	     v_monto		 
    FROM cglsaldodet  
   WHERE sldet_tipo = a_tipo  AND  
         sldet_cuenta = a_cuenta  AND  
         sldet_ccosto like a_ccosto  AND  
         sldet_ano = a_anio  
	 group by sldet_periodo
	 order by sldet_periodo

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

--  LET v_saldo = v_saldo + v_monto;

INSERT INTO tmp_saldosac90(
	    periodo,
		debito,
		credito,
		acumulado,
		total )
	VALUES(	v_periodo,
		 v_debito,
	     v_credito,
	     v_monto,
		 v_saldo);

END FOREACH;

update  tmp_saldosac90
set total  = v_saldo ;

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
    FROM tmp_saldosac90

  RETURN v_periodo,
  		 v_debito,
	     v_credito,
	     v_monto,
		 v_saldo
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_saldosac90;
END PROCEDURE	