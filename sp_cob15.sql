-- Procedimiento que carga el detalle del Dia de cobros
-- 
-- Creado    : 20/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 04/06/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob15;

CREATE PROCEDURE "informix".sp_cob15(
a_compania CHAR(3), 
a_sucursal CHAR(3), 
a_cobrador CHAR(3), 
a_dia INT
) RETURNING	INT,  
			INT,
			INT,
			CHAR(20),
			CHAR(100),
			DATE,
			DATE,
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			CHAR(10),
			CHAR(10),
			CHAR(50),
			CHAR(100),
			SMALLINT,
			SMALLINT,
			CHAR(10);

DEFINE v_dia1	          INT;
DEFINE v_dia2             INT;
DEFINE v_procesar         INT;
DEFINE v_documento        CHAR(20);
DEFINE v_asegurado,_descripcion CHAR(100);
DEFINE v_vigen_ini        DATE;
DEFINE v_vigen_fin        DATE;
DEFINE v_saldo            DEC(16,2);
DEFINE v_prima_orig       DEC(16,2);
DEFINE v_por_vencer       DEC(16,2);	 
DEFINE v_exigible,_prima_bruta DEC(16,2);
DEFINE v_corriente		  DEC(16,2);
DEFINE v_monto_30		  DEC(16,2);
DEFINE v_monto_60		  DEC(16,2);
DEFINE v_monto_90		  DEC(16,2);
DEFINE v_apagar,_saldo    DEC(16,2);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_poliza,_cod_pagador,v_nopoliza,_no_poliza_ult CHAR(10);
DEFINE _cod_compania	 CHAR(3);
DEFINE _gestion			 CHAR(1);
DEFINE _cod_sucursal,_cod_cobrador    CHAR(3);
DEFINE _actualizado		 INT;
DEFINE _mes_char         CHAR(2);
DEFINE _ano_char		 CHAR(4);
DEFINE _periodo          CHAR(7);
DEFINE _cod_formapag     INT;
DEFINE _cod_cliente      CHAR(10);
DEFINE _des_pagador      CHAR(50);
DEFINE _cobra_poliza,_cobra_poliza_pol CHAR(1);
DEFINE _estatus,_estatus2,_tipo_forma,_tipo_produccion SMALLINT;
DEFINE _cod_tipoprod,_cod_ramo     CHAR(3);
DEFINE _ramo_sis		 SMALLINT;
--DEFINE _secuencia	     INT;

LET _estatus  = 0;	--Saber si cambiaron el pagador
LET _estatus2 = 0;	--Saber si cambiaron el dia de cobro de la poliza
LET _descripcion = "";
--LET _secuencia = 0;

--Armar varibale que contiene el periodo(aaaa-mm)
IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'||MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char = YEAR(TODAY);
LET _periodo  = _ano_char || "-" || _mes_char;

FOREACH
 SELECT SUM(saldo),
		no_documento
   INTO _saldo,
		v_documento
   FROM emipomae
  WHERE cod_compania = a_compania
    AND cod_sucursal = a_sucursal
    AND actualizado = 1
	AND estatus_poliza IN (1,2,3)
	AND (dia_cobros1 = a_dia
	 OR  dia_cobros2 = a_dia)
  GROUP BY no_documento

	FOREACH
	 SELECT no_poliza,
	        vigencia_final,
			cod_ramo,
			gestion
	   INTO _no_poliza_ult,
			v_vigen_fin,
			_cod_ramo,
			_gestion
	   FROM emipomae
	  WHERE no_documento   = v_documento
	    AND actualizado    = 1
		AND estatus_poliza IN (1,2,3)
		AND (dia_cobros1 = a_dia OR
		     dia_cobros2 = a_dia)
	  ORDER BY vigencia_final DESC
			EXIT FOREACH;
	END FOREACH

	SELECT ramo_sis
	  INTO _ramo_sis
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	--Si el saldo es menor o = a cero, se excluyen los registros para todos los ramos con
	--excepcion de SALUD(5) y VIDA INDIVIDUAL(6)
	IF _saldo <= 0 THEN 
		IF _ramo_sis <> 5 AND _ramo_sis <> 6 THEN
			CONTINUE FOREACH;
		END IF
	END IF

-- Lectura de Polizas cuyo no_poliza es el de la ultima vig.
	SELECT x.dia_cobros1,
		   x.dia_cobros2,
		   x.cod_compania,
		   x.cod_sucursal,
		   x.actualizado,
		   x.cod_formapag,
		   x.cod_contratante,
		   x.no_poliza,
		   x.vigencia_inic,
		   x.vigencia_final,
		   x.prima_bruta,
		   x.cobra_poliza,
		   x.cod_pagador,
		   x.cod_tipoprod,
		   x.cod_ramo
	  INTO v_dia1,
	   	   v_dia2,
	   	   _cod_compania,
	   	   _cod_sucursal,
	   	   _actualizado,
		   _cod_formapag,
		   _cod_cliente,
		   _no_poliza,
		   v_vigen_ini,
		   v_vigen_fin,
		   _prima_bruta,
		   _cobra_poliza_pol,
		   _cod_pagador,
		   _cod_tipoprod,
		   _cod_ramo
	  FROM emipomae x
	 WHERE x.no_poliza = _no_poliza_ult;

 	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	--Si la forma de pago es con VISA(2) o ACH(4), se excluyen los reg.
	IF _tipo_forma = 2 OR _tipo_forma = 4 THEN	
		CONTINUE FOREACH;
	END IF
 
 -- Lectura de Emitipro(Saber el tipo de produccion)
 -- Si es Coaseg Minoritario debe excluir registros.
 	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_produccion = 3 THEN	
		CONTINUE FOREACH;
	END IF

 -- Lectura de Emipoagt(Corredores)
   FOREACH	
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza
	 EXIT FOREACH;
   END FOREACH

   --_cod_cobrador = codigo de cobrador que esta en corredores	
   SELECT cobra_poliza,
   		  cod_cobrador
     INTO _cobra_poliza,
	 	  _cod_cobrador
     FROM agtagent
    WHERE cod_agente = _cod_agente;

	--Solo se traen reg. de corredores para el cobrador que esta procesando.
	IF _cod_cobrador <> a_cobrador THEN
		CONTINUE FOREACH;
	END IF

	--Se excluyen polizas que cobra el corredor.
	IF _cobra_poliza = "C" THEN	
		CONTINUE FOREACH;
	END IF

	--Si en el corredor esta marcado que la poliza la cobran ambos,
	--pero en la poliza dice que la cobra el corredor o ambos, entonces
	--se excluyen esas polizas.
	IF _cobra_poliza = "A" THEN	
		IF _cobra_poliza_pol = "C" OR 
		   _cobra_poliza_pol = "A" THEN
			CONTINUE FOREACH;
		END IF
	END IF

	--Si existe la poliza, se busca la morosidad de la misma.
	IF _no_poliza IS NOT NULL THEN

		CALL sp_cob33(
		a_compania,
		a_sucursal,
		v_documento,
		_periodo,
		today
		) RETURNING v_por_vencer,
				    v_exigible,  
				    v_corriente, 
				    v_monto_30,  
				    v_monto_60,  
				    v_monto_90,
				    v_saldo
				    ;
	END IF		     

	SELECT ramo_sis
	  INTO _ramo_sis
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	IF v_saldo <= 0 THEN 
		IF _ramo_sis <> 5 AND _ramo_sis <> 6 THEN
			CONTINUE FOREACH;
		END IF
	END IF

	LET v_apagar = v_exigible;	    
	
	--Lectura de Asegurado
	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	--Lectura de Pagador
	SELECT nombre
	  INTO _des_pagador
	  FROM cliclien
	 WHERE cod_cliente = _cod_pagador;
	 
	SELECT no_poliza,
		   descripcion
	  INTO v_nopoliza,
	  	   _descripcion
	  FROM cobruter
	 WHERE no_poliza = _no_poliza;

	--Si se encuentra la poliza en el rutero, se marca como procesada
	IF v_nopoliza IS NOT NULL THEN
		LET v_procesar = 1;
	ELSE
		LET v_procesar = 0;
		LET _descripcion = "";
	END IF

	RETURN v_dia1,	   
		   v_dia2,      
		   v_procesar,  
		   v_documento, 
		   v_asegurado, 
		   v_vigen_ini, 
		   v_vigen_fin, 
		   v_saldo,     
		   _prima_bruta,
		   v_por_vencer,
		   v_exigible,  
		   v_corriente,	
		   v_monto_30,	
		   v_monto_60,	
		   v_monto_90,	
		   v_apagar,
		   _no_poliza,
		   _cod_pagador,
		   _des_pagador,
		   _descripcion,
		   _estatus,
		   _estatus2,
		   _cod_cliente
		   WITH RESUME;

END FOREACH;
END PROCEDURE