-- Procedimiento que genera las cartas de Salud
-- Aviso de Cancelacion
-- Carta para enviar cuando no se recibe el pago de la prima dentro del periodo de gracia

-- Creado    : 03/10/2001 - Autor: Marquelda Valdelamar
-- Modificado: 09/10/2001 - Autor: Marquelda Valdelamar

-- Este reporte incluye todas las polizas con saldo a 90 dias que no esten canceladas

DROP PROCEDURE "informix".sp_pr76d;
CREATE PROCEDURE "informix".sp_pr76d(
a_compania      CHAR(50),
a_agencia       CHAR(50),
a_fecha         DATE,
a_periodo       CHAR(7)
)RETURNING CHAR(20),      -- No_documento
		   CHAR(50),      -- Nombre del cliente
		   CHAR(50),      -- Direccion_1
		   CHAR(50),      -- Direccion_2
           DATE,          -- fecha_vence
		   DECIMAL(16,2), -- saldo
		   CHAR(50),      -- Nombre del Agente
		   DATE,          -- fecha
	 	   CHAR(50);      -- Nombre de la Compania
		  			  		         
DEFINE _no_poliza  		   CHAR(10);
DEFINE _cod_agente         CHAR(5);
DEFINE _cod_asegurado      CHAR(10);
DEFINE _cod_ramo           CHAR(3);
DEFINE _nombre_cliente     CHAR(50);
DEFINE _nombre_corredor    CHAR(50);
DEFINE _direccion1		   CHAR(50);
DEFINE _direccion2         CHAR(50);
DEFINE _no_documento       CHAR(20);
DEFINE _cod_cliente        CHAR(10);
DEFINE _saldo              DECIMAL(16,2);
DEFINE _fecha_vence        DATE;   
DEFINE _fecha_ult_pago     DATE;   
DEFINE v_compania_nombre   CHAR(50);
DEFINE _monto_90           DECIMAL(16,2);
DEFINE _estatus            CHAR(1);

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania); 

--Ramo de Salud
SELECT cod_ramo
  INTO _cod_ramo
  FROM prdramo
 WHERE ramo_sis = 5;

SET ISOLATION TO DIRTY READ;

-- Morosidad de Cartera

CALL sp_cob03(
a_compania,
a_agencia,
a_fecha
);

-- Seleccion de las polizas con saldo a 90 dias
FOREACH
 SELECT no_poliza,
		cod_agente,
		saldo,
        monto_90,
		doc_poliza,
		estatus,
		fecha_ult_pago
   INTO _no_poliza,
		_cod_agente,
		_saldo,
	    _monto_90,
		_no_documento,
		_estatus,
		_fecha_ult_pago
   FROM tmp_moros
  WHERE cod_ramo = _cod_ramo
    AND	monto_90 > 0 
    AND saldo > 0
   	AND estatus <> 'C'
	AND vigencia_final >= a_fecha

	LET _fecha_vence = (_fecha_ult_pago + 30);

	    -- Asegurados de la Poliza
	FOREACH
	 SELECT cod_asegurado
	   INTO	_cod_asegurado
	   FROM emipouni
	  WHERE no_poliza = _no_poliza

		-- Datos del Cliente
	SELECT nombre, 
	       direccion_1, 
	       direccion_2
	  INTO _nombre_cliente,
	       _direccion1,
		   _direccion2
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

      -- Agente de la Poliza  		 
  		 
	  	 SELECT nombre
	  	   INTO _nombre_corredor
	  	   FROM agtagent
	  	  WHERE cod_agente = _cod_agente;

	  -- Acreedor Hipotecario  
    	 SELECT nombre
	  	   INTO _nombre_corredor
	  	   FROM agtagent
	  	  WHERE cod_agente = _cod_agente;

		RETURN 
		 _no_documento,
		 _nombre_cliente,
		 _direccion1,
		 _direccion2,
		 _fecha_vence,
		 _saldo,
		 _nombre_corredor,
		 a_fecha,
	 	 v_compania_nombre
		 WITH RESUME;
	   END FOREACH;
	END FOREACH;
END PROCEDURE;



