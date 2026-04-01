-- Procedimiento que Carga la Siniestralidad Por Poliza en un Periodo 
-- 
-- Creado    : 25/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/01/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_endoso;

CREATE PROCEDURE "informix".sp_endoso()	RETURNING CHAR(10),CHAR(05),CHAR(03),DEC(16,2),DEC(16,2);

DEFINE _no_poliza,y_no_poliza,_no_reclamo    CHAR(10);
DEFINE _cod_ramo,_cod_subramo,v_cod_tipoprod CHAR(3);
DEFINE _no_endoso,y_no_endoso,y_no_unidad    CHAR(5);
DEFINE _cod_sucursal CHAR(3);
DEFINE v_filtros     CHAR(255);
DEFINE _prima_suscrita,v_prima_suscrita,z_prima_suscrita,p_prima,a_prima,
       b_prima  DECIMAL(16,2);
DEFINE cont     SMALLINT;

LET z_prima_suscrita = 0;
LET p_prima = 0;
LET cont = 0;
--AND a.no_poliza >= "81905" 
-- 	AND a.no_poliza <= "81945" 

SET ISOLATION TO DIRTY READ;
FOREACH
 SELECT a.no_poliza,a.no_endoso,a.prima_suscrita
   INTO	_no_poliza,_no_endoso,v_prima_suscrita
   FROM endedmae a,emipomae b
  WHERE a.cod_compania = "001"
    AND a.actualizado  = 1
    AND a.periodo     >= "2000-12"
    AND a.periodo     <= "2000-12"
   	AND a.no_poliza = b.no_poliza
   	AND b.cod_ramo = "002"
  ORDER BY a.no_poliza

  LET cont = 0;
 
 FOREACH
    SELECT prima_suscrita
      INTO _prima_suscrita
      FROM endeduni
     WHERE no_poliza = _no_poliza
       AND no_endoso = _no_endoso
	LET z_prima_suscrita = z_prima_suscrita + _prima_suscrita;
	LET cont = cont + 1;

 END FOREACH
   
   IF v_prima_suscrita <> z_prima_suscrita THEN
         FOREACH
		    SELECT SUM(prima),no_poliza,no_endoso,no_unidad
			       INTO p_prima,y_no_poliza,y_no_endoso,y_no_unidad
			       FROM emifacon
				  WHERE no_poliza = _no_poliza
				    AND no_endoso = _no_endoso
                  GROUP BY no_poliza,no_endoso,no_unidad
					 
		  
		{  	 UPDATE endeduni
		        SET prima_suscrita = p_prima
		      WHERE no_poliza = y_no_poliza
		        AND no_endoso = y_no_endoso	
                AND no_unidad = y_no_unidad;} 
 

         -- RETURN _no_poliza,_no_endoso,y_no_unidad,v_prima_suscrita,z_prima_suscrita,p_prima
         --         WITH RESUME;

		  END FOREACH  
		  LET a_prima = v_prima_suscrita - z_prima_suscrita;
		  LET b_prima = z_prima_suscrita - v_prima_suscrita;
          
		  IF (a_prima > 0.02 OR b_prima > 0.02) THEN 
		      				 
		       SELECT cod_tipoprod
		         INTO v_cod_tipoprod
		         FROM emipomae
		        WHERE no_poliza = _no_poliza;
		          
		  RETURN _no_poliza,_no_endoso,v_cod_tipoprod,v_prima_suscrita,z_prima_suscrita
                 WITH RESUME;
		  END IF 	  
		  LET z_prima_suscrita = 0;
	      LET p_prima = 0;
	   
   END IF
   LET z_prima_suscrita = 0;
   LET v_prima_suscrita = 0; 

END FOREACH

 
END PROCEDURE;
