-- Procedimiento que elimina cuentas duplicas por ramo y origen 
-- 
-- Creado     :	21/03/2014 - Autor: Angel Tello
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc03a;		

create procedure "informix".sp_ttc03a()
       RETURNING CHAR(1),
				 CHAR(50),
				 CHAR(25),
				 CHAR(100);
				  

define _no_poliza   			 char(7);
define _cod_ramo    			 char(3);
define _cuenta      			 char(25);
define _cod_origen				 char(3);
define _no_registro              integer;
define _error				  	 integer;
define _error_isam			     integer;
define _error_desc			     char(50);
define _fecha					 date;
define _no_remesa 				 char(10);
define _renglon					 smallint;
define _no_tranrec				 char(10);
define _no_reclamo				 char(10);
define _no_registroa             char(10);
define _nombre_ramo				 char(100);
define _nombre_origen			 char(25);
define _tabla_registro			 char(25);
define _band_cuenta				 char(25);
define _cta_nombre 				 char(100);
define _cod_tipoprod			 char(25);
define _registros_d				 integer;
define _cta_cuenta               CHAR(3);
define _nombre_codtipro          char(50);


 
set isolation to dirty read;

--tabla prima devengada 
CREATE TEMP TABLE tmp_asientos(
		cod_origen           char(5),
		nombre_origen        char(25),
		cuenta   			 char(25),
		cta_conbre			 char(100)
	    ) WITH NO LOG;

CREATE INDEX xie01_tmp_asientos ON tmp_asientos(cod_origen);
CREATE INDEX xie03_tmp_asientos ON tmp_asientos(cuenta);


FOREACH WITH HOLD	
	
	SELECT cod_origen, 
           cod_cuenta
      INTO _cod_origen,                                   
		   _cuenta
	  FROM deivid_ttcorp:tmp_asient   
     WHERE tabla_registro = 'chqchcta'
     ORDER BY 1	

	SELECT count(*)
      INTO _registros_d 
	  FROM tmp_asientos
	 WHERE cod_origen    = _cod_origen
       AND cuenta        = _cuenta;
	

	IF  _registros_d > 0 THEN 
        CONTINUE FOREACH; 
    END IF  

	
	let _cta_cuenta = _cuenta[1,3];
	 
	 SELECT cta_nombre 
	   INTO _cta_nombre
	   FROM cglcuentas
	  WHERE cta_cuenta = _cta_cuenta;
	  
	  IF _cod_origen = '1' THEN
	  	LET _nombre_origen	 = 'CONTABLILIDAD';
	  END IF

	   IF _cod_origen = '2' THEN
	  	LET _nombre_origen	 = 'CORREDOR';
	  END IF
	  
	   IF _cod_origen = '3' THEN
	  	LET _nombre_origen	 = 'RECLAMOS';
	  END IF
     		
	  IF _cod_origen = '4' THEN
	  	LET _nombre_origen	 = 'REASEGURO';
	  END IF

	   IF _cod_origen = '5' THEN
	  	LET _nombre_origen	 = 'COASEGURO';
	  END IF
	  
	   IF _cod_origen = '6' THEN
	  	LET _nombre_origen	 = 'COBROS';
	  END IF
     
	  IF _cod_origen = '7' THEN
	  	LET _nombre_origen	 = 'HONORARIOS';
	  END IF

	   IF _cod_origen = '8' THEN
	  	LET _nombre_origen	 = 'BONIFICACION COBRANZA AGENTES';
	  END IF
	  
	   IF _cod_origen = 'A' THEN
	  	LET _nombre_origen	 = 'HONORARIOS POR SER. PROFECIONALES';
	  END IF
     		
	  IF _cod_origen = 'B' THEN
	  	LET _nombre_origen	 = 'SERVICIOS BASICOS';
	  END IF

	   IF _cod_origen = 'C' THEN
	  	LET _nombre_origen	 = 'ALQUILERES POR ARRENDAMIENTOS COMERCIALES';
	  END IF
	  
	   IF _cod_origen = '9' THEN
	  	LET _nombre_origen	 = 'INCENTIVO DE FIDELIDAD AGENTES';
	  END IF
     
	  IF _cod_origen = 'D' THEN
	  	LET _nombre_origen	 = 'BONIFICACION POR RENTABILIDAD AGENTES';
	  END IF

	   IF _cod_origen = 'E' THEN
	  	LET _nombre_origen	 = 'BONIFICACION RECLUTAMIENTO';
	  END IF
	  
	   IF _cod_origen = 'P' THEN
	  	LET _nombre_origen	 = 'PLANILLA';
	  END IF
     		
	  IF _cod_origen = 'G' THEN
	  	LET _nombre_origen	 = 'GASTOS ADMINISTRATIVOS';
	  END IF

	   IF _cod_origen = 'S' THEN
	  	LET _nombre_origen	 = 'DEVOLUCION PRIMA SUSPENSO';
	  END IF
	  
	   IF _cod_origen = 'K' THEN
	  	LET _nombre_origen	 = 'DEVOLUCION POLIZA CANCELADA';
	  END IF
     
    INSERT INTO tmp_asientos( cod_origen,           
							   nombre_origen,        
							   cuenta, 
							   cta_conbre) 
				   	  VALUES(  _cod_origen,
							   _nombre_origen,
							   _cuenta,
							   _cta_nombre);
							  
END FOREACH	
 

FOREACH WITH HOLD	

	SELECT cod_origen,           
		   nombre_origen,        
		   cuenta, 
		   cta_conbre
	  INTO _cod_origen,
		   _nombre_origen,
		   _cuenta,
		   _cta_nombre
	  FROM tmp_asientos
	  
	return _cod_origen,
		   _nombre_origen,
		   _cuenta,
		   _cta_nombre
		  with resume;
END FOREACH

END PROCEDURE
