-- Encabezado de los Estados de Cuenta por Poliza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob54;

CREATE PROCEDURE "informix".sp_cob54(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_cod_agente   CHAR(5),
a_periodo      CHAR(7),
a_fecha        DATE     
)RETURNING	CHAR(50),	-- nombre_cliente
			CHAR(100),	-- direccion1
			CHAR(100),  -- direccion2
			CHAR(20),   -- telefono1
			CHAR(20),	-- telefono2
			CHAR(10),   -- apartado
			CHAR(20),   -- no_documento
			DATE,       -- vigencia_inic
			DATE,       -- vigencia_final
			CHAR(50),	-- nombre_agente
			CHAR(50),   -- nombre_ramo
			CHAR(50),   -- nombre_subramo
			CHAR(3);    -- cod_agente
  	
DEFINE _nombre_cliente    CHAR(50);
DEFINE _direccion1        CHAR(100);
DEFINE _direccion2        CHAR(100);
DEFINE _telefono1         CHAR(20);
DEFINE _telefono2         CHAR(20);
DEFINE _apartado          CHAR(10);
DEFINE _no_documento      CHAR(20);
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final    DATE;
DEFINE _nombre_agente     CHAR(50);
DEFINE _nombre_ramo       CHAR(50);
DEFINE _nombre_subramo    CHAR(50);
DEFINE _cod_ramo		  CHAR(3);
DEFINE _cod_subramo		  CHAR(3);
DEFINE _no_poliza		  CHAR(10);
DEFINE _cod_cliente       CHAR(10);

-- Agente de la Poliza
	FOREACH
		SELECT no_poliza
		  INTO _no_poliza
		  FROM emipoagt
		 WHERE cod_agente = a_cod_agente

		SELECT nombre
		  INTO _nombre_agente
		  FROM agtagent
		WHERE  cod_agente = a_cod_agente;

	-- Datos de la Poliza
			SELECT vigencia_inic,
			        vigencia_final,
					cod_ramo,
					cod_subramo,
					cod_contratante,
					no_poliza,
					no_documento
			  INTO  _vigencia_inic,
					_vigencia_final,
					_cod_ramo,
					_cod_subramo,
					_cod_cliente,
					_no_poliza,
					_no_documento
			  FROM  emipomae
			 WHERE  no_poliza = _no_poliza;

	-- Datos del Cliente
		SELECT nombre,
		       direccion_1,
			   direccion_2,
			   telefono1,
			   telefono2,
			   apartado
		INTO   _nombre_cliente,
		       _direccion1,
			   _direccion2,
			   _telefono1,
			   _telefono2,
			   _apartado
		FROM   cliclien
		WHERE  cod_cliente = _cod_cliente;

	-- Ramo y Subramo
		SELECT nombre
		INTO   _nombre_ramo
		FROM   prdramo
		WHERE  cod_ramo = _cod_ramo;	

		SELECT nombre
		INTO   _nombre_subramo
		FROM   prdsubra
		WHERE  cod_ramo = _cod_ramo
		AND    cod_subramo = _cod_subramo;
END FOREACH
RETURN
   _nombre_cliente,
   _direccion1,
   _direccion2,
   _telefono1,
   _telefono2,
   _apartado,
   _no_documento,
   _vigencia_inic,
   _vigencia_final,
   _nombre_agente,
   _nombre_ramo,
   _nombre_subramo,
   a_cod_agente
   WITH RESUME;
END PROCEDURE;
