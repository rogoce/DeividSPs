-- Reporte Emireimp (Solo Acreedores)
-- Creado    : 04/12/2012 - Autor: Roman Gordon

drop procedure sp_pro349a;
create procedure "informix".sp_pro349a(a_desde date,a_hasta date,a_sucursal char(255))
returning char(20),		-- no_documento,	
		  char(10),		-- no_poliza,   	
		  date,			-- fecha_impresion,	  
		  char(8),		-- user_imprimio,
		  char(10),		-- no_factura	   
		  char(255),	-- filtros
		  char(5),		--cod_acreedor    
		  char(5),		--cod_agente      
		  char(10),		--cod_cliente     
		  char(50),		--nombre_agente	 
		  char(50),		--nombre_cliente	 
		  char(50);		--nombre_acreedor 

define v_filtros		char(255);
define _nombre_acreedor	char(50);
define _nombre_cliente	char(50);
define _nombre_agente	char(50);
define _nom_leasing		char(50);
define _no_documento	char(20);
define _cod_leasing		char(10);
define _cod_cliente		char(10);
define _no_factura		char(10);
define _no_poliza		char(10);
define _user_imprimio	char(8);
define _cod_acreedor	char(5);
define _cod_agente		char(5);
define _sucursal		char(3);
define _tipo			char(1);
define _es_leasing		smallint;
define _seleccion		smallint;
define _cnt_acre		smallint;
define _leasing			smallint;
define _fecha_impresion	date;
Define v_no_poliza		  char(10);

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
	nombre_acreedor CHAR(50)		 	 	
	 ) With No Log;	 	

set isolation to dirty read;
--set debug file to "sp_pro349a.trc"; 
--trace on;

let _no_poliza  = null;
let _no_factura	= null;
let v_filtros   = "";
let _cnt_acre	= 0;

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
    
	select count(*)
	  into _cnt_acre
	  from emipoacr
	 where no_poliza = _no_poliza;
	
	select no_factura,
		   sucursal_origen,
		   cod_contratante,
		   leasing
	  into _no_factura,
		   _sucursal,
		   _cod_cliente,
		   _leasing
	  from emipomae 
	 where no_poliza   = _no_poliza
	   and actualizado = 1 ;   	
	
	if _cnt_acre < 1 and _leasing = 0 then
		continue foreach;
	end if
	
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
	
	if (_cod_acreedor is null or _cod_acreedor = '') and _leasing = 1 then
		foreach
			select cod_asegurado
			  into _cod_leasing
			  from emipouni
			 where no_poliza = _no_poliza
			 
			select nombre,
				   leasing
			  into _nom_leasing,
				   _es_leasing
			  from cliclien
			 where cod_cliente = _cod_leasing;
			 
			if _es_leasing = 1 then
				let _nombre_acreedor	= trim(_nom_leasing);
				let _cod_acreedor		= _cod_leasing;
				exit foreach;
			end if
		end foreach
	end if		
	
	-- selecciona el primer corredor de la poliza
	foreach 
		select distinct cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

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
	
   insert into tmp_pro349(
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
			 nombre_acreedor			 			 	
			 )     
   values	(_no_documento,	
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
			_nombre_acreedor	
			);	     

end foreach

let _tipo = "";
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
		   nombre_acreedor			 		 	                 
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
		   _nombre_acreedor	    	     	     	                            
      from tmp_pro349  
	 where seleccion = 1
	 order by nombre_acreedor,no_documento

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
		   _nombre_acreedor	                    	       		  	  		   		  
		   with resume;
end foreach
drop table tmp_pro349;
end procedure	


   