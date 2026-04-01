-- Procedimiento para traer polizas de auto y salud
--
-- Creado    : 07/05/2003 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 30/05/2003 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro115d;

CREATE PROCEDURE "informix".sp_pro115d(a_documento CHAR(20), a_opcion CHAR(1))
  RETURNING CHAR(10),
			CHAR(20),
			CHAR(100),
            CHAR(30),  
   			CHAR(5);

  DEFINE v_retorno		CHAR(10);
  DEFINE v_error        INTEGER;
  DEFINE _no_documento  CHAR(20);
  DEFINE _nombre, _nombre_par, _conyuge, _hijo1, _hijo2, _hijo3, _hijo4  CHAR(100);
  DEFINE _placa         CHAR(10);
  DEFINE _no_motor      CHAR(30);
  DEFINE _cod_sucursal, _cod_parentesco, _cod_ramo, _cod_subramo CHAR(3);
  DEFINE _vigencia_inic, _vigencia_final DATE;
  DEFINE _no_unidad     CHAR(5);
  DEFINE _cant          SMALLINT;
  DEFINE _limite_1, _limite_2, _no_poliza CHAR(10);
  DEFINE _cod_asegurado CHAR(10);

  SET ISOLATION TO DIRTY READ;

	CREATE TEMP TABLE temp_perfil
	     (no_poliza      	CHAR(10),
	      no_documento   	CHAR(20),
		  nombre            CHAR(100),
		  no_motor          CHAR(30),
		  no_unidad         CHAR(5),
	      PRIMARY KEY(no_poliza,no_unidad))
	      WITH NO LOG;



--SET DEBUG FILE TO "sp_pro115b.trc"; 
--trace on;

LET v_retorno = 'ERROR';
LET _nombre_par = '';
LET _conyuge = '';
LET _hijo1 = '';
LET _hijo2 = '';
LET _hijo3 = '';
LET _hijo4 = '';
LET a_documento = a_documento;

IF a_opcion = "1" THEN
	FOREACH	
		SELECT x.no_documento,
		       y.nombre,
		       t.placa,
		       u.no_motor,
		       x.cod_sucursal,
		       z.no_unidad,
		       x.no_poliza 
		  INTO _no_documento,
		       _nombre,
		       _placa,
		       _no_motor,
		       _cod_sucursal,
			   _no_unidad,
			   _no_poliza
		  FROM emivehic t, endmoaut u, endedmae v, emipomae x, cliclien y, emiauto z 
		 WHERE x.no_poliza = v.no_poliza  
		   AND y.cod_cliente = x.cod_contratante
		   AND (v.cod_endomov = '004' OR (v.cod_endomov = '011' AND x.nueva_renov = 'N'))  
		   AND z.no_poliza = x.no_poliza 
		   AND z.uso_auto = 'P'
		   AND u.no_motor = z.no_motor 
		   AND t.no_motor = u.no_motor 
		   AND x.cod_ramo = '002' 
		   AND (x.cod_subramo = '001' or  x.cod_subramo = '012')
		   AND x.actualizado = 1
		   AND x.no_documento = a_documento
 --		   AND x.sucursal_origen NOT IN ('051','023','056') 

		BEGIN
			ON EXCEPTION SET v_error
			END EXCEPTION
		  	INSERT INTO temp_perfil(
			   no_poliza,    
			   no_documento, 
			   nombre,       
			   no_motor,     
			   no_unidad    
			   )
		  	   VALUES(
			   _no_poliza,
		  	   _no_documento,
		  	   _nombre,
		  	   _no_motor,
			   _no_unidad
		  	   );
		END

	END FOREACH;
ELSE
-- Panama 1, Panama 2, Global, Colectivo Especial, otros especiales

	FOREACH
	 SELECT	no_poliza,
	        vigencia_final
      INTO	_no_poliza,
	        _vigencia_final
	   FROM	emipomae
	  WHERE no_documento       = a_documento
		AND actualizado        = 1			   	   
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH

	FOREACH	
		SELECT x.no_documento,
		       v.vigencia_inic,
		       v.no_unidad,
			   v.cod_asegurado
		  INTO _no_documento,
			   _vigencia_inic,
			   _no_unidad,
			   _cod_asegurado
	 	  FROM emipouni v, emipomae x, emicarnet y, prdprod z 
		 WHERE v.no_poliza = x.no_poliza 
		   AND v.activo = 1 
	       AND x.actualizado = 1  
	       AND (x.cod_ramo = '018' or a_documento in ('1620-00009-01'))
	       AND z.cod_producto = v.cod_producto
           AND z.cod_carnet = y.cod_carnet
		   AND x.no_poliza = _no_poliza

		SELECT nombre
		  INTO _nombre
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		BEGIN
			ON EXCEPTION SET v_error
			END EXCEPTION
		  	INSERT INTO temp_perfil(
			   no_poliza,    
			   no_documento, 
			   nombre,       
			   no_motor,     
			   no_unidad    
			   )
		  	   VALUES(
			   _no_poliza,
		  	   _no_documento,
		  	   _nombre,
		  	   '',
			   _no_unidad
		  	   );
		END
	END FOREACH
END IF

 	FOREACH WITH HOLD
		SELECT no_poliza,    
		       no_documento, 
		       nombre,       
		       no_motor,     
		       no_unidad    
		  INTO _no_poliza,
		       _no_documento,
		       _nombre,
			   _no_motor,
			   _no_unidad
		 FROM temp_perfil

		RETURN 	_no_poliza,
	            _no_documento,
		  	    _nombre,
				_no_motor,
			    _no_unidad
				WITH RESUME;

	 END FOREACH
DROP TABLE temp_perfil;
END PROCEDURE

