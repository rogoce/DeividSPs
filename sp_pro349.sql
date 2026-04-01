-- Reporte Emireimp
-- Creado    : 14/04/2011 - Autor: Henry Giron
DROP PROCEDURE sp_pro349;
CREATE PROCEDURE "informix".sp_pro349(a_desde date,a_hasta date,a_sucursal char(255))
returning char(20),		 -- no_documento,	
		  char(10),      -- no_poliza,   	
		  date,			 -- fecha_impresion,	  
		  char(8),		 -- user_imprimio,
		  char(10),		 -- no_factura	   
		  CHAR(255),     -- filtros
		  CHAR(5),		 --	cod_acreedor    
		  CHAR(5),		 --	cod_agente      
		  CHAR(10),		 --	cod_cliente     
		  CHAR(50),		 --	nombre_agente	 
		  CHAR(50),		 --	nombre_cliente	 
		  CHAR(50),      --	nombre_acreedor 
		  date,          --	vigencia_inic
		  date;		     --	vigencia_final

define _no_documento	char(20);	   	
define _no_poliza   	char(10); 		
define _fecha_impresion date;		 	
define _user_imprimio	char(8);
define _no_factura      char(10);				
define _sucursal        char(3);
define _seleccion       smallint;
DEFINE _tipo            char(01);
DEFINE v_filtros        char(255);

DEFINE _cod_acreedor      CHAR(5);
DEFINE _cod_agente        CHAR(5);
DEFINE _cod_cliente       CHAR(10);
DEFINE _nombre_agente	  CHAR(50);
DEFINE _nombre_cliente	  CHAR(50);
DEFINE _nombre_acreedor	  CHAR(50);
Define v_no_poliza		  char(10);

define _vigencia_final		date;
define _vigencia_inic		date;

Create Temp Table tmp_pro349(
	 no_documento	char(20),
     no_poliza   	char(10),
	 fecha_impresion date,		
	 user_imprimio	char(8),
	 no_factura      char(10),
	 sucursal        char(3),
	 seleccion       smallint,
	 cod_acreedor    CHAR(5),
	 cod_agente      CHAR(5),
	 cod_cliente     CHAR(10),
	 nombre_agente	 CHAR(50),
	 nombre_cliente	 CHAR(50),
	 nombre_acreedor CHAR(50),
     vigencia_inic	 date,
     vigencia_final	 date	 
	 ) With No Log;	 	

SET ISOLATION TO DIRTY READ;

let _no_poliza  = null;
let _no_factura = null;
LET v_filtros   = "";

foreach
	select no_documento,   
           no_poliza,
		   fecha_impresion,
		   user_imprimio
	  into _no_documento,	
    	   v_no_poliza,   ---_no_poliza,  --- SD#6973 HG MONICA 28/06/2023
		   _fecha_impresion,
		   _user_imprimio
	  from emireimp  
     where fecha_impresion >= a_desde
	   and fecha_impresion <= a_hasta
	   
	   let _no_poliza = sp_sis21(_no_documento);
    
	select no_factura, sucursal_origen, cod_contratante,vigencia_inic,vigencia_final
	  into _no_factura, _sucursal, _cod_cliente,_vigencia_inic,_vigencia_final
	  from emipomae 
	 where no_poliza   = _no_poliza --- SD#6973 HG MONICA 28/06/2023
	   and actualizado = 1 ;   	

-- Selecciona el Cliente de la Poliza
	Select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
	   
-- selecciona el primer acreedor de la poliza
	let _nombre_acreedor = '... SIN ACREEDOR ...';
	let _cod_acreedor    = '';

	foreach	 select	distinct cod_acreedor
	   into	_cod_acreedor
	   from emipoacr
	  where	no_poliza = _no_poliza

		if _cod_acreedor is not null then
		   select nombre
			 into _nombre_acreedor
			 from emiacre
			where cod_acreedor = _cod_acreedor;
			 exit foreach;
		end if
	end foreach

	if _cod_acreedor is null then
	   let _cod_acreedor = '';
	   let _nombre_acreedor = '... SIN ACREEDOR ...';
	end if

	-- selecciona el primer corredor de la poliza
	foreach 
	 select	distinct cod_agente
	   into	_cod_agente
	   from emipoagt
	  where	no_poliza = _no_poliza

		if _cod_agente is not null then
			select nombre
			  into _nombre_agente
			  from agtagent
			 where cod_agente = _cod_agente;
			 exit foreach;
		end if

	end foreach			 		   	   

	if _cod_agente is null then
	   let _cod_agente = '';
	   let _cod_agente = '... SIN CORREDOR ...';
	end if

 
   Insert into tmp_pro349(
			 no_documento,	
			 no_poliza,   	
			 fecha_impresion,
			 user_imprimio,
			 no_factura,
			 sucursal,
			 seleccion,
			 cod_acreedor,
			 cod_agente, 
			 cod_cliente, 
			 nombre_agente, 
			 nombre_cliente,
			 nombre_acreedor,
			 vigencia_inic,
			 vigencia_final
			 )     
   values (	_no_documento,	
			_no_poliza,   	
			_fecha_impresion, 
			_user_imprimio,
			_no_factura,
			_sucursal,
			1,
			_cod_acreedor,    
			_cod_agente,      
			_cod_cliente,     
			_nombre_agente,	
			_nombre_cliente,	
			_nombre_acreedor,
            _vigencia_inic,
			_vigencia_final			
			);	     

end foreach

LET _tipo = "";
--Filtro por Sucursal
if a_sucursal <> "*" then
	let v_filtros = trim(v_filtros) ||"Sucursal "||trim(a_sucursal);
	let _tipo = sp_sis04(a_sucursal); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
	   update tmp_pro349
	      set seleccion = 0
	    where seleccion = 1
	      and sucursal not in(select codigo from tmp_codigos);
	else
	   update tmp_pro349
	      set seleccion = 0
	    where seleccion = 1
	      and sucursal in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if


foreach
  select no_documento,	
		 no_poliza,   	
		 fecha_impresion,
		 user_imprimio,
		 no_factura,
		 sucursal,
		 cod_acreedor,
		 cod_agente, 
		 cod_cliente, 
		 nombre_agente, 
		 nombre_cliente,
		 nombre_acreedor,
         vigencia_inic,
		 vigencia_final		 
    into _no_documento,	
		 _no_poliza,   	
		 _fecha_impresion, 
		 _user_imprimio,
    	 _no_factura,
    	 _sucursal,
    	 _cod_acreedor,   
    	 _cod_agente,     
    	 _cod_cliente,    
    	 _nombre_agente,	
    	 _nombre_cliente,	
    	 _nombre_acreedor,
		 _vigencia_inic,
		 _vigencia_final		 
    from tmp_pro349  
   where seleccion = 1

   return _no_documento,	
		  _no_poliza,   	
		  _fecha_impresion, 
          _user_imprimio,
          _no_factura,
          v_filtros,
          _cod_acreedor,   
          _cod_agente,     
          _cod_cliente,    
          _nombre_agente,	
          _nombre_cliente,	
          _nombre_acreedor,
		  _vigencia_inic,
		  _vigencia_final		  
          with resume;

end foreach
drop table tmp_pro349;


end procedure	


   