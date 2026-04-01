-- Procedimiento que busca las unidades de una poliza para el json asegurado

-- Creado:	01/02/2018 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_json04;
 
create procedure sp_json04(a_no_documento CHAR(20), a_cod_cliente varchar(10))
returning VARCHAR(5),
		  VARCHAR(10),
		  decimal(16,2),
		  varchar(50),
		  varchar(50),
		  varchar(255),
		  varchar(20),
		  date,
		  varchar(65),
		  varchar(65),
		  varchar(65),
		  varchar(65),
		  varchar(65),
		  varchar(50);

define _cod_marca 			char(5);
define _cod_modelo			char(5);
define _nombre_marca		varchar(50);
define _nombre_modelo		varchar(50);
define _ano_auto        	integer;
define _placa				varchar(10);			
define _cod_ramo			char(3);
define _no_unidad			char(5);
define _no_poliza			char(10);
define _no_motor			char(30);		
define _uso					char(1);
define _descripcion     	VARCHAR(255);
define _barrio          	varchar(50);
define _cod_manzana     	varchar(15);
define _suma_asegurada  	dec(16,2);
define _tipo_incendio   	integer;
define _desc_incendio   	varchar(50);
define _nombre_producto 	varchar(50);
define _cod_producto    	varchar(10);
define _nombre_asegurado 	varchar(50);
define _cod_asegurado    	varchar(10);
define _cod_pagador	    	varchar(10);
define _cod_dependiente     varchar(10);
define _nombre_dependiente  varchar(50);
define _activo           	integer;
define _vigencia_inic       date;
define _beneficio1          varchar(65);
define _beneficio2          varchar(65);
define _beneficio3          varchar(65);
define _beneficio4          varchar(65);
define _beneficio5			varchar(65);
define _cod_carnet          char(3);
define _nombre_red          varchar(50);


--set debug file to "sp_json02.trc";
--trace on;

let _descripcion = "";
call sp_sis21(a_no_documento) returning _no_poliza;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza
   and cod_ramo  = '018';
 
foreach 
	 select no_unidad,
			suma_asegurada,
			cod_manzana,
			tipo_incendio,
			cod_producto,
			cod_asegurado,
			activo,
			vigencia_inic
	   into _no_unidad,
			_suma_asegurada,
			_cod_manzana,
			_tipo_incendio,
			_cod_producto,
			_cod_asegurado,
			_activo,
			_vigencia_inic
	   from emipouni
	  where no_poliza 	  = _no_poliza
	    and cod_asegurado = a_cod_cliente
		and activo 		  = 1
	  order by no_unidad asc
	
	select nombre,
		   beneficio1, 
		   beneficio2, 
		   beneficio3, 
		   beneficio4,
		   beneficio5,
		   cod_carnet
	  into _nombre_producto,
		   _beneficio1,
		   _beneficio2,
		   _beneficio3,
		   _beneficio4,
		   _beneficio5,
		   _cod_carnet
	  from prdprod
	 where cod_producto = _cod_producto;
	 	
			select nombre
			  into _nombre_asegurado
			  from cliclien
			 where cod_cliente = _cod_asegurado;
			 
			foreach
				 select cod_cliente
				   into _cod_dependiente
				   from emidepen
				  where no_poliza = _no_poliza
					and no_unidad = _no_unidad
					and activo = 1
					
				select trim(nombre)
				  into _nombre_dependiente
				  from cliclien
				 where cod_cliente = _cod_dependiente;
				
			let _descripcion = _nombre_dependiente ||" \n "||_descripcion;
			end foreach
			
			select nombre
              into _nombre_red			
			  from emicarnet
			 where cod_carnet = _cod_carnet;
			
		return _no_unidad,
		       _no_poliza,
			   _suma_asegurada,
			   _nombre_producto,
			   _nombre_asegurado,
			   _descripcion,
			   a_no_documento,
			   _vigencia_inic,
			   _beneficio1,
			   _beneficio2,
			   _beneficio3,
			   _beneficio4,
			   _beneficio5,
			   _nombre_red
			   with resume;			
end foreach

end procedure
