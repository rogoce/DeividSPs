-- Procedimiento que busca el producto vigente para las polizas de salud modulo de hospitales
-- Creado:	23/07/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web37;
 
create procedure sp_web37(a_no_poliza char(10))
returning char(5),
          char(50),
		  char(50),
          char(10),
          char(5),
		  date;
		  
define v_no_unidad          char(5);
define v_nombre_asegurado   char(50);
define v_nombre_producto    char(50);
define v_cod_cliente        char(10);
define v_cod_producto_emi   char(5); 
define v_cod_producto_end   char(5);
define v_cod_producto       char(5);
define v_vigencia_inic      date;
define v_max_endoso         char(5);

--set debug file to "sp_web33.trc";
--trace on;

set isolation to dirty read;

let v_nombre_producto = '';
let v_cod_producto    = '';

	foreach
		SELECT no_unidad,
			   cliclien.nombre,
			   prdprod.nombre ,
			   cliclien.cod_cliente , 
			   prdprod.cod_producto,
			   emipouni.vigencia_inic
		  into v_no_unidad,
			   v_nombre_asegurado,
			   v_nombre_producto,
			   v_cod_cliente,
			   v_cod_producto_emi,
			   v_vigencia_inic
		  from emipouni
	inner join prdprod on prdprod.cod_producto = emipouni.cod_producto
	inner join cliclien on cod_cliente 		   = cod_asegurado
		 where emipouni.no_poliza = a_no_poliza    
		   and emipouni.activo = '1'
		   
	select max(no_endoso)
	  into v_max_endoso
	  from endedmae
	 where no_poliza = a_no_poliza
	   and endedmae.vigencia_inic <= today
	   and cod_endomov in('011','014');
		
	select cod_producto
	  into v_cod_producto_end
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_unidad = v_no_unidad
	   and no_endoso = v_max_endoso;
	   
	if v_cod_producto_end is null then
		let v_cod_producto_end =  v_cod_producto_emi;
	end if	

	if v_cod_producto_end <> v_cod_producto_emi then
		let v_cod_producto = v_cod_producto_end;
		 select nombre
		   into v_nombre_producto
		   from prdprod
		  where cod_producto =  v_cod_producto_end;
	else
		let v_cod_producto = v_cod_producto_emi;
	end if	   
			return v_no_unidad,
				   v_nombre_asegurado,
				   v_nombre_producto,
				   v_cod_cliente,
				   v_cod_producto,
				   v_vigencia_inic				   
				   WITH RESUME;
	end foreach;	
end procedure