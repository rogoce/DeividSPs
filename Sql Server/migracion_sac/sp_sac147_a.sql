-- Consulta de Movimientos de Cuentas Sac 
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac147('01','26605','%','2009','01','2009','02','sac')

DROP PROCEDURE sp_sac147_a;
CREATE PROCEDURE sp_sac147_a(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_anio char(4),a_mes char(2), a_anio2 char(4),a_mes2 char(2),a_db CHAR(18)) 
RETURNING	INTEGER,     -- numero de transaccion
			CHAR(15),      -- numero de comprobante 
			DATE,         -- fecha de registro
			CHAR(3),      -- tipo de comprobante
			DEC(15,2),    -- monto debito
			DEC(15,2),    -- monto credito
			DEC(15,2),    -- acumulado
			DEC(15,2),	  -- total
			CHAR(2),	  -- tipo de ingreso
			CHAR(3),	  -- centro de costo
			CHAR(50),	  -- cia
			CHAR(50),     -- cuenta
			CHAR(50),	  -- centro
			CHAR(50),	  -- concepto
			CHAR(7),	  -- concepto
			CHAR(7),	  -- concepto
			char(12) ;    -- concepto



DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_saldo            DEC(15,2);
DEFINE v_speriodo         CHAR(2);
DEFINE v_notrx			  INTEGER;
DEFINE v_comp			  CHAR(15);
DEFINE v_f_inicio		  DATE;
DEFINE v_f_final    	  DATE;
DEFINE v_fecha			  DATE;
DEFINE v_tipo	          CHAR(3);
DEFINE v_saldo_inicial    DEC(15,2);
DEFINE v_leido		      DEC(15,2);
DEFINE v_total            DEC(15,2);
DEFINE v_periodo          CHAR(100);
DEFINE v_tipoing		  CHAR(2);
DEFINE v_ccosto           CHAR(3);
DEFINE _fecha_inicial     date;
DEFINE _fecha_final		  date;
DEFINE _cia_nom			  char(50);
DEFINE l_nombre     	  char(50);
DEFINE l_desc_concepto    char(50);
DEFINE l_desc_centro      char(50);
DEFINE l_desde,l_hasta    char(7);

DEFINE v_anterior  			DEC(15,2);
DEFINE _mes_ant  			DEC(15,2);

define _error			integer;
define _error_desc		char(50);


SET ISOLATION TO DIRTY READ;

select cia_nom
  into _cia_nom
  from deivid:sigman02
 where cia_bda_codigo = a_db;

SELECT cta_nombre
  INTO l_nombre
  FROM cglcuentas
 WHERE cta_cuenta = a_cuenta;

if a_mes < 10 then
	let a_mes = "0"||a_mes;
end if
if a_mes2 < 10 then
	let a_mes2 = "0"||a_mes2;
end if

let l_desde	=  a_anio || "-" || a_mes;
let l_hasta =  a_anio2 || "-" || a_mes2;

--call sp_sac148(a_tipo,a_cuenta,a_ccosto,a_anio,a_mes,a_anio2,a_mes2,a_db) returning _error, _error_desc; 

--DROP TABLE tmp_saldosac;
CREATE TEMP TABLE tmp_saldosac(
	    no_trx         INTEGER	default 0,
		comp            CHAR(15),
		fecha           DATE,
		tipocomp        CHAR(3),
		debito          DEC(15,2)	default 0,
		credito        	DEC(15,2)	default 0,
		acumulado       DEC(15,2)   default 0,
		total           DEC(15,2)   default 0,
		tipo 			CHAR(2),
		ccosto 			CHAR(3),
		cia_nom			char(50),
		cta_nombre   	char(50)
		) WITH NO LOG; 	

--  set debug file to "sp_sac96.trc";	
--  trace on;

  LET v_saldo = 0;
  LET l_desc_centro = "";
  LET l_desc_concepto = "";

  if a_mes < 10 then
		if  a_mes[2] is null then
	    	let  v_speriodo = "0" || a_mes[1] ;
		else
	    	let  v_speriodo = "0" || a_mes[2] ;
		end if
  else 
    	let  v_speriodo = a_mes;
  end if

  let _fecha_inicial = mdy(a_mes, 1, a_anio) ;
  let _fecha_final   = sp_sis36(a_anio2 || "-" || a_mes2) ;


  SELECT cglperiodo.per_inicio,   
         cglperiodo.per_final,
		 cglperiodo.per_descrip
    INTO v_f_inicio,
		 v_f_final,
		 v_periodo
    FROM cglperiodo  
   WHERE ( cglperiodo.per_ano = a_anio ) AND  
         ( cglperiodo.per_mes = v_speriodo ) ;

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


LET v_anterior = 0;
LET _mes_ant = 0;

if a_mes > 1 then
	LET _mes_ant = a_mes - 1;
	SELECT sum(cglresumen.res_debito-cglresumen.res_credito)
	INTO v_anterior
	FROM cglresumen
	WHERE ( cglresumen.res_cuenta = a_cuenta ) AND
	     ( cglresumen.res_tipo_resumen like a_tipo ) AND
	     ( cglresumen.res_ccosto like a_ccosto) AND
	     ( year(cglresumen.res_fechatrx) = a_anio) AND
	     ( month(cglresumen.res_fechatrx) <= _mes_ant ) ;

	IF v_anterior IS NULL THEN
		LET v_anterior = 0 ;
	END IF
end if

LET v_saldo = v_saldo_inicial + v_anterior ;


FOREACH
  SELECT cglresumen.res_notrx,
         cglresumen.res_comprobante,
         cglresumen.res_fechatrx,
         cglresumen.res_tipcomp,
         cglresumen.res_debito,
         cglresumen.res_credito,
		 cglresumen.res_tipo_resumen,
		 cglresumen.res_ccosto
    INTO v_notrx,
	     v_comp,
		 v_fecha,
		 v_tipo,
		 v_debito,
	     v_credito,
		 v_tipoing,
		 v_ccosto
    FROM cglresumen
   WHERE ( cglresumen.res_cuenta = a_cuenta ) AND
         ( cglresumen.res_tipo_resumen like a_tipo ) AND
         ( cglresumen.res_ccosto like a_ccosto ) AND		 
--         ( year(cglresumen.res_fechatrx) = a_anio ) AND
--         ( month(cglresumen.res_fechatrx) = v_speriodo ) 
         ( cglresumen.res_fechatrx >= _fecha_inicial ) AND
         ( cglresumen.res_fechatrx <= _fecha_final )  
  order by cglresumen.res_fechatrx, cglresumen.res_comprobante, cglresumen.res_tipcomp, cglresumen.res_origen

  LET v_saldo = v_saldo + v_debito - v_credito ;

INSERT INTO tmp_saldosac(
		no_trx,
		comp,
		fecha,
		tipocomp,
		debito,
		credito,
		acumulado,
		total,
		tipo,
		ccosto,
		cia_nom,
		cta_nombre )
	VALUES(	v_notrx,
	     v_comp,
		 v_fecha,
		 v_tipo,
		 v_debito,
	     v_credito,
		 v_saldo,
		 0.00,
		 v_tipoing,
		 v_ccosto,
		 _cia_nom,
		 l_nombre);

END FOREACH;

LET v_saldo = v_saldo_inicial + v_anterior ;

update  tmp_saldosac
set total  = v_saldo ;


FOREACH	
  SELECT no_trx,
		comp,
		fecha,
		tipocomp,
		debito,
		credito,
		total,
		tipo,
		ccosto,
		cia_nom,
		cta_nombre
	INTO v_notrx,
	     v_comp,
		 v_fecha,
		 v_tipo,
		 v_debito,
	     v_credito,
		 v_total, 
		 v_tipoing,
		 v_ccosto,
		 _cia_nom,
		 l_nombre
    FROM tmp_saldosac
   order by fecha, comp

  SELECT cen_descripcion  
    INTO l_desc_centro
    FROM cglcentro  
    where cen_codigo = v_ccosto;

    SELECT con_descrip 
      INTO l_desc_concepto
      FROM cglconcepto
    where con_codigo = v_tipo;

	let v_saldo = v_saldo + v_debito - v_credito;
	
  RETURN v_notrx,  			--1
	     v_comp,			--2
		 v_fecha,			--3
		 v_tipo,			--4
		 v_debito,			--5
	     v_credito,			--6
		 v_saldo,			--7
		 v_total,			--8
		 v_tipoing,			--9
		 v_ccosto,			--10
		 _cia_nom,			--11
		 l_nombre,			--12
		 l_desc_centro,		--13
		 l_desc_concepto,	--14
		 l_desde,			--15
		 l_hasta,			--16
		 a_cuenta			--17
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_saldosac;
END PROCEDURE					 