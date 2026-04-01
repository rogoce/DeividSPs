-- Procedimiento para actualizar los valores de las primas en endedcob
-- Creado    : 19/03/2014 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
-- copia del sp_proe01

DROP PROCEDURE sp_end01;
CREATE PROCEDURE "informix".sp_end01(a_poliza CHAR(10), a_unidad CHAR(5), a_cia CHAR(3), a_endoso char(5))
			RETURNING   SMALLINT			 -- _error
						

DEFINE _error		  INTEGER;
DEFINE ls_cobertura   CHAR(5);	
DEFINE ls_unidad   	  CHAR(5);	
DEFINE ls_producto    CHAR(5);	
DEFINE ls_ramo        CHAR(3);

DEFINE ld_factor_vigencia   DECIMAL(9,6);  --10,4
DEFINE ld_prima             DECIMAL(16,2);
DEFINE ld_prima_resta		DECIMAL(16,2);
DEFINE ld_prima_anual		DECIMAL(16,2);
DEFINE ld_descuento			DECIMAL(16,2);
DEFINE ld_recargo			DECIMAL(16,2);
DEFINE ld_recargo_dep		DECIMAL(16,2);
DEFINE ld_prima_neta		DECIMAL(16,2);
DEFINE ld_prima_dep         DECIMAL(16,2);

DEFINE li_acepta_desc    	INTEGER;
DEFINE li_tipo_ramo			SMALLINT;
define _linea_rapida        smallint;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe01.trc";      
--TRACE ON;                                                                     

LET ld_factor_vigencia = 1.000000;
let _linea_rapida = 0;

SELECT factor_vigencia
  INTO ld_factor_vigencia
  FROM endedmae 
 WHERE no_poliza = a_poliza
   and no_endoso = a_endoso;
   
SELECT cod_ramo
  INTO ls_ramo
  FROM emipomae 
 WHERE no_poliza = a_poliza;

Select prdramo.ramo_sis 
  Into li_tipo_ramo
  From prdramo
 Where prdramo.cod_ramo = ls_ramo;

if _linea_rapida = 1 and ls_ramo = '020' then
	return 0;
end if

FOREACH
	SELECT no_unidad,
		   cod_producto
	  INTO ls_unidad,
	  	   ls_producto
	  FROM endeduni 
	 WHERE no_poliza = a_poliza
	   AND no_unidad MATCHES a_unidad
	   and no_endoso = a_endoso

    FOREACH
    	SELECT endedcob.cod_cobertura, endedcob.prima_anual 
    	  INTO ls_cobertura, ld_prima_anual
		  FROM endedcob
		 WHERE endedcob.no_poliza = a_poliza
		   AND endedcob.no_unidad = ls_unidad
		   and endedcob.no_endoso = a_endoso
      		
		SELECT prdcobpd.acepta_desc
		  INTO li_acepta_desc
		  FROM prdcobpd
		 WHERE prdcobpd.cod_producto  = ls_producto
		   AND prdcobpd.cod_cobertura = ls_cobertura;
		   		
		IF li_acepta_desc IS NULL THEN
		   LET li_acepta_desc = 0;
		END IF

        let ld_prima_dep = 0;

		If li_tipo_ramo = 5 Then   --> Amado cuando se hace un recargo a una unidad se tiene que aplicar solo a la prima del asegurado y no de toda la familia 17/11/2010
		    If ld_prima_anual <> 0.00 Then
				CALL sp_proe54(a_poliza, ls_unidad) RETURNING ld_prima_dep;
				LET ld_prima_dep = ld_factor_vigencia * ld_prima_dep;
			End if
	    End If
				
		LET ld_prima = ld_factor_vigencia * ld_prima_anual;
		
		LET ld_prima_resta = ld_prima - ld_prima_dep; --> Amado 17/11/2010
				
	    -- Buscar Descuento
		LET ld_descuento = 0.00;
		If li_acepta_desc = 1 Then
		   CALL sp_proe21(a_poliza, ls_unidad, ld_prima) RETURNING ld_descuento;
		End If

		If ld_descuento > 0 Then
		   LET ld_prima_resta = ld_prima - ld_descuento;
		End If

		-- Buscar Recargo
		LET ld_recargo = 0.00;
		If li_acepta_desc = 1 Then
		   CALL sp_proe22(a_poliza, ls_unidad, ld_prima_resta) RETURNING ld_recargo;
		End If

		-- Buscar Recargo por dependiente
		LET ld_recargo_dep = 0.00;
		IF ld_prima_anual <> 0.00 THEN
			CALL sp_proe53(a_poliza, ls_unidad) RETURNING ld_recargo_dep;
			LET ld_recargo = ld_recargo + ld_recargo_dep;
		END IF

		
		-- Calcular Prima Neta
		LET ld_prima_neta = ld_prima + ld_recargo - ld_descuento;

		Update endedcob
		   Set prima 			= ld_prima,
			   descuento		= ld_descuento,
			   recargo			= ld_recargo,
			   prima_neta		= ld_prima_neta
		 Where no_poliza 		= a_poliza
		   And no_unidad 		= ls_unidad
		   And cod_cobertura	= ls_cobertura
		   and no_endoso        = a_endoso;
	END FOREACH
	CALL sp_end02(a_poliza, ls_unidad, a_cia, a_endoso) RETURNING _error;
END FOREACH
RETURN 0;
END
END PROCEDURE;