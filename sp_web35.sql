-- Procedimiento que genera la informacion del sistema de revisiones para los usuarios que van a prestar el servicio de revisado
-- Creado:	23/07/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web35;
 
create procedure sp_web35(a_opcion integer, a_parametro varchar(50))
returning char(20),
          char(5),
		  char(10),
          char(50),
          char(50),
          char(50),
          smallint,
          char(10),
          date,
		  date;
		  
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

--set debug file to "sp_web33.trc";
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
				   emipouni.no_unidad
			  into v_no_documento,
				   v_nombre,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_estatus_poliza,
				   v_no_poliza,
				   v_no_unidad
			  from cliclien inner join emipomae on cod_contratante = cod_cliente
				   inner join emipouni on emipomae.no_poliza = emipouni.no_poliza
			 where cedula 			= a_parametro
			   and emipomae.cod_ramo in('002','023')
			   and cod_producto in ('02894','02699','03012','03013','03780')
			   and estatus_poliza 	= 1
			   and actualizado      = 1
			  
			--foreach
				{select no_unidad
				  into v_no_unidad
				  from emipouni
				 where no_poliza = v_no_poliza}
				 
				select no_motor
				  into v_no_motor			
				  from emiauto 
				 where no_poliza = v_no_poliza
				   and no_unidad = v_no_unidad;
				   
				select b.nombre,
					   c.nombre,
					   ano_auto,
					   placa
				  into v_nombre_marca,
					   v_nombre_modelo,
					   v_ano_auto,
					   v_placa
				  from emivehic a inner join emimarca b on a.cod_marca = b.cod_marca
				 inner join emimodel c on a.cod_modelo = c.cod_modelo
				 where no_motor = v_no_motor;
				 
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
					   v_vigencia_final				   
					   WITH RESUME;
			--end foreach;
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
				   emipouni.no_unidad
			  into v_no_documento,
				   v_nombre,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_estatus_poliza,
				   v_no_poliza,
				   v_no_unidad
			  from cliclien inner join emipomae on cod_contratante = cod_cliente
			 inner join emipouni on emipomae.no_poliza = emipouni.no_poliza
			 where no_documento 	= a_parametro
			   and emipomae.cod_ramo in('002','023')
			   and cod_producto in ('02894','02699','03012','03013','03780')
			   and estatus_poliza 	= 1
			  
			--foreach
				{select no_unidad
				  into v_no_unidad
				  from emipouni
				 where no_poliza = v_no_poliza}
				 
				select no_motor
				  into v_no_motor			
				  from emiauto 
				 where no_poliza = v_no_poliza
				   and no_unidad = v_no_unidad;
				   
				select b.nombre,
					   c.nombre,
					   ano_auto,
					   placa
				  into v_nombre_marca,
					   v_nombre_modelo,
					   v_ano_auto,
					   v_placa
				  from emivehic a inner join emimarca b on a.cod_marca = b.cod_marca
				 inner join emimodel c on a.cod_modelo = c.cod_modelo
				 where no_motor = v_no_motor;
				 
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
					   v_vigencia_final				   
					   WITH RESUME;
			--end foreach;
		end foreach;
	end if
-- Busqueda por Placa--
	if a_opcion = 2 then	
		foreach
			select no_documento,
				   nombre, 
				   emipomae.vigencia_inic,
				   emipomae.vigencia_final,
				   estatus_poliza,
				   emipomae.no_poliza,
				   emipouni.no_unidad
			  into v_no_documento,
				   v_nombre,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_estatus_poliza,
				   v_no_poliza,
				   v_no_unidad
			 from cliclien inner join emipomae on cod_contratante = cod_cliente
			inner join emipouni on emipomae.no_poliza = emipouni.no_poliza
	        inner join emiauto on emiauto.no_poliza = emipomae.no_poliza
			inner join emivehic on emiauto.no_motor = emivehic.no_motor
			where placa 	= a_parametro
			  and emipomae.cod_ramo in('002','023')
			  and emipouni.no_unidad = emiauto.no_unidad
			  and cod_producto in ('02894','02699','03012','03013','03780')
			  and estatus_poliza 	= 1      

			--foreach
				{select no_unidad
				  into v_no_unidad
				  from emipouni
				 where no_poliza = v_no_poliza}
				 
				select no_motor
				  into v_no_motor			
				  from emiauto 
				 where no_poliza = v_no_poliza
				   and no_unidad = v_no_unidad;
				   
				select b.nombre,
					   c.nombre,
					   ano_auto,
					   placa
				  into v_nombre_marca,
					   v_nombre_modelo,
					   v_ano_auto,
					   v_placa
				  from emivehic a inner join emimarca b on a.cod_marca = b.cod_marca
				 inner join emimodel c on a.cod_modelo = c.cod_modelo
				 where no_motor = v_no_motor;
				 
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
					   v_vigencia_final				   
					   WITH RESUME;
			--end foreach;
		end foreach;
	end if		
end procedure