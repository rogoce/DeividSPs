-- Procedimiento  
-- 
-- Creado    : 06/03/2003 -
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec71;

CREATE PROCEDURE "informix".sp_rec71(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7)) 
RETURNING CHAR(18),	   -- Reclamo
		  CHAR(50),      -- Evento
		  DATE,          -- Comision de Prima Suscrita
		  DECIMAL(16,2), -- Monto
		  DECIMAL(16,2), -- Monto dpa
		  CHAR(50);	   -- Compania

DEFINE _no_poliza    	CHAR(10); 
DEFINE _cod_ramo     	CHAR(3);  
DEFINE _cod_subramo,  _cod_evento CHAR(3);  
DEFINE _cod_grupo    	CHAR(5);  
DEFINE _doc_poliza   	CHAR(20); 
DEFINE _cod_sucursal 	CHAR(3);  
DEFINE _cod_coasegur 	CHAR(3);  
DEFINE _porcentaje   	DEC(16,4);
DEFINE _cod_agente, _cod_cobertura   	CHAR(5);
DEFINE _cod_cliente, _no_reclamo, _no_tranrec  	CHAR(10); 
DEFINE _porc_comis_agt 	DEC(5,2);

DEFINE v_filtros     CHAR(255);
DEFINE _count        INTEGER;
DEFINE _contador     INT;
DEFINE v_numrecla    CHAR(18);
DEFINE v_fecha_audiencia DATE;
DEFINE v_evento, v_compania_nombre   CHAR(50);

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = a_compania;

LET  v_compania_nombre = sp_sis01(a_compania); 
   
-- Tabla Temporal


CREATE TEMP TABLE tmp_montos(
		no_reclamo           CHAR(10)  NOT NULL,
		monto_total         DEC(16,2) DEFAULT 0 NOT NULL,
		monto_dpa           DEC(16,2) DEFAULT 0 NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_montos ON tmp_montos(no_reclamo);

-- Primas Suscritas

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec14.trc";-- Nombre de la Compania
--TRACE ON;



-- Incurrido Bruto y Sinestro Pagado
SET ISOLATION TO DIRTY READ;

BEGIN

DEFINE _monto_total  DECIMAL(16,2);
DEFINE _monto_dpa    DECIMAL(16,2);


FOREACH 
 SELECT	a.no_tranrec,
        a.no_reclamo,
		b.no_poliza
   INTO	_no_tranrec,
        _no_reclamo,
		_no_poliza
   FROM	rectrmae a, recrcmae b
  WHERE b.periodo >= a_periodo1
    AND b.periodo <= a_periodo2
	AND a.no_reclamo = b.no_reclamo
	AND a.cod_tipotran = '004'
	AND a.actualizado = 1

  SELECT cod_ramo
    INTO _cod_ramo
	FROM emipomae
   WHERE no_poliza = _no_poliza;

  IF _cod_ramo <> '002' THEN
     CONTINUE FOREACH;
  END IF    

	LET _monto_total = 0;
	LET _monto_dpa = 0;

 FOREACH
  SELECT monto,
         cod_cobertura
    INTO _monto_total,
	     _cod_cobertura
	FROM rectrcob
   WHERE no_tranrec = _no_tranrec

  IF TRIM(_cod_cobertura) = '00113' THEN
	LET _monto_dpa = _monto_total;
  END IF 
  
	INSERT INTO tmp_montos(
	no_reclamo,      
	monto_total,     
	monto_dpa  
	)
	VALUES(
	_no_reclamo,
	_monto_total,     
	_monto_dpa
	);
 END FOREACH
END FOREACH

END


BEGIN

DEFINE _monto_total  DECIMAL(16,2);
DEFINE _monto_dpa    DECIMAL(16,2);

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec14.trc";-- Nombre de la Compania
--TRACE ON;

FOREACH WITH HOLD

 SELECT SUM(monto_total),
        SUM(monto_dpa),		
 		no_reclamo
   INTO	_monto_total,
		_monto_dpa,
		_no_reclamo
   FROM tmp_montos
  GROUP BY no_reclamo
  	
	SELECT numrecla,
	       cod_evento,
		   fecha_audiencia
	  INTO v_numrecla,
	       _cod_evento,
		   v_fecha_audiencia
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

    SELECT nombre
      INTO v_evento
      FROM recevent
     WHERE cod_evento = _cod_evento;    

	RETURN v_numrecla,
	       v_evento,
		   v_fecha_audiencia,
		   _monto_total,
		   _monto_dpa,
		   v_compania_nombre
		   WITH RESUME;


END FOREACH

END 

DROP TABLE tmp_montos;

END PROCEDURE;
