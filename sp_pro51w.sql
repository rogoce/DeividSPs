-- Procedimiento para calculo de tarifas y primas por cobertura	MINSA
-- Creado    : 15/12/2010 - Autor: Amado Perez M.
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro51w;

CREATE PROCEDURE "informix".sp_pro51w(a_poliza CHAR(10))
RETURNING INTEGER, CHAR(5);  -- Tarifa por cobertura

--declaracion de variables

DEFINE _factor_division   SMALLINT;
DEFINE _valor_asignar     CHAR(1);
DEFINE _tipo_valor        CHAR(1);
DEFINE _busqueda 	      CHAR(1);
DEFINE _ld_tarifa         DECIMAL(20,4);
DEFINE _ld_ded_min        DECIMAL(20,4);
DEFINE _ld_limite_1       DECIMAL(20,4);
DEFINE _ld_limite_2	      DECIMAL(20,4);
DEFINE _ld_prima_neta     DECIMAL(20,4);
DEFINE _ld_prima_bruta    DECIMAL(20,4);
DEFINE _ld_descuento_max  DECIMAL(20,4);
DEFINE _ld_suma           DECIMAL(20,4);
DEFINE _ld_prima          DECIMAL(20,4);
DEFINE _ld_prima_resta    DECIMAL(20,4);
DEFINE _ld_recargo        DECIMAL(20,4);
DEFINE _ld_descuento      DECIMAL(20,4);
DEFINE _ldv_tar_unica     DECIMAL(20,4);
DEFINE _ld_valor          DECIMAL(20,4);
DEFINE _tipo_deduc        SMALLINT;
DEFINE _acepta_desc       SMALLINT;
DEFINE _fact_vigencia     DECIMAL(9,6);
DEFINE _ramo_sis          SMALLINT;
DEFINE _no_motor          CHAR(30);
DEFINE _ld_anos           SMALLINT;
DEFINE _cod_producto      CHAR(5);
DEFINE _no_unidad         CHAR(5);
DEFINE _suma_asegurada    DEC(16,2);
DEFINE _cant              INTEGER;
DEFINE _preguntar_suma	  SMALLINT;
DEFINE _cod_cobertura     CHAR(5);
DEFINE _orden 			  SMALLINT;
DEFINE _cob_requerida     SMALLINT;
DEFINE _cob_default       SMALLINT;
DEFINE _deducible         DEC(16,2);
DEFINE _desc_limite1      VARCHAR(50);
DEFINE _desc_limite2      VARCHAR(50);
DEFINE _porc_suma         DEC(5,2);
DEFINE _user_added        CHAR(8);
DEFINE _error			  INTEGER;
DEFINE _nombre, _deducible_s VARCHAR(50);

--set debug file to "sp_pro51v.trc";
--trace on;																	 

begin work;

BEGIN

ON EXCEPTION SET _error
    rollback work; 
 	RETURN _error, _no_unidad;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET _ld_suma 	     =   0.00;
LET _ld_tarifa       =  00.00;
LET _ld_ded_min      =  00.00;
LET _ld_limite_1     =  00.00;
LET _ld_limite_2     =  00.00;
LET _ld_prima_neta   =  00.00;
LET _ld_prima_bruta  =  00.00;
LET _ld_descuento_max=  00.00;
LET _ld_descuento    =  00.00;
LET _ld_prima        =  00.00;
LET _ld_prima_resta  =  00.00;
LET _ld_descuento    =  00.00;
LET _ld_recargo      =  00.00;
LET _ldv_tar_unica   =  00.00;
LET _ramo_sis        =      0;
LET _ld_anos         =      0;
LET _fact_vigencia   =      0; 
LET _no_unidad       = ""; 

FOREACH
 SELECT cod_producto,
        no_unidad,
		suma_asegurada
   INTO _cod_producto,  
		_no_unidad,     
      	_suma_asegurada
   FROM emipouni
  WHERE no_poliza = a_poliza
  --  and no_unidad = '01424'
    IF _cod_producto <> '01549' AND _cod_producto <> '01550' THEN
		CONTINUE FOREACH;
	END IF

    LET _ld_suma = _suma_asegurada;	

	IF _ld_suma IS NULL THEN
	   LET _ld_suma = 00.00;
	END IF

	LET _cant = 0;

    SELECT COUNT(*)
	  INTO _cant
	  FROM emipocob
	 WHERE no_poliza = a_poliza
	   AND no_unidad = _no_unidad
	   AND cod_cobertura = '00907';

	IF _cant = 0 THEN
	 FOREACH 
	 SELECT  prdprod.preguntar_suma,   
	         prdcobpd.cod_cobertura,   
	         prdcobpd.orden,   
	         prdcobpd.valor_asignar,   
	         prdcobpd.busqueda,   
	         prdcobpd.tipo_valor,   
	         prdcobpd.valor_tar_unica,   
	         prdcobpd.factor_division,   
	         prdcobpd.acepta_desc,   
	         prdcobpd.cob_requerida,   
	         prdcobpd.cob_default,   
	         prdcobpd.deducible,   
	         prdcobpd.desc_limite1,   
	         prdcobpd.desc_limite2,   
	         prdcober.nombre,   
	         prdcobpd.porc_suma,   
	         prdcobpd.deducible_min,   
	         prdcobpd.tipo_deducible
	    INTO _preguntar_suma,
		     _cod_cobertura,
	    	 _orden,
	    	 _valor_asignar,
	    	 _busqueda,
			 _tipo_valor,   
	    	 _ldv_tar_unica,
	    	 _factor_division,
	    	 _acepta_desc,   
	    	 _cob_requerida,  
	    	 _cob_default,   
	    	 _deducible,   
	    	 _desc_limite1,   
	    	 _desc_limite2,   
	    	 _nombre,   
	    	 _porc_suma,   
	    	 _ld_ded_min,  
	    	 _tipo_deduc
	    FROM prdprod,   
	         prdcobpd,   
	         prdcober  
	   WHERE ( prdcobpd.cod_producto = prdprod.cod_producto ) and  
	         ( prdcober.cod_cobertura = prdcobpd.cod_cobertura ) and  
	         ( ( prdprod.cod_producto = _cod_producto ) AND  
	         ( prdprod.activo = 1 ) AND  
	         ( prdcobpd.cod_cobertura = '00907'))   
	ORDER BY prdcobpd.orden ASC   

	SELECT factor_vigencia
	  INTO _fact_vigencia
	  FROM emipomae
	 WHERE no_poliza = a_poliza;

	LET _ld_limite_1 = 0.00; 
	LET _ld_limite_2 = 0.00;

	IF _busqueda = "1" THEN      --Secuencial
	    SELECT valor, rango_monto1, rango_monto2
	      INTO _ld_valor, _ld_limite_1, _ld_limite_2 
	      FROM prdtasec
	 	 WHERE cod_cobertura = _cod_cobertura
	   	   AND cod_producto  = _cod_producto;

		IF _tipo_valor = "P" THEN
			 LET _ld_tarifa =  _ld_valor;
		ELSE 
		   IF _factor_division > 0 AND _ld_suma <> 0 THEN
			  LET _ld_tarifa = (_ld_valor * _factor_division) / _ld_suma;
			  LET _ld_tarifa = _ld_tarifa /  _factor_division;
			  LET _ld_tarifa = _ld_tarifa *  _ld_suma;
		   ELSE
			  LET _ld_tarifa = 00.00;
		   END IF
		END IF

		IF _valor_asignar = "S" THEN
			LET _ld_limite_1 = _suma_asegurada * _porc_suma / 100;
			LET _ld_limite_2 = 0.00;
	    END IF

	   	IF _deducible IS NULL THEN
	    	LET _deducible = 0.00;
		END IF

		LET _deducible_s = _deducible;

	   	IF _deducible_s IS NULL OR TRIM(_deducible_s) = "" THEN
			LET _deducible_s = "0";
	   	END IF 

	ELIF _busqueda = "2" THEN   --Unica
		LET _ld_tarifa = 0;
		If _tipo_valor = "P" Then
			LET _ld_tarifa = _ldv_tar_unica;
		Else
			If _factor_division > 0 Then
				LET _ld_tarifa = _ldv_tar_unica / _factor_division;
				LET _ld_tarifa = _ld_tarifa * _ld_suma;
			End If
		End If

		LET _ld_limite_1 = 0.00;
		LET _ld_limite_2 = 0.00;

		IF _valor_asignar = "S" THEN
			LET _ld_limite_1 = _suma_asegurada * _porc_suma / 100;
			LET _ld_limite_2 = 0.00;
		END IF

	   	IF _deducible IS NULL THEN
	    	LET _deducible = 0.00;
		END IF

		LET _deducible_s = _deducible;

	   	IF _deducible_s IS NULL OR TRIM(_deducible_s) = "" THEN
			LET _deducible_s = "0";
	   	END IF 
		
	{ELIF _busqueda in ("3", "4") THEN --llave ¢ rango
		 SELECT ramo_sis
	       INTO _ramo_sis
	       FROM prdramo
	      WHERE cod_ramo = a_ramo;

	   	 IF _ramo_sis = 1 THEN
		 	SELECT no_motor
		      INTO _no_motor
		   	  FROM emiauto
		   	 WHERE no_poliza = a_poliza
		       AND no_unidad = a_unidad;

		    CALL  sp_sis61e(_no_motor) RETURNING _ld_anos;
	   	 ELSE
		   LET _ld_anos = 0;
	   	 END IF

	     CALL sp_sis51c(_busqueda, a_producto, a_cobertura, _ld_anos, _ld_suma) RETURNING _ld_valor;

		 IF _tipo_valor = "P" THEN  --Prima
		   	IF _ld_valor > 0  THEN
		   	  LET _ld_tarifa = _ld_valor;
		    END IF
		 ElIF _tipo_valor = "T" THEN --Tarifa
		   	  IF _factor_division > 0 THEN
		   	     IF _ld_valor     > 0 THEN
		   		    LET _ld_tarifa = _ld_valor / _factor_division;
		   	        LET _ld_tarifa = _ld_tarifa * _ld_suma;
		   		 END IF
		   	  END IF
		 END IF
	}
	END IF															

	--Calculo de prima y descuento
	  
	LET _ld_prima       = _fact_vigencia * _ld_tarifa;
	LET _ld_prima_resta = _ld_prima;
	LET _ld_descuento   = 00.00;
	LET _ld_descuento   = 00.00;

	IF _acepta_desc = 1 THEN --Calcula descuento
	   CALL sp_proe21(a_poliza, _no_unidad, _ld_prima) RETURNING _ld_descuento;

	   IF _ld_descuento IS NULL THEN
	      LET _ld_descuento = 00.00;
	   END IF

	END IF

	IF _ld_descuento > 00.00 THEN
	   LET _ld_prima_resta = _ld_prima - _ld_descuento;
	END IF

	LET _ld_recargo = 00.00;

	IF _acepta_desc = 1 THEN --Calcula recargo

	   CALL sp_proe22(a_poliza, _no_unidad, _ld_prima_resta) RETURNING _ld_recargo;

	   IF _ld_recargo IS NULL THEN
	      LET _ld_recargo = 00.00;
	   END IF

	END IF

	-- Calcular Prima Neta

	LET _ld_prima_neta = _ld_prima + _ld_recargo - _ld_descuento;

	IF _deducible < _ld_ded_min THEN
		LET _deducible = _ld_ded_min;
	END IF

	Insert Into emipocob (no_poliza, no_unidad, cod_cobertura, orden, tarifa, 
							 deducible, limite_1, limite_2, prima_anual, prima, 
							 descuento, recargo, prima_neta, date_added, 
							 date_changed, factor_vigencia, desc_limite1, 
							 desc_limite2)
	Values (a_poliza, _no_unidad, _cod_cobertura, _orden, 0, 
			  _deducible_s, _ld_limite_1, _ld_limite_2, _ld_tarifa, _ld_prima, 
			  _ld_descuento, _ld_recargo, _ld_prima_neta, today, 
			  today, _fact_vigencia, _desc_limite1, _desc_limite2);

	END FOREACH
  END IF

  LET _cant = 0;

	SELECT COUNT(*)
	  INTO _cant
	  FROM emifacon
	 WHERE no_poliza = a_poliza
	   AND no_unidad = _no_unidad;

	IF _cant = 0 THEN
	   SELECT user_added
	     INTO _user_added
		 FROM emipomae
		WHERE no_poliza = a_poliza;

	   CALL sp_proe04(a_poliza, _no_unidad, _suma_asegurada, _user_added) RETURNING _error;

	   IF _error <> 0 THEN
		rollback work;
		RETURN _error, _no_unidad;
	   END IF
      
	END IF
END FOREACH

END 
commit work;
RETURN 0, _no_unidad;

END PROCEDURE