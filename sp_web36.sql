-- Procedimiento que genera la informacion para los usuarios de panama asistencia
-- Creado:	26/07/2016 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
drop procedure sp_web36;
create procedure sp_web36(a_opcion integer, a_parametro varchar(50))
returning VARCHAR(25),
          date,
		  date,
		  varchar(25),
		  varchar(25),
		  varchar(60),
		  varchar(20),
		  date,
		  varchar(50),
		  varchar(50),
		  varchar(10),
		  varchar(10),
		  varchar(10),
		  varchar(10),
		  varchar(5),
		  varchar(1),
		  varchar(4),
		  varchar(10),
		  varchar(20),
		  varchar(25),
		  varchar(3),
		  varchar(50);	  
define v_no_documento 		char(20);
define v_no_poliza 			char(10);
define v_estatus_poliza     smallint;
define v_nombre_marca       char(50);
define v_nombre_modelo      char(50);
define v_sql                lvarchar;
define v_from               lvarchar;
define v_where              lvarchar;
define v_consulta           lvarchar;
DEFINE v_por_vencer     	DEC(16,2);	 
DEFINE v_exigible       	DEC(16,2);
DEFINE v_corriente			DEC(16,2);
DEFINE v_monto_30			DEC(16,2);
DEFINE v_monto_60			DEC(16,2);
DEFINE v_monto_90			DEC(16,2);
DEFINE v_saldo				DEC(16,2);
DEFINE _total_mor			DEC(16,2);
define v_vigencia_inic		date;
define v_vigencia_final 	date;
DEFINE v_marca			 	VARCHAR(25);
DEFINE v_modelo			 	VARCHAR(25);
DEFINE v_nombre			 	VARCHAR(60);
DEFINE v_cedula  			VARCHAR(20);
DEFINE v_fecha_aniversario 	DATE;
define _direccion_1         varchar(50);
define _direccion_2         varchar(50);
DEFINE _telefono1       	VARCHAR(10);
DEFINE _telefono2       	VARCHAR(10);
DEFINE _telefono3       	VARCHAR(10);
DEFINE _celular         	VARCHAR(10);
define v_no_unidad      	varchar(5);
DEFINE v_uso_auto	 	 	VARCHAR(1);
DEFINE v_ano_auto		 	VARCHAR(4); 
DEFINE v_placa			 	VARCHAR(10);
DEFINE v_no_motor       	VARCHAR(20);
DEFINE v_no_chasis      	VARCHAR(25);
DEFINE v_asistencia         varchar(3);
DEFINE v_cod_producto       varchar(5);
DEFINE _cod_cobertura       varchar(10);
DEFINE _cod_tipoveh         varchar(3);
DEFINE _fecha               date; 
DEFINE _periodo 	        VARCHAR(7); 
define _no_poliza			varchar(10);
define _cod_grupo           varchar(5);
DEFINE v_edad,_pin      	VARCHAR(4);
define _cod_subramo			varchar(3);
DEFINE _fecha_suspension 	DATE;
define _fecha_hoy  			date;
define _nombre_grupo        varchar(50);
--set debug file to "sp_web36.trc";
--trace on;
CREATE TEMP TABLE tmp_prod_exc (
	cod_producto CHAR(5),
	PRIMARY KEY (cod_producto)) WITH NO LOG;
set isolation to dirty read;
let _fecha 		= today;
let _fecha_hoy    = today;
call sp_sis39(_fecha) RETURNING _periodo;
INSERT INTO tmp_prod_exc
SELECT cod_producto 
  FROM prdprod
 WHERE cod_producto in ('04561','04562','05769','07229','07285','08270'); --,'01496','04486'
--************************************************************************************************************************************************************************************************************************************************		
-- *** Automovil
-- *** Particular, Empresarial
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario,b.direccion_1,b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad,f.uso_auto, e.ano_auto,  e.placa,  e.no_motor,  e.no_chasis, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, cligrupo z";
let v_asistencia = 'C';
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (a.cod_ramo = '002' AND a.cod_subramo in ('001','012')  AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current)  AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005'  AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1)  and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (a.cod_ramo = '002' AND a.cod_subramo in ('001','012')  AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current)  AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005'  AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1)  and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (a.cod_ramo = '002' AND a.cod_subramo in ('001','012')  AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current)  AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005'  AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1)  and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
						let v_por_vencer 	= 0;
						let v_exigible 		= 0;  
						let v_corriente		= 0; 
						let v_monto_30 		= 0;  
						let v_monto_60 		= 0;  
						let v_monto_90 		= 0;  
						let v_saldo 		= 0;
						let _no_poliza = sp_sis21(v_no_documento);
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;
						LET _pin = "";
						let _pin = sp_super21(_no_poliza,v_no_unidad);
						if _pin is null then
							let _pin = '';
						end if
						if _pin = '' then
							let v_asistencia = 'C';
						else
							let v_asistencia = _pin;
						end if
							select fecha_suspension
							  into _fecha_suspension
							  from emipoliza
							 where no_documento = v_no_documento;  
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if   						   
							return v_no_documento, v_vigencia_inic, v_vigencia_final, v_marca, v_modelo, v_nombre, v_cedula, v_fecha_aniversario, _direccion_1, _direccion_2, _telefono1, _telefono2, _telefono3, _celular, v_no_unidad, v_uso_auto, v_ano_auto, v_placa, v_no_motor, v_no_chasis, v_asistencia, _nombre_grupo WITH RESUME;
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;
-- **************************************************************************************************************************************************************************************************************************************************************		
-- *** Automovil
-- *** Comercial, Empresarial, Alquiler, Transporte Publico, Estado		
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario, b.direccion_1, b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad, f.uso_auto, e.ano_auto,  e.placa,  e.no_motor, e.no_chasis, h.cod_cobertura, f.cod_tipoveh, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, emipocob h, cligrupo z";
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND g.no_poliza = h.no_poliza AND g.no_unidad = h.no_unidad AND (a.cod_ramo = '002' AND a.cod_subramo in ('002','012','004','005','003') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND h.cod_cobertura in('00907', '01030', '01141') AND a.actualizado = 1  AND a.linea_rapida <> 1 AND a.estatus_poliza = 1) and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND g.no_poliza = h.no_poliza AND g.no_unidad = h.no_unidad AND (a.cod_ramo = '002' AND a.cod_subramo in ('002','012','004','005','003') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND h.cod_cobertura in('00907', '01030', '01141')	AND a.actualizado = 1  AND a.linea_rapida <> 1 AND a.estatus_poliza = 1) and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND g.no_poliza = h.no_poliza AND g.no_unidad = h.no_unidad AND (a.cod_ramo = '002' AND a.cod_subramo in ('002','012','004','005','003') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND h.cod_cobertura in('00907', '01030', '01141')	AND a.actualizado = 1  AND a.linea_rapida <> 1 AND a.estatus_poliza = 1) and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 _cod_cobertura,
											 _cod_tipoveh,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
					let _no_poliza = sp_sis21(v_no_documento);
						select cod_grupo,
								cod_subramo
						  into _cod_grupo,
							   _cod_subramo
						  from emipomae
						 where no_poliza = _no_poliza;
						IF _cod_cobertura = "01141" THEN  --> 
							LET v_asistencia = "C";
						elif _cod_tipoveh in('010') then	--_cod_tipoveh in('025','042','035','008','009','010')
							let v_asistencia = 'EP';
						ELSE
							LET v_asistencia = "L";
						END IF
						let _pin = '';	
						let _pin = sp_super21(_no_poliza,v_no_unidad);
						if _pin is null then
							let _pin = '';
						end if
						if _pin = '' then
						else
							if _cod_tipoveh in('010') then
								let _pin = 'RCEP';
							end if
							let v_asistencia = _pin;
						end if
						if _cod_subramo = '005' then
							let v_asistencia = "TP";
						end if
						let v_por_vencer 	= 0;
						let v_exigible 		= 0;  
						let v_corriente		= 0; 
						let v_monto_30 		= 0;  
						let v_monto_60 		= 0;  
						let v_monto_90 		= 0;  
						let v_saldo 		= 0;
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;
						select fecha_suspension
						  into _fecha_suspension
						  from emipoliza
						 where no_documento = v_no_documento; 
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if   						   
								return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										_nombre_grupo										 
								WITH RESUME;
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;
-- **************************************************************************************************************************************************************************************************************************************************************
 --*** EL SUBRAMO CERTIFICADO F9 de Maryelys 13/05/2019
-- *** F9 de Maryelys 13/05/2019
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario, b.direccion_1, b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad, f.uso_auto, e.ano_auto,  e.placa,  e.no_motor, e.no_chasis, '', f.cod_tipoveh, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, cligrupo z";
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo  AND a.cod_ramo = '002' AND g.cod_ramo = '002' AND a.cod_subramo in ('016') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND a.actualizado = 1 AND a.estatus_poliza = 1 and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo  AND a.cod_ramo = '002' AND g.cod_ramo = '002' AND a.cod_subramo in ('016') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND a.actualizado = 1 AND a.estatus_poliza = 1 and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo  AND a.cod_ramo = '002' AND g.cod_ramo = '002' AND a.cod_subramo in ('016') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND a.actualizado = 1 AND a.estatus_poliza = 1 and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
									 v_vigencia_inic,
									 v_vigencia_final,
									 v_marca,
									 v_modelo,
									 v_nombre,
									 v_cedula,
									 v_fecha_aniversario,
									 _direccion_1,
									 _direccion_2,
									 _telefono1,
									 _telefono2,
									 _telefono3,
									 _celular,
									 v_no_unidad,
									 v_uso_auto,
									 v_ano_auto,
									 v_placa,
									 v_no_motor,
									 v_no_chasis,
									 _cod_cobertura,
									 _cod_tipoveh,
									 _nombre_grupo;				 
				IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
						let _no_poliza = sp_sis21(v_no_documento);
						select cod_subramo into _cod_subramo from emipomae where no_poliza = _no_poliza;
						foreach 
							select cod_cobertura into _cod_cobertura from emipocob where no_poliza = _no_poliza and no_unidad = v_no_unidad
							IF _cod_cobertura = "01141" THEN  --> --ASISTENCIA VIAL
								LET v_asistencia = "C";
							elif _cod_tipoveh in('010') then	--_cod_tipoveh in('025','042','035','008','009','010')
								let v_asistencia = 'EP';
							ELSE
								LET v_asistencia = "L";
							END IF
						end foreach;
						let _pin = '';	
						let _pin = sp_super21(_no_poliza,v_no_unidad);
						if _pin is null then
							let _pin = '';
						end if
						if _pin = '' then
						else
							if _cod_tipoveh in('010') then
								let _pin = 'RCEP';
							end if
							let v_asistencia = trim(_pin);
						end if
						if _cod_subramo = '005' then
							let v_asistencia = "TP";
						end if
						let v_por_vencer 	= 0;
						let v_exigible 		= 0;  
						let v_corriente		= 0; 
						let v_monto_30 		= 0;  
						let v_monto_60 		= 0;  
						let v_monto_90 		= 0;  
						let v_saldo 		= 0;
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;
						select fecha_suspension
						  into _fecha_suspension
						  from emipoliza
						 where no_documento = v_no_documento; 
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;  
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if   						   
								  return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										_nombre_grupo										 
										WITH RESUME;
					 end if
				ELSE
					EXIT;
				END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;	
-- **************************************************************************************************************************************************************************************************************************************************************
 --*** Soda  MULTIPOLIZA RAMO 024
-- *** Particular, Empresarial	
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario, b.direccion_1, b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad, f.uso_auto, e.ano_auto,  e.placa,  e.no_motor, e.no_chasis, cod_producto, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, cligrupo z";
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND a.cod_ramo = '024' AND g.cod_ramo = '020' AND a.cod_subramo in ('001') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.estatus_poliza = 1 and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND a.cod_ramo = '024' AND g.cod_ramo = '020' AND a.cod_subramo in ('001') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.estatus_poliza = 1 and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND a.cod_ramo = '024' AND g.cod_ramo = '020' AND a.cod_subramo in ('001') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.estatus_poliza = 1 and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 v_cod_producto,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
						IF v_cod_producto = "02520" THEN
							LET v_asistencia = "S1";
						ELIF v_cod_producto = "02521" THEN
							LET v_asistencia = "L";
						ELIF v_cod_producto = "04979" THEN
							LET v_asistencia = "ST";
						ELIF v_cod_producto = "04980" THEN
							LET v_asistencia = "S1T";
						ELIF v_cod_producto = "04981" THEN
							LET v_asistencia = "ST";
						END IF
						if v_cod_producto in('06132','06134','06138','06140') then
							LET v_asistencia = "ST";
						end if	
						let v_por_vencer 	= 0;
						let v_exigible 		= 0;  
						let v_corriente		= 0; 
						let v_monto_30 		= 0;  
						let v_monto_60 		= 0;  
						let v_monto_90 		= 0;  
						let v_saldo 		= 0;
						let _no_poliza = sp_sis21(v_no_documento);
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;
						    select fecha_suspension
							  into _fecha_suspension
							  from emipoliza
							 where no_documento = v_no_documento; 
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if   						   
								return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										_nombre_grupo										 
								WITH RESUME;
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;		
-- **************************************************************************************************************************************************************************************************************************************************************
-- *** Soda RAMO MULTIPOLIZA
-- *** Transporte Publico
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario, b.direccion_1, b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad, f.uso_auto, e.ano_auto,  e.placa,  e.no_motor, e.no_chasis, cod_producto, f.cod_tipoveh, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, cligrupo z";
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND e.cod_marca = c.cod_marca AND a.cod_ramo = '024' AND g.cod_ramo = '020' AND a.cod_subramo in ('003') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND a.actualizado = 1 AND a.estatus_poliza = 1 and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND e.cod_marca = c.cod_marca AND a.cod_ramo = '024' AND g.cod_ramo = '020' AND a.cod_subramo in ('003') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND a.actualizado = 1 AND a.estatus_poliza = 1 and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND e.cod_marca = c.cod_marca AND a.cod_ramo = '024' AND g.cod_ramo = '020' AND a.cod_subramo in ('003') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND a.actualizado = 1 AND a.estatus_poliza = 1 and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 v_cod_producto,
											 _cod_tipoveh,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
							LET v_asistencia = "S";
							IF v_cod_producto in("02494") THEN
								LET v_asistencia = "S";
							ELIF v_cod_producto = "04979" THEN
								LET v_asistencia = "ST";
							ELIF v_cod_producto = "04980" THEN
								LET v_asistencia = "S1T";
							ELIF v_cod_producto = "04981" THEN
								LET v_asistencia = "ST";
							END IF
							let v_por_vencer 	= 0;
							let v_exigible 		= 0;  
							let v_corriente		= 0; 
							let v_monto_30 		= 0;  
							let v_monto_60 		= 0;  
							let v_monto_90 		= 0;  
							let v_saldo 		= 0;
						let _no_poliza = sp_sis21(v_no_documento);
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;	
							select fecha_suspension
							  into _fecha_suspension
							  from emipoliza
							 where no_documento = v_no_documento; 
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if   						   		
								return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										_nombre_grupo										 
								WITH RESUME;
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;	
-- **************************************************************************************************************************************************************************************************************************************************************
-- *** Soda 
-- *** Particular, Empresarial
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario, b.direccion_1, b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad, f.uso_auto, e.ano_auto,  e.placa,  e.no_motor, e.no_chasis, cod_producto, f.cod_tipoveh, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, cligrupo z";
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (((a.cod_ramo = '002' AND a.linea_rapida = 1) OR a.cod_ramo = '020') AND a.cod_subramo in ('001','012') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.estatus_poliza = 1) and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (((a.cod_ramo = '002' AND a.linea_rapida = 1) OR a.cod_ramo = '020') AND a.cod_subramo in ('001','012') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.estatus_poliza = 1) and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (((a.cod_ramo = '002' AND a.linea_rapida = 1) OR a.cod_ramo = '020') AND a.cod_subramo in ('001','012') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.estatus_poliza = 1) and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 v_cod_producto,
											 _cod_tipoveh,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
							IF v_cod_producto in("01496","01606","01961") THEN  --> Producto SODA EXPRESS, SE MARCA CON S EN ASISTENCIA. ARMANDO 29/02/2016
								LET v_asistencia = "S";
							ELIF v_cod_producto = "01492" THEN  --> Producto SODA EXPRESS +, SE MARCA CON S1 EN ASISTENCIA. ARMANDO 29/02/2016
								LET v_asistencia = "S1";
							ELIF v_cod_producto = "04979" THEN
								LET v_asistencia = "ST";
							ELIF v_cod_producto = "04980" THEN
								LET v_asistencia = "S1T";
							ELIF v_cod_producto = "04981" THEN
								LET v_asistencia = "ST";
							ELSE
								LET v_asistencia = "C";
							END IF
							if v_cod_producto in('06132','06134','06138','06140') then
								LET v_asistencia = "ST";
							end if
							let v_por_vencer 	= 0;
							let v_exigible 		= 0;  
							let v_corriente		= 0; 
							let v_monto_30 		= 0;  
							let v_monto_60 		= 0;  
							let v_monto_90 		= 0;  
							let v_saldo 		= 0;	
						let _no_poliza = sp_sis21(v_no_documento);
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;	
						select fecha_suspension
						  into _fecha_suspension
						  from emipoliza
						 where no_documento = v_no_documento; 							 
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if   						   
								return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										_nombre_grupo										 
								WITH RESUME;
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;	
--************************************************************************************************************************************************************************************************************************************************		
-- *** Soda
-- *** Comercial, Alquiler, Transporte Publico, Estado
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario,b.direccion_1,b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad,f.uso_auto, e.ano_auto,  e.placa,  e.no_motor,  e.no_chasis, cod_producto, f.cod_tipoveh, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, cligrupo z";
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " where a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND e.cod_marca = c.cod_marca AND (((a.cod_ramo = '002' AND a.linea_rapida = 1) OR a.cod_ramo = '020') AND a.cod_subramo in ('002','004','005','003','012') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND g.vigencia_final >= date(current) AND a.actualizado = 1 AND a.estatus_poliza = 1) and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " where a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND e.cod_marca = c.cod_marca AND (((a.cod_ramo = '002' AND a.linea_rapida = 1) OR a.cod_ramo = '020') AND a.cod_subramo in ('002','004','005','003','012') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND g.vigencia_final >= date(current) AND a.actualizado = 1 AND a.estatus_poliza = 1) and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " where a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND e.cod_marca = c.cod_marca AND (((a.cod_ramo = '002' AND a.linea_rapida = 1) OR a.cod_ramo = '020') AND a.cod_subramo in ('002','004','005','003','012') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.cod_producto not in(select cod_producto from tmp_prod_exc) AND g.vigencia_final >= date(current) AND a.actualizado = 1 AND a.estatus_poliza = 1) and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 v_cod_producto,
											 _cod_tipoveh,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
						--LET v_asistencia = "L";
						LET v_asistencia = "S";
						IF v_cod_producto = "01738" THEN  --> Producto Taxi City va Completo o Ilimitada cambio por Sabish 02/01/2013 Amado
							LET v_asistencia = "C";	 
							-- continue foreach;			 -- > Favor eliminar el producto 01738 de la ruta a panama asistencia por Sabish 15/05/2013 Amado, Edgar lo mando a activar 22/05/2013
						END IF
						IF v_cod_producto in("01496","01606","01961") THEN  --> Producto SODA EXPRESS, SE MARCA CON S EN ASISTENCIA. ARMANDO 29/02/2016
							LET v_asistencia = "S";
						ELIF v_cod_producto = "01492" THEN  --> Producto SODA EXPRESS +, SE MARCA CON S1 EN ASISTENCIA. ARMANDO 29/02/2016
							LET v_asistencia = "S1";
						ELIF v_cod_producto = "04979" THEN
							LET v_asistencia = "ST";
						ELIF v_cod_producto = "04980" THEN
							LET v_asistencia = "S1T";
						ELIF v_cod_producto = "04981" THEN
							LET v_asistencia = "ST";
						END IF
						let v_por_vencer 	= 0;
						let v_exigible 		= 0;  
						let v_corriente		= 0; 
						let v_monto_30 		= 0;  
						let v_monto_60 		= 0;  
						let v_monto_90 		= 0;  
						let v_saldo 		= 0;
						let _no_poliza = sp_sis21(v_no_documento);
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;	
							select fecha_suspension
							  into _fecha_suspension
							  from emipoliza
							 where no_documento = v_no_documento; 
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if  			
								return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										 _nombre_grupo										 
								WITH RESUME;
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;
--************************************************************************************************************************************************************************************************************************************************		
-- *** Automovil Flota
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario,b.direccion_1,b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad,f.uso_auto, e.ano_auto,  e.placa,  e.no_motor,  e.no_chasis, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, cligrupo z";
let v_asistencia = 'C';
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (a.cod_ramo = '023' AND a.cod_subramo = '004' AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)) and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (a.cod_ramo = '023' AND a.cod_subramo = '004' AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)) and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND (a.cod_ramo = '023' AND a.cod_subramo = '004' AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND f.cod_tipoveh = '005' AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)) and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
						let _no_poliza = sp_sis21(v_no_documento);
						let v_asistencia = 'FC';
						let _pin = '';	
						let _pin = sp_super21(_no_poliza,v_no_unidad);
						if _pin is null then
							let _pin = '';
						end if
						if _pin = '' then
						else
							let v_asistencia = "F"||trim(_pin);
						end if
						let v_por_vencer 	= 0;
						let v_exigible 		= 0;  
						let v_corriente		= 0; 
						let v_monto_30 		= 0;  
						let v_monto_60 		= 0;  
						let v_monto_90 		= 0;  
						let v_saldo 		= 0;		
						select cod_grupo
						  into _cod_grupo
						  from emipomae
						 where no_poliza = _no_poliza;				 
						select fecha_suspension
						  into _fecha_suspension
						  from emipoliza
						 where no_documento = v_no_documento; 
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if
							select cod_producto 
							  into v_cod_producto 
							  from emipouni
							 where no_poliza = _no_poliza
							   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if  
								return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										 _nombre_grupo										 
								WITH RESUME;
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;	
-- **************************************************************************************************************************************************************************************************************************************************************		
-- Automovil Flota -- Empresarial, Transporte publico - cobertura limitada 01310	
let v_sql 	= "SELECT a.no_documento, a.vigencia_inic, a.vigencia_final, c.nombre, d.nombre, b.nombre, b.cedula, b.fecha_aniversario, b.direccion_1, b.direccion_2, b.telefono1, b.telefono2, b.telefono3, b.celular, g.no_unidad, f.uso_auto, e.ano_auto,  e.placa,  e.no_motor, e.no_chasis, h.cod_cobertura, f.cod_tipoveh, z.nombre";
let v_from 	= " FROM emipomae a, emimarca c, emimodel d, cliclien b, emipouni g, emiauto f, emivehic e, emipocob h, cligrupo z";
-- Busqueda por Cedula---------
if a_opcion = 0 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND g.no_poliza = h.no_poliza AND g.no_unidad = h.no_unidad AND (a.cod_ramo = '023' AND a.cod_subramo in ('004','005','003','006') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND h.cod_cobertura in ('01310','01341') AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)) and cedula = '"||a_parametro||"'; ";
-- Busqueda por Poliza---------	
elif a_opcion = 1 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND g.no_poliza = h.no_poliza AND g.no_unidad = h.no_unidad AND (a.cod_ramo = '023' AND a.cod_subramo in ('004','005','003','006') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND h.cod_cobertura in ('01310','01341') AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)) and no_documento = '"||a_parametro||"'; ";
-- Busqueda por placa---------	
elif a_opcion = 2 then
	let v_where = " WHERE a.cod_contratante = b.cod_cliente and a.cod_grupo = z.cod_grupo AND a.no_poliza = g.no_poliza AND g.no_poliza = f.no_poliza AND g.no_unidad = f.no_unidad AND f.no_motor = e.no_motor AND e.cod_marca = c.cod_marca AND e.cod_marca = d.cod_marca AND e.cod_modelo = d.cod_modelo AND g.no_poliza = h.no_poliza AND g.no_unidad = h.no_unidad AND (a.cod_ramo = '023' AND a.cod_subramo in ('004','005','003','006') AND a.cod_tipoprod in ('001','005') AND g.vigencia_inic <= date(current) AND g.vigencia_final >= date(current) AND h.cod_cobertura in ('01310','01341') AND a.actualizado = 1 AND a.linea_rapida <> 1 AND a.estatus_poliza = 1 AND g.cod_producto not in(select cod_producto from tmp_prod_exc)) and placa = '"||a_parametro||"'; ";
end if	
	let v_consulta = v_sql || v_from || v_where;
	prepare equisql from v_consulta;	
		declare equicur cursor for equisql;
		open equicur;
			while (1 = 1)
				fetch equicur into	 v_no_documento,
											 v_vigencia_inic,
											 v_vigencia_final,
											 v_marca,
											 v_modelo,
											 v_nombre,
											 v_cedula,
											 v_fecha_aniversario,
											 _direccion_1,
											 _direccion_2,
											 _telefono1,
											 _telefono2,
											 _telefono3,
											 _celular,
											 v_no_unidad,
											 v_uso_auto,
											 v_ano_auto,
											 v_placa,
											 v_no_motor,
											 v_no_chasis,
											 _cod_cobertura,
											 _cod_tipoveh,
											 _nombre_grupo;				   
				  IF (SQLCODE != 100) THEN
					if v_no_documento is not null or trim(v_no_documento) <> '' then
						IF _cod_cobertura = "01341" THEN  --> 
							LET v_asistencia = "FC";
						ELIF _cod_tipoveh in('010') then
							let v_asistencia = 'FEP'; --let v_asistencia = 'FEP';
						ELSE	
							LET v_asistencia = "FL";
						END IF
						let v_por_vencer 	= 0;
						let v_exigible 		= 0;  
						let v_corriente		= 0; 
						let v_monto_30 		= 0;  
						let v_monto_60 		= 0;  
						let v_monto_90 		= 0;  
						let v_saldo 		= 0;
						let _no_poliza = sp_sis21(v_no_documento);
						select cod_grupo,
								cod_subramo
						  into _cod_grupo,
							   _cod_subramo
						  from emipomae
						 where no_poliza = _no_poliza;	
						select fecha_suspension
						  into _fecha_suspension
						  from emipoliza
						 where no_documento = v_no_documento;
						if _fecha_suspension < _fecha_hoy and v_no_documento not in ('0210-01288-01', '2315-000107-01','0221-01883-01') and _cod_grupo <> "1090" then -- Se agrega la poliza Rapid Group Associated - Amado 27-10-2021 solicitud # 1823
							if _cod_grupo in('77850','1090','1009','01016','124','00087','125','148','1122','77960','77982') then  --Correo Jesus 18/02/2020 autorizando a estos grupos para que siempre vayan a pma asistencia.  -- SD#3010 77960  11/04/2022 10:00  -- SD#5708 23/02/2023 HG
							else
								continue while;
							end if
						end if			
						select cod_producto 
						  into v_cod_producto 
						  from emipouni
						 where no_poliza = _no_poliza
						   and no_unidad = v_no_unidad;
						if v_cod_producto in ('05769','07229','07285') then -- se excluye producto segun caso F9 34606 Daivis Fernandez. '04561','04562','05769','07229'
							continue while;
						end if
						if v_cod_producto in ('01496','04486') and v_vigencia_inic >= '01/11/2022' then -- ID de la solicitud	# 5085 -- Amado 23-11-2022
							continue while;
						end if  
						CALL sp_cob33("001","001", v_no_documento, _periodo, current) RETURNING v_por_vencer, v_exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo;
						
							if _cod_grupo = "1090" then
								let v_monto_60 = 0;
								let v_monto_90 = 0;
							end if		
						let _pin = '';	
						let _pin = sp_super21(_no_poliza,v_no_unidad);
						if _pin is null then
							let _pin = '';
						end if	
						if _pin = '' then
						else
							if _cod_tipoveh in('010') then
								let _pin = 'RCEP';
							end if
							let v_asistencia = "F"||_pin;
						end if
						if _cod_subramo = '005' then
							let v_asistencia = "TP";
						end if		
						if (v_monto_60 + v_monto_90 > 0) and v_no_documento not in ('0210-01288-01', '2315-000107-01') then --Minsa y BHN
							-- no debe mostrar la poliza.
						else
								return v_no_documento,
										 v_vigencia_inic,
										 v_vigencia_final,
										 v_marca,
										 v_modelo,
										 v_nombre,
										 v_cedula,
										 v_fecha_aniversario,
										 _direccion_1,
										 _direccion_2,
										 _telefono1,
										 _telefono2,
										 _telefono3,
										 _celular,
										 v_no_unidad,
										 v_uso_auto,
										 v_ano_auto,
										 v_placa,
										 v_no_motor,
										 v_no_chasis,
										 v_asistencia,
										 _nombre_grupo										 
								WITH RESUME;
						end if
					end if
				  ELSE
					EXIT;
				  END IF
			END WHILE
		close equicur;	
		free equicur;
		free equisql;
		DROP TABLE tmp_prod_exc;
end procedure