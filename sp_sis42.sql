-- Procedimiento que Actualiza el Endoso

-- Creado: 29/10/2003 - Autor: Amado Perez Mendoza 


{DROP PROCEDURE sp_demetrio;			

CREATE PROCEDURE sp_demetrio(
a_no_poliza		CHAR(10), 
a_no_endoso		CHAR(5)
) 
--} 
--{
DROP PROCEDURE sp_sis42;			

CREATE PROCEDURE sp_sis42(
a_no_poliza		CHAR(10), 
a_no_endoso		CHAR(5)
)
--}
RETURNING SMALLINT,
          CHAR(10),
          CHAR(100);

DEFINE _no_factura      CHAR(10);
DEFINE _mensaje         CHAR(100);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _cod_endomov		CHAR(3);
DEFINE _tipo_mov		SMALLINT;
DEFINE _periodo_par     CHAR(7);
DEFINE _periodo_end     CHAR(7);
DEFINE _cod_tipocan     CHAR(3);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final	DATE;
DEFINE _prima_bruta     DEC(16,2);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_neta      DEC(16,2);
DEFINE _descuento       DEC(16,2);
DEFINE _recargo         DEC(16,2);
DEFINE _prima           DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);
DEFINE _no_fac_orig,nvo_no_pol     CHAR(10);
DEFINE _error			SMALLINT;
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(16,4);
DEFINE _cod_coasegur	CHAR(3);

DEFINE _prima_sus_sum	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);
DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);
DEFINE _no_endoso_ext	CHAR(5);
DEFINE _tiene_impuesto	SMALLINT;
DEFINE _no_endoso       CHAR(5);
DEFINE _user_added		CHAR(8);

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,'', 'Error al Actualizar el Endoso ...';         
END EXCEPTION           

-- Lectura de la Tabla de Endosos

--SET DEBUG FILE TO "sp_apm43.trc";
--trace on;

LET _no_fac_orig = NULL;
LET nvo_no_pol = a_no_poliza;
LET _no_endoso = a_no_endoso;

SELECT cod_compania,
	   cod_sucursal,
	   cod_endomov,
	   periodo,
	   vigencia_inic,
	   vigencia_final,
	   cod_tipocan,
	   prima_bruta,
	   impuesto,
	   prima_neta,
	   descuento,
	   recargo,
	   prima,
	   prima_suscrita,
	   prima_retenida,
	   tiene_impuesto,
	   user_added
  INTO _cod_compania,
	   _cod_sucursal,
	   _cod_endomov,
	   _periodo_end,
	   _vigencia_inic,
	   _vigencia_final,	
	   _cod_tipocan,
	   _prima_bruta,	
	   _impuesto,
	   _prima_neta,
	   _descuento,
	   _recargo,
	   _prima,
	   _prima_suscrita,
	   _prima_retenida,
	   _tiene_impuesto,
	   _user_added
  FROM endedmae
 WHERE no_poliza   = a_no_poliza
   AND no_endoso   = a_no_endoso
   AND actualizado = 1;


BEGIN

	DEFINE _cant_fact  INTEGER;

	-- Determina el Numero de Factura

 	LET _no_factura = sp_sis14(_cod_compania, _cod_sucursal, a_no_poliza); 

	SELECT COUNT(*)
	  INTO _cant_fact
	  FROM endedmae
	 WHERE no_factura  = _no_factura;

	IF _cant_fact IS NULL THEN
		LET _cant_fact = 0;
	END IF

	IF _cant_fact >= 1 THEN
		LET _mensaje = 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...';
		RETURN 1,'', _mensaje;
	END IF
	
	-- Actualizacion de los Valores del Endoso

	UPDATE endedmae
	   SET no_factura = _no_factura
	 WHERE no_poliza = a_no_poliza
	   AND no_endoso = a_no_endoso;

	-- Actualizacion de los Valores de la Poliza

    IF a_no_endoso = '00000' THEN
	   UPDATE emipomae
	      SET no_factura = _no_factura
	    WHERE no_poliza = a_no_poliza; 
	END IF

END 

--CALL sp_pro100(a_no_poliza, a_no_endoso);


LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _no_factura, _mensaje;

END

END PROCEDURE;

