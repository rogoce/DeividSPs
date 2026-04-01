-- POLIZAS REHABILITADAS-- 
--
-- Creado    : 19/02/2003 - Autor: Marquelda Valdelamar
-- Modificado: 20/02/2003 - Autor: Marquelda Valdelamar.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro108;

CREATE PROCEDURE "informix".sp_pro108(
a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7) 
)
RETURNING	CHAR(20),	   --Poliza
			CHAR(100),	   --Asegurado
			DATE,		   --Fecha de la rehabilitacion
			DECIMAL(16,2), --monto de la rehabilitacion
			CHAR(7),       --periodo
			CHAR(3),       --codigo de ramo
			CHAR(50),      --descripcion del ramo
			CHAR(10),      --factura
			CHAR(50);      --Nombre Compania
	       
DEFINE _no_documento        	CHAR(20);
DEFINE _nombre_asegurado    	CHAR(50);
DEFINE _cod_cliente             CHAR(10);
DEFINE _fecha_rehabilitacion	DATE;
DEFINE _prima_suscrita			DECIMAL(16,2);
DEFINE v_nombre_cia             CHAR(50);
DEFINE _nombre_ramo             CHAR(50);
DEFINE _cod_ramo				CHAR(3);
DEFINE _periodo					CHAR(7);
DEFINE _no_poliza               CHAR(10);
DEFINE _no_factura              CHAR(10);

-- Nombre de la Compania
LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_rehabi(
		no_documento    CHAR(20),	
		asegurado       CHAR(50),
		fecha           DATE,
		monto           DEC(16,2),
		periodo         CHAR(7),  
		cod_ramo        CHAR(3),
		nombre_ramo     CHAR(50),
		no_factura      CHAR(10)
		) WITH NO LOG;

FOREACH
 SELECT no_documento,
	    fecha_emision,
	    prima_suscrita, 
		periodo,
		no_poliza,
		no_factura
   INTO _no_documento,
        _fecha_rehabilitacion,
        _prima_suscrita,
		_periodo,
		_no_poliza,
		_no_factura
   FROM endedmae
  WHERE cod_endomov    = '003' 			--Rehabilitacion de poliza
    AND cod_compania   = a_compania
    AND periodo       >= a_periodo1
	AND periodo       <= a_periodo2
	AND actualizado    = 1
	AND prima_suscrita <> 0

	 SELECT cod_contratante,
	        cod_ramo
	   INTO _cod_cliente,
	        _cod_ramo
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

	 SELECT nombre
	   INTO _nombre_asegurado
	   FROM cliclien
	  WHERE cod_cliente = _cod_cliente;

	 SELECT nombre
	   INTO _nombre_ramo
	   FROM prdramo 
	  WHERE cod_ramo = _cod_ramo;

	 INSERT INTO tmp_rehabi(
	   			 cod_ramo,
				 no_documento,
				 asegurado,
				 fecha,
				 monto,
				 periodo,
				 nombre_ramo,
				 no_factura
				 )
		  VALUES(_cod_ramo,
		        _no_documento,
			    _nombre_asegurado,
			    _fecha_rehabilitacion,
			    _prima_suscrita,
			    _periodo,
			    _nombre_ramo,
			    _no_factura);

END FOREACH

 FOREACH
  SELECT cod_ramo, 
  		 no_documento,
		 asegurado,
		 fecha,
		 monto,
		 periodo,
		 nombre_ramo,
		 no_factura
   INTO _cod_ramo,
        _no_documento,
        _nombre_asegurado,
        _fecha_rehabilitacion,
        _prima_suscrita,
		_periodo,
		_nombre_ramo,
		_no_factura
   FROM tmp_rehabi
  ORDER BY cod_ramo, periodo, fecha

	RETURN _no_documento, 
		   _nombre_asegurado,
		   _fecha_rehabilitacion, 
		   _prima_suscrita, 
	       _periodo,
		   _cod_ramo,
		   _nombre_ramo,
		   _no_factura,
		   v_nombre_cia
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_rehabi;

END PROCEDURE

