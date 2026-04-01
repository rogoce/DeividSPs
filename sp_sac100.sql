--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
--*  ACTUALIZACION DE COMPROBANTES
--*  Henry Giron  - MARZO 2009
--*  Ref. Power Builder

DROP PROCEDURE sp_sac100;

CREATE PROCEDURE sp_sac100(pant_ano integer, pant_mes integer) RETURNING SMALLINT, CHAR(150);

BEGIN
----
DEFINE wdatabase        char(18);
DEFINE w_periodos       char(2);
DEFINE w_par_mesfiscal  char(2);
DEFINE w_par_anofiscal  char(4);
DEFINE w_par_ingreso1   char(12);
DEFINE w_par_ingreso2   char(12);
DEFINE mes_fiscal       char(2);
DEFINE ano_fiscal       char(4);
DEFINE nvo_ano          char(4);
---Variables de la tabla cgltrx1
DEFINE w1_notrx       integer;
DEFINE w1_tipo        char(2);
DEFINE w1_comprobante char(8);
DEFINE w1_fecha       date;
DEFINE w1_concepto    char(3);
DEFINE w1_ccosto      char(3);
DEFINE w1_descrip     char(50);
DEFINE w1_monto       decimal(15,2);
DEFINE w1_moneda      char(2);
DEFINE w1_debito      decimal(15,2);
DEFINE w1_credito     decimal(15,2);
DEFINE w1_status      char(1);
DEFINE w1_origen      char(3);
DEFINE w1_usuario     char(15);
DEFINE w1_fechacap    datetime year to second;
---Variables de la tabla cgltrx2
DEFINE w2_notrx   integer;
DEFINE w2_tipo    char(2);
DEFINE w2_linea   integer;
DEFINE w2_cuenta  char(12);
DEFINE w2_ccosto  char(3);
DEFINE w2_debito  decimal(15,2);
DEFINE w2_credito decimal(15,2);
DEFINE w2_actlzdo char(1);
---Variables de la tabla cgltrx2
DEFINE w3_notrx integer;
DEFINE w3_tipo char(2);
DEFINE w3_lineatrx2 integer;
DEFINE w3_linea integer;
DEFINE w3_cuenta char(12);
DEFINE w3_auxiliar char(5);
DEFINE w3_debito decimal(15,2);
DEFINE w3_credito decimal(15,2);
DEFINE w3_actlzdo char(1);
---Variables de la tabla cglcuenta
DEFINE wcta_nivel      char(1);
DEFINE wcta_tippartida char(1);
DEFINE wcta_recibe     char(1);
DEFINE wcta_histmes    char(1);
DEFINE wcta_histano    char(1);
DEFINE wcta_auxiliar   char(1);
DEFINE wcta_saldoprom  char(1);
DEFINE wcta_moneda     char(2);
-------------------------------------
DEFINE w_status1      char(1);
DEFINE mensaje_error  char(150);
DEFINE l_codigo       SMALLINT;
DEFINE ls_auxiliar   char(1);
-- 1 Error
-- 0 Satisfactorio

DEFINE wper_ano        char(4);
DEFINE wper_mes        char(2);
DEFINE wper_status     char(1);
DEFINE pos1            SMALLINT;
DEFINE pos2            SMALLINT;
DEFINE indice          SMALLINT;
DEFINE I               SMALLINT;
DEFINE J               SMALLINT;
DEFINE K               SMALLINT;
DEFINE idx             SMALLINT;
DEFINE nivel1          SMALLINT;
DEFINE work_cta        CHAR(12);
DEFINE work_ano        CHAR(04);
DEFINE total_db_det    DECIMAL(15,2);
DEFINE total_cr_det    DECIMAL(15,2);
DEFINE ls_cuenta       char(12);
DEFINE pdebitos        DECIMAL(15,2);
DEFINE pcreditos       DECIMAL(15,2);
DEFINE psaldo          DECIMAL(15,2);
DEFINE pdebitos2       DECIMAL(15,2);
DEFINE pcreditos2      DECIMAL(15,2);
DEFINE psaldo2         DECIMAL(15,2);
DEFINE pdebitos3       DECIMAL(15,2);
DEFINE pcreditos3      DECIMAL(15,2);
DEFINE psaldo3         DECIMAL(15,2);
DEFINE ls_cuenta3      char(12);
DEFINE ls_auxiliar3    char(5);
DEFINE pdebitos4       DECIMAL(15,2);
DEFINE pcreditos4      DECIMAL(15,2);
DEFINE psaldo4         DECIMAL(15,2);
DEFINE psaldo5         DECIMAL(15,2);
DEFINE wsldet_periodo  SMALLINT;
DEFINE ws_periodo  	   SMALLINT;
DEFINE ws_periodo1     SMALLINT;
DEFINE wsld1_periodo   SMALLINT;
DEFINE no_reg_mes      INTEGER;
DEFINE ll_ciclo        INTEGER;
DEFINE ld_fecha_inicio date;
DEFINE ld_fecha_final  date;
DEFINE mes_ant		   INTEGER;
DEFINE ano_ant		   INTEGER;
DEFINE _cantidad	   INTEGER;
DEFINE _act_empieza, _act_termina DATETIME YEAR TO FRACTION (5);
DEFINE _cod_bitactsal    INTEGER;
DEFINE _act_usuario    VARCHAR(32);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

--set debug file to "sp_sac100.trc";
--trace on;

let ls_cuenta3 = "";
let _act_empieza = CURRENT;
let _cod_bitactsal = 0;
let _act_usuario = NULL;

begin
on exception set _error, _error_isam, _error_desc
	return _error, ls_cuenta3 || " " || _error_desc;
end exception

update cglsaldodet
   set sldet_debtop	 = 0.00,
	   sldet_cretop	 = 0.00,
	   sldet_saldop	 = 0.00
 WHERE sldet_ano     = pant_ano
   AND sldet_periodo = pant_mes;	         

update cglsaldoaux1
   set sld1_debitos  = 0,
       sld1_creditos = 0,
       sld1_saldo    = 0
 where sld1_tipo     = "01"
   and sld1_ano      = pant_ano
   and sld1_periodo  = pant_mes;

if pant_mes = 13 then

	 FOREACH
	  SELECT res_ccosto,
	         res_cuenta, 
	         SUM(res_debito), 
	         SUM(res_credito)
	    INTO w2_ccosto,
	         ls_cuenta,
	         pdebitos,
	         pcreditos
	    FROM cglresumen
	   WHERE year(res_fechatrx)  =  pant_ano
	   	 and month(res_fechatrx) =  12
	     and res_tipcomp         in ("020")
	--	 and res_cuenta          like "111%"
	   GROUP BY 1, 2

	      IF pdebitos IS NULL THEN
	         LET pdebitos = 0;
	      END IF
	      IF pcreditos IS NULL THEN
	         LET pcreditos = 0;
	      END IF

	      LET pcreditos = pcreditos * -1;

	      SELECT cta_nivel 
	        INTO wcta_nivel 
	        FROM cglcuentas
	       WHERE cta_cuenta = ls_cuenta;

	      IF wcta_nivel IS NULL THEN
	         CONTINUE FOREACH;
	      END IF

	      LET nivel1 = wcta_nivel;

	      FOR indice = nivel1 TO 1 STEP -1

	          SELECT est_posinicial, 
	                 est_posfinal 
	            INTO pos1, 
	                 pos2
	            FROM cglestructura
	           WHERE est_nivel = indice;

	           LET work_cta = substring(ls_cuenta from 1 for pos2);

	          SELECT sldet_debtop,
	                 sldet_cretop,
	                 sldet_saldop
	            INTO pdebitos2,
	                 pcreditos2,
	                 psaldo2 
	            FROM cglsaldodet
	           WHERE sldet_tipo    = "01"
	             AND sldet_cuenta  = work_cta
	             AND sldet_ano     = pant_ano
	             AND sldet_periodo = pant_mes
	             AND sldet_ccosto  = w2_ccosto;	
	             
			   if psaldo2 is null then

		           	LET pdebitos2  = 0.00;
		          	LET pcreditos2 = 0.00;
		           	LET psaldo2    = 0.00;

					select count(*)
					  into _cantidad
					  from cglsaldoctrl
					 where sld_tipo   = "01"
					   and sld_cuenta = work_cta
					   and sld_ccosto = w2_ccosto
					   and sld_ano    = pant_ano;

					if _cantidad = 0 then

						insert into cglsaldoctrl
						values ("01", work_cta, w2_ccosto, pant_ano, 0.00);

					end if
					   

					insert into cglsaldodet
					values ("01", work_cta, w2_ccosto, pant_ano, pant_mes, 0.00, 0.00, 0.00);

			   end if				   

	           LET pdebitos2  = pdebitos  + pdebitos2;
	           LET pcreditos2 = pcreditos + pcreditos2;
	           LET psaldo2    = pdebitos  + pcreditos + psaldo2 ;

	           UPDATE cglsaldodet
	              SET sldet_debtop  = pdebitos2,
	                  sldet_cretop  = pcreditos2,
	                  sldet_saldop  = psaldo2
	            WHERE sldet_tipo    = "01"
	              AND sldet_cuenta  = work_cta
	              AND sldet_ano     = pant_ano
	              AND sldet_periodo = pant_mes
	              AND sldet_ccosto  = w2_ccosto;         

	      END FOR

	END FOREACH

	-- cglsaldoaux1

	  FOREACH
	   SELECT a.res_cuenta, 
	          b.res1_auxiliar,
	          SUM(b.res1_debito), 
	          SUM(b.res1_credito)
		 INTO ls_cuenta3,
		      ls_auxiliar3,
		      pdebitos3,
		      pcreditos3
		 FROM cglresumen a, cglresumen1 b
		WHERE year(a.res_fechatrx)  =  pant_ano
		  and month(a.res_fechatrx) =  12
		  and a.res_tipcomp         = "020"
		  AND a.res_noregistro      = b.res1_noregistro
		  AND a.res_cuenta          = b.res1_cuenta
		  AND a.res_comprobante     = b.res1_comprobante
		GROUP BY a.res_cuenta,  b.res1_auxiliar
		order by b.res1_auxiliar, a.res_cuenta

			IF pdebitos3 IS NULL THEN
			 LET pdebitos3 = 0;
			END IF
			IF pcreditos3 IS NULL THEN
			 LET pcreditos3 = 0;
			END IF

			LET pcreditos3 = pcreditos3 * -1;

			-- verifica si esta creada la cuenta en cglsaldoaux y cglsaldoaux1

			LET idx = 0;

			SELECT COUNT(*) 
			  INTO idx
			  FROM cglsaldoaux1
			 WHERE sld1_tipo    = "01"
			   AND sld1_cuenta  = ls_cuenta3
			   AND sld1_tercero = ls_auxiliar3
			   AND sld1_ano     = pant_ano 
			   AND sld1_periodo = pant_mes;

			IF idx = 0 THEN

				BEGIN
				ON EXCEPTION IN(-239,-268)
					UPDATE cglsaldoaux
					SET sld_incioano = 0
					WHERE sld_tipo    = "01"
					AND sld_cuenta  = ls_cuenta3
					AND sld_tercero = ls_auxiliar3
					AND sld_ano     = pant_ano; 
				END EXCEPTION

				INSERT INTO cglsaldoaux
				VALUES('01',ls_cuenta3,
				ls_auxiliar3,
				pant_ano, 0);

				END

				BEGIN
				ON EXCEPTION IN(-239,-268)
					UPDATE cglsaldoaux1
					SET sld1_debitos  = 0,
					  sld1_creditos = 0,
					  sld1_saldo    = 0
					WHERE sld1_tipo    = "01"
					AND sld1_cuenta  = ls_cuenta3
					AND sld1_tercero = ls_auxiliar3
					AND sld1_ano     = pant_ano
					AND sld1_periodo = pant_mes 	;						 
				END EXCEPTION

				INSERT INTO cglsaldoaux1
				 VALUES('01',
				    ls_cuenta3,
				    ls_auxiliar3,
				    pant_ano, pant_mes, 0, 0, 0);

				END

			END IF

			SELECT sld1_debitos,sld1_creditos,sld1_saldo
			 INTO pdebitos4,pcreditos4,psaldo4 
			 FROM cglsaldoaux1
			WHERE sld1_tipo    = "01"
			  AND sld1_cuenta  = ls_cuenta3
			  AND sld1_tercero = ls_auxiliar3
			  AND sld1_ano     = pant_ano
			  AND sld1_periodo = pant_mes ;

			LET pdebitos4  = pdebitos4  + pdebitos3;
			LET pcreditos4 = pcreditos4 + pcreditos3;
			LET psaldo4    = psaldo4    + pdebitos3 + pcreditos3;

			UPDATE cglsaldoaux1
			  SET sld1_debitos  = pdebitos4,
			      sld1_creditos = pcreditos4,
			      sld1_saldo    = psaldo4
			WHERE sld1_tipo    = "01"
			  AND sld1_cuenta  = ls_cuenta3
			  AND sld1_tercero = ls_auxiliar3
			  AND sld1_ano     = pant_ano
			  AND sld1_periodo = pant_mes;

			LET ano_ant = pant_ano - 1;
			LET mes_ant = 13;

			SELECT sum(sld1_saldo)
			INTO  psaldo5
			FROM cglsaldoaux1
			WHERE sld1_tipo    = "01"
			AND sld1_cuenta  = ls_cuenta3
			AND sld1_tercero = ls_auxiliar3
			AND sld1_ano     = ano_ant
			AND sld1_periodo = mes_ant 	;

			IF psaldo5 IS NULL THEN
			 LET psaldo5 = 0;
			END IF

			UPDATE cglsaldoaux
			SET sld_incioano = psaldo5
			WHERE sld_tipo    = "01"
			AND sld_cuenta  = ls_cuenta3
			AND sld_tercero = ls_auxiliar3
			AND sld_ano     = pant_ano; 

	END FOREACH

elif pant_mes = 14 then

	 FOREACH
	  SELECT res_ccosto,
	         res_cuenta, 
	         SUM(res_debito), 
	         SUM(res_credito)
	    INTO w2_ccosto,
	         ls_cuenta,
	         pdebitos,
	         pcreditos
	    FROM cglresumen
	   WHERE year(res_fechatrx)  =  pant_ano
	   	 and month(res_fechatrx) =  12
    	 and res_tipcomp         in ("021")
	--	 and res_cuenta          like "111%"
	   GROUP BY 1, 2

	      IF pdebitos IS NULL THEN
	         LET pdebitos = 0;
	      END IF
	      IF pcreditos IS NULL THEN
	         LET pcreditos = 0;
	      END IF

	      LET pcreditos = pcreditos * -1;

	      SELECT cta_nivel 
	        INTO wcta_nivel 
	        FROM cglcuentas
	       WHERE cta_cuenta = ls_cuenta;

	      IF wcta_nivel IS NULL THEN
	         CONTINUE FOREACH;
	      END IF

	      LET nivel1 = wcta_nivel;

	      FOR indice = nivel1 TO 1 STEP -1

	          SELECT est_posinicial, 
	                 est_posfinal 
	            INTO pos1, 
	                 pos2
	            FROM cglestructura
	           WHERE est_nivel = indice;

	           LET work_cta = substring(ls_cuenta from 1 for pos2);

	          SELECT sldet_debtop,
	                 sldet_cretop,
	                 sldet_saldop
	            INTO pdebitos2,
	                 pcreditos2,
	                 psaldo2 
	            FROM cglsaldodet
	           WHERE sldet_tipo    = "01"
	             AND sldet_cuenta  = work_cta
	             AND sldet_ano     = pant_ano
	             AND sldet_periodo = pant_mes
	             AND sldet_ccosto  = w2_ccosto;	         

			   if psaldo2 is null then

		           	LET pdebitos2  = 0.00;
		          	LET pcreditos2 = 0.00;
		           	LET psaldo2    = 0.00;

					select count(*)
					  into _cantidad
					  from cglsaldoctrl
					 where sld_tipo   = "01"
					   and sld_cuenta = work_cta
					   and sld_ccosto = w2_ccosto
					   and sld_ano    = pant_ano;

					if _cantidad = 0 then

						insert into cglsaldoctrl
						values ("01", work_cta, w2_ccosto, pant_ano, 0.00);

					end if

					insert into cglsaldodet
					values ("01", work_cta, w2_ccosto, pant_ano, pant_mes, 0.00, 0.00, 0.00);

			   end if 

	           LET pdebitos2  = pdebitos  + pdebitos2;
	           LET pcreditos2 = pcreditos + pcreditos2;
	           LET psaldo2    = pdebitos  + pcreditos + psaldo2 ;

	           UPDATE cglsaldodet
	              SET sldet_debtop  = pdebitos2,
	                  sldet_cretop  = pcreditos2,
	                  sldet_saldop  = psaldo2
	            WHERE sldet_tipo    = "01"
	              AND sldet_cuenta  = work_cta
	              AND sldet_ano     = pant_ano
	              AND sldet_periodo = pant_mes
	              AND sldet_ccosto  = w2_ccosto;         

	      END FOR

	END FOREACH

	-- cglsaldoaux1

	  FOREACH
	   SELECT a.res_cuenta, 
	          b.res1_auxiliar,
	          SUM(b.res1_debito), 
	          SUM(b.res1_credito)
		 INTO ls_cuenta3,
		      ls_auxiliar3,
		      pdebitos3,
		      pcreditos3
		 FROM cglresumen a, cglresumen1 b
		WHERE year(a.res_fechatrx)  =  pant_ano
		  and month(a.res_fechatrx) =  12
		  and a.res_tipcomp         = "021"
		  AND a.res_noregistro      = b.res1_noregistro
		  AND a.res_cuenta          = b.res1_cuenta
		  AND a.res_comprobante     = b.res1_comprobante
		GROUP BY a.res_cuenta,  b.res1_auxiliar
		order by b.res1_auxiliar, a.res_cuenta

			IF pdebitos3 IS NULL THEN
			 LET pdebitos3 = 0;
			END IF
			IF pcreditos3 IS NULL THEN
			 LET pcreditos3 = 0;
			END IF

			LET pcreditos3 = pcreditos3 * -1;

			-- verifica si esta creada la cuenta en cglsaldoaux y cglsaldoaux1

			LET idx = 0;

			SELECT COUNT(*) 
			  INTO idx
			  FROM cglsaldoaux1
			 WHERE sld1_tipo    = "01"
			   AND sld1_cuenta  = ls_cuenta3
			   AND sld1_tercero = ls_auxiliar3
			   AND sld1_ano     = pant_ano 
			   AND sld1_periodo = pant_mes;

			IF idx = 0 THEN

				BEGIN
				ON EXCEPTION IN(-239,-268)
					UPDATE cglsaldoaux
					SET sld_incioano = 0
					WHERE sld_tipo    = "01"
					AND sld_cuenta  = ls_cuenta3
					AND sld_tercero = ls_auxiliar3
					AND sld_ano     = pant_ano; 
				END EXCEPTION

				INSERT INTO cglsaldoaux
				VALUES('01',ls_cuenta3,
				ls_auxiliar3,
				pant_ano, 0);

				END

				BEGIN
				ON EXCEPTION IN(-239,-268)
					UPDATE cglsaldoaux1
					SET sld1_debitos  = 0,
					  sld1_creditos = 0,
					  sld1_saldo    = 0
					WHERE sld1_tipo    = "01"
					AND sld1_cuenta  = ls_cuenta3
					AND sld1_tercero = ls_auxiliar3
					AND sld1_ano     = pant_ano
					AND sld1_periodo = pant_mes 	;						 
				END EXCEPTION

				INSERT INTO cglsaldoaux1
				 VALUES('01',
				    ls_cuenta3,
				    ls_auxiliar3,
				    pant_ano, pant_mes, 0, 0, 0);

				END

			END IF

			SELECT sld1_debitos,sld1_creditos,sld1_saldo
			 INTO pdebitos4,pcreditos4,psaldo4 
			 FROM cglsaldoaux1
			WHERE sld1_tipo    = "01"
			  AND sld1_cuenta  = ls_cuenta3
			  AND sld1_tercero = ls_auxiliar3
			  AND sld1_ano     = pant_ano
			  AND sld1_periodo = pant_mes ;

			LET pdebitos4  = pdebitos4  + pdebitos3;
			LET pcreditos4 = pcreditos4 + pcreditos3;
			LET psaldo4    = psaldo4    + pdebitos3 + pcreditos3;

			UPDATE cglsaldoaux1
			  SET sld1_debitos  = pdebitos4,
			      sld1_creditos = pcreditos4,
			      sld1_saldo    = psaldo4
			WHERE sld1_tipo    = "01"
			  AND sld1_cuenta  = ls_cuenta3
			  AND sld1_tercero = ls_auxiliar3
			  AND sld1_ano     = pant_ano
			  AND sld1_periodo = pant_mes;

			LET ano_ant = pant_ano - 1;
			LET mes_ant = 14;

			SELECT sum(sld1_saldo)
			INTO  psaldo5
			FROM cglsaldoaux1
			WHERE sld1_tipo    = "01"
			AND sld1_cuenta  = ls_cuenta3
			AND sld1_tercero = ls_auxiliar3
			AND sld1_ano     = ano_ant
			AND sld1_periodo = mes_ant 	;

			IF psaldo5 IS NULL THEN
			 LET psaldo5 = 0;
			END IF

			UPDATE cglsaldoaux
			SET sld_incioano = psaldo5
			WHERE sld_tipo    = "01"
			AND sld_cuenta  = ls_cuenta3
			AND sld_tercero = ls_auxiliar3
			AND sld_ano     = pant_ano; 

	END FOREACH

else

	 FOREACH
	  SELECT res_ccosto,
	         res_cuenta, 
	         SUM(res_debito), 
	         SUM(res_credito)
	    INTO w2_ccosto,
	         ls_cuenta,
	         pdebitos,
	         pcreditos
	    FROM cglresumen
	   WHERE year(res_fechatrx)  =  pant_ano
	   	 and month(res_fechatrx) =  pant_mes
	     and res_tipcomp         not in ("020", "021")
	--	 and res_cuenta  like "%0805"
	--	 and res_cuenta          like "111%"
	   GROUP BY 1, 2

	      IF pdebitos IS NULL THEN
	         LET pdebitos = 0;
	      END IF
	      IF pcreditos IS NULL THEN
	         LET pcreditos = 0;
	      END IF

	      LET pcreditos = pcreditos * -1;

	      SELECT cta_nivel 
	        INTO wcta_nivel 
	        FROM cglcuentas
	       WHERE cta_cuenta = ls_cuenta;

	      IF wcta_nivel IS NULL THEN
	         CONTINUE FOREACH;
	      END IF

	      LET nivel1 = wcta_nivel;

	      FOR indice = nivel1 TO 1 STEP -1

	          SELECT est_posinicial, 
	                 est_posfinal 
	            INTO pos1, 
	                 pos2
	            FROM cglestructura
	           WHERE est_nivel = indice;

	           LET work_cta = substring(ls_cuenta from 1 for pos2);

	          SELECT sldet_debtop,
	                 sldet_cretop,
	                 sldet_saldop
	            INTO pdebitos2,
	                 pcreditos2,
	                 psaldo2 
	            FROM cglsaldodet
	           WHERE sldet_tipo    = "01"
	             AND sldet_cuenta  = work_cta
	             AND sldet_ano     = pant_ano
	             AND sldet_periodo = pant_mes
	             AND sldet_ccosto  = w2_ccosto;	         

			   if psaldo2 is null then

		           	LET pdebitos2  = 0.00;
		          	LET pcreditos2 = 0.00;
		           	LET psaldo2    = 0.00;

					select count(*)
					  into _cantidad
					  from cglsaldoctrl
					 where sld_tipo   = "01"
					   and sld_cuenta = work_cta
					   and sld_ccosto = w2_ccosto
					   and sld_ano    = pant_ano;

					if _cantidad = 0 then

						insert into cglsaldoctrl
						values ("01", work_cta, w2_ccosto, pant_ano, 0.00);

					end if

					insert into cglsaldodet
					values ("01", work_cta, w2_ccosto, pant_ano, pant_mes, 0.00, 0.00, 0.00);

			   end if				   

	           LET pdebitos2  = pdebitos  + pdebitos2;
	           LET pcreditos2 = pcreditos + pcreditos2;
	           LET psaldo2    = pdebitos  + pcreditos + psaldo2 ;

	           UPDATE cglsaldodet
	              SET sldet_debtop  = pdebitos2,
	                  sldet_cretop  = pcreditos2,
	                  sldet_saldop  = psaldo2
	            WHERE sldet_tipo    = "01"
	              AND sldet_cuenta  = work_cta
	              AND sldet_ano     = pant_ano
	              AND sldet_periodo = pant_mes
	              AND sldet_ccosto  = w2_ccosto;         

	      END FOR

	END FOREACH

	-- cglsaldoaux1

	  foreach
	   select a.res_cuenta, 
	          b.res1_auxiliar,
	          sum(b.res1_debito), 
	          sum(b.res1_credito)
		 into ls_cuenta3,
		      ls_auxiliar3,
		      pdebitos3,
		      pcreditos3
		 from cglresumen a, cglresumen1 b
		where year(a.res_fechatrx)  =  pant_ano
		  and month(a.res_fechatrx) =  pant_mes
		  and a.res_tipcomp         not in ("020", "021")
		  and a.res_noregistro      = b.res1_noregistro
		  and a.res_cuenta          = b.res1_cuenta
		group by a.res_cuenta, b.res1_auxiliar
		order by a.res_cuenta, b.res1_auxiliar

			IF pdebitos3 IS NULL THEN
				LET pdebitos3 = 0;
			END IF
			IF pcreditos3 IS NULL THEN
				LET pcreditos3 = 0;
			END IF

			LET pcreditos3 = pcreditos3 * -1;

			-- verifica si esta creada la cuenta en cglsaldoaux y cglsaldoaux1

			LET idx = 0;

			SELECT COUNT(*) 
			  INTO idx
			  FROM cglsaldoaux1
			 WHERE sld1_tipo    = "01"
			   AND sld1_cuenta  = ls_cuenta3
			   AND sld1_tercero = ls_auxiliar3
			   AND sld1_ano     = pant_ano 
			   AND sld1_periodo = pant_mes;

			IF idx = 0 THEN

				BEGIN
				ON EXCEPTION IN(-239,-268)
					UPDATE cglsaldoaux
					SET sld_incioano = 0
					WHERE sld_tipo    = "01"
					AND sld_cuenta  = ls_cuenta3
					AND sld_tercero = ls_auxiliar3
					AND sld_ano     = pant_ano; 
				END EXCEPTION

				INSERT INTO cglsaldoaux
				VALUES('01',ls_cuenta3,
				ls_auxiliar3,
				pant_ano, 0);

				END

				BEGIN
				ON EXCEPTION IN(-239,-268)
					UPDATE cglsaldoaux1
					SET sld1_debitos  = 0,
					  sld1_creditos = 0,
					  sld1_saldo    = 0
					WHERE sld1_tipo    = "01"
					AND sld1_cuenta  = ls_cuenta3
					AND sld1_tercero = ls_auxiliar3
					AND sld1_ano     = pant_ano
					AND sld1_periodo = pant_mes 	;						 
				END EXCEPTION

				INSERT INTO cglsaldoaux1
				 VALUES('01',
				    ls_cuenta3,
				    ls_auxiliar3,
				    pant_ano, pant_mes, 0, 0, 0);

				END

			END IF

			select sld1_debitos,
			       sld1_creditos,
			       sld1_saldo
			  into pdebitos4,
			       pcreditos4,
			       psaldo4 
			  from cglsaldoaux1
			 where sld1_tipo    = "01"
			   and sld1_cuenta  = ls_cuenta3
			   and sld1_tercero = ls_auxiliar3
			   and sld1_ano     = pant_ano
			   and sld1_periodo = pant_mes ;

			let pdebitos4  = pdebitos4  + pdebitos3;
			let pcreditos4 = pcreditos4 + pcreditos3;
			let psaldo4    = psaldo4    + pdebitos3 + pcreditos3;

			update cglsaldoaux1
			   set sld1_debitos  = pdebitos4,
			       sld1_creditos = pcreditos4,
			       sld1_saldo    = psaldo4
			 where sld1_tipo     = "01"
			   and sld1_cuenta   = ls_cuenta3
			   and sld1_tercero  = ls_auxiliar3
			   and sld1_ano      = pant_ano
			   and sld1_periodo  = pant_mes;

			{
			LET ano_ant = pant_ano - 1;
			LET mes_ant = 14;

			SELECT sum(sld1_saldo)
			INTO  psaldo5
			FROM cglsaldoaux1
			WHERE sld1_tipo    = "01"
			AND sld1_cuenta  = ls_cuenta3
			AND sld1_tercero = ls_auxiliar3
			AND sld1_ano     = ano_ant
			AND sld1_periodo = mes_ant 	;

			IF psaldo5 IS NULL THEN
			 LET psaldo5 = 0;
			END IF

			UPDATE cglsaldoaux
			SET sld_incioano = psaldo5
			WHERE sld_tipo    = "01"
			AND sld_cuenta  = ls_cuenta3
			AND sld_tercero = ls_auxiliar3
			AND sld_ano     = pant_ano; 
			}

	end foreach

end if

end

call sp_sac101(pant_ano) returning _error, _error_desc;

let _act_termina = CURRENT;

select max(cod_bitactsal)
  into _cod_bitactsal
  from bitactsaldo;
  
if _cod_bitactsal is null then
	let _cod_bitactsal = 0;
end if	

let _cod_bitactsal = _cod_bitactsal + 1;

let _act_usuario = sp_sis84();

insert into bitactsaldo 
       (cod_bitactsal,
	   act_empieza,
	   act_usuario)
values (_cod_bitactsal,
        _act_empieza,
		_act_usuario);


RETURN 0, "Actualizacion Exitosa";

END

END PROCEDURE;	  