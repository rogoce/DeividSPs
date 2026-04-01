-- Procedimiento de Cotizacion de Reparacion
-- a una Fecha Dada
-- 
-- Creado    : 17/11/2003 - Autor: Amado Perez Mendoza 
-- Modificado: 17/11/2003 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec22b1;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec22b1(a_compania CHAR(3), a_agencia CHAR(3), a_numrecla CHAR(18), a_tercero CHAR(10) DEFAULT NULL) 
			RETURNING   CHAR(50),
						CHAR(100),
						CHAR(100),
						CHAR(18),
						CHAR(50),
						CHAR(50),
						CHAR(10),
						INT;


DEFINE v_taller           CHAR(100);
DEFINE v_marca		      CHAR(50);
DEFINE v_asegurado        CHAR(100);
DEFINE v_reclamante       CHAR(100);
DEFINE v_reclamo          CHAR(18);
DEFINE v_ajustador		  CHAR(50);
DEFINE v_fecha_cotiza	  DATE;
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_placa            CHAR(10);
DEFINE v_ano_auto         INT;
DEFINE v_modelo           CHAR(50);

DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _cod_reclamante	 CHAR(10);
DEFINE _cod_ajustador    CHAR(3);
DEFINE _no_motor         CHAR(30);
DEFINE _cod_proveedor    CHAR(10);
DEFINE _cod_marca        CHAR(5);
DEFINE _cod_modelo       CHAR(5);
DEFINE _user_added       CHAR(8);
DEFINE _cod_tipopago     CHAR(3);
DEFINE _cod_tercero      CHAR(10);		  

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania


FOREACH	

-- Lectura de Reclamos

SELECT numrecla,
	   no_poliza,
	   cod_reclamante,
	   no_motor,
	   ajust_interno,
	   no_reclamo
  INTO v_reclamo,
       _no_poliza,
	   _cod_reclamante,
	   _no_motor,
	   _cod_ajustador,
	   _no_reclamo
  FROM recrcmae
 WHERE numrecla = a_numrecla
   AND cod_compania = a_compania
   AND actualizado = 1
  	    
-- Lectura de Polizas

SELECT cod_contratante
  INTO _cod_cliente
  FROM emipomae
 WHERE no_poliza = _no_poliza;

-- Lectura de Cliente

SELECT nombre
  INTO v_asegurado
  FROM cliclien
 WHERE cod_cliente = _cod_cliente;
 			   
IF v_asegurado IS NULL THEN
	LET v_asegurado = " ";
END IF 

-- Lectura de Reclamante

IF a_tercero IS NULL THEN
	SELECT nombre
	  INTO v_reclamante
	  FROM cliclien
	 WHERE cod_cliente = _cod_reclamante;

	SELECT cod_marca,
	       cod_modelo,
	       placa,
		   ano_auto
	  INTO _cod_marca,
	       _cod_modelo,
		   v_placa,
		   v_ano_auto
	  FROM emivehic
	 WHERE no_motor = _no_motor;
ELSE
	SELECT nombre
	  INTO v_reclamante
	  FROM cliclien
	 WHERE cod_cliente = a_tercero;

	SELECT cod_marca,
	       cod_modelo,
	       placa,
		   ano_auto
	  INTO _cod_marca,
	       _cod_modelo,
		   v_placa,
		   v_ano_auto
	  FROM recterce
	 WHERE no_reclamo = _no_reclamo
	   AND cod_tercero = a_tercero;
END IF

-- Lectura de Ajustador

SELECT nombre
  INTO v_ajustador
  FROM recajust
 WHERE cod_ajustador = _cod_ajustador;

SELECT nombre
  INTO v_marca
  FROM emimarca
 WHERE cod_marca = _cod_marca;

SELECT nombre 
  INTO v_modelo
  FROM emimodel
 WHERE cod_marca = _cod_marca
   AND cod_modelo = _cod_modelo;

RETURN v_marca,		    
 	   v_asegurado,      
	   v_reclamante,     
	   v_reclamo,        
	   v_ajustador,		
	   v_modelo,
	   v_placa,
	   v_ano_auto
	   WITH RESUME; 
		     	
END FOREACH


END PROCEDURE