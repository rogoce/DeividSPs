--- Actualizar el codigo de tipo de tarifa a las nuevas y renovadas
--- Creado 28/07/2014 por Armando Moreno

drop procedure sp_sis416;

create procedure "informix".sp_sis416(a_poliza char(10))
returning integer;

begin

define _cod_producto  	char(5);
define _cod_ramo    	char(3);
define _no_unidad,_cod_grupo       char(5);
define _tipo            smallint;
define _cnt             integer;
define _nueva_renov     char(1);
define _porc            decimal(16,2);
define _porc_feria      decimal(16,2);
define _porc_vehic      decimal(16,2);
define _cod_subramo     char(3);
define _descuento_max    smallint;
define _descuento_modelo smallint;
define _descuento_vehic  smallint;
define _cod_tipo_tar     char(3);

--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;

let _tipo = 0;
let _cod_tipo_tar = "";
select cod_ramo,
       cod_subramo,
       nueva_renov,
	   cod_grupo
  into _cod_ramo,
       _cod_subramo,
	   _nueva_renov,
	   _cod_grupo
  from emipomae
 where no_poliza = a_poliza;

if _cod_ramo Not in('002','023') then
	return 0;
end if

if _nueva_renov <> 'N' then	--Solo Nuevas
	return 0;
end if

foreach

	select no_unidad,
	       cod_producto
	  into _no_unidad,
	       _cod_producto
	  from emipouni
	 where no_poliza = a_poliza

	let _tipo = sp_proe75(a_poliza,_no_unidad);
	 
	if _tipo = 1 or _tipo = 2 or _tipo = 3 then  --Es sedan, suv o pickup
				
		SELECT count(*)
	      INTO _cnt
		  FROM prdcobpd p, emipocob e
		 WHERE p.cod_cobertura = e.cod_cobertura
		   AND p.cod_producto  = _cod_producto
		   AND p.tipo_descuento in (1,2)
		   AND e.no_poliza = a_poliza
		   AND e.no_unidad = _no_unidad;
		   
		let _porc = 0;
		let _porc_feria = 0;
		let _porc_vehic = 0;
		
		let _descuento_max = 0;
		let _descuento_modelo = 0;
		let _descuento_vehic = 0;
		
	    if _cnt > 0 then		
			select count(*)
			  into _descuento_max
			  from emicobde
			 where no_poliza = a_poliza
			   and no_unidad = _no_unidad
			   and cod_descuen = '004'; 
			
			select count(*)
			  into _descuento_modelo
			  from emicobde
			 where no_poliza = a_poliza
			   and no_unidad = _no_unidad
			   and cod_descuen = '005'; 
			   
			select count(*)
			  into _descuento_vehic
			  from emicobde
			 where no_poliza = a_poliza
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
			if _cod_grupo = '77850' then
				let _cod_tipo_tar = '009';
			end if
			update emipouni
			   set cod_tipo_tar = _cod_tipo_tar	--descuento por feria
			 where no_poliza = a_poliza
			   and no_unidad = _no_unidad;
		end if
		   
	   { if _cnt > 0 then
		    if _cod_ramo = '002' and _cod_subramo = '001' then
				let _porc_vehic = sp_proe85(a_poliza,_no_unidad); -- Descuento por Vehiculo Clasificado 
				if _porc_vehic > 0 then
					update emipouni
					   set cod_tipo_tar = '008'
					 where no_poliza = a_poliza
					   and no_unidad = _no_unidad;
				end if
			end if
			
			if _porc_vehic = 0 then
				let _porc = sp_proe80(a_poliza,_no_unidad); -- Descuento por Modelo
				let _porc_feria = sp_proe82(a_poliza, _no_unidad); -- Descuento por feria
				if _porc = 0 then
					update emipouni
					   set cod_tipo_tar = '002'
					 where no_poliza = a_poliza
					   and no_unidad = _no_unidad;
				else
					update emipouni
					   set cod_tipo_tar = '004'	--descuento por modelo 20/08/2015
					 where no_poliza = a_poliza
					   and no_unidad = _no_unidad;
				end if
				if _cod_producto in ('02206','03005','03012', '03013') then --MotorShow 2016
					update emipouni
					   set cod_tipo_tar = '007'	--descuento por feria
					 where no_poliza = a_poliza
					   and no_unidad = _no_unidad;
				end if
			end if		   	
	    end if
}
	end if

end foreach
end 
return 0;
end procedure;
