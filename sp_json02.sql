-- Procedimiento que busca las unidades de una poliza para el json asegurado

-- Creado:	01/02/2018 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_json02;
 
create procedure sp_json02(a_no_documento CHAR(20), a_cod_cliente varchar(10))
returning VARCHAR(5),
		  VARCHAR(10),
		  decimal(16,2),
		  varchar(50),
		  varchar(50),
		  varchar(255),
		  integer,
		  varchar(10);

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


--set debug file to "sp_json02.trc";
--trace on;

let _descripcion = "";
call sp_sis21(a_no_documento) returning _no_poliza;

select cod_ramo,
	   cod_pagador
  into _cod_ramo,
	   _cod_pagador
  from emipomae
 where no_poliza = _no_poliza;

if _cod_pagador <> a_cod_cliente then
	foreach 
		 select no_unidad,
				suma_asegurada,
				cod_manzana,
				tipo_incendio,
				cod_producto,
				cod_asegurado,
				activo
		   into _no_unidad,
				_suma_asegurada,
				_cod_manzana,
				_tipo_incendio,
				_cod_producto,
				_cod_asegurado,
				_activo
		   from emipouni
		  where no_poliza 	  = _no_poliza
			and cod_asegurado = a_cod_cliente
		  order by no_unidad asc
		
		select nombre
		  into _nombre_producto
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		if _cod_ramo <> '002' and _cod_ramo <> '020' and _cod_ramo <> '023'then
		--if a_cod_cliente = _cod_pagador then	 
			if _cod_ramo = '001' or _cod_ramo = '003' then
				
				select nombre
				  into _nombre_asegurado
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				
				select nombre
				  INTO 	_barrio
				  from emiman05, emiman04
				 where cod_manzana = _cod_manzana
				   and emiman05.cod_provincia = emiman04.cod_provincia
				   and emiman05.cod_distrito = emiman04.cod_distrito
				   and emiman05.cod_correg = emiman04.cod_correg
				   and emiman05.cod_barrio = emiman04.cod_barrio;
				
			--let _descripcion = "No UNIDAD: "||_no_unidad||" TIPO: "||_desc_incendio||" BARRIO: "||_barrio;
				
			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   " ",
				   0,
				   " "
				   with resume;	
			
			elif _cod_ramo = '004' or _cod_ramo = '019' then
				select nombre
				  into _nombre_asegurado
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				 
				foreach
					 select nombre
					   into _nombre_dependiente
					   from emibenef
					  where no_poliza = _no_poliza
						and no_unidad = _no_unidad
					
				let _descripcion = _nombre_dependiente ||" \n "||_descripcion;
				end foreach

			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   _descripcion,
				   0,
				   " "
				   with resume;		
			
			elif _cod_ramo = '018' and _activo = 1 then
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

			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   _descripcion,
				   0,
				   _cod_asegurado
				   with resume;	
			else
				select nombre
				  into _nombre_asegurado
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				 
				foreach
					 select nombre
					   into _nombre_dependiente
					   from emibenef
					  where no_poliza = _no_poliza
						and no_unidad = _no_unidad
					
				let _descripcion = _nombre_dependiente ||" \n "||_descripcion;
				end foreach

			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   " ",
				   0,
				   " "
				   with resume;		
			end if	
		--end if		
		end if
			if _cod_ramo = '002' or _cod_ramo = '020' or _cod_ramo = '023' then
				select no_motor
				  into _no_motor
				  from emiauto
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;
				   
				select trim(b.nombre), 
					   trim(c.nombre), 
					   ano_auto, 
					   trim(placa)
				 into  _nombre_marca,
					   _nombre_modelo,
					   _ano_auto,
					   _placa
				 from emivehic a inner join emimarca b on a.cod_marca = b.cod_marca
				 inner join emimodel c on b.cod_marca = c.cod_marca
				 where no_motor 	= _no_motor
				   and a.cod_marca 	= b.cod_marca
				   and a.cod_modelo = c.cod_modelo;
				
			--let _descripcion = "MARCA: "||_nombre_marca||" \n MODELO: "||_nombre_modelo||" "||_ano_auto||" \n PLACA : "||_placa;
				
			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_marca,
				   _nombre_modelo,
				   _ano_auto,
				   _placa
				   with resume;
				
			end if
	end foreach
	if _cod_ramo = '018' then
		foreach 
			 select a.no_unidad,
					a.suma_asegurada,
					a.cod_manzana,
					a.tipo_incendio,
					a.cod_producto,
					a.cod_asegurado,
					a.activo
			   into _no_unidad,
					_suma_asegurada,
					_cod_manzana,
					_tipo_incendio,
					_cod_producto,
					_cod_asegurado,
					_activo
		       from emipouni a inner join emidepen b on a.no_poliza = b.no_poliza
		      where a.no_poliza    = _no_poliza and a.no_unidad = b.no_unidad
			    and (cod_asegurado = a_cod_cliente or cod_cliente = a_cod_cliente)
		   order by no_unidad asc
			
			select nombre
			  into _nombre_producto
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

			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   _descripcion,
				   0,
				   _cod_asegurado
				   with resume;	
		end foreach
	end if
else
	foreach 
		 select no_unidad,
				suma_asegurada,
				cod_manzana,
				tipo_incendio,
				cod_producto,
				cod_asegurado,
				activo
		   into _no_unidad,
				_suma_asegurada,
				_cod_manzana,
				_tipo_incendio,
				_cod_producto,
				_cod_asegurado,
				_activo
		   from emipouni
		  where no_poliza 	  = _no_poliza
		  order by no_unidad asc
		
		select nombre
		  into _nombre_producto
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		if _cod_ramo <> '002' and _cod_ramo <> '020' and _cod_ramo <> '023'then
		--if a_cod_cliente = _cod_pagador then	 
			if _cod_ramo = '001' or _cod_ramo = '003' then
				
				select nombre
				  into _nombre_asegurado
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				
				select nombre
				  INTO 	_barrio
				  from emiman05, emiman04
				 where cod_manzana = _cod_manzana
				   and emiman05.cod_provincia = emiman04.cod_provincia
				   and emiman05.cod_distrito = emiman04.cod_distrito
				   and emiman05.cod_correg = emiman04.cod_correg
				   and emiman05.cod_barrio = emiman04.cod_barrio;
				
			--let _descripcion = "No UNIDAD: "||_no_unidad||" TIPO: "||_desc_incendio||" BARRIO: "||_barrio;
				
			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   " ",
				   0,
				   " "
				   with resume;	
			
			elif _cod_ramo = '004' or _cod_ramo = '019' then
				select nombre
				  into _nombre_asegurado
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				 
				foreach
					 select nombre
					   into _nombre_dependiente
					   from emibenef
					  where no_poliza = _no_poliza
						and no_unidad = _no_unidad
					
				let _descripcion = _nombre_dependiente ||" \n "||_descripcion;
				end foreach

			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   _descripcion,
				   0,
				   " "
				   with resume;		
			
			elif _cod_ramo = '018' and _activo = 1 then
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

			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   _descripcion,
				   0,
				   _cod_asegurado
				   with resume;	
			else
				select nombre
				  into _nombre_asegurado
				  from cliclien
				 where cod_cliente = _cod_asegurado;
				 
				foreach
					 select nombre
					   into _nombre_dependiente
					   from emibenef
					  where no_poliza = _no_poliza
						and no_unidad = _no_unidad
					
				let _descripcion = _nombre_dependiente ||" \n "||_descripcion;
				end foreach

			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_asegurado,
				   " ",
				   0,
				   " "
				   with resume;		
			end if	
		--end if		
		end if
			if _cod_ramo = '002' or _cod_ramo = '020' or _cod_ramo = '023' then
				select no_motor
				  into _no_motor
				  from emiauto
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;
				   
				select trim(b.nombre), 
					   trim(c.nombre), 
					   ano_auto, 
					   trim(placa)
				 into  _nombre_marca,
					   _nombre_modelo,
					   _ano_auto,
					   _placa
				 from emivehic a inner join emimarca b on a.cod_marca = b.cod_marca
				 inner join emimodel c on b.cod_marca = c.cod_marca
				 where no_motor 	= _no_motor
				   and a.cod_marca 	= b.cod_marca
				   and a.cod_modelo = c.cod_modelo;
				
			--let _descripcion = "MARCA: "||_nombre_marca||" \n MODELO: "||_nombre_modelo||" "||_ano_auto||" \n PLACA : "||_placa;
				
			return _no_unidad,
				   _no_poliza,
				   _suma_asegurada,
				   _nombre_producto,
				   _nombre_marca,
				   _nombre_modelo,
				   _ano_auto,
				   _placa
				   with resume;
				
			end if
	end foreach
end if

end procedure
