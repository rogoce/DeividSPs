-- Consulta de Movimientos de Auxiliar Sac 
-- Creado    : 29/12/2008 -- Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac97;
CREATE PROCEDURE sp_sac97(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_aux char(5),a_anio char(4),a_mes char(2)) 
RETURNING	INTEGER,      -- numero de transaccion
            INTEGER,      -- numero de linea
            INTEGER,      -- numero de registro
			CHAR(8),      -- numero de comprobante 
			DATE,         -- fecha de registro
			CHAR(3),      -- tipo de comprobante
			DEC(15,2),    -- monto debito
			DEC(15,2),    -- monto credito
			DEC(15,2),    -- acumulado
			DEC(15,2),	  -- total
			CHAR(2),	  -- tipo de ingreso
			CHAR(3),	  -- centro de costo
			char(3),	  -- origen
			char(12),	  -- cuenta
			char(5) ;     -- reaseguro

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_saldo            DEC(15,2);
DEFINE v_speriodo         CHAR(2);
DEFINE v_notrx			  INTEGER;
DEFINE v_comp			  CHAR(8);
DEFINE v_f_inicio		  DATE;
DEFINE v_f_final    	  DATE;
DEFINE v_fecha			  DATE;
DEFINE v_tipo	          CHAR(3);
DEFINE v_saldo_inicial    DEC(15,2);
DEFINE v_leido		      DEC(15,2);
DEFINE v_linea			  INTEGER;
DEFINE v_norgt			  INTEGER;
DEFINE v_periodo          CHAR(100);
DEFINE v_total            DEC(15,2);  
DEFINE v_tipoing		  CHAR(2);
DEFINE v_ccosto           CHAR(3);
DEFINE v_saldo_ant        DEC(15,2);
DEFINE v_saldo_acum       DEC(15,2);
DEFINE psaldo5            DEC(15,2);
DEFINE v_anio_ant         SMALLINT;
DEFINE v_mes_ant          SMALLINT;
DEFINE _li_cnt            integer;

define _fecha_inicial	  date;
define _fecha_final		  date;
define _mes_inic		  char(2);
define _mes_fin			  char(2);
define v_origen           CHAR(3);
define v_cuenta           char(12);
define v_auxiliar         char(5);

--set debug file to "sp_sac97.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldosac;
CREATE TEMP TABLE tmp_saldosac(
	    no_trx          INTEGER,
		linea           INTEGER,
		no_rgt          INTEGER,
		comp            CHAR(8),
		fecha           DATE,
		tipocomp        CHAR(3),
		debito          DEC(15,2)	default 0,
		credito        	DEC(15,2)	default 0,
		acumulado       DEC(15,2)   default 0,
		total           DEC(15,2)   default 0,
		tipo 			CHAR(2),
		ccosto 			CHAR(3),
		origen          CHAR(3),
		cuenta          char(12),
		auxiliar        char(5)
		) WITH NO LOG; 	

--	    no_trx          SMALLINT	default 0,

LET v_saldo      = 0;
LET psaldo5      = 0;
LET v_saldo_ant  = 0;
LET v_saldo_acum = 0;
let v_cuenta = a_cuenta;
let v_auxiliar = a_aux;

if a_mes = "*" then
	
	let _mes_inic = "01";
	let _mes_fin  = "12";

else

	if a_mes < "10" then
	   if length(a_mes) = 1 then
			let  v_speriodo = "0" || a_mes;
	   end if
	end if

	let v_speriodo = a_mes;
	let _mes_inic = v_speriodo;
	let _mes_fin  = v_speriodo;
	let a_mes = v_speriodo;
end if

let _fecha_inicial = mdy(_mes_inic, 1, a_anio);
let _fecha_final   = sp_sis36(a_anio || "-" || _mes_fin);

LET v_saldo_inicial = 0;
LET v_anio_ant      = a_anio - 1;

SELECT cglsaldoaux.sld_incioano
  INTO v_saldo_ant
  FROM cglsaldoaux
 WHERE ( cglsaldoaux.sld_tipo    like a_tipo )  AND
       ( cglsaldoaux.sld_cuenta  = a_cuenta )   AND
       ( cglsaldoaux.sld_tercero = a_aux )      AND
       ( cglsaldoaux.sld_ano     = a_anio) ; 

IF v_saldo_ant IS NULL THEN
	LET v_saldo_ant = 0;
END IF

if 	a_mes = "01" or a_mes = "*" then
    LET psaldo5    = 0;
else
	LET v_anio_ant = a_anio;
	LET v_mes_ant  = a_mes - 1;
	LET psaldo5    = 0;

	SELECT sum(sld1_debitos + sld1_creditos)
	  INTO  psaldo5
	  FROM cglsaldoaux1
	 WHERE sld1_tipo    = "01"
	   AND sld1_cuenta  = a_cuenta
	   AND sld1_tercero = a_aux
	   AND sld1_ano     = v_anio_ant
	   AND sld1_periodo <= v_mes_ant;

	IF psaldo5 IS NULL THEN
		LET psaldo5 = 0;
	END IF

end if

LET v_saldo_inicial = psaldo5 + v_saldo_ant ;
LET v_saldo = v_saldo_inicial;

FOREACH
  SELECT cglresumen.res_notrx,   
         cglresumen1.res1_linea,   
         cglresumen1.res1_noregistro,   
         cglresumen.res_comprobante,   
         cglresumen.res_fechatrx,   
         cglresumen.res_tipcomp,   
         cglresumen1.res1_debito,   
         cglresumen1.res1_credito,
		 cglresumen1.res1_tipo_resumen,
		 cglresumen.res_ccosto,
		 cglresumen.res_origen
    INTO v_notrx,
	     v_linea,
		 v_norgt,
	     v_comp,
		 v_fecha,
		 v_tipo,
		 v_debito,
	     v_credito,
         v_tipoing,
		 v_ccosto,
		 v_origen
    FROM cglresumen1,   
         cglresumen  
   WHERE ( cglresumen.res_noregistro = cglresumen1.res1_noregistro ) and  
         ( cglresumen1.res1_cuenta = a_cuenta ) AND  
         ( cglresumen1.res1_tipo_resumen like a_tipo ) AND  
         ( cglresumen1.res1_auxiliar = a_aux ) AND  
         ( cglresumen.res_ccosto like a_ccosto ) AND		 
         ( cglresumen.res_fechatrx >= _fecha_inicial ) AND
         ( cglresumen.res_fechatrx <= _fecha_final )  

				LET v_saldo = v_saldo + v_debito - v_credito;

				INSERT INTO tmp_saldosac(
				no_trx,
				linea, 
				no_rgt, 
				comp,
				fecha,
				tipocomp,
				debito,
				credito,
				acumulado,
				total,
				tipo,
				ccosto,
				origen,
				cuenta,
				auxiliar )
				VALUES(	v_notrx,
				 v_linea,
				 v_norgt,
				 v_comp,
				 v_fecha,
				 v_tipo,
				 v_debito,
				 v_credito,
				 v_saldo,
				 0.00,
				 v_tipoing,
				 v_ccosto,
				 v_origen,
				 v_cuenta,
				 v_auxiliar);

END FOREACH;

select count(*) 
into _li_cnt
from tmp_saldosac;

if _li_cnt = 0 then
	INSERT INTO tmp_saldosac(
	no_trx,
	linea, 
	no_rgt, 
	comp,
	fecha,
	tipocomp,
	debito,
	credito,
	acumulado,
	total,
	tipo,
	ccosto,
	origen,
	cuenta,
	auxiliar   )
	VALUES(	
	0,
	0,
	0,
	'',
	current,
	'',
	0,
	0,
	0,
	0.00,
	'',
	'',
	'',
	'',
	'');
end if

--trace off;

update  tmp_saldosac
set total  = v_saldo_inicial ;

FOREACH	
  SELECT no_trx,
		linea, 
		no_rgt, 
		comp,
		fecha,
		tipocomp,
		debito,
		credito,
		acumulado,
		total,
		tipo,
		ccosto,
		origen,
		cuenta,
		auxiliar
	INTO v_notrx,
	     v_linea,
		 v_norgt,
	     v_comp,
		 v_fecha,
		 v_tipo,
		 v_debito,
	     v_credito,
	     v_saldo,
		 v_total, 
		 v_tipoing,
		 v_ccosto,
		 v_origen,
		 v_cuenta,
		 v_auxiliar
    FROM tmp_saldosac

  RETURN v_notrx,
	     v_linea,
		 v_norgt,
	     v_comp,
		 v_fecha,
		 v_tipo,
		 v_debito,
	     v_credito,
	     v_saldo,
	     v_total, 
		 v_tipoing ,
		 v_ccosto,
		 v_origen,
		 v_cuenta,
		 v_auxiliar
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_saldosac;
END PROCEDURE					 