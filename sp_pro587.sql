-- Procedimiento que genera salida reporte de auditoria

-- Creado    : 21/06/2019 - Autor: Amado Perez.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_pro587;

CREATE PROCEDURE "informix".sp_pro587()
returning CHAR(20) AS poliza,
          DATE AS vigencia_inicial,
		  DATE AS vigencia_final,
		  CHAR(5) AS unidad,
		  VARCHAR(100) AS asegurado,
		  CHAR(10) AS canal,
		  INTEGER AS no_pagos,
		  DEC(7,4) AS coas_asumido,
		  DEC(7,4) AS coas_cedido,
          VARCHAR(50) AS cia_aseguradora,
		  SMALLINT AS ano_auto,
		  VARCHAR(50) AS marca,
		  VARCHAR(50) AS modelo,
		  DEC(16,2) AS suma_asegurada,
		  iNTEGER AS peso,
		  DEC(5,2) AS descuento,
		  DEC(16,2) AS tasa,
		  DEC(16,2) AS prima_suscrita,
		  VARCHAR(50) AS agente,
		  DEC(5,2) AS porc_comis_agt,
		  VARCHAR(50) AS cobertura_1,
		  DEC(16,2) AS limite_1_1,
		  DEC(16,2) AS limite_2_1,
		  VARCHAR(50) AS deducible_1,
		  VARCHAR(50) AS cobertura_2,
		  DEC(16,2) AS limite_1_2,
		  DEC(16,2) AS limite_2_2,
		  VARCHAR(50) AS deducible_2,
		  VARCHAR(50) AS cobertura_3,
		  DEC(16,2) AS limite_1_3,
		  DEC(16,2) AS limite_2_3,
		  VARCHAR(50) AS deducible_3,
		  VARCHAR(50) AS cobertura_4,
		  DEC(16,2) AS limite_1_4,
		  DEC(16,2) AS limite_2_4,
		  VARCHAR(50) AS deducible_4,
		  VARCHAR(50) AS cobertura_5,
		  DEC(16,2) AS limite_1_5,
		  DEC(16,2) AS limite_2_5,
		  VARCHAR(50) AS deducible_5,
		  VARCHAR(50) AS cobertura_6,
		  DEC(16,2) AS limite_1_6,
		  DEC(16,2) AS limite_2_6,
		  VARCHAR(50) AS deducible_6,
		  VARCHAR(50) AS cobertura_7,
		  DEC(16,2) AS limite_1_7,
		  DEC(16,2) AS limite_2_7,
		  VARCHAR(50) AS deducible_7,
		  VARCHAR(50) AS cobertura_8,
		  DEC(16,2) AS limite_1_8,
		  DEC(16,2) AS limite_2_8,
		  VARCHAR(50) AS deducible_8,
		  VARCHAR(50) AS cobertura_9,
		  DEC(16,2) AS limite_1_9,
		  DEC(16,2) AS limite_2_9,
		  VARCHAR(50) AS deducible_9,
		  VARCHAR(50) AS cobertura_10,
		  DEC(16,2) AS limite_1_10,
		  DEC(16,2) AS limite_2_10,
		  VARCHAR(50) AS deducible_10,
		  VARCHAR(50) AS cobertura_11,
		  DEC(16,2) AS limite_1_11,
		  DEC(16,2) AS limite_2_11,
		  VARCHAR(50) AS deducible_11,
		  VARCHAR(50) AS cobertura_12,
		  DEC(16,2) AS limite_1_12,
		  DEC(16,2) AS limite_2_12,
		  VARCHAR(50) AS deducible_12,
		  CHAR(5) AS cod_producto,
		  VARCHAR(50) AS producto,
		  DATE AS fecha_emision,
		  CHAR(10) AS uso_auto,
		  CHAR(10) AS usuario,
		  VARCHAR(30) AS cedula_ruc,
		  VARCHAR(50) AS zona;
		  
DEFINE _no_poliza 		  CHAR(10);
DEFINE _no_documento      CHAR(20);
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final    DATE;
DEFINE _cod_contratante   CHAR(10);
DEFINE _cotizacion        CHAR(10);
DEFINE _no_pagos          SMALLINT;
DEFINE _cod_tipoprod      CHAR(3);
DEFINE _cod_coasegur      CHAR(3);
DEFINE _porc_partic_ancon DEC(7,4);
DEFINE _cod_agente        CHAR(5); 
DEFINE _porc_partic_agt   DEC(5,2);
DEFINE _porc_comis_agt    DEC(5,2);
DEFINE _cia_aseguradora   VARCHAR(50);
DEFINE _coaseguro_asumido DEC(7,4);
DEFINE _coaseguro_cedido  DEC(7,4);
DEFINE _no_unidad         CHAR(5);
DEFINE _cod_asegurado     CHAR(10);
DEFINE _cod_marca         CHAR(5);
define _cod_modelo        CHAR(5);
DEFINE _ano_auto          SMALLINT;
DEFINE _marca             VARCHAR(50);
DEFINE _modelo            VARCHAR(50);
DEFINE _suma_asegurada    DEC(16,2);
DEFINE _prima_suscrita    DEC(16,2);
DEFINE _asegurado         VARCHAR(100);
DEFINE _no_motor          CHAR(30);
DEFINE _cod_cobertura     CHAR(5);
DEFINE _limite_1          DEC(16,2);
DEFINE _limite_2          DEC(16,2);
DEFINE _deducible         VARCHAR(50);
DEFINE _tasa              DEC(16,2);
DEFINE _peso              DEC(16,2);
DEFINE _canal             CHAR(10);
DEFINE _descuento         DEC(5,2);
DEFINE _cobertura         VARCHAR(50);
DEFINE _agente            VARCHAR(50);
DEFINE _cobertura_1         VARCHAR(50);
DEFINE _limite_1_1          DEC(16,2);
DEFINE _limite_2_1          DEC(16,2);
DEFINE _deducible_1         VARCHAR(50);
DEFINE _cobertura_2         VARCHAR(50);
DEFINE _limite_1_2          DEC(16,2);
DEFINE _limite_2_2          DEC(16,2);
DEFINE _deducible_2         VARCHAR(50);
DEFINE _cobertura_3         VARCHAR(50);
DEFINE _limite_1_3          DEC(16,2);
DEFINE _limite_2_3          DEC(16,2);
DEFINE _deducible_3         VARCHAR(50);
DEFINE _cobertura_4         VARCHAR(50);
DEFINE _limite_1_4          DEC(16,2);
DEFINE _limite_2_4          DEC(16,2);
DEFINE _deducible_4         VARCHAR(50);
DEFINE _cobertura_5         VARCHAR(50);
DEFINE _limite_1_5          DEC(16,2);
DEFINE _limite_2_5          DEC(16,2);
DEFINE _deducible_5         VARCHAR(50);
DEFINE _cobertura_6         VARCHAR(50);
DEFINE _limite_1_6          DEC(16,2);
DEFINE _limite_2_6          DEC(16,2);
DEFINE _deducible_6         VARCHAR(50);
DEFINE _cobertura_7         VARCHAR(50);
DEFINE _limite_1_7          DEC(16,2);
DEFINE _limite_2_7          DEC(16,2);
DEFINE _deducible_7         VARCHAR(50);
DEFINE _cobertura_8         VARCHAR(50);
DEFINE _limite_1_8          DEC(16,2);
DEFINE _limite_2_8          DEC(16,2);
DEFINE _deducible_8         VARCHAR(50);
DEFINE _cobertura_9         VARCHAR(50);
DEFINE _limite_1_9          DEC(16,2);
DEFINE _limite_2_9          DEC(16,2);
DEFINE _deducible_9         VARCHAR(50);
DEFINE _cobertura_10         VARCHAR(50);
DEFINE _limite_1_10          DEC(16,2);
DEFINE _limite_2_10          DEC(16,2);
DEFINE _deducible_10         VARCHAR(50);
DEFINE _cobertura_11         VARCHAR(50);
DEFINE _limite_1_11          DEC(16,2);
DEFINE _limite_2_11          DEC(16,2);
DEFINE _deducible_11         VARCHAR(50);
DEFINE _cobertura_12         VARCHAR(50);
DEFINE _limite_1_12          DEC(16,2);
DEFINE _limite_2_12          DEC(16,2);
DEFINE _deducible_12         VARCHAR(50);
DEFINE _contador            SMALLINT;
DEFINE _cod_producto        CHAR(5);
DEFINE _producto             VARCHAR(50);
DEFINE _fecha_suscripcion   DATE;
DEFINE _uso_automovil       CHAR(10);
DEFINE _user_added          CHAR(8);
DEFINE _cedula              VARCHAR(30);
DEFINE _cod_vendedor        CHAR(3);
DEFINE _zona                VARCHAR(50);
				   
SET ISOLATION TO DIRTY READ;

LET _tasa = null;
LET _peso = null;

FOREACH 
	SELECT no_poliza,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_contratante,
		   cotizacion,
		   no_pagos,
		   cod_tipoprod,
		   fecha_suscripcion,
		   user_added
	  INTO _no_poliza,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_contratante,
		   _cotizacion,
		   _no_pagos,
		   _cod_tipoprod,
		   _fecha_suscripcion,
		   _user_added
	  FROM emipomae
	 WHERE fecha_suscripcion >= '01/01/2021'
--	   AND fecha_suscripcion <= '04/03/2019'
	   AND fecha_suscripcion <= '31/08/2021'
	   AND cod_ramo IN ('002','020','023')
	   AND nueva_renov = 'N'
	   AND actualizado = 1
	   
	IF _cotizacion IS NULL OR TRIM(_cotizacion) = "" THEN
		LET _canal = "DEIVID";
	ELIF _cotizacion[1,3] = "009" THEN
		LET _canal = "WEB";
	ELSE
		LET _canal = "WORKFLOW";
	END IF
	
	   
	LET  _cod_coasegur = NULL;  
	LET  _porc_partic_ancon = 0.00;  
	LET  _cia_aseguradora = NULL;  
	   
	SELECT cod_coasegur,
	       porc_partic_ancon
	  INTO _cod_coasegur,
	       _porc_partic_ancon
	  FROM emicoami
	 WHERE no_poliza = _no_poliza;
	 
	IF _cod_coasegur IS NOT NULL THEN
		SELECT nombre
		  INTO _cia_aseguradora
		  FROM emicoase
		 WHERE cod_coasegur = _cod_coasegur;
		 
		LET _coaseguro_asumido = _porc_partic_ancon;
		LET _coaseguro_cedido = 100 - _porc_partic_ancon;
	ELSE
		LET _coaseguro_asumido = 100;
		LET _coaseguro_cedido = 0;
	END IF
	   
	FOREACH 
		SELECT cod_agente,
	           porc_partic_agt,
			   porc_comis_agt
	      INTO _cod_agente,
	           _porc_partic_agt,
			   _porc_comis_agt
	      FROM emipoagt
	     WHERE no_poliza = _no_poliza
	  
	    SELECT nombre,
		       cod_vendedor
		  INTO _agente,
		       _cod_vendedor
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
		 
		SELECT nombre
          INTO _zona
          FROM agtvende
         WHERE cod_vendedor = _cod_vendedor;		  
	   
		FOREACH
			SELECT no_unidad,
				   cod_asegurado,
				   suma_asegurada,
				   prima_suscrita,
				   cod_producto
			  INTO _no_unidad,
				   _cod_asegurado,
				   _suma_asegurada,
				   _prima_suscrita,
				   _cod_producto
			  FROM emipouni
			 WHERE no_poliza = _no_poliza
			 
			SELECT nombre,
			       cedula
			  INTO _asegurado,
			       _cedula
			  FROM cliclien
		     WHERE cod_cliente = _cod_asegurado;

			SELECT no_motor,
			       case when uso_auto = "P" then "PARTICULAR" else "COMERCIAL" end as uso 
			  INTO _no_motor,
                   _uso_automovil			  
			  FROM emiauto
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = _no_unidad;		 
			   
			SELECT cod_marca,
				   cod_modelo,
				   ano_auto
			  INTO _cod_marca,
				   _cod_modelo,
				   _ano_auto
			  FROM emivehic
			 WHERE no_motor = _no_motor;
			 
			SELECT nombre
			  INTO _marca
			  FROM emimarca
			 WHERE cod_marca = _cod_marca;
			 
			SELECT nombre
			  INTO _modelo
			  FROM emimodel
			 WHERE cod_modelo = _cod_modelo;
			 
			SELECT sum(porc_descuento)
			  INTO _descuento
			  FROM emiunide
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = _no_unidad;		
			   
			SELECT nombre
			  INTO _producto
			  FROM prdprod
			 WHERE cod_producto = _cod_producto;
			   
			LET _contador = 1;
			LET _cobertura_1 = null;
			LET _limite_1_1 = 0;
			LET _limite_2_1 = 0;
			LET _deducible_1 = null;
			LET _cobertura_2 = null;
			LET _limite_1_2 = 0;
			LET _limite_2_2 = 0;
			LET _deducible_2 = null;
			LET _cobertura_3 = null;
			LET _limite_1_3 = 0;
			LET _limite_2_3 = 0;
			LET _deducible_3 = null;
			LET _cobertura_4 = null;
			LET _limite_1_4 = 0;
			LET _limite_2_4 = 0;
			LET _deducible_4 = null;
			LET _cobertura_5 = null;
			LET _limite_1_5 = 0;
			LET _limite_2_5 = 0;
			LET _deducible_5 = null;
			LET _cobertura_6 = null;
			LET _limite_1_6 = 0;
			LET _limite_2_6 = 0;
			LET _deducible_6 = null;
			LET _cobertura_7 = null;
			LET _limite_1_7 = 0;
			LET _limite_2_7 = 0;
			LET _deducible_7 = null;
			LET _cobertura_8 = null;
			LET _limite_1_8 = 0;
			LET _limite_2_8 = 0;
			LET _deducible_8 = null;
			LET _cobertura_9 = null;
			LET _limite_1_9 = 0;
			LET _limite_2_9 = 0;
			LET _deducible_9 = null;
			LET _cobertura_10 = null;
			LET _limite_1_10 = 0;
			LET _limite_2_10 = 0;
			LET _deducible_10 = null;
			LET _cobertura_11 = null;
			LET _limite_1_11 = 0;
			LET _limite_2_11 = 0;
			LET _deducible_11 = null;
			LET _cobertura_12 = null;
			LET _limite_1_12 = 0;
			LET _limite_2_12 = 0;
			LET _deducible_12 = null;

            FOREACH
				SELECT cod_cobertura,
				       limite_1,
					   limite_2,
					   deducible
				  INTO _cod_cobertura,
				       _limite_1,
					   _limite_2,
					   _deducible
				  FROM emipocob
				 WHERE no_poliza = _no_poliza
				   AND no_unidad = _no_unidad
				ORDER BY orden
				   
			   SELECT nombre
                 INTO _cobertura
				 FROM prdcober
				WHERE cod_cobertura = _cod_cobertura;
			
               IF _contador = 1 THEN			
				LET _cobertura_1 = _cobertura;
				LET _limite_1_1 = _limite_1;
				LET _limite_2_1 = _limite_2;
				LET _deducible_1 = _deducible;
               ELIF _contador = 2 THEN			
				LET _cobertura_2 = _cobertura;
				LET _limite_1_2 = _limite_1;
				LET _limite_2_2 = _limite_2;
				LET _deducible_2 = _deducible;
               ELIF _contador = 3 THEN			
				LET _cobertura_3 = _cobertura;
				LET _limite_1_3 = _limite_1;
				LET _limite_2_3 = _limite_2;
				LET _deducible_3 = _deducible;
               ELIF _contador = 4 THEN			
				LET _cobertura_4 = _cobertura;
				LET _limite_1_4 = _limite_1;
				LET _limite_2_4 = _limite_2;
				LET _deducible_4 = _deducible;
               ELIF _contador = 5 THEN			
				LET _cobertura_5 = _cobertura;
				LET _limite_1_5 = _limite_1;
				LET _limite_2_5 = _limite_2;
				LET _deducible_5 = _deducible;
               ELIF _contador = 6 THEN			
				LET _cobertura_6 = _cobertura;
				LET _limite_1_6 = _limite_1;
				LET _limite_2_6 = _limite_2;
				LET _deducible_6 = _deducible;
               ELIF _contador = 7 THEN			
				LET _cobertura_7 = _cobertura;
				LET _limite_1_7 = _limite_1;
				LET _limite_2_7 = _limite_2;
				LET _deducible_7 = _deducible;
               ELIF _contador = 8 THEN			
				LET _cobertura_8 = _cobertura;
				LET _limite_1_8 = _limite_1;
				LET _limite_2_8 = _limite_2;
				LET _deducible_8 = _deducible;
				LET _cobertura_9 = _cobertura;
               ELIF _contador = 9 THEN			
				LET _limite_1_9 = _limite_1;
				LET _limite_2_9 = _limite_2;
				LET _deducible_9 = _deducible;
               ELIF _contador = 10 THEN			
				LET _cobertura_10 = _cobertura;
				LET _limite_1_10 = _limite_1;
				LET _limite_2_10 = _limite_2;
				LET _deducible_10 = _deducible;
               ELIF _contador = 11 THEN			
				LET _cobertura_11 = _cobertura;
				LET _limite_1_11 = _limite_1;
				LET _limite_2_11 = _limite_2;
				LET _deducible_11 = _deducible;
               ELIF _contador = 12 THEN			
				LET _cobertura_12 = _cobertura;
				LET _limite_1_12 = _limite_1;
				LET _limite_2_12 = _limite_2;
				LET _deducible_12 = _deducible;
			   END IF 
			   LET _contador = _contador + 1;
            END FOREACH			
			
			  Return _no_documento,
                     _vigencia_inic,
                     _vigencia_final,
					 _no_unidad,
                     _asegurado,
					 _canal,
                     _no_pagos,
                     _coaseguro_asumido,
                     _coaseguro_cedido,
                     _cia_aseguradora,
                     _ano_auto,
                     _marca,
                     _modelo,					 
				     _suma_asegurada,
					 _peso,
					 _descuento,
					 _tasa,
					 _prima_suscrita,
                     _agente,
					 _porc_comis_agt,
					 _cobertura_1,
					 _limite_1_1,
					 _limite_2_1,
					 _deducible_1,
					 _cobertura_2,
					 _limite_1_2,
					 _limite_2_2,
					 _deducible_2,
					 _cobertura_3,
					 _limite_1_3,
					 _limite_2_3,
					 _deducible_3,
					 _cobertura_4,
					 _limite_1_4,
					 _limite_2_4,
					 _deducible_4,
					 _cobertura_5,
					 _limite_1_5,
					 _limite_2_5,
					 _deducible_5,
					 _cobertura_6,
					 _limite_1_6,
					 _limite_2_6,
					 _deducible_6,
					 _cobertura_7,
					 _limite_1_7,
					 _limite_2_7,
					 _deducible_7,
					 _cobertura_8,
					 _limite_1_8,
					 _limite_2_8,
					 _deducible_8,
					 _cobertura_9,
					 _limite_1_9,
					 _limite_2_9,
					 _deducible_9,
					 _cobertura_10,
					 _limite_1_10,
					 _limite_2_10,
					 _deducible_10,
					 _cobertura_11,
					 _limite_1_11,
					 _limite_2_11,
					 _deducible_11,
					 _cobertura_12,
					 _limite_1_12,
					 _limite_2_12,
					 _deducible_12,
					 _cod_producto,
					 _producto,
					 _fecha_suscripcion,
					 _uso_automovil,
					 _user_added,
					 _cedula,
					 _zona
					 WITH RESUME;
		END FOREACH
	END FOREACH	
END FOREACH


END PROCEDURE
