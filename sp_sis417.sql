--- Actualizar el codigo de tipo de tarifa a las nuevas y renovadas
--- Creado 30/07/2014 por Amado Perez

drop procedure sp_sis417;

create procedure "informix".sp_sis417(a_poliza char(10), a_endoso char(5))
returning integer;

begin

define _cod_producto  	char(5);
define _cod_ramo    	char(3);
define _no_unidad       char(5);
define _tipo            smallint;
define _cnt             integer;
define _porc            decimal(16,2);
define _no_motor        char(30);
define _nuevo           smallint;
define _porc_feria      decimal(16,2);

define _descuento_max    smallint;
define _descuento_modelo smallint;
define _descuento_vehic  smallint;
define _cod_tipo_tar     char(3);

--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;

let _tipo = 0;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_poliza;

if _cod_ramo Not in('002','023') then
	return 0;
end if


foreach

	select no_unidad,
	       cod_producto
	  into _no_unidad,
	       _cod_producto
	  from endeduni
	 where no_poliza = a_poliza
	   and no_endoso = a_endoso
	 
	select no_motor  
	  into _no_motor
	  from emiauto
	 where no_poliza = a_poliza
	   and no_unidad = _no_unidad;

	select nuevo
	  into _nuevo
	  from emivehic
	 where no_motor = _no_motor;

	let _tipo = sp_proe76(a_poliza, a_endoso ,_no_unidad);
	 
	if _tipo = 1 or _tipo = 2 or _tipo = 3 then  --Es sedan, suv o pickup
				
		SELECT count(*)
	      INTO _cnt
		  FROM prdcobpd p, endedcob e
		 WHERE p.cod_cobertura = e.cod_cobertura
		   AND p.cod_producto  = _cod_producto
		   AND p.tipo_descuento in (1,2)
		   AND e.no_poliza = a_poliza
		   AND e.no_endoso = a_endoso
		   AND e.no_unidad = _no_unidad;

		let _porc = 0;
		let _porc_feria = 0;

		let _descuento_max = 0;
		let _descuento_modelo = 0;
		let _descuento_vehic = 0;
		
		if _cnt > 0 then
			select count(*)
			  into _descuento_max
			  from endcobde
			 where no_poliza = a_poliza
			   and no_endoso = a_endoso
			   and no_unidad = _no_unidad
			   and cod_descuen = '004'; 
			
			select count(*)
			  into _descuento_modelo
			  from endcobde
			 where no_poliza = a_poliza
			   and no_endoso = a_endoso
			   and no_unidad = _no_unidad
			   and cod_descuen = '005'; 
			   
			select count(*)
			  into _descuento_vehic
			  from endcobde
			 where no_poliza = a_poliza
			   and no_endoso = a_endoso
			   and no_unidad = _no_unidad
			   and cod_descuen = '007'; 
			   
			if _descuento_max > 0 then
				let _cod_tipo_tar = '002';
			end if
			if _descuento_modelo > 0 then
				let _cod_tipo_tar = '004';
			end if
			if _descuento_vehic > 0 then
				let _cod_tipo_tar = '008';
			end if
			
			if _cod_producto in ('02206','03005','03012', '03013') then --MotorShow 2016
				let _cod_tipo_tar = '007';
			end if
			
			update emipouni
			   set cod_tipo_tar = _cod_tipo_tar	--descuento por feria
			 where no_poliza = a_poliza
			   and no_unidad = _no_unidad;
		
		end if
		
	   { if _cnt > 0 then
			let _porc = sp_proe80(a_poliza,_no_unidad); --Descuento por modelo
			if _cod_producto in ('02206','03005','03012', '03013') and _nuevo = 1 then -- MotorShow
				let _porc_feria = sp_proe82(a_poliza, _no_unidad);
			end if
			
			if _porc = 0 then
				update emipouni
				   set cod_tipo_tar = '002'   --descuento combinado
				 where no_poliza = a_poliza
				   and no_unidad = _no_unidad;
			else
				update emipouni
				   set cod_tipo_tar = '004'	--descuento por modelo 20/08/2015
				 where no_poliza = a_poliza
				   and no_unidad = _no_unidad;
			end if
			
			if _cod_producto = '02206' then
				update emipouni
				   set cod_tipo_tar = '007'	--Motor Show
				 where no_poliza = a_poliza
				   and no_unidad = _no_unidad;
			end if
			   	
	    end if
       }
	end if

end foreach
end 
return 0;

end procedure;
