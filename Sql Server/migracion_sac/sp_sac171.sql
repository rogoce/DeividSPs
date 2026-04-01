-- Consulta de Rango de Cuentas por anio y mes
-- Creado    : 18/02/2009 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_sac171;
CREATE PROCEDURE sp_sac171(a_tipo char(2),a_cuenta1 char(12),a_cuenta2 char(12),a_ccosto char(3),a_anio char(4),a_mes char(2), a_db CHAR(18)) 
RETURNING	
			CHAR(12),  -- cuenta1        
			CHAR(50),  -- nam_cuenta1     
			CHAR(12),  -- cuenta2        
			CHAR(50),  -- nam_cuenta2     
			CHAR(4),   -- anio			
			CHAR(2),   -- mes				
			CHAR(12),  -- cta				
			CHAR(50),  -- name			
			DEC(15,2), -- inicial         
			DEC(15,2), -- debito          
			DEC(15,2), -- credito         
			DEC(15,2), -- neto            
			DEC(15,2), -- acumulado       
			DEC(15,2), -- total
			CHAR(50);  -- cia

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_neto             DEC(15,2);
DEFINE v_monto            DEC(15,2);
DEFINE v_saldo            DEC(15,2);

DEFINE v_cuenta           CHAR(12);
DEFINE v_namcta           CHAR(50);

DEFINE r_cuenta1          CHAR(12);
DEFINE v_namcta1          CHAR(50);

DEFINE r_cuenta2          CHAR(12);
DEFINE v_namcta2          CHAR(50);
DEFINE r_anio			  CHAR(4);
DEFINE r_mes			  CHAR(2);
DEFINE v_recibe           CHAR(1);
DEFINE l_cia_nom          CHAR(50);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_rangocta(
	    cuenta1         CHAR(12),
	    nam_cuenta1     CHAR(50),
	    cuenta2         CHAR(12),
	    nam_cuenta2     CHAR(50),
		anio			CHAR(4),
		mes				CHAR(2),
		cta				CHAR(12),
		name			CHAR(50),
		inicial         DEC(15,2)	default 0,
		debito          DEC(15,2)	default 0,
		credito         DEC(15,2)	default 0,
		neto            DEC(15,2)	default 0,
		acumulado       DEC(15,2)	default 0,
		total        	DEC(15,2)	default 0
		) WITH NO LOG; 	

LET v_saldo = 0;
LET v_debito = 0;
LET v_credito = 0;
LET v_neto = 0; 
LET v_monto = 0;

LET r_anio = a_anio; 
LET r_mes = a_mes;

select cta_cuenta, 
	   cta_nombre
  into r_cuenta1,
	   v_namcta1
  from cglcuentas
 where cta_cuenta = a_cuenta1;

select cta_cuenta, 
	   cta_nombre
  into r_cuenta2,
	   v_namcta2
  from cglcuentas
 where cta_cuenta = a_cuenta2;

SELECT cia_nom
  INTO l_cia_nom
  FROM deivid:sigman02
 WHERE cia_bda_codigo = a_db;


FOREACH
  SELECT sldet_cuenta,sum(sldet_debtop), sum(sldet_cretop), sum(sldet_debtop) + sum(sldet_cretop), sum(sldet_saldop)
	INTO v_cuenta,v_debito, v_credito, v_neto , v_monto
    FROM cglsaldodet
   WHERE sldet_tipo   =  a_tipo  AND
         sldet_cuenta >= a_cuenta1  AND
         sldet_cuenta <= a_cuenta2  AND
         sldet_ccosto like a_ccosto AND
         sldet_ano = a_anio  AND sldet_periodo in (a_mes)
   group by sldet_cuenta
   order by sldet_cuenta

		select cta_nombre,cta_recibe
		  into v_namcta, v_recibe
		  from cglcuentas
		 where cta_cuenta =  v_cuenta;

		if v_recibe = "S" then

			INSERT INTO tmp_rangocta(
			cuenta1,
			nam_cuenta1,
			cuenta2,
			nam_cuenta2,
			anio,
			mes,
			cta,
			name,
			inicial,
			debito,
			credito,
			neto,
			acumulado,
			total)
			VALUES(
			a_cuenta1,
			v_namcta1,
			a_cuenta2,
			v_namcta2,
			r_anio,
			r_mes,
			v_cuenta,
			v_namcta,
			v_monto - v_neto, 
			v_debito,
			v_credito, 
			v_neto, 
			v_monto,
			0
			);
		end if

END FOREACH;


FOREACH	
  SELECT cuenta1,
	     nam_cuenta1,
	     cuenta2,
	     nam_cuenta2,
		 anio,
		 mes,
		 cta,
		 name,
		 inicial,
		 debito,
		 credito,
		 neto,
		 acumulado
	INTO r_cuenta1,
		 v_namcta1,
		 r_cuenta2,
		 v_namcta2,
		 r_anio,
		 r_mes,
		 v_cuenta,
         v_namcta,
		 v_saldo, 
		 v_debito,
		 v_credito, 
		 v_neto, 
		 v_monto
    FROM tmp_rangocta

  RETURN r_cuenta1,
		 v_namcta1,
		 r_cuenta2,
		 v_namcta2,
		 r_anio,
		 r_mes,
		 v_cuenta,
         v_namcta,
		 v_saldo, 
		 v_debito,
		 v_credito, 
		 v_neto, 
		 v_monto,
		 0,
		 l_cia_nom
    	 WITH RESUME;

END FOREACH;

DROP TABLE tmp_rangocta;
END PROCEDURE	