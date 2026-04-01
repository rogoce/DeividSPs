-- Reporte Pool de Cancelacion - Logistica
-- Creado    : 14/10/2011 - Autor: Henry Giron
DROP PROCEDURE sp_pr1003;
CREATE PROCEDURE "informix".sp_pr1003(a_desde DATE,a_hasta DATE,a_sucursal CHAR(255))
returning CHAR(20),		 -- no_documento,	
		  CHAR(10),      -- no_poliza,   	
		  DATE,			 -- fecha_impresion,	  
		  CHAR(8),		 -- user_imprimio,
		  CHAR(10),		 -- no_factura	   
		  CHAR(255),     -- filtros
		  CHAR(5), 		 -- cod_acreedor 	
		  CHAR(50),		 -- nombre_acreedor
		  CHAR(5), 		 -- cod_agente 	
		  CHAR(50),		 -- nombre_agente 	
		  CHAR(100);     -- n_cliente			  

define _no_documento	char(20);	   	
define _no_poliza   	char(10); 		
define _fecha_impresion date;		 	
define _user_imprimio	char(8);
define _no_factura      char(10);				
define _sucursal        char(3);
define _seleccion       smallint;
DEFINE _tipo            char(01);
DEFINE v_filtros        char(255);
DEFINE _cod_acreedor 	CHAR(5); 
DEFINE _nombre_acreedor CHAR(50);
DEFINE _cod_agente 	    CHAR(5); 
DEFINE _nombre_agente   CHAR(50);  
define _n_cliente       char(100); 

Create Temp Table tmp_pr1003(
	 no_documento	char(20),
     no_poliza   	char(10),
	 fecha_impresion date,		
	 user_imprimio	char(8),
	 no_factura      char(10),
	 sucursal        char(3),
	 seleccion       smallint,
	 cod_acreedor 	 char(5),
	 nombre_acreedor char(50),
	 cod_agente 	 char(5), 
	 nombre_agente 	 char(50),
     n_cliente       char(100)	 
	 ) With No Log;	 	

SET ISOLATION TO DIRTY READ;

let _no_poliza  = null;
let _no_factura = null;
LET v_filtros   = "";

foreach
  SELECT no_documento,
         no_poliza,
         fecha_cancela, --date_imp_log,
         user_imp_log,
		 no_factura,
		 cod_acreedor, 	
		 nombre_acreedor,
		 cod_agente, 	 
		 nombre_agente,
		 nombre_cliente
    into _no_documento,	
    	 _no_poliza,   	
    	 _fecha_impresion, 
    	 _user_imprimio,
    	 _no_factura,
    	 _cod_acreedor, 	
    	 _nombre_acreedor,
		 _cod_agente, 	 
    	 _nombre_agente,
         _n_cliente		 
    FROM avisocanc
   WHERE ( fecha_cancela >= a_desde ) AND
         ( fecha_cancela <= a_hasta ) AND 
		 (estatus   = 'Z')
{   WHERE ( date_imp_log >= a_desde ) AND
         ( date_imp_log <= a_hasta ) AND 
		 (estatus   = 'Z')}
         
		select sucursal_origen 
	      into _sucursal
		  from emipomae 
		 where no_poliza   = _no_poliza
		   and actualizado = 1 ;   		   
 
   Insert into tmp_pr1003(
			 no_documento,	
			 no_poliza,   	
			 fecha_impresion,
			 user_imprimio,
			 no_factura,
			 sucursal,
			 seleccion,
			 cod_acreedor, 	
			 nombre_acreedor,
			 cod_agente, 	 
			 nombre_agente,
			 n_cliente
			 )     
   values (	_no_documento,
			_no_poliza,
			_fecha_impresion, 
			_user_imprimio,
			_no_factura,
			_sucursal,
			1,
			_cod_acreedor, 	
			_nombre_acreedor,
			_cod_agente, 	 
			_nombre_agente,
			_n_cliente
			);	     
end foreach

LET _tipo = "";

--Filtro por Sucursal
{IF a_sucursal <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_sucursal);
	LET _tipo = sp_sis04(a_sucursal); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
	   UPDATE tmp_pr1001
	      SET seleccion = 0
	    WHERE seleccion = 1
	      AND sucursal NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
	   UPDATE tmp_pr1001
	      SET seleccion = 0
	    WHERE seleccion = 1
	      AND sucursal IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF}


foreach
  SELECT no_documento,	
		 no_poliza,   	
		 fecha_impresion,
		 user_imprimio,
		 no_factura,
		 sucursal,
		 cod_acreedor, 	
		 nombre_acreedor,
		 cod_agente, 	 
		 nombre_agente,
         n_cliente		 
    into _no_documento,	
		 _no_poliza,   	
		 _fecha_impresion, 
		 _user_imprimio,
    	 _no_factura,
    	 _sucursal,                           
		 _cod_acreedor, 	
		 _nombre_acreedor,
		 _cod_agente, 	 
		 _nombre_agente,
		 _n_cliente
    FROM tmp_pr1003  
   WHERE seleccion = 1

   return _no_documento, 
		  _no_poliza, 
		  _fecha_impresion, 
          _user_imprimio,
          _no_factura,
          v_filtros,
          _cod_acreedor, 		       		  	  		   		  
          _nombre_acreedor,
		  _cod_agente, 	 
		  _nombre_agente,
		  _n_cliente
          with resume;

end foreach
	DROP TABLE tmp_pr1003;


END PROCEDURE	

