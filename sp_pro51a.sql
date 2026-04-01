-- Reporte de Vencimientos
-- Creado    : 31/12/2008 - Autor: Ricardo Jim‚nez B.
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro51a;
CREATE PROCEDURE "informix".sp_pro51a(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7), a_sucursal CHAR(255) DEFAULT "*", a_saldo CHAR(1), a_poliza CHAR(20) DEFAULT "*" )
RETURNING  CHAR(10),       -- _cod_contratante,
           CHAR(100),      -- _asegurado,
		   CHAR(10),	   -- _no_poliza,
		   CHAR(20),       -- _no_documento,
		   DATE,           -- _ld_vig_inici,
		   DATE,           -- _ld_vig_final,
		   CHAR(5),        -- _cod_acreedor,
		   CHAR(100),      -- _acreedor,
		   DECIMAL(16,2),  -- _ld_prima_nueva,
		   DECIMAL(16,2),  -- _ld_nuevo_deduc,
		   DECIMAL(16,2),  -- _ld_limite_1,
		   DECIMAL(16,2),  -- _ld_limite_2,
		   DECIMAL(16,2),  -- _ld_prima_deduc,
		   DECIMAL(16,2),  -- _ld_sum_aseg_1,
		   DECIMAL(16,2),  -- _ld_porc_depr,
		   DECIMAL(16,2),  -- _ld_porc_desc,
		   DECIMAL(16,2),  -- _ld_saldo,
		   SMALLINT,       -- _ld_identrec,
		   CHAR(5),	       -- _no_unidad,
		   CHAR(5),        -- _cod_cobertura,
		   CHAR(100),      -- _cobertura,
		   SMALLINT,	   -- _orden
		   DECIMAL(16,2);  -- _ld_descuento
		   
--*************DECLARACION DE VARIABLES***************--

DEFINE _asegurado            CHAR(100);
DEFINE _ld_saldo		 DECIMAL(16,2);
DEFINE _ld_prima_nueva 	 DECIMAL(16,2);
DEFINE _ld_prima_deduc	 DECIMAL(16,2);
DEFINE _ld_deduc_nuevo	 DECIMAL(16,2);
DEFINE _ld_deduc_anter	 DECIMAL(16,2);
DEFINE _ld_prima_anter	 DECIMAL(16,2);
DEFINE _ld_tarifa        DECIMAL(16,2);
DEFINE _ld_descuento     DECIMAL(16,2);
DEFINE _ld_sum_aseg_1    DECIMAL(16,2);
DEFINE _ld_sum_aseg_2	 DECIMAL(16,2);
DEFINE _ld_nuevo_deduc	 DECIMAL(16,2);
DEFINE _ld_limite_1      DECIMAL(16,2);
DEFINE _ld_limite_2      DECIMAL(16,2);
DEFINE _ld_porc_desc     DECIMAL(16,2);
DEFINE _ld_porc_depr     DECIMAL(16,2);
DEFINE _rec_ded_col      DECIMAL(16,2);
DEFINE _rec_ded_com		 DECIMAL(16,2);
DEFINE _ld_vig_inici              DATE;
DEFINE _ld_vig_final	          DATE;
DEFINE _filtros          	 CHAR(255);
DEFINE _cod_ramo         	   CHAR(3);
DEFINE _cod_grupo        	   CHAR(5);
DEFINE _cod_contratante  	  CHAR(10);
DEFINE _cod_agente       	   CHAR(5);
DEFINE _cod_cobertura    	   CHAR(5);
DEFINE _cobertura        	 CHAR(100);
DEFINE _cod_acreedor     	   CHAR(5);
DEFINE _acreedor  	         CHAR(100);
DEFINE _no_unidad        	   CHAR(5);
DEFINE _no_documento     	  CHAR(20);
DEFINE _no_poliza        	  CHAR(10);
DEFINE _vigencia_inic    		  DATE;
DEFINE _vigencia_final            DATE;
DEFINE _no_motor         	  CHAR(30);
DEFINE _cod_marca        	   CHAR(5);
DEFINE _cod_prod	     	   CHAR(5);
DEFINE _tipo_rec_col     	   CHAR(1);
DEFINE _tipo_rec_com     	   CHAR(1);
DEFINE _uso_auto         	   CHAR(1);
DEFINE _ld_identrec    	      SMALLINT;
DEFINE _ld_orden              SMALLINT;
DEFINE _ld_rec_existe         SMALLINT;
DEFINE _fecha_aud1                DATE;
DEFINE _fecha_aud2                DATE;
DEFINE _acep_desc             SMALLINT;

SET ISOLATION TO DIRTY READ;

--***Arma y crea el archivo temporal segun parametro establecido***--
LET _filtros = sp_pro51b(a_compania, a_agencia, a_periodo1, a_periodo2, a_sucursal, a_saldo, a_poliza);
--*********************inicializa las variables********************--


LET _ld_saldo       = 00.00;
LET _ld_prima_nueva = 00.00;
LET _ld_prima_deduc = 00.00;
LET _ld_deduc_nuevo = 00.00;
LET _ld_deduc_anter = 00.00;
LET _ld_prima_anter = 00.00;
LET _ld_tarifa      = 00.00;
LET _ld_descuento   = 00.00;

LET _ld_sum_aseg_1  = 00.00;
LET _ld_sum_aseg_2  = 00.00;

LET _ld_nuevo_deduc = 00.00;

LET _ld_limite_1    = 00.00;
LET _ld_limite_2    = 00.00;  
LET _ld_porc_desc   = 00.00;
LET _ld_porc_depr   = 00.00;


LET _rec_ded_col    = 00.00;
LET _rec_ded_com    = 00.00;

LET _ld_identrec    = 0;
LET _ld_orden       = 0;
LET _ld_rec_existe  = 0;

LET _acep_desc      = 0;

--**Recorre la tabla temporal y asigna valores a variables de salida**--

FOREACH WITH HOLD
  SELECT no_documento,
         cod_contratante,
		 vigencia_inicial,
         vigencia_final,
         prima,
		 saldo,
         cod_ramo,
         no_poliza
    INTO _no_documento,
         _cod_contratante,
		 _ld_vig_inici,
         _ld_vig_final,
		 _ld_prima_anter,
		 _ld_saldo,
         _cod_ramo,
         _no_poliza

    FROM tmp_prod
   WHERE seleccionado = 1 ORDER BY cod_ramo, no_documento

--************* Nombre del cliente **************--

  SELECT nombre
    INTO _asegurado
    FROM cliclien
   WHERE cod_cliente = _cod_contratante;

--********* Recorrido poliza por unidad *********--

  FOREACH
    SELECT no_unidad
      INTO _no_unidad
      FROM emipouni
     WHERE no_poliza = _no_poliza

    LET _ld_sum_aseg_2 = 00.00;

--******** Obtiene Suma Asegurada Por Unidad******--

    SELECT suma_asegurada
      INTO _ld_sum_aseg_2
      FROM emipouni
     WHERE no_poliza = _no_poliza
       AND no_unidad = _no_unidad;

--******** Obtiene el codigo del producto ********--

    SELECT cod_producto
	  INTO _cod_prod
	  FROM emipouni
     WHERE no_poliza = _no_poliza
       AND no_unidad = _no_unidad;

--******** Obtiene el codigo del acreedor ********--
    LET _cod_acreedor = "";

	FOREACH 
    	SELECT cod_acreedor
      	  INTO _cod_acreedor
      	  FROM emipoacr
     	 WHERE no_poliza = _no_poliza
       	   AND no_unidad = _no_unidad

	   EXIT FOREACH;
			
	END FOREACH

   
   IF _cod_acreedor IS NULL THEN
	  LET _cod_acreedor = "0";
   END IF

--******** Obtiene el nombre del acreedor ********--

   SELECT nombre
     INTO _acreedor
     FROM emiacre
    WHERE cod_acreedor = _cod_acreedor;

	IF _acreedor IS NULL THEN
	   LET _acreedor = "SIN ACREEDOR";
	END IF

 	LET _ld_prima_nueva = 00.00;
	LET _ld_descuento   = 00.00;

	FOREACH

--****** Obtiene el codigo de la cobertura  *******--

   SELECT cod_cobertura
     INTO _cod_cobertura
   	 FROM emipocob
    WHERE no_poliza = _no_poliza
      AND no_unidad = _no_unidad

--******* Blanquea variables prima y deducible*****--

   LET _ld_prima_deduc = 00.00;
   LET _ld_prima_anter = 00.00;
	   
   LET _ld_limite_1    = 00.00;
   LET _ld_limite_2    = 00.00;

   LET _ld_deduc_nuevo = 00.00;
   LET _ld_deduc_anter = 00.00;
	    	      	          	   
   SELECT deducible,
          prima_neta, 
          limite_1,
   	      limite_2,
		  orden
	 INTO _ld_deduc_anter,
   	      _ld_prima_anter,
		  _ld_limite_1,
		  _ld_limite_2,
		  _ld_orden

	 FROM emipocob
    WHERE no_poliza     = _no_poliza
      AND no_unidad     = _no_unidad
      AND cod_cobertura = _cod_cobertura;

--******* Obtiene el nombre de la cobertura ********--
	   	   
   SELECT nombre
   	 INTO _cobertura
	 FROM prdcober
	WHERE cod_ramo      = _cod_ramo
	  AND cod_cobertura = _cod_cobertura;

--******* Si tiene o no reclamo culposo ***********--

   --SELECT count(*)
   	-- INTO _ld_identrec
   	-- FROM recrcmae
   	--WHERE actualizado  = 1
   	 -- AND no_poliza = _no_poliza
   	 -- AND no_unidad = _no_unidad 
   	 -- AND estatus_audiencia <> 0;

   SELECT count(*)
     INTO _ld_identrec
     FROM recrcmae
    WHERE actualizado  = 1
      AND no_poliza = _no_poliza
      AND no_unidad = _no_unidad
      AND fecha_audiencia between _ld_vig_inici AND _ld_vig_final
      AND estatus_audiencia <> 0;
	  
   LET _ld_porc_depr  = 00.00;
   LET _ld_porc_desc  = 00.00;

--******* Obtiene el No motor y el Uso del Auto****--

   SELECT no_motor,
          uso_auto
   	 INTO _no_motor,
   	      _uso_auto
   	 FROM emiauto
   	WHERE no_poliza = _no_poliza
   	  AND no_unidad = _no_unidad;

--******* Obtiene el descuento por el Tipo de Auto*--

   SELECT emiparmren.desc
     INTO _ld_porc_desc
  	 FROM emiparmren
 	WHERE uso_auto = _uso_auto;

   SELECT sum(emiunide.porc_descuento)
   	 INTO _ld_porc_desc
   	 FROM emidescu,
   	      emiunide
   	WHERE emiunide.no_poliza   = _no_poliza
   	  AND emiunide.no_unidad   = _no_unidad
   	  AND emiunide.cod_descuen = emidescu.cod_descuen;


	IF _ld_porc_desc IS NULL THEN
	   LET _ld_porc_desc = 00.00;
	END IF

--******* Porcentaje depreciaci¢n para automovil (Particular/Comercial)

   SELECT porc_depre
     INTO _ld_porc_depr
  	 FROM emidepre
 	WHERE uso_auto  = _uso_auto
   	  AND ano_desde = 2
   	  AND ano_hasta = 99;

--******* Calcula la Nueva Suma Asegurada
	IF 	_ld_sum_aseg_2 IS NULL THEN
		LET _ld_sum_aseg_2  = 0;
	END IF

	LET _ld_sum_aseg_1 = _ld_sum_aseg_2 - (_ld_sum_aseg_2 *  (_ld_porc_depr/100));

	SELECT cod_marca
  	  INTO _cod_marca
  	  FROM emivehic
 	 WHERE no_motor = _no_motor;

	CALL sp_pro51t(_no_poliza, _cod_prod,  _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) RETURNING _ld_tarifa;
	CALL sp_pro51c(_no_poliza, _cod_prod,  _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) RETURNING _ld_prima_deduc;
	CALL sp_pro51d(_no_poliza, _cod_prod,  _cod_ramo, _no_unidad,  _cod_cobertura,  _cod_marca, _ld_sum_aseg_1, _ld_tarifa, _uso_auto) RETURNING _ld_deduc_nuevo;
	
	IF _cod_cobertura IN ("00119", "00118", "00120", "00121", "00606", "00900", "00103", "00901", "00902", "00903", "00904") THEN
	   LET _ld_limite_1 = _ld_sum_aseg_1;
	END IF

   	IF _ld_identrec > 0 THEN
	   LET _ld_identrec = 1; -- si existe reclamo culposo dentro de la poliza
	ELSE
	   --LET _ld_prima_nueva  = _ld_prima_nueva - (_prima * (_porc_desc/100));
	   --LET _ld_prima_nueva    = 00.00;
	END IF

	IF _ld_deduc_nuevo = 00.00 THEN
	   LET _ld_deduc_nuevo = _ld_deduc_anter;
	END IF
	   
	LET _ld_prima_nueva = _ld_prima_nueva + _ld_prima_deduc;
	   
	IF  _ld_prima_deduc IS NULL THEN
		LET _ld_prima_deduc = 00.00;
	END IF

	SELECT acepta_desc
	  INTO _acep_desc
	  FROM prdcobpd
 	 WHERE cod_cobertura = _cod_cobertura
   	   AND cod_producto  = _cod_prod;

	IF _acep_desc IS NULL THEN
	   LET _acep_desc = 0 ;
	END IF

	IF _acep_desc = 1 THEN
	   CALL sp_proe21(_no_poliza, _no_unidad, _ld_prima_deduc) RETURNING _ld_descuento;
	   IF _ld_descuento IS NULL THEN
	      LET _ld_descuento = 00.00;
	   END IF
	ELSE
	   LET _ld_descuento = 00.00;
	END IF


    IF _ld_limite_1 IS NULL THEN
	   LET _ld_limite_1 = 00.00;
    END IF

	IF _ld_limite_2 IS NULL THEN
	   LET _ld_limite_2 = 00.00;
    END IF 

	IF _ld_sum_aseg_1 IS NULL THEN
	   LET _ld_sum_aseg_1 = 00.00;
    END IF 



	LET _ld_limite_1   = TRUNC(_ld_limite_1,0);
	LET _ld_limite_2   = TRUNC(_ld_limite_2,0);
    LET _ld_sum_aseg_1 = TRUNC(_ld_sum_aseg_1,0);

	--***** retorna valores ya calculados *****--

	RETURN _cod_contratante,
       	   _asegurado,
       	   _no_poliza,
       	   _no_documento,
       	   _ld_vig_inici,
       	   _ld_vig_final,
       	   _cod_acreedor,
       	   _acreedor,
       	   _ld_prima_nueva,
       	   _ld_deduc_nuevo,
       	   _ld_limite_1,
       	   _ld_limite_2,
       	   _ld_prima_deduc,
       	   _ld_sum_aseg_1,
       	   _ld_porc_depr,
       	   _ld_porc_desc,
       	   _ld_saldo,
       	   _ld_identrec,
       	   _no_unidad,
       	   _cod_cobertura,
       	   _cobertura,
		   _ld_orden,
		   _ld_descuento

	WITH RESUME;

     END FOREACH

  END FOREACH

END FOREACH

DROP TABLE tmp_prod;

END PROCEDURE                       

