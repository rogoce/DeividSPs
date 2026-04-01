-- Procedimiento que Carga la Siniestralidad acumulada por ajustadores
-- Creado: 12/05/2014 - Autor: Angel Tello
-- 
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_niif10;

CREATE PROCEDURE "informix".sp_niif10(
		a_periodo1  CHAR(7),
		a_periodo2  CHAR(7)	
		) RETURNING integer, char(250);

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);

DEFINE _var_cob_total	DECIMAL(16,2);
DEFINE _var_cob_bruto   DECIMAL(16,2);
DEFINE _var_cob_neto    DECIMAL(16,2);

define _cod_cobertura	char(5);
define _cod_cober_reas	char(3);

DEFINE _incurrido_abierto DEC(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;
DEFINE v_desc_grupo,v_desc_agente   CHAR(50);
DEFINE v_codigo,_cod_agente         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,v_no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo,_peri,v_periodo,_periodo_rec CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _no_unidad       CHAR(5);
DEFINE _no_tranrec      CHAR(10);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;
DEFINE _cod_acreedor    CHAR(5);
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _periodo_reclamo CHAR(7);
DEFINE _desc_ajus_nomb  CHAR(255);
DEFINE _cod_tipotran    CHAR(3);
define _pago_y_ded		DECIMAL(16,2);
define _salv_y_recup    DECIMAL(16,2);
define _suma_limite     DECIMAL(16,2);
define _cnt             smallint;
define _suma_asegurada  DECIMAL(16,2);
DEFINE _fecha_siniestro DATE;
DEFINE _limite1, _limite1_end DECIMAL(16,2);
DEFINE _limite2, _limite2_end DECIMAL(16,2);
DEFINE _no_documento    CHAR(20);
DEFINE _opcion          smallint;

CREATE TEMP TABLE tmp_niif17(
		no_reclamo           CHAR(10)  NOT NULL,
		cod_cober_reas       CHAR(3)   NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		suma_limite          DEC(16,2) DEFAULT 0 NOT NULL,
		periodo              CHAR(7)   NOT NULL
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

DELETE FROM niif_rcs WHERE periodo >= a_periodo1 and periodo <= a_periodo2;

LET _cod_coasegur = sp_sis02('001', '001');

-- Pagos, Salvamentos, Recuperos y Deducibles

LET _monto_total = 0;
LET _monto_bruto = 0;
LET _monto_neto  = 0;

FOREACH
 SELECT no_reclamo,
 		monto,
		periodo,
		no_tranrec,
		cod_tipotran
   INTO _no_reclamo,
   		_monto_total,
		_peri,
		_no_tranrec,
		_cod_tipotran
   FROM rectrmae
  WHERE actualizado  = 1
	AND cod_tipotran IN ('004','005','006','007')
	AND periodo      >= a_periodo1 
	AND periodo      <= a_periodo2
    AND monto        <> 0

	-- Informacion de Coaseguro

	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF

	SELECT periodo,
	       no_poliza,
		   suma_asegurada,
		   fecha_siniestro,
		   no_unidad
	  INTO _periodo_rec,
	       _no_poliza,
		   _suma_asegurada,
		   _fecha_siniestro,
		   _no_unidad
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
	 
	-- Calculos
	
	FOREACH
		SELECT cod_cobertura,
		       monto
		  INTO _cod_cobertura,
          	   _monto_total
          FROM rectrcob
         WHERE no_tranrec = _no_tranrec
		   AND monto <> 0
		 
		SELECT cod_cober_reas
          INTO _cod_cober_reas
          FROM prdcober
         WHERE cod_cobertura = _cod_cobertura;	

        LET _cnt = 0;		 
        LET _limite1 = 0;		 
        LET _limite2 = 0;	
		LET _limite1_end = 0;
		LET _limite2_end = 0;
		LET _opcion = 0;
		 
		SELECT count(*)
          INTO _cnt
          FROM reacobre	
         WHERE cod_cober_reas = _cod_cober_reas
		   AND UPPER(nombre) like "%CASCO%";		  
		 
		IF _cnt IS NULL THEN
			LET _cnt = 0;
		END IF
		 
		IF _cnt > 0 THEN 
			LET _suma_limite = _suma_asegurada;
		ELSE
		    FOREACH
				SELECT a.limite_1,
			           a.limite_2,
					   a.opcion
			      INTO _limite1_end,
                       _limite2_end,
					   _opcion
                  FROM endedcob a, endedmae b
                 WHERE a.no_poliza = b.no_poliza
                   AND a.no_endoso = b.no_endoso
				   AND a.no_unidad = _no_unidad
				   and a.cod_cobertura = _cod_cobertura
                   AND b.no_poliza = _no_poliza
                   AND b.fecha_emision	<= _fecha_siniestro		  
              ORDER BY b.no_endoso asc
			  
			 if _opcion in (0,1,2) then
				LET _limite1 = _limite1 + _limite1_end;
				LET _limite2 = _limite2 + _limite2_end;
             elif _opcion = 3 then
			    LET _limite1 = 0;		 
				LET _limite2 = 0;
             end if			 
			  
               
			END FOREACH 
			
			IF _limite1 IS NULL THEN
				LET _limite1 = 0.00;
			END IF
			
			IF _limite2 IS NULL THEN
				LET _limite2 = 0.00;
			END IF
			
			IF _limite2 = 0.00 THEN
				LET _suma_limite = _limite1;
			ELSE
				LET _suma_limite = _limite2;			
			END IF
			
		END IF	
		 
		LET _monto_bruto = _monto_total / 100 * _porc_coas;

		INSERT INTO tmp_niif17(
		no_reclamo,
		cod_cober_reas,
		pagado_bruto,
		suma_limite,
		periodo
		)
		VALUES(
		_no_reclamo,
		_cod_cober_reas,
		_monto_bruto,
		_suma_limite,
		_peri
		);
	END FOREACH	

END FOREACH


BEGIN

DEFINE _pagado_bruto  DEC(16,2);

FOREACH 
 SELECT no_reclamo,	
        cod_cober_reas,
		SUM(pagado_bruto),
		suma_limite,
		periodo
   INTO _no_reclamo,	
        _cod_cober_reas,
		_pagado_bruto,
		_suma_limite,
		_peri
   FROM tmp_niif17
  GROUP BY no_reclamo, cod_cober_reas, suma_limite, periodo
  
  	-- Lectura de la Tabla de Reclamo

	SELECT no_poliza,
	       no_unidad,
		   no_documento,
	       fecha_siniestro
	  INTO _no_poliza,
	       _no_unidad,
		   _no_documento,
	       _fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
	 	 
	SELECT cod_ramo,
           cod_subramo
      INTO _cod_ramo,
           _cod_subramo
      FROM emipomae
     WHERE no_poliza = _no_poliza;	  
	 
	BEGIN 		 
	on exception in (-239, -268)
		return 1, _no_reclamo || " " || _no_poliza || " " || _no_unidad || " " || _no_documento || " " || _peri || " " || _cod_cober_reas;  
	end exception			 
	

	INSERT INTO niif_rcs(
	no_reclamo,
	no_poliza,
	no_unidad,
	no_documento,
	periodo,
	cod_ramo,
	cod_subramo,
	suma_limite,
	cod_cober_reas,
	fecha_siniestro,
	monto_pagado
	)
	VALUES(
	_no_reclamo,
	_no_poliza,
	_no_unidad,
	_no_documento,
	_peri,
	_cod_ramo,
	_cod_subramo,
	_suma_limite,
	_cod_cober_reas,
	_fecha_siniestro,
	_pagado_bruto);
	
	END

END FOREACH


END 


DROP TABLE tmp_niif17;
RETURN 0, 'Proceso Completado';

END PROCEDURE;
