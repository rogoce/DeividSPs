---------------------------------------------
---  PERFIL DE CARTERA - RAMOS PERSONAS   ---
---            POLIZAS VIGENTES           ---
---       Amado Pérez M. 03-04-2024       ---       
---------------------------------------------

drop procedure spj_pro602;
create procedure spj_pro602(
a_codramo	char(255) default "*",
a_subramo   char(255) default "*")
returning	varchar(255);

define v_filtros			varchar(255);
define _no_documento		char(20);
define v_cod_subramo		char(3);
define v_contratante		char(10);
define _no_factura			char(10);
define _no_poliza			char(10);
define v_usuario			char(8);
define _periodo				char(7);
define v_cod_agente			char(5);
define v_cod_grupo			char(5);
define ano					char(4);
define v_cod_tipoprod		char(3);
define v_cod_sucursal		char(3);
define v_cod_ramo			char(3);
define mes1					char(2);
define _tipo				char(1);
define v_porc_partic		dec(5,2);
define v_prima_retenida		dec(16,2);
define v_prima_suscrita		dec(16,2);
define v_suma_asegurada		dec(16,2);
define v_prima_bruta		dec(16,2);
define mes					smallint;
define v_vigencia_final		date;
define v_fecha_suscrip		date;
define v_vigencia_inic		date;
define _fecha_cancelacion	date;
define _fecha_emision		date;
define a_periodo	        date;
define _cod_producto        char(5);
define _cnt                 integer;
define _nombre              varchar(50);
define _cod_ramo            char(3);
define _cod_subramo         char(3);
DEFINE _no_unidad           CHAR(5);
DEFINE _cod_asegurado		CHAR(10);
define _nombre_aseg		    char(100);
define _nombre_contratante	char(100);
define _desc_producto       CHAR(100);	
define _nombre_ramo		    char(50);
define _nombre_subramo   	char(50); 

let a_periodo = today; 
let _no_unidad = '';

let _nombre_aseg = '';
let _nombre_contratante = '';
let _desc_producto = '';

--Se crea la tabla temporal que contendra la información del proceso
create temp table temp_producto(
cod_producto        char(5),
nombre              varchar(50),
cod_ramo			char(3),
cod_subramo			char(3),
seleccionado		smallint default 1) with no log;

create temp table temp_perfil(
no_poliza			char(10),
cod_producto        char(5),
cnt                 integer,
no_documento		char(20),
no_factura			char(10),
cod_ramo			char(3),
cod_subramo			char(3),
cod_sucursal		char(3),
cod_grupo			char(5),
cod_tipoprod		char(3),
cod_contratante		char(10),
cod_agente			char(5),
prima_suscrita		dec(16,2),
prima_retenida		dec(16,2),
vigencia_inic		date,
vigencia_final		date,
fecha_suscripcion	date,
usuario				char(08),
suma_asegurada		dec(16,2),
prima_bruta			dec(16,2),
no_unidad           char(5),
cod_asegurado		char(10),
nombre_aseg		    char(100),
nombre_contratante  char(100),
desc_producto		char(100),
nombre_ramo		    char(50),
nombre_subramo   	char(50),
seleccionado		smallint default 1) with no log;
--     PRIMARY KEY(no_poliza))
create index i_perfil1 on temp_perfil(no_poliza);
create index i_perfil2 on temp_perfil(cod_ramo);
create index i_perfil3 on temp_perfil(cod_subramo);
create index i_perfil4 on temp_perfil(cod_tipoprod);
create index i_perfil5 on temp_perfil(cod_sucursal);
create index i_perfil6 on temp_perfil(no_unidad);

--Se inicializan las variables
let v_cod_tipoprod = null;
let v_cod_sucursal = null;
let v_cod_subramo  = null;
let _no_documento = null;
let v_cod_agente = null;
let v_cod_grupo = null;
let _no_factura = null;
let v_cod_ramo = null;
let _no_poliza = null;
let _tipo = null;
let v_prima_suscrita = 0;
let v_prima_retenida = 0;
let v_prima_bruta = 0;
let v_filtros = " ";

{let mes = month(a_periodo);
if mes <= 9 then
	   let mes1[1,1] = '0';
	   let mes1[2,2] = mes;
	else
	   let mes1 = mes;
	end if
    let ano = year(a_periodo);
	let _periodo[1,4] = ano;
	let _periodo[5] = "-";
	let _periodo[6,7] = mes1;}

--Se busca el periodo de la fecha hasta la que se quiere generar el reporte. 
let _periodo = sp_sis39(a_periodo);

--set debug file to "sp_pro03.trc"; 
--trace on;

set isolation to dirty read;

--Se Deben incluir todos los Ramos
if a_codramo = "*" then
	foreach with hold
		select cod_producto,
		       nombre,
			   cod_ramo,
			   cod_subramo
		  into _cod_producto,
		       _nombre,
			   _cod_ramo,
			   _cod_subramo
		  from prdprod
		 where cod_ramo in ('004','016','018','019') 
		   and activo = 1
		
		INSERT INTO temp_producto 
		VALUES (_cod_producto,
				_nombre,
				_cod_ramo,
				_cod_subramo,
				1);
					
	end foreach

	foreach with hold
		select a.no_poliza,
			   a.no_documento,
			   a.no_factura,
			   a.sucursal_origen,
			   a.cod_grupo,
			   a.cod_ramo,
			   a.cod_subramo,
			   a.cod_tipoprod,
			   a.cod_contratante,
			   a.prima_suscrita,
			   a.prima_retenida,
			   a.vigencia_inic,
			   a.vigencia_final,
			   a.fecha_suscripcion,
			   a.user_added,
			   a.suma_asegurada,
			   a.fecha_cancelacion,
			   a.prima_bruta,
			   b.no_unidad,
			   b.cod_asegurado
		  into _no_poliza,
			   _no_documento,
			   _no_factura,
			   v_cod_sucursal,
			   v_cod_grupo,
			   v_cod_ramo,
			   v_cod_subramo,
			   v_cod_tipoprod,
			   v_contratante,
			   v_prima_suscrita,
			   v_prima_retenida,
			   v_vigencia_inic,
			   v_vigencia_final,
			   v_fecha_suscrip,
			   v_usuario,
			   v_suma_asegurada,
			   _fecha_cancelacion,
			   v_prima_bruta,
			   _no_unidad,
			   _cod_asegurado
		  from emipomae a, emipouni b
		 where a.no_poliza = b.no_poliza
           and (a.vigencia_final >= a_periodo or a.vigencia_final is null)
		   and a.fecha_suscripcion <= a_periodo
		   and a.vigencia_inic <= a_periodo
		   and a.actualizado = 1
		   and a.cod_ramo in ('004','016','018','019') 
		   and b.activo = 1

		let _fecha_emision = null;

		if _fecha_cancelacion <= a_periodo then
			--foreach
			select max(fecha_emision)
			  into _fecha_emision
			  from endedmae
			 where no_poliza = _no_poliza
			   and cod_endomov = '002'
			   and actualizado = 1;
				--   and vigencia_inic = _fecha_cancelacion
			--end foreach

			if  _fecha_emision <= a_periodo then
				continue foreach;
			end if
		end if

		foreach
			select cod_agente,
				   porc_partic_agt
			  into v_cod_agente,
				   v_porc_partic
			  from emipoagt
			 where no_poliza = _no_poliza
			exit foreach; 
			-- let v_prima_suscrita = v_prima_suscrita * (v_porc_partic/100);
		end foreach	
		
		foreach
			select a.cod_producto,
			       count(a.no_unidad)
			  into _cod_producto,
			       _cnt
			  from emipouni a, temp_producto b
			 where a.cod_producto = b.cod_producto
			   and a.no_poliza = _no_poliza
			   and b.cod_ramo in ('004','016','018','019') 
			   and b.seleccionado = 1
			   and a.no_unidad = _no_unidad
			   and a.activo = 1
		  group by 1
		  
		  	select trim(nombre)||" - "||trim(cod_cliente)
			  into _nombre_contratante
			  from cliclien
			 where cod_cliente = v_contratante;
			 
		  	select trim(nombre)||" - "||trim(cod_cliente)
			  into _nombre_aseg
			  from cliclien
			 where cod_cliente = _cod_asegurado;			 

			select trim(nombre)||" - "||trim(cod_producto)
			  into _desc_producto
			  from prdprod
		     where cod_producto = _cod_producto;			 

			SELECT trim(nombre)||" - "||trim(cod_ramo)
			  INTO _nombre_ramo
			  FROM prdramo
			 WHERE cod_ramo = v_cod_ramo;

			SELECT trim(nombre)||" - "||trim(cod_subramo)
			  INTO _nombre_subramo
			  FROM prdsubra
			 WHERE cod_ramo = v_cod_ramo
			   AND cod_subramo = v_cod_subramo;			 
			 
				BEGIN
				  ON EXCEPTION IN(-239)
				  END EXCEPTION		
					insert into temp_perfil
					values(	_no_poliza,
							_cod_producto,
							1,
							_no_documento,
							_no_factura,
							v_cod_ramo,
							v_cod_subramo,
							v_cod_sucursal,
							v_cod_grupo,
							v_cod_tipoprod,
							v_contratante,
							v_cod_agente,
							v_prima_suscrita,
							v_prima_retenida,
							v_vigencia_inic,
							v_vigencia_final,
							v_fecha_suscrip,
							v_usuario,
							v_suma_asegurada,
							v_prima_bruta,
							_no_unidad,
							_cod_asegurado,
							_nombre_aseg,
							_nombre_contratante,
							_desc_producto,
							_nombre_ramo,
							_nombre_subramo,
							1);
				END
		end foreach
	end foreach
--Se Debe Aplicar el filtro de Ramos solicitado por el Usuario
else
	--Crear una tabla temporal con los codigos especificados por el usuario
	let _tipo = sp_sis04(a_codramo);
	
	--Se agregan los filtros a la etiqueta de filtros aplicados
	let v_filtros = trim(v_filtros) ||"Ramo "||trim(a_codramo);

	--Se Deben incluir los Ramos especificados
	if _tipo <> "E" then -- incluir los registros
		foreach with hold
			select cod_producto,
				   nombre,
				   cod_ramo,
				   cod_subramo
			  into _cod_producto,
				   _nombre,
				   _cod_ramo,
				   _cod_subramo
			  from prdprod
			 where cod_ramo in (select codigo from tmp_codigos)
			   and activo = 1
			
			INSERT INTO temp_producto 
			VALUES (_cod_producto,
				    _nombre,
				    _cod_ramo,
				    _cod_subramo,
					1);
		end foreach
		
		let _no_unidad = '';
		
		foreach with hold
			select a.no_poliza,
				   a.no_documento,
				   a.no_factura,
				   a.sucursal_origen,
				   a.cod_grupo,
				   a.cod_ramo,
				   a.cod_subramo,
				   a.cod_tipoprod,
				   a.cod_contratante,
				   a.prima_suscrita,
				   a.prima_retenida,
				   a.vigencia_inic,
				   a.vigencia_final,
				   a.fecha_suscripcion,
				   a.user_added,
				   a.suma_asegurada,
				   a.fecha_cancelacion,
				   a.prima_bruta,
				   b.no_unidad,
			       b.cod_asegurado
			  into _no_poliza,
				   _no_documento,
				   _no_factura,
				   v_cod_sucursal,
				   v_cod_grupo,
				   v_cod_ramo,
				   v_cod_subramo,
				   v_cod_tipoprod,
				   v_contratante,
				   v_prima_suscrita,
				   v_prima_retenida,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_fecha_suscrip,
				   v_usuario,
				   v_suma_asegurada,
				   _fecha_cancelacion,
				   v_prima_bruta,
			       _no_unidad,
				   _cod_asegurado
			  from emipomae a, emipouni b
			 where a.no_poliza = b.no_poliza
			   and  a.vigencia_final >= a_periodo
			   and a.fecha_suscripcion <= a_periodo
			   and a.vigencia_inic <= a_periodo
			   and a.actualizado = 1
			   and a.periodo <= _periodo
			   and a.cod_ramo in (select codigo from tmp_codigos)
			   --and (fecha_cancelacion is null or   fecha_cancelacion > a_periodo)

			let _fecha_emision = null;

			if _fecha_cancelacion <= a_periodo then
				--foreach
					select max(fecha_emision)
					  into _fecha_emision
					  from endedmae
					 where no_poliza = _no_poliza
					   and cod_endomov = '002';
					 --  and vigencia_inic = _fecha_cancelacion
				--end foreach

				if  _fecha_emision <= a_periodo then
					continue foreach;
				end if
			end if

			foreach
				select cod_agente,
					   porc_partic_agt
				  into v_cod_agente,
					   v_porc_partic
				  from emipoagt
				 where no_poliza = _no_poliza
				 order by porc_partic_agt desc
				exit foreach;
			end foreach

		foreach
			select a.cod_producto,
			       count(a.no_unidad)
			  into _cod_producto,
			       _cnt
			  from emipouni a, temp_producto b
			 where a.cod_producto = b.cod_producto
			   and a.no_poliza = _no_poliza
			   and b.seleccionado = 1
			   and a.no_unidad = _no_unidad
			   and a.activo = 1			   
		  group by 1
		  
		  	select trim(nombre)||" - "||trim(cod_cliente)
			  into _nombre_contratante
			  from cliclien
			 where cod_cliente = v_contratante;
			 
		  	select trim(nombre)||" - "||trim(cod_cliente)
			  into _nombre_aseg
			  from cliclien
			 where cod_cliente = _cod_asegurado;			 

			select trim(nombre)||" - "||trim(cod_producto)
			  into _desc_producto
			  from prdprod
		     where cod_producto = _cod_producto;			 

			SELECT trim(nombre)||" - "||trim(cod_ramo)
			  INTO _nombre_ramo
			  FROM prdramo
			 WHERE cod_ramo = v_cod_ramo;

			SELECT trim(nombre)||" - "||trim(cod_subramo)
			  INTO _nombre_subramo
			  FROM prdsubra
			 WHERE cod_ramo = v_cod_ramo
			   AND cod_subramo = v_cod_subramo;					 
		  
				BEGIN
				  ON EXCEPTION IN(-239)
				  END EXCEPTION			
					insert into temp_perfil
					values(	_no_poliza,
							_cod_producto,
							1,
							_no_documento,
							_no_factura,
							v_cod_ramo,
							v_cod_subramo,
							v_cod_sucursal,
							v_cod_grupo,
							v_cod_tipoprod,
							v_contratante,
							v_cod_agente,
							v_prima_suscrita,
							v_prima_retenida,
							v_vigencia_inic,
							v_vigencia_final,
							v_fecha_suscrip,
							v_usuario,
							v_suma_asegurada,
							v_prima_bruta,
							_no_unidad,
							_cod_asegurado,
							_nombre_aseg,
							_nombre_contratante,
							_desc_producto,
							_nombre_ramo,
							_nombre_subramo,
							1);
				END
			end foreach
		end foreach
		drop table tmp_codigos;
	else 
		foreach with hold
			select cod_producto,
				   nombre,
				   cod_ramo,
				   cod_subramo
			  into _cod_producto,
				   _nombre,
				   _cod_ramo,
				   _cod_subramo
			  from prdprod
			 where cod_ramo not in (select codigo from tmp_codigos)
			   and activo = 1
			
			INSERT INTO temp_producto 
			VALUES (_cod_producto,
				    _nombre,
				    _cod_ramo,
				    _cod_subramo,
					1);
		end foreach
		let _no_unidad = '';		
		foreach with hold
			select a.no_poliza,
				   a.no_documento,
				   a.no_factura,
				   a.sucursal_origen,
				   a.cod_grupo,
				   a.cod_ramo,
				   a.cod_subramo,
				   a.cod_tipoprod,
				   a.cod_contratante,
				   a.prima_suscrita,
				   a.prima_retenida,
				   a.vigencia_inic,
				   a.vigencia_final,
				   a.fecha_suscripcion,
				   a.user_added,
				   a.suma_asegurada,
				   a.fecha_cancelacion,
				   a.prima_bruta,
				   b.no_unidad,
			       b.cod_asegurado
			  into _no_poliza,
				   _no_documento,
				   _no_factura,
				   v_cod_sucursal,
				   v_cod_grupo,
				   v_cod_ramo,
				   v_cod_subramo,
				   v_cod_tipoprod,
				   v_contratante,
				   v_prima_suscrita,
				   v_prima_retenida,
				   v_vigencia_inic,
				   v_vigencia_final,
				   v_fecha_suscrip,
				   v_usuario,
				   v_suma_asegurada,
				   _fecha_cancelacion,
				   v_prima_bruta,
			       _no_unidad,
				   _cod_asegurado
			  from emipomae a, emipouni b
			 where a.no_poliza = b.no_poliza
			   and a.vigencia_final >= a_periodo
			   and a.fecha_suscripcion <= a_periodo
			   and a.periodo <= _periodo
			   and a.actualizado = 1
			   and a.vigencia_inic <= a_periodo
			   and a.cod_ramo not in(select codigo from tmp_codigos)
			   --and (fecha_cancelacion is null or  fecha_cancelacion > a_periodo)

			let _fecha_emision = null;

			if _fecha_cancelacion <= a_periodo then
				--foreach
					select max(fecha_emision)
					  into _fecha_emision
					  from endedmae
					 where no_poliza = _no_poliza
					   and cod_endomov = '002';
					   --and vigencia_inic = _fecha_cancelacion
				--end foreach

				if  _fecha_emision <= a_periodo then
					continue foreach;
				end if
			end if

			foreach
				select cod_agente,
					   porc_partic_agt
				  into v_cod_agente,
					   v_porc_partic
				  from emipoagt z
				 where z.no_poliza = _no_poliza
				exit foreach;
			end foreach	

			foreach
				select a.cod_producto,
					   count(a.no_unidad)
				  into _cod_producto,
					   _cnt
				  from emipouni a, temp_producto b
				 where a.cod_producto = b.cod_producto
				   and a.no_poliza = _no_poliza
				   and b.seleccionado = 1
				   and a.no_unidad = _no_unidad
				   and a.activo = 1				   
			  group by 1
			  
				select trim(nombre)||" - "||trim(cod_cliente)
				  into _nombre_contratante
				  from cliclien
				 where cod_cliente = v_contratante;
				 
				select trim(nombre)||" - "||trim(cod_cliente)
				  into _nombre_aseg
				  from cliclien
				 where cod_cliente = _cod_asegurado;			 

				select trim(nombre)||" - "||trim(cod_producto)
				  into _desc_producto
				  from prdprod
				 where cod_producto = _cod_producto;			 

				SELECT trim(nombre)||" - "||trim(cod_ramo)
				  INTO _nombre_ramo
				  FROM prdramo
				 WHERE cod_ramo = v_cod_ramo;

				SELECT trim(nombre)||" - "||trim(cod_subramo)
				  INTO _nombre_subramo
				  FROM prdsubra
				 WHERE cod_ramo = v_cod_ramo
				   AND cod_subramo = v_cod_subramo;						 
			 
				BEGIN
				  ON EXCEPTION IN(-239)
				  END EXCEPTION
					insert into temp_perfil
					values(_no_poliza,
						   _cod_producto,
						   1,
						   _no_documento,
						   _no_factura,
						   v_cod_ramo,
						   v_cod_subramo,
						   v_cod_sucursal,
						   v_cod_grupo,
						   v_cod_tipoprod,
						   v_contratante,
						   v_cod_agente,
						   v_prima_suscrita,
						   v_prima_retenida,
						   v_vigencia_inic,
						   v_vigencia_final,
						   v_fecha_suscrip,
						   v_usuario, 
						   v_suma_asegurada,
						   v_prima_bruta,
						   _no_unidad,
						   _cod_asegurado,
						   _nombre_aseg,
						   _nombre_contratante,
						   _desc_producto,
						   _nombre_ramo,
						   _nombre_subramo,
						   1);    
				END						   
			end foreach
		end foreach
		drop table tmp_codigos;
	end if
end if

if a_subramo <> "*" then
	--Crear una tabla temporal con los codigos especificados por el usuario
	let _tipo = sp_sis04(a_subramo);
	
	--Se agregan los filtros a la etiqueta de filtros aplicados
	let v_filtros = trim(v_filtros) ||" Subramo "||trim(a_subramo);
	
	if _tipo <> "E" then -- incluir los registros
		update temp_producto
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in (select codigo from tmp_codigos);	
		
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo not in (select codigo from tmp_codigos);
	else		        -- excluir estos registros
		update temp_producto
		  set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in (select codigo from tmp_codigos);
		
		update temp_perfil
		  set seleccionado = 0
		 where seleccionado = 1
		   and cod_subramo in (select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
	
	
end if

return v_filtros;
end procedure;