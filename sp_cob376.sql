-- Procedimiento para el reporte de las gestiones de plan de pago por gestion
-- Creado    : 29/05/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cob376;

CREATE PROCEDURE "informix".sp_cob376(a_compania     CHAR(3),
								   a_desde  DATE,
								   a_hasta DATE)
RETURNING CHAR(20),                --No documento
          CHAR(100),               --Nombre cliente
		  DATE,                    --Fecha cambio
          DECIMAL(16,2),           --Saldo 
		  CHAR(10),                --Factura,
		  CHAR(3),                 --Cod_campana
		  CHAR(50),                --Nombre campana
          DATE,                    --Desde
		  DATE;                    --Hasta
		  
		  
DEFINE _no_documento    CHAR(20);
DEFINE _fecha_cambio    DATE;
DEFINE _saldo           DECIMAL(16,2);
DEFINE _no_factura      CHAR(10);
DEFINE _cod_campana     CHAR(3);
DEFINE _nombre_campa    CHAR(50);
DEFINE _no_poliza       CHAR(10); 
DEFINE _cod_contratante CHAR(10);
DEFINE _nombre_cliente  CHAR(100);

FOREACH

	SELECT no_documento,
	       no_poliza,
		   fecha_cambio,
		   saldo,
		   no_factura,
		   cod_campana
	  INTO _no_documento,
	       _no_poliza,
		   _fecha_cambio,
		   _saldo,
		   _no_factura,
		   _cod_campana
	FROM cobcampl
	WHERE cod_campana <> ''
	AND fecha_cambio BETWEEN date(a_desde) and date(a_hasta)
	AND actualizado = 1
	
	SELECT nombre 
	  INTO _nombre_campa
	  FROM cobcampa
	 WHERE cod_campana = _cod_campana;
	 
	SELECT cod_contratante 
	  INTO _cod_contratante
	  FROM emipomae
     WHERE no_poliza = _no_poliza;
	 
	 SELECT nombre 
	   INTO _nombre_cliente
	   FROM cliclien
      WHERE cod_cliente = _cod_contratante;
	  
	  return _no_documento,
	         _nombre_cliente,
			 _fecha_cambio,
			 _saldo,
			 _no_factura,
			 _cod_campana,
			 _nombre_campa,
			 a_desde,
			 a_hasta with resume;

END FOREACH

END PROCEDURE;