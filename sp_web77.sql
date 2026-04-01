-- Procedimiento que genera la informacion del sistema de revisiones para los usuarios que van a prestar el servicio de revisado
-- Creado:	23/07/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web77;
 
create procedure sp_web77(a_opcion integer, a_parametro varchar(50))
returning char(20),
          char(5),
		  char(10),
          char(50),
          char(50),
          char(50),
          smallint,
          char(10),
          date,
		  date,
		  varchar(30),
		  char(3);
		  
define v_no_documento 		char(20);
define v_no_poliza 			char(10);
define v_estatus_poliza     smallint;
define v_no_unidad          char(5);
define v_nombre             char(50);
define v_no_motor           char(50);
define v_vigencia_inic      date;
define v_vigencia_final     date;
define v_nombre_marca       char(50);
define v_nombre_modelo      char(50);
define v_ano_auto           smallint;
define v_placa              char(10);
define v_cod_producto		char(5);
define v_cod_ramo			char(3);
define cnt_cober_flota      smallint;
define cnt_cober_auto		smallint;
define v_cedula				varchar(30);

--set debug file to "sp_web77.trc";
--trace on;

set isolation to dirty read;
-- Busqueda por Cedula---------
	if a_opcion = 0 then
		foreach
			select no_documento,
				   nombre, 
				   emipomae.vigencia_inic,
				   emipomae.vigencia_final,
				   estatus_poliza,
				   emipomae.no_poliza,
				   emipomae.cod_ramo,
				   emipouni.no_unidad,
				   cod_producto, 
				   cedula
			  into v_no_documento,
				   v_nombre,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_estatus_poliza,
				   v_no_poliza,
				   v_cod_ramo,
				   v_no_unidad,
				   v_cod_producto,
				   v_cedula
			  from cliclien inner join emipouni on cod_asegurado = cod_cliente
			 inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			 where cedula 			= a_parametro
			   and emipomae.cod_ramo in('018','016','004','019')
			   and estatus_poliza 	= 1
			   and actualizado      = 1
			   and emipouni.activo 	= 1

			let v_nombre_marca = "";
			let v_nombre_modelo = "";
			let v_ano_auto = "";
			let v_placa = "";

			--call sp_sis21(v_no_documento)returning v_no_poliza;

				return v_no_documento,
					   v_no_unidad,
					   v_no_poliza,
					   v_nombre,
					   v_nombre_marca,
					   v_nombre_modelo,
					   v_ano_auto,
					   v_placa,
					   v_vigencia_inic,
					   v_vigencia_final,
					   v_cedula,
					   v_cod_ramo
					   WITH RESUME;
		end foreach;
		foreach
			select no_documento,
				   nombre, 
				   a.vigencia_inic,
				   a.vigencia_final,
				   estatus_poliza,
				   a.no_poliza,
				   a.cod_ramo,
				   b.no_unidad,
				   cod_producto,
				   cedula
			  into v_no_documento,
				   v_nombre,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_estatus_poliza,
				   v_no_poliza,
				   v_cod_ramo,
				   v_no_unidad,
				   v_cod_producto,
				   v_cedula
			  from emipomae a inner join emipouni b on a.no_poliza = b.no_poliza
              inner join emidepen c on b.no_poliza = c.no_poliza
              inner join cliclien d on d.cod_cliente = c.cod_cliente
			 where (cedula 		= a_parametro
			   and a.cod_ramo in('018','016','004','019')
			  and estatus_poliza 	= 1
			   and actualizado      = 1
			   and b.activo 	= 1
               and c.activo 	= 1
               and c.no_unidad =  b.no_unidad )

			let v_nombre_marca = "";
			let v_nombre_modelo = "";
			let v_ano_auto = "";
			let v_placa = "";

			--call sp_sis21(v_no_documento)returning v_no_poliza;

				return v_no_documento,
					   v_no_unidad,
					   v_no_poliza,
					   v_nombre,
					   v_nombre_marca,
					   v_nombre_modelo,
					   v_ano_auto,
					   v_placa,
					   v_vigencia_inic,
					   v_vigencia_final,
					   v_cedula,
					   v_cod_ramo					   
					   WITH RESUME;
		end foreach;
	end if
-- Busqueda por Poliza--
	if a_opcion = 1 then	
		foreach
			select no_documento,
				   nombre, 
				   emipomae.vigencia_inic,
				   emipomae.vigencia_final,
				   estatus_poliza,
				   emipomae.no_poliza,
				   emipomae.cod_ramo,
				   emipouni.no_unidad,
				   cod_producto,
				   cedula
			  into v_no_documento,
				   v_nombre,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_estatus_poliza,
				   v_no_poliza,
				   v_cod_ramo,
				   v_no_unidad,
				   v_cod_producto,
				   v_cedula
			  from cliclien inner join emipouni on cod_asegurado = cod_cliente
			 inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			 where no_documento 	= a_parametro
			   and emipomae.cod_ramo in('018','016','004','019')
			   and estatus_poliza 	= 1
			   and actualizado      = 1
			   and emipouni.activo 	= 1
			  
			let v_nombre_marca = "";
			let v_nombre_modelo = "";
			let v_ano_auto = "";
			let v_placa = "";
			
			--call sp_sis21(v_no_documento)returning v_no_poliza;

				return v_no_documento,
					   v_no_unidad,
					   v_no_poliza,
					   v_nombre,
					   v_nombre_marca,
					   v_nombre_modelo,
					   v_ano_auto,
					   v_placa,
					   v_vigencia_inic,
					   v_vigencia_final,
                       v_cedula,
					   v_cod_ramo					   
					   WITH RESUME;

		end foreach;
		foreach
			select no_documento,
				   nombre, 
				   a.vigencia_inic,
				   a.vigencia_final,
				   estatus_poliza,
				   a.no_poliza,
				   a.cod_ramo,
				   b.no_unidad,
				   cod_producto,
				   cedula
			  into v_no_documento,
				   v_nombre,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_estatus_poliza,
				   v_no_poliza,
				   v_cod_ramo,
				   v_no_unidad,
				   v_cod_producto,
				   v_cedula
			  from emipomae a inner join emipouni b on a.no_poliza = b.no_poliza
             inner join emidepen c on b.no_poliza = c.no_poliza
             inner join cliclien d on d.cod_cliente = c.cod_cliente
			 where ( no_documento = a_parametro
			   and a.cod_ramo in('018','016','004','019')
			  and estatus_poliza 	= 1
			   and actualizado      = 1
			   and b.activo 	    = 1
               and c.activo 	= 1
               and c.no_unidad =  b.no_unidad )
			  
			let v_nombre_marca = "";
			let v_nombre_modelo = "";
			let v_ano_auto = "";
			let v_placa = "";
			
			--call sp_sis21(v_no_documento)returning v_no_poliza;

				return v_no_documento,
					   v_no_unidad,
					   v_no_poliza,
					   v_nombre,
					   v_nombre_marca,
					   v_nombre_modelo,
					   v_ano_auto,
					   v_placa,
					   v_vigencia_inic,
					   v_vigencia_final,
					   v_cedula,
					   v_cod_ramo					   
					   WITH RESUME;

		end foreach;

	end if	
end procedure