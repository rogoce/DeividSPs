-- Procedimiento que elimina cuentas duplicas por ramo y origen 
-- 
-- Creado     :	21/03/2014 - Autor: Angel Tello
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc03;		

create procedure "informix".sp_ttc03(a_tabla char(25))
       RETURNING CHAR(3),
				 CHAR(50),
				 CHAR(3),
				 CHAR(25),
				 CHAR(3),
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
		cod_ramo             CHAR(3),
	   	nombre_ramo			 CHAR(50),
		cod_origen           char(5),
		nombre_origen        char(25),
		cuenta   			 char(25),
		cta_conbre			 char(100),
		cod_tipoprod		 char(03),
		nombre_codtipoprod   char(50)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_asientos ON tmp_asientos(cod_origen);
CREATE INDEX xie02_tmp_asientos ON tmp_asientos(cod_ramo);
CREATE INDEX xie03_tmp_asientos ON tmp_asientos(cuenta);
CREATE INDEX xie04_tmp_asientos ON tmp_asientos(cod_tipoprod);

FOREACH WITH HOLD	
	
	SELECT cod_ramo, 
	       cod_origen, 
           cod_cuenta,
		   cod_tipoprod
      INTO _cod_ramo,
		   _cod_origen,                                   
		   _cuenta,
		   _cod_tipoprod
	  FROM deivid_ttcorp:tmp_asient   
     WHERE tabla_registro = a_tabla
	 ORDER BY 1	

SELECT count(*)
      INTO _registros_d 
	  FROM tmp_asientos
	 WHERE cod_ramo      = _cod_ramo
       AND cod_origen    = _cod_origen
       AND cuenta        = _cuenta
	   AND cod_tipoprod  = _cod_tipoprod;
	

	IF  _registros_d > 0 THEN 
        CONTINUE FOREACH; 
    END IF  

	 SELECT nombre
	  INTO _nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	
	let _cta_cuenta = _cuenta[1,3];
	 
	 SELECT cta_nombre 
	   INTO _cta_nombre
	   FROM cglcuentas
	  WHERE cta_cuenta = _cta_cuenta;
	  
	 SELECT nombre 
	   INTO _nombre_codtipro
	   FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;
	  
	IF _cod_origen = '001' THEN 
	 
	    LET _nombre_origen = 'LOCAL';
	ELSE 
        LET _nombre_origen = 'EXTERIOR';
    END IF	
	 
	 
	 INSERT INTO tmp_asientos( cod_ramo,             
							   nombre_ramo,			 
							   cod_origen,           
							   nombre_origen,        
							   cuenta, 
							   cta_conbre,
							   cod_tipoprod,
							   nombre_codtipoprod) 
				   	  VALUES(  _cod_ramo, 					
		                       _nombre_ramo,
							   _cod_origen,
							   _nombre_origen,
							   _cuenta,
							   _cta_nombre,
							   _cod_tipoprod,
							   _nombre_codtipro);
							  
END FOREACH	
 

FOREACH WITH HOLD	

	SELECT cod_ramo,             
		   nombre_ramo,			 
		   cod_origen,           
		   nombre_origen,        
		   cuenta,
		   cta_conbre,
		   cod_tipoprod,
		   nombre_codtipoprod
	  INTO _cod_ramo, 					
		   _nombre_ramo,
		   _cod_origen,
		   _nombre_origen,
		   _cuenta,
		   _cta_nombre,
		   _cod_tipoprod,
		   _nombre_codtipro
	  FROM tmp_asientos
	  
	return _cod_ramo, 					
		   _nombre_ramo,
		   _cod_origen,
		   _nombre_origen,
		   _cod_tipoprod,
		   _nombre_codtipro,
		   _cuenta,
		   _cta_nombre
		  with resume;
END FOREACH

END PROCEDURE
