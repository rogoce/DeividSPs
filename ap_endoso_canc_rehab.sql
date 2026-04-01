   DROP procedure ap_endoso_canc_rehab;
   CREATE procedure "informix".ap_endoso_canc_rehab()
   RETURNING CHAR(20) as no_documento,
			 CHAR(10) as no_factura,
             CHAR(10) as no_poliza,
			 CHAR(5) as no_endoso,
			 DATE as vigencia_inic,
			 DATE as vigencia_final,
			 DATE as vigencia_inic_pol,
			 DATE as vigencia_final_pol,
			 CHAR(3) as cod_tipocalc,
			 VARCHAR(50) as tipocal,
			 CHAR(7) as periodo,
			 CHAR(3) as cod_ramo,
			 VARCHAR(50) as ramo, 
			 CHAR(3) as cod_subramo,
			 VARCHAR(50) as subramo,
			 CHAR(3) as cod_endomov,
			 VARCHAR(50) as endomov,
			 DECIMAL(9,6) as factor_vigencia,
			 DECIMAL(16,2) as prima_neta, 
			 DECIMAL(16,2) as prima_suscrita,
			 DATE as fecha_emision,
			 CHAR(8) as user_added;
   
--------------------------------------------
--  AMADO P 21-02-2025
--------------------------------------------

DEFINE _no_documento  				CHAR(20);
DEFINE _cod_ramo,_cod_subramo, _cod_tipocalc, _cod_endomov	CHAR(3);
DEFINE v_desc_ramo        			VARCHAR(50); 
DEFINE v_desc_subramo     			VARCHAR(50);
DEFINE _no_poliza         			CHAR(10);
DEFINE _no_endoso         			char(5);
DEFINE _prima_suscrita,_prima_neta  DECIMAL(16,2);
DEFINE _vigencia_inic, _vigencia_final, _vigencia_inic_pol, _vigencia_final_pol, _fecha_emision DATE;
DEFINE _periodo						CHAR(7);
DEFINE _user_added					CHAR(8);
DEFINE _factor_vigencia				DECIMAL(9,6);
DEFINE _tipocal						VARCHAR(50);
DEFINE _endomov						VARCHAR(50);
DEFINE _no_factura                  CHAR(10);

LET v_desc_subramo   = NULL;
LET _prima_suscrita  = 0;
LET _prima_neta  = 0;

SET ISOLATION TO DIRTY READ;

FOREACH
       SELECT no_documento,
	          no_factura,
	          no_poliza,
			  no_endoso,
			  vigencia_inic,
			  vigencia_final,
			  vigencia_inic_pol,
			  vigencia_final_pol,
			  cod_tipocalc,
			  periodo,
			  cod_endomov,
			  factor_vigencia, 
			  prima_neta, 
			  prima_suscrita, 
			  fecha_emision, 
			  user_added
         INTO _no_documento,
		      _no_factura,
	          _no_poliza,
			  _no_endoso,
			  _vigencia_inic,
			  _vigencia_final,
			  _vigencia_inic_pol,
			  _vigencia_final_pol,
			  _cod_tipocalc,
			  _periodo,
			  _cod_endomov,
			  _factor_vigencia, 
			  _prima_neta, 
			  _prima_suscrita, 
			  _fecha_emision, 
			  _user_added
         FROM endedmae
		WHERE periodo between '2024-01' and '2024-12'
		  AND cod_endomov in ('002','003')
		  AND cod_tipocalc <> '001'
		  AND actualizado = 1
	 ORDER BY no_documento, no_poliza, no_endoso
	 
	   SELECT cod_ramo,
	          cod_subramo
		 INTO _cod_ramo,
		      _cod_subramo
		 FROM emipomae
		WHERE no_poliza = _no_poliza;

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = _cod_ramo;

       SELECT nombre
         INTO v_desc_subramo
         FROM prdsubra
        WHERE cod_ramo    = _cod_ramo
          AND cod_subramo = _cod_subramo;
		  
	   SELECT nombre
         INTO _endomov
         FROM endtimov
        WHERE cod_endomov = _cod_endomov;		 
		
	   SELECT nombre
         INTO _tipocal
         FROM emitical
        WHERE cod_tipocalc = _cod_tipocalc;		 
		
       RETURN _no_documento,
	          _no_factura,
	          _no_poliza,
			  _no_endoso,
			  _vigencia_inic,
			  _vigencia_final,
			  _vigencia_inic_pol,
			  _vigencia_final_pol,
			  _cod_tipocalc,
			  _tipocal,
			  _periodo,
			  _cod_ramo,
			  v_desc_ramo,
			  _cod_subramo,
			  v_desc_subramo,
			  _cod_endomov,
			  _endomov,
			  _factor_vigencia, 
			  _prima_neta, 
			  _prima_suscrita, 
			  _fecha_emision, 
			  _user_added WITH RESUME;
END FOREACH
END PROCEDURE;
