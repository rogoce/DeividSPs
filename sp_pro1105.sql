-- Procedimiento que elimina cuentas duplicas por ramo y origen 
-- 
-- Creado     :	21/03/2014 - Autor: Angel Tello
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro1105;		

create procedure "informix".sp_pro1105()
       RETURNING CHAR(3),
				 CHAR(70),
				 CHAR(100),
				 CHAR(25),
				 CHAR(50),
				 DATE,
				 char(25);
				  

define _no_poliza   			 char(7);
define _no_documento  			 char(25);
define _cod_ramo    			 char(3);
define _cod_estatus				 char(1);
define _nombre_estatus			 char(25);
define _cod_cliente			     char(7);
define _nombre_cliente			 char(100);
define _nombre_ramo 			 char(100);
define _fecha_can				 date;
define _vigencia_final			 date;
define _fecha 					 date;
define _no_factura 			     char(25);


 
set isolation to dirty read;

FOREACH WITH HOLD	
	
	SELECT cod_ramo, 
	       no_documento, 
           cod_status,
		   cod_pagador,
		   vigencia_fin
      INTO _cod_ramo,
		   _no_documento,                                   
		   _cod_estatus,
		   _cod_cliente,
		   _vigencia_final
	  FROM emipoliza    
     WHERE cod_sucursal = '001'
	   AND cod_status in(2,3)
	 ORDER BY 1	
	 
	 IF _cod_ramo = '018' OR _cod_ramo = '002' OR _cod_ramo = '020' THEN
		CONTINUE FOREACH;
	 END IF

	SELECT nombre
	  INTO _nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	 
	FOREACH WITH HOLD	
	
	 SELECT fecha_cancelacion,
			no_factura
	   INTO _fecha_can,
			_no_factura
	   FROM emipomae
	  WHERE no_documento =  _no_documento
		AND estatus_poliza = _cod_estatus

	
	 IF _cod_estatus = '2' THEN
		LET _nombre_estatus = 'CANCELADA';
		LET _fecha = _fecha_can;
		
	 END IF
	 
	 IF _cod_estatus = '3' THEN
		LET _nombre_estatus = 'VENCIDA';
		LET _fecha = _vigencia_final;
	END IF
	
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	  
	return _cod_ramo,
		   _nombre_ramo,
		   _nombre_cliente,
		   _no_documento,
		   _nombre_estatus,
		   _fecha,
		   _no_factura
		  with resume;
	END FOREACH
END FOREACH

END PROCEDURE
