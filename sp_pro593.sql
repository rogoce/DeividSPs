-- Procedimiento para el reporte de los clientes bloqueados por la siniestralidad
--
-- creado: 10/08/2009 - Autor: Amado Perez M.

DROP PROCEDURE sp_pro593;
CREATE PROCEDURE "informix".sp_pro593(a_periodo1 CHAR(7), a_periodo2 CHAR(7))
	RETURNING CHAR(10) as cod_ramo, 
	          VARCHAR(50) as nombre_ramo, 
			  CHAR(20) as no_documento, 
			  VARCHAR(100) as asegurado,
			  DATE as vigencia_inic,
			  DATE as vigencia_fin,
			  DATE as fecha_emision,
			  VARCHAR(50) as desc_grupo,
			  DEC(16,2) as suma_asegurada,
			  DEC(16,2) as prima_suscrita,
			  VARCHAR(31) as filtro,
			  DEC(16,2) as prima_bruta,
			  VARCHAR(50) as tipo_coaseguro,
			  VARCHAR(50) as zona,
			  CHAR(20) as reemplaza_poliza;  

DEFINE _no_poliza            CHAR(10);
DEFINE _cod_ramo             CHAR(3);
DEFINE _ramo                 VARCHAR(50);
DEFINE _no_documento         CHAR(20);
DEFINE _cod_contratante      CHAR(10);
DEFINE _nombre               VARCHAR(100);
DEFINE _vigencia_inic        DATE;
DEFINE _vigencia_final       DATE;
DEFINE _fecha_suscripcion    DATE;
DEFINE _cod_grupo            CHAR(3);
DEFINE _grupo                VARCHAR(50);
DEFINE _suma_asegurada       DECIMAL(16,2);
DEFINE _prima_suscrita       DECIMAL(16,2);
DEFINE _prima_bruta          DECIMAL(16,2);
DEFINE _cod_tipoprod         CHAR(3);
DEFINE _reemplaza_poliza     CHAR(20);
DEFINE _tipo_coaseguro       VARCHAR(50); 
DEFINE _cod_agente           CHAR(5); 
DEFINE _cod_vendedor         CHAR(3);
DEFINE _zona                 VARCHAR(50);
DEFINE _fecha_inicio         DATE;
DEFINE _fecha_fin            DATE;

SET ISOLATION TO DIRTY READ;

let _fecha_inicio = sp_sis36b(a_periodo1);
let _fecha_fin    = sp_sis36(a_periodo2);

FOREACH
	SELECT no_poliza,
	       cod_ramo,
	       no_documento,
		   cod_contratante,
           vigencia_inic,
           vigencia_final,			
           fecha_suscripcion,
           cod_grupo,
           suma_asegurada,
           prima_suscrita,
           prima_bruta,
           cod_tipoprod, 
           reemplaza_poliza		   
      INTO _no_poliza,
	       _cod_ramo,
	       _no_documento,
		   _cod_contratante,
           _vigencia_inic,
           _vigencia_final,			
           _fecha_suscripcion,
           _cod_grupo,
           _suma_asegurada,
           _prima_suscrita,
           _prima_bruta,
           _cod_tipoprod, 
           _reemplaza_poliza
      FROM emipomae
     WHERE estatus_poliza = 1
	   AND actualizado = 1
       AND reemplaza_poliza is not null
	   AND trim(reemplaza_poliza) <> ""
       AND fecha_suscripcion >= _fecha_inicio
       AND fecha_suscripcion <= _fecha_fin	
    ORDER BY cod_ramo, no_documento	   

    SELECT nombre
      INTO _ramo
      FROM prdramo
     WHERE cod_ramo = _cod_ramo;	 

    SELECT nombre		 
	  INTO _nombre
	  FROM cliclien
     WHERE cod_cliente = _cod_contratante;
	 
    SELECT nombre		 
	  INTO _grupo
	  FROM cligrupo
     WHERE cod_grupo = _cod_grupo;
	 
    SELECT nombre		 
	  INTO _tipo_coaseguro
	  FROM emitipro
     WHERE cod_tipoprod = _cod_tipoprod;
	
    SELECT FIRST 1 cod_agente
      INTO _cod_agente
      FROM emipoagt
     WHERE no_poliza = _no_poliza;
 
    SELECT cod_vendedor
      INTO _cod_vendedor
      FROM agtagent
     WHERE cod_agente = _cod_agente;

	SELECT nombre
      INTO _zona
      FROM agtvende
     WHERE cod_vendedor = _cod_vendedor;	  
      
	  RETURN _cod_ramo,
	         _ramo,
			 _no_documento,
	         _nombre,
			 _vigencia_inic,
			 _vigencia_final,
			 _fecha_suscripcion,
			 _grupo,
			 _suma_asegurada,
			 _prima_suscrita,
			 "DESDE: " || a_periodo1 || " // HASTA " || a_periodo2,
			 _prima_bruta,
			 _tipo_coaseguro,
			 _zona,
			 _reemplaza_poliza with resume;
END FOREACH

END PROCEDURE
