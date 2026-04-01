-- Reporte del Flujo de Caja
-- 
-- Creado    : 09/05/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/05/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cheq_sp_che15a_dw1 -- DEIVID, S.A.

DROP PROCEDURE sp_che15a;

CREATE PROCEDURE "informix".sp_che15a(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha DATE)
RETURNING CHAR(3),   --cod_flujo
		  CHAR(50),	 --descr. del flujo
		  DEC(16,2), --dia
		  DEC(16,2), --mes
		  DEC(16,2), --ano
		  SMALLINT,	 --tipo de flujo
		  CHAR(50);	 --cia

DEFINE v_tipo_flujo	SMALLINT;
DEFINE v_cod_flujo	CHAR(3);
DEFINE v_nombre	    CHAR(50);
DEFINE v_monto_dia	DEC(16,2);
DEFINE v_monto_mes	DEC(16,2);
DEFINE v_monto_ano	DEC(16,2);
DEFINE v_nombre_cia	CHAR(50);
DEFINE _monto		DEC(16,2);
DEFINE _periodo		CHAR(7);
DEFINE _fecha_mes	DATE;
DEFINE _fecha_ano	DATE;
DEFINE _ano			INTEGER;
DEFINE _mes			INTEGER;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che15a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_ingresos(
cod_flujo	CHAR(3),
monto_dia	DEC(16,2),
monto_mes	DEC(16,2),
monto_ano	DEC(16,2),
tipo_flujo	SMALLINT
);

LET  v_nombre_cia = sp_sis01(a_compania); 

LET _mes = MONTH(a_fecha);
LET _ano = YEAR(a_fecha);

LET _fecha_mes = MDY(_mes, 1, _ano);
LET _fecha_ano = MDY(1, 1, _ano);

---
IF MONTH(a_fecha) < 10 THEN
	LET _periodo = YEAR(a_fecha) || '-0' || MONTH(a_fecha);
ELSE
	LET _periodo = YEAR(a_fecha) || '-' || MONTH(a_fecha);
END IF

-- Flujo de Caja del Dia

CALL sp_che15(
a_compania,
a_sucursal,
a_fecha,
a_fecha
);

FOREACH
 SELECT SUM(monto),
		cod_flujo
   INTO _monto,
		v_cod_flujo
   FROM tmp_flujo
  GROUP BY cod_flujo

	SELECT tipo_flujo
	  INTO v_tipo_flujo
	  FROM chqfluti
	 WHERE cod_flujo = v_cod_flujo;

	INSERT INTO tmp_ingresos
	VALUES(
	v_cod_flujo,
	_monto,
	0,
	0,
	v_tipo_flujo
	);

END FOREACH

DROP TABLE tmp_flujo;

-- Flujo de Caja del Mes

FOREACH                            
 SELECT monto,                
		cod_flujo
   INTO _monto,
		v_cod_flujo
   FROM chqfluac
  WHERE periodo = _periodo

                                   
	SELECT tipo_flujo               
	  INTO v_tipo_flujo             
	  FROM chqfluti                 
	 WHERE cod_flujo = v_cod_flujo; 
                                   
	INSERT INTO tmp_ingresos        
	VALUES(                         
	v_cod_flujo,                    
	0,                              
	_monto,                         
	0,                              
	v_tipo_flujo                    
	);                              
END FOREACH                        
                                   
-- Flujo de Caja del Ano           
                                   
FOREACH                            
 SELECT SUM(monto),                
		cod_flujo                   
   INTO _monto,                    
		v_cod_flujo                 
   FROM chqfluac
  WHERE periodo[1,4] = _periodo[1,4]                  
  GROUP BY cod_flujo               
                                   
	SELECT tipo_flujo               
	  INTO v_tipo_flujo             
	  FROM chqfluti                 
	 WHERE cod_flujo = v_cod_flujo; 
                                   
	INSERT INTO tmp_ingresos        
	VALUES(                         
	v_cod_flujo,                    
	0,                              
	0,                              
	_monto,                         
	v_tipo_flujo                    
	);                              
                                   
END FOREACH                        
                                   
FOREACH
 SELECT cod_flujo,
        SUM(monto_dia),
		SUM(monto_mes),
		SUM(monto_ano),
		tipo_flujo
   INTO v_cod_flujo,
        v_monto_dia,
		v_monto_mes,
		v_monto_ano,
		v_tipo_flujo
   FROM tmp_ingresos
  GROUP BY tipo_flujo, cod_flujo
  ORDER BY tipo_flujo, cod_flujo

	 {IF v_tipo_flujo = 2 THEN
		LET v_monto_dia = v_monto_dia * -1;
		LET v_monto_mes = v_monto_mes * -1;
		LET v_monto_ano = v_monto_ano * -1;
	 ELIF v_tipo_flujo = 1 THEN
		LET v_monto_dia = v_monto_dia * -1;
	 END IF}

	LET v_monto_mes = v_monto_mes + v_monto_dia;
	LET v_monto_ano = v_monto_ano + v_monto_dia;

	SELECT nombre
	  INTO v_nombre
	  FROM chqfluti
	 WHERE cod_flujo = v_cod_flujo;

	RETURN v_cod_flujo,
		   v_nombre,
		   v_monto_dia,
		   v_monto_mes,
		   v_monto_ano,
		   v_tipo_flujo,
		   v_nombre_cia
		   WITH RESUME;
   
END FOREACH	

DROP TABLE tmp_ingresos;
		
END PROCEDURE;