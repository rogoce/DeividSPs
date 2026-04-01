-- Reporte Pool de Endoso - Logistica - Acreedores
-- Creado    : 12/04/2017 - Autor: Henry Giron
DROP PROCEDURE sp_log029;
CREATE PROCEDURE "informix".sp_log029(a_desde DATE,a_hasta DATE,a_sucursal CHAR(255))
returning CHAR(20),		 -- no_documento,	
		  CHAR(10),      -- no_poliza,   	
		  DATE,			 -- fecha_impresion,	  
		  CHAR(8),		 -- user_imprimio,
		  CHAR(10),		 -- no_factura	   
		  CHAR(255),     -- filtros
		  CHAR(5), 		 -- cod_acreedor 	
		  CHAR(50),		 -- nombre_acreedor
		  CHAR(5), 		 -- cod_agente 	
		  CHAR(50),      -- nombre_agente 	
		  SMALLINT, --;		 -- estado_pro
		  DATE,			 -- fecha_elimino,	  
		  CHAR(8),		 -- user_elimino,		  
		  CHAR(50),		 -- t_endoso	   
		  CHAR(100);     -- n_cliente	  

define _no_documento	char(20);	   	
define _no_poliza   	char(10); 		
define _fecha_impresion date;		 	
define _user_imprimio	char(8);
define _no_factura      char(10);				
define _numero          char(10);				
define _sucursal        char(3);
define _seleccion       smallint;
DEFINE _tipo            char(01);
DEFINE v_filtros        char(255);
DEFINE _cod_acreedor 	CHAR(5); 
DEFINE _nombre_acreedor CHAR(50);
DEFINE _cod_agente 	    CHAR(5); 
DEFINE _nombre_agente   CHAR(50);  
define _estado_log      smallint;
define _estado_pro      smallint; 
define _user_elimino    char(10); 
define _fecha_elimino   date; 
define _t_endoso        char(50); 
define _n_cliente       char(100); 
define _cod_cliente 	char(10);	 
define _cod_endomov     char(3);

drop table if exists tmp_log029;

Create Temp Table tmp_log029(
	 no_documento	 char(20),
     no_poliza   	 char(10),
	 fecha_impresion date,		
	 user_imprimio	 char(8),
	 no_factura      char(10),
	 sucursal        char(3),
	 seleccion       smallint,
	 cod_acreedor 	 char(5),
	 nombre_acreedor char(50),
	 cod_agente 	 char(5), 
	 nombre_agente 	 char(50),
	 estado_log      smallint,
	 estado_pro      smallint,
	 fecha_elimino   date,		
	 user_elimino	 char(8),
	 t_endoso        char(50),
	 n_cliente       char(100)
	 ) With No Log;	 	

SET ISOLATION TO DIRTY READ;

let _no_poliza  = null;
let _no_factura = null;
let _numero     = null;
LET v_filtros   = "";
let _fecha_elimino = null;
let _user_elimino = "";

 --set debug file to "sp_log029.trc";
 --trace on;
Foreach
select numero, fecha_recibe, trim(usuario_recibe)
  into _numero, _fecha_impresion, _user_imprimio
  from logcaja0 
 where (fecha_recibe >= a_desde ) AND
       (fecha_recibe <= a_hasta ) AND     
	   (activo <> 4)	   	   

	foreach
	 SELECT no_documento,
			no_poliza,
			no_factura,
			cod_acreedor,		 
			cod_agente,
			estado_log,
			estado_pro,
			fecha_elimino,
			user_elimino,
			cod_cliente,
			cod_endomov
	   into _no_documento,	
			_no_poliza,   	
			_no_factura,
			_cod_acreedor, 	    	 
			_cod_agente,
			_estado_log,
			_estado_pro,
			_fecha_elimino,
			_user_elimino,
			_cod_cliente,
			_cod_endomov		
	   FROM endpool0
	   where no_factura = _numero
	   
	  --WHERE (fecha_imprimio >= a_desde ) AND
			--(fecha_imprimio <= a_hasta ) AND     
			--(estado_pro in (0,2)) AND  -- 6, eliminar los cod_endomov 024 y 025 , cia_depto not in (008,010) Front y Back Office	 
			--(estado_log in (0,1,2,3,5))	
			
		if _cod_endomov = "002" then  -- las cancelaciones no seran tomadas en este pool endoso, se manejarna en el pool de cancelaciones. 
			continue foreach;		
		end if		
		 
		select nombre
		  into _nombre_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;
			 
		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;		   
			 
		select sucursal_origen 
		  into _sucursal
		  from emipomae 
		 where no_poliza   = _no_poliza
		   and actualizado = 1 ;   		   
		   
		select nombre
		  into _n_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;	  
		 
		select nombre
		  into _t_endoso
		  from endtimov
		 where cod_endomov = _cod_endomov;	  	 	 
	 
	   Insert into tmp_log029(
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
				 estado_log,
				 estado_pro,
				 fecha_elimino,
				 user_elimino,
				 t_endoso,
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
				 _estado_log,
				 _estado_pro,
				 _fecha_elimino,
				 _user_elimino,
				 _t_endoso,
				 _n_cliente			 			 
				);	     
	end foreach
end foreach
--trace off;

LET _tipo = "";

--Filtro por Sucursal
{IF a_sucursal <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_sucursal);
	LET _tipo = sp_sis04(a_sucursal); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
	   UPDATE tmp_log025
	      SET seleccion = 0
	    WHERE seleccion = 1
	      AND sucursal NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
	   UPDATE tmp_log025
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
         estado_pro,
		 fecha_elimino,
		 user_elimino,
		 t_endoso,
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
		 _estado_pro,
		 _fecha_elimino,
		 _user_elimino,
		 _t_endoso,
		 _n_cliente			 		 		 
    FROM tmp_log029 
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
		  _estado_pro,
          _fecha_elimino,
		  _user_elimino,
		  _t_endoso,
		  _n_cliente			  
          with resume;

end foreach
END PROCEDURE	

