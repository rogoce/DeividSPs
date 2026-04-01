-- SD#3394:JEPEREZ- REPORTE PROVEEDOR SIGMA
-- Creado     : 16/05/2022 - Autor: Henry Giron.
-- SD#3394:JEPEREZ- REPORTE PROVEEDOR SIGMA
-- Creado     : 16/05/2022 - Autor: Henry Giron.
DROP procedure sp_pro1106;
CREATE PROCEDURE sp_pro1106(a_fecha date, a_proveedor char(10) default '1', a_coberturas varchar(255) default '*', a_nombre_prov varchar (50) default null )
RETURNING CHAR(20) as No_Poliza, 	
		  VARCHAR(100) as Nombre_Contratante,	
		  VARCHAR(100) as Nombre_Asegurado,	
		  char(30) as Cedula,
		  date as Fecha_Nacimiento,
		  char(20) as Tipo_Asegurado,
		  date as Fecha_Efectividad,
		  VARCHAR(100) as Nombre_Cobertura,
		  char(50) as descr_cia,
		  char(5) as unidad,
		  char(50) as parentesco,
		  char(60) as n_grupo,
		  CHAR(15) as estatus,
		  VARCHAR(50) as proveedor;

 BEGIN

    DEFINE _no_documento        CHAR(20);
    DEFINE _no_poliza           CHAR(10);    
	DEFINE _contratante         CHAR(10);    
	DEFINE _cod_asegurado       CHAR(10);    
	DEFINE _cod_cobertura       CHAR(10);    
    DEFINE _cod_ramo            CHAR(3);
    DEFINE _fecha_efectiva      DATE;
	DEFINE _fecha_nac           DATE;
	DEFINE _fecha_hoy           DATE;       
	DEFINE _fecha_nac_dep       DATE;       	    
    DEFINE _filtros             CHAR(255);    
    DEFINE _descr_cia           CHAR(50);	
	DEFINE _cnt_dep             INTEGER;
	DEFINE _cnt_cob_dep         INTEGER;
	DEFINE _cnt_cobertura       integer;
	DEFINE _n_contratante       VARCHAR(100);
	DEFINE _n_asegurado         VARCHAR(100);
	DEFINE _n_cobertura         VARCHAR(100);	
	define _cedula              char(30);	 
	define _tipo_aseg           char(20);
	define _nombre_depen        char(30);  
	define _cod_cltdepe         char(10);	 
	define _cod_parent          char(3);    
	define _tipo_parent         char(15); 
	define _cedula_depen        char(30);	
	define _n_parentesco        char(50); 
	define _no_unidad           char(5);
	define _cnt_cob_op          SMALLINT;
    DEFINE _cod_grupo           CHAR(5);		
	define _n_grupo			    char(60);
	define _estatus_poliza	    SMALLINT;
	define _n_estatus           CHAR(15);	
	define _n_proveedor         VARCHAR(50);
	
	let _n_proveedor = a_nombre_prov;
	
	drop table if exists tmp_pro1106;
	drop table if exists temp_perfil;
	
	create temp table tmp_pro1106(
			no_documento CHAR(20),
			n_contratante  VARCHAR(100),
			n_asegurado  VARCHAR(100),
			cedula  char(30),
			fecha_nac date,
			tipo_aseg char(20),
			fecha_efectiva date,
			n_cobertura VARCHAR(100),
			descr_cia  CHAR(50),
			no_unidad  CHAR(5),
			parentesco char(50),
			n_grupo	char(60),
			n_estatus  char(15)
			) with no log;
	CREATE INDEX idx1_tmp_pro1106 ON tmp_pro1106(no_documento,no_unidad,n_contratante,n_asegurado,cedula,tipo_aseg);
	
	if a_fecha is null then
		LET a_fecha = TODAY;  
	end if
	LET _fecha_hoy = TODAY;           
    LET _descr_cia = NULL;
    LET _filtros = NULL;
	let _n_estatus = '';
	let _n_grupo = '';
	
	--SET DEBUG FILE TO 'sp_pro1106.trc'; 
   -- trace on;
    SET ISOLATION TO DIRTY READ;

    LET _descr_cia = sp_sis01('001');
	CALL sp_pro03('001','001',_fecha_hoy,"018,004,016;")  RETURNING _filtros;    --vigente al dia de salud. Se agrega ramo 004 a solicitud de Jean Carlos el 23/06/22
	drop table if exists tmp_codigos;
	
	IF a_proveedor = '1' THEN
		CALL sp_pro03h('001','001',_fecha_hoy,"018,004,016;")  RETURNING _filtros;  -- Salud -Vencidas   12/07/2022
		CALL sp_sis04('01862,01822,01823,01824,01825,01826,01827,01828,01829,01830,01831,01840,01853,01857,01863,01867,01868,01899;') returning _filtros;	
		 
		LET _cod_grupo   = NULL;
		LET _n_proveedor = 'SIGMA';
		
		FOREACH
		   SELECT distinct y.no_poliza,
				  y.no_documento,
				  y.cod_ramo,
				  y.cod_contratante,
				  y.cod_grupo			  
			 INTO _no_poliza,
				  _no_documento,
				  _cod_ramo,
				  _contratante,
				  _cod_grupo			  
			 FROM temp_perfil y     
			WHERE seleccionado = 1    		   
		   
			select estatus_poliza
			  into _estatus_poliza
			  from emipomae
			 where no_poliza = _no_poliza;		 
			 
			if _estatus_poliza not in (1,3) then	 --Solo Vigente y Vencidas
				continue foreach;
			end if			 

			if _estatus_poliza = 1 then
				let _n_estatus = "Vigente";	
			elif _estatus_poliza = 3 then
				let _n_estatus = "Vencida";	
			end if					

			let _n_grupo = '';
			
			select trim(nombre)||' - '||trim(_cod_grupo)
			  into _n_grupo
			  from cligrupo
			 where cod_grupo = _cod_grupo;			
			
		    let _cnt_cobertura = 0;       --- polizas coberturas especial
			
			SELECT count(distinct x.cod_asegurado)
			  INTO _cnt_cobertura
			  FROM emipouni x, emipocob y, prdcobpd z
			 WHERE x.no_poliza = _no_poliza
			   AND x.no_poliza = y.no_poliza
			   AND x.no_unidad = y.no_unidad
			   AND z.cod_producto = x.cod_producto
			   AND z.cod_cobertura = y.cod_cobertura			   
			   AND x.vigencia_inic <= _fecha_hoy
			   AND x.activo        = 1
			   AND y.cod_cobertura IN (select codigo  from tmp_codigos );

			if _cnt_cobertura  is null  then
				let _cnt_cobertura = 0;
			end if	   
			   
			if _cnt_cobertura > 0 then --- proveedor solicitado				   
			    SELECT nombre
				  INTO _n_contratante
				  FROM cliclien
				 WHERE cod_cliente = _contratante;	   										

				FOREACH
					SELECT x.no_unidad,x.cod_asegurado, y.cod_cobertura, x.vigencia_inic
					  INTO _no_unidad,_cod_asegurado, _cod_cobertura, _fecha_efectiva          
					  FROM emipouni x, emipocob y, prdcobpd z
					 WHERE y.no_poliza = _no_poliza
					   AND x.no_poliza = y.no_poliza
					   AND x.no_unidad = y.no_unidad
					   AND z.cod_producto = x.cod_producto
					   AND z.cod_cobertura = y.cod_cobertura
					   AND x.no_poliza     = _no_poliza
					   AND x.vigencia_inic <= _fecha_hoy
					   AND x.activo        = 1
					   AND y.cod_cobertura IN (select codigo  from tmp_codigos )
					 
					SELECT nombre,fecha_aniversario,cedula
					  INTO _n_asegurado, _fecha_nac,_cedula
					  FROM cliclien
					 WHERE cod_cliente = _cod_asegurado;
				 
					select trim(cod_cobertura)||'-'||trim(nombre )
					  INTO _n_cobertura	
					  from prdcober
					 where cod_cobertura = _cod_cobertura
					   and cod_ramo = _cod_ramo;	
					   
					begin 
						on exception in(-239)
						end exception
							let _tipo_aseg   = 'Principal';
							LET _nombre_depen 	= "";
							let _cod_cltdepe 	= "";
							let _cod_parent 	= "";
							let _cedula_depen   = "";	
							LET _tipo_parent 	= "";
							let _n_parentesco   = "";																	

						insert into tmp_pro1106(
								no_documento,
								n_contratante,
								n_asegurado,
								cedula,
								fecha_nac,
								tipo_aseg,
								fecha_efectiva,
								n_cobertura,
								descr_cia,
								no_unidad,
								parentesco,
								n_grupo,
								n_estatus)
								Values(
								_no_documento,
								_n_contratante,
								_n_asegurado,
								_cedula,
								_fecha_nac,
								_tipo_aseg,
								_fecha_efectiva,
								_n_cobertura,
								_descr_cia,
								_no_unidad,
								_n_parentesco,
								_n_grupo,
								_n_estatus
								);
					end									   
						 						 
					let _cnt_dep = 0;
					
					SELECT COUNT(*)
					  INTO _cnt_dep
					  FROM emidepen
					 WHERE no_poliza = _no_poliza
					   AND no_unidad = _no_unidad
					   AND activo = 1
					   AND fecha_efectiva <= _fecha_hoy;		 
					  
					IF _cnt_dep IS NULL THEN
					   LET _cnt_dep = 0;
					END IF			  
						
					if _cnt_dep > 0 and _cod_cobertura not in ('01831','01822','01825','01857','01863','01867','01868','01899') then	--SD#6826:HGIRON 13/06/2023  --SD#7108:HG 13/07/2023
								 
						let _cnt_cob_dep = 0;       --- polizas coberturas 
						   
						SELECT count(distinct x.cod_asegurado)
						  INTO _cnt_cob_dep
						  FROM emipouni x, emipocob y, prdcobpd z
						 WHERE y.no_poliza = _no_poliza
						   AND x.no_poliza = y.no_poliza
						   AND x.no_unidad = y.no_unidad
						   AND z.cod_producto = x.cod_producto
						   AND z.cod_cobertura = y.cod_cobertura
						   AND x.no_poliza = _no_poliza
						   AND x.no_unidad = _no_unidad
						   AND x.vigencia_inic <= _fecha_hoy
						   AND x.activo        = 1
						   AND y.cod_cobertura = _cod_cobertura;
					--	and y.cod_cobertura in ('01823','01824','01827','01829','01830') ;

					    if _cnt_cob_dep is null then
							let _cnt_cob_dep = 0;
					    end if	  			   
			 
						if _cnt_cob_dep > 0 then																																	
							foreach		 
								select cod_cliente,
									   cod_parentesco,
									   fecha_efectiva
								  into _cod_cltdepe,
									   _cod_parent,
									   _fecha_efectiva
								  FROM emipouni p, emidepen d
								 WHERE p.no_poliza = _no_poliza
								   AND p.no_unidad = _no_unidad
								   AND p.no_poliza = d.no_poliza
								   AND p.no_unidad = d.no_unidad								
								   AND p.vigencia_inic <= _fecha_hoy
								   AND p.activo = 1
								   AND d.activo = "1"																							

								select nombre, 
										cedula,
										fecha_aniversario														
								  into _nombre_depen, 
										_cedula_depen, 
										_fecha_nac_dep
								  from cliclien 					  
								 where cod_cliente = _cod_cltdepe;			  											 
									
								if _cedula_depen is null then
									let _cedula_depen = _cod_cltdepe;
								end if
							  
								select upper(nombre)
								  into _n_parentesco
								  from emiparen
								 where cod_parentesco   = _cod_parent;				  												 
	   
								begin
									on exception in(-239)
									end exception
									let _tipo_aseg   = 'Dependiente';	

									insert into tmp_pro1106(
											no_documento,
											n_contratante,
											n_asegurado,
											cedula,
											fecha_nac,
											tipo_aseg,
											fecha_efectiva,
											n_cobertura,
											descr_cia,
											no_unidad,
											parentesco,
											n_grupo,
											n_estatus)
											Values(
											_no_documento,
											_n_contratante,
											_nombre_depen,
											_cedula_depen,
											_fecha_nac_dep,
											_tipo_aseg,
											_fecha_efectiva,
											_n_cobertura,
											_descr_cia,
											_no_unidad,
											_n_parentesco,
											_n_grupo,
											_n_estatus
											);
								end									 
							end foreach
						end if	
					end if			
				end foreach			
			end if						
		END FOREACH
	ELIF a_proveedor = '2' THEN
		CALL sp_sis04('01835,01836;') returning _filtros;	
		 
		LET _cod_grupo   = NULL;
		LET _n_proveedor = 'BEST CARE';
		
		FOREACH
		   SELECT distinct y.no_poliza,
				  y.no_documento,
				  y.cod_ramo,
				  y.cod_contratante,
				  y.cod_grupo			  
			 INTO _no_poliza,
				  _no_documento,
				  _cod_ramo,
				  _contratante,
				  _cod_grupo			  
			 FROM temp_perfil y     
			WHERE seleccionado = 1    		   
		   
			select estatus_poliza
			  into _estatus_poliza
			  from emipomae
			 where no_poliza = _no_poliza;		 
			 
			if _estatus_poliza not in (1,3) then	 --Solo Vigente y Vencidas
				continue foreach;
			end if			 

			if _estatus_poliza = 1 then
				let _n_estatus = "Vigente";	
			elif _estatus_poliza = 3 then
				let _n_estatus = "Vencida";	
			end if					

			let _n_grupo = '';
			
			select trim(nombre)||' - '||trim(_cod_grupo)
			  into _n_grupo
			  from cligrupo
			 where cod_grupo = _cod_grupo;			
			
		    let _cnt_cobertura = 0;       --- polizas coberturas especial
			
			SELECT count(distinct x.cod_asegurado)
			  INTO _cnt_cobertura
			  FROM emipouni x, emipocob y, prdcobpd z
			 WHERE x.no_poliza = _no_poliza
			   AND x.no_poliza = y.no_poliza
			   AND x.no_unidad = y.no_unidad
			   AND z.cod_producto = x.cod_producto
			   AND z.cod_cobertura = y.cod_cobertura			   
			   AND x.vigencia_inic <= _fecha_hoy
			   AND x.activo        = 1
			   AND y.cod_cobertura IN (select codigo  from tmp_codigos );

			if _cnt_cobertura  is null  then
				let _cnt_cobertura = 0;
			end if	   
			   
			if _cnt_cobertura > 0 then --- proveedor solicitado				   
			    SELECT nombre
				  INTO _n_contratante
				  FROM cliclien
				 WHERE cod_cliente = _contratante;	   										

				FOREACH
					SELECT x.no_unidad,x.cod_asegurado, y.cod_cobertura, x.vigencia_inic
					  INTO _no_unidad,_cod_asegurado, _cod_cobertura, _fecha_efectiva          
					  FROM emipouni x, emipocob y, prdcobpd z
					 WHERE y.no_poliza = _no_poliza
					   AND x.no_poliza = y.no_poliza
					   AND x.no_unidad = y.no_unidad
					   AND z.cod_producto = x.cod_producto
					   AND z.cod_cobertura = y.cod_cobertura
					   AND x.no_poliza     = _no_poliza
					   AND x.vigencia_inic <= _fecha_hoy
					   AND x.activo        = 1
					   AND y.cod_cobertura IN (select codigo  from tmp_codigos )
					 
					SELECT nombre,fecha_aniversario,cedula
					  INTO _n_asegurado, _fecha_nac,_cedula
					  FROM cliclien
					 WHERE cod_cliente = _cod_asegurado;
				 
					select trim(cod_cobertura)||'-'||trim(nombre )
					  INTO _n_cobertura	
					  from prdcober
					 where cod_cobertura = _cod_cobertura
					   and cod_ramo = _cod_ramo;	
					   
					begin 
						on exception in(-239)
						end exception
							let _tipo_aseg   = 'Principal';
							LET _nombre_depen 	= "";
							let _cod_cltdepe 	= "";
							let _cod_parent 	= "";
							let _cedula_depen   = "";	
							LET _tipo_parent 	= "";
							let _n_parentesco   = "";																	

						insert into tmp_pro1106(
								no_documento,
								n_contratante,
								n_asegurado,
								cedula,
								fecha_nac,
								tipo_aseg,
								fecha_efectiva,
								n_cobertura,
								descr_cia,
								no_unidad,
								parentesco,
								n_grupo,
								n_estatus)
								Values(
								_no_documento,
								_n_contratante,
								_n_asegurado,
								_cedula,
								_fecha_nac,
								_tipo_aseg,
								_fecha_efectiva,
								_n_cobertura,
								_descr_cia,
								_no_unidad,
								_n_parentesco,
								_n_grupo,
								_n_estatus
								);
					end									   
						 						 
					let _cnt_dep = 0;
					
					SELECT COUNT(*)
					  INTO _cnt_dep
					  FROM emidepen
					 WHERE no_poliza = _no_poliza
					   AND no_unidad = _no_unidad
					   AND activo = 1
					   AND fecha_efectiva <= _fecha_hoy;		 
					  
					IF _cnt_dep IS NULL THEN
					   LET _cnt_dep = 0;
					END IF			  
						
--					if _cnt_dep > 0 and _cod_cobertura not in ('01831','01822','01825','01857','01863','01867','01868','01899') then	--SD#6826:HGIRON 13/06/2023  --SD#7108:HG 13/07/2023
								 
						let _cnt_cob_dep = 0;       --- polizas coberturas 
						   
						SELECT count(distinct x.cod_asegurado)
						  INTO _cnt_cob_dep
						  FROM emipouni x, emipocob y, prdcobpd z
						 WHERE y.no_poliza = _no_poliza
						   AND x.no_poliza = y.no_poliza
						   AND x.no_unidad = y.no_unidad
						   AND z.cod_producto = x.cod_producto
						   AND z.cod_cobertura = y.cod_cobertura
						   AND x.no_poliza = _no_poliza
						   AND x.no_unidad = _no_unidad
						   AND x.vigencia_inic <= _fecha_hoy
						   AND x.activo        = 1
						   AND y.cod_cobertura = _cod_cobertura;
					--	and y.cod_cobertura in ('01823','01824','01827','01829','01830') ;

					    if _cnt_cob_dep is null then
							let _cnt_cob_dep = 0;
					    end if	  			   
			 
						if _cnt_cob_dep > 0 then																																	
							foreach		 
								select cod_cliente,
									   cod_parentesco,
									   fecha_efectiva
								  into _cod_cltdepe,
									   _cod_parent,
									   _fecha_efectiva
								  FROM emipouni p, emidepen d
								 WHERE p.no_poliza = _no_poliza
								   AND p.no_unidad = _no_unidad
								   AND p.no_poliza = d.no_poliza
								   AND p.no_unidad = d.no_unidad								
								   AND p.vigencia_inic <= _fecha_hoy
								   AND p.activo = 1
								   AND d.activo = "1"																							

								select nombre, 
										cedula,
										fecha_aniversario														
								  into _nombre_depen, 
										_cedula_depen, 
										_fecha_nac_dep
								  from cliclien 					  
								 where cod_cliente = _cod_cltdepe;			  											 
									
								if _cedula_depen is null then
									let _cedula_depen = _cod_cltdepe;
								end if
							  
								select upper(nombre)
								  into _n_parentesco
								  from emiparen
								 where cod_parentesco   = _cod_parent;				  												 
	   
								begin
									on exception in(-239)
									end exception
									let _tipo_aseg   = 'Dependiente';	

									insert into tmp_pro1106(
											no_documento,
											n_contratante,
											n_asegurado,
											cedula,
											fecha_nac,
											tipo_aseg,
											fecha_efectiva,
											n_cobertura,
											descr_cia,
											no_unidad,
											parentesco,
											n_grupo,
											n_estatus)
											Values(
											_no_documento,
											_n_contratante,
											_nombre_depen,
											_cedula_depen,
											_fecha_nac_dep,
											_tipo_aseg,
											_fecha_efectiva,
											_n_cobertura,
											_descr_cia,
											_no_unidad,
											_n_parentesco,
											_n_grupo,
											_n_estatus
											);
								end									 
							end foreach
						end if	
--					end if			
				end foreach			
			end if						
		END FOREACH
	
    ELSE
		CALL sp_sis04(a_coberturas) returning _filtros;	
		 
		LET _cod_grupo   = NULL;
		
		FOREACH
		   SELECT distinct y.no_poliza,
				  y.no_documento,
				  y.cod_ramo,
				  y.cod_contratante,
				  y.cod_grupo			  
			 INTO _no_poliza,
				  _no_documento,
				  _cod_ramo,
				  _contratante,
				  _cod_grupo			  
			 FROM temp_perfil y     
			WHERE seleccionado = 1    		   
		   
			select estatus_poliza
			  into _estatus_poliza
			  from emipomae
			 where no_poliza = _no_poliza;		 
			 
			if _estatus_poliza not in (1,3) then	 --Solo Vigente y Vencidas
				continue foreach;
			end if			 

			if _estatus_poliza = 1 then
				let _n_estatus = "Vigente";	
			elif _estatus_poliza = 3 then
				let _n_estatus = "Vencida";	
			end if					

			let _n_grupo = '';
			
			select trim(nombre)||' - '||trim(_cod_grupo)
			  into _n_grupo
			  from cligrupo
			 where cod_grupo = _cod_grupo;			
			
		    let _cnt_cobertura = 0;       --- polizas coberturas especial
			
			SELECT count(distinct x.cod_asegurado)
			  INTO _cnt_cobertura
			  FROM emipouni x, emipocob y, prdcobpd z
			 WHERE x.no_poliza = _no_poliza
			   AND x.no_poliza = y.no_poliza
			   AND x.no_unidad = y.no_unidad
			   AND z.cod_producto = x.cod_producto
			   AND z.cod_cobertura = y.cod_cobertura			   
			   AND x.vigencia_inic <= _fecha_hoy
			   AND x.activo        = 1
			   AND y.cod_cobertura IN (select codigo  from tmp_codigos );

			if _cnt_cobertura  is null  then
				let _cnt_cobertura = 0;
			end if	   
			   
			if _cnt_cobertura > 0 then --- proveedor solicitado				   
			    SELECT nombre
				  INTO _n_contratante
				  FROM cliclien
				 WHERE cod_cliente = _contratante;	   										

				FOREACH
					SELECT x.no_unidad,x.cod_asegurado, y.cod_cobertura, x.vigencia_inic
					  INTO _no_unidad,_cod_asegurado, _cod_cobertura, _fecha_efectiva          
					  FROM emipouni x, emipocob y, prdcobpd z
					 WHERE y.no_poliza = _no_poliza
					   AND x.no_poliza = y.no_poliza
					   AND x.no_unidad = y.no_unidad
					   AND z.cod_producto = x.cod_producto
					   AND z.cod_cobertura = y.cod_cobertura
					   AND x.no_poliza     = _no_poliza
					   AND x.vigencia_inic <= _fecha_hoy
					   AND x.activo        = 1
					   AND y.cod_cobertura IN (select codigo  from tmp_codigos )
					 
					SELECT nombre,fecha_aniversario,cedula
					  INTO _n_asegurado, _fecha_nac,_cedula
					  FROM cliclien
					 WHERE cod_cliente = _cod_asegurado;
				 
					select trim(cod_cobertura)||'-'||trim(nombre )
					  INTO _n_cobertura	
					  from prdcober
					 where cod_cobertura = _cod_cobertura
					   and cod_ramo = _cod_ramo;	
					   
					begin 
						on exception in(-239)
						end exception
							let _tipo_aseg   = 'Principal';
							LET _nombre_depen 	= "";
							let _cod_cltdepe 	= "";
							let _cod_parent 	= "";
							let _cedula_depen   = "";	
							LET _tipo_parent 	= "";
							let _n_parentesco   = "";																	

						insert into tmp_pro1106(
								no_documento,
								n_contratante,
								n_asegurado,
								cedula,
								fecha_nac,
								tipo_aseg,
								fecha_efectiva,
								n_cobertura,
								descr_cia,
								no_unidad,
								parentesco,
								n_grupo,
								n_estatus)
								Values(
								_no_documento,
								_n_contratante,
								_n_asegurado,
								_cedula,
								_fecha_nac,
								_tipo_aseg,
								_fecha_efectiva,
								_n_cobertura,
								_descr_cia,
								_no_unidad,
								_n_parentesco,
								_n_grupo,
								_n_estatus
								);
					end									   
						 						 
					let _cnt_dep = 0;
					
					SELECT COUNT(*)
					  INTO _cnt_dep
					  FROM emidepen
					 WHERE no_poliza = _no_poliza
					   AND no_unidad = _no_unidad
					   AND activo = 1
					   AND fecha_efectiva <= _fecha_hoy;		 
					  
					IF _cnt_dep IS NULL THEN
					   LET _cnt_dep = 0;
					END IF			  
						
--					if _cnt_dep > 0 and _cod_cobertura not in ('01831','01822','01825','01857','01863','01867','01868','01899') then	--SD#6826:HGIRON 13/06/2023  --SD#7108:HG 13/07/2023
								 
						let _cnt_cob_dep = 0;       --- polizas coberturas 
						   
						SELECT count(distinct x.cod_asegurado)
						  INTO _cnt_cob_dep
						  FROM emipouni x, emipocob y, prdcobpd z
						 WHERE y.no_poliza = _no_poliza
						   AND x.no_poliza = y.no_poliza
						   AND x.no_unidad = y.no_unidad
						   AND z.cod_producto = x.cod_producto
						   AND z.cod_cobertura = y.cod_cobertura
						   AND x.no_poliza = _no_poliza
						   AND x.no_unidad = _no_unidad
						   AND x.vigencia_inic <= _fecha_hoy
						   AND x.activo        = 1
						   AND y.cod_cobertura = _cod_cobertura;
					--	and y.cod_cobertura in ('01823','01824','01827','01829','01830') ;

					    if _cnt_cob_dep is null then
							let _cnt_cob_dep = 0;
					    end if	  			   
			 
						if _cnt_cob_dep > 0 then																																	
							foreach		 
								select cod_cliente,
									   cod_parentesco,
									   fecha_efectiva
								  into _cod_cltdepe,
									   _cod_parent,
									   _fecha_efectiva
								  FROM emipouni p, emidepen d
								 WHERE p.no_poliza = _no_poliza
								   AND p.no_unidad = _no_unidad
								   AND p.no_poliza = d.no_poliza
								   AND p.no_unidad = d.no_unidad								
								   AND p.vigencia_inic <= _fecha_hoy
								   AND p.activo = 1
								   AND d.activo = "1"																							

								select nombre, 
										cedula,
										fecha_aniversario														
								  into _nombre_depen, 
										_cedula_depen, 
										_fecha_nac_dep
								  from cliclien 					  
								 where cod_cliente = _cod_cltdepe;			  											 
									
								if _cedula_depen is null then
									let _cedula_depen = _cod_cltdepe;
								end if
							  
								select upper(nombre)
								  into _n_parentesco
								  from emiparen
								 where cod_parentesco   = _cod_parent;				  												 
	   
								begin
									on exception in(-239)
									end exception
									let _tipo_aseg   = 'Dependiente';	

									insert into tmp_pro1106(
											no_documento,
											n_contratante,
											n_asegurado,
											cedula,
											fecha_nac,
											tipo_aseg,
											fecha_efectiva,
											n_cobertura,
											descr_cia,
											no_unidad,
											parentesco,
											n_grupo,
											n_estatus)
											Values(
											_no_documento,
											_n_contratante,
											_nombre_depen,
											_cedula_depen,
											_fecha_nac_dep,
											_tipo_aseg,
											_fecha_efectiva,
											_n_cobertura,
											_descr_cia,
											_no_unidad,
											_n_parentesco,
											_n_grupo,
											_n_estatus
											);
								end									 
							end foreach
						end if	
--					end if			
				end foreach			
			end if						
		END FOREACH
	END IF
	
	let _n_grupo = '';
foreach
	 select no_documento,
			n_contratante,
			n_asegurado,
			cedula,
			fecha_nac,
			tipo_aseg,
			fecha_efectiva,
			n_cobertura,
			descr_cia,
			no_unidad,
			parentesco,
			n_grupo,
			n_estatus
	  into 	_no_documento,
		   _n_contratante,
		   _n_asegurado,
		   _cedula,
		   _fecha_nac,				   
		   _tipo_aseg, 
		   _fecha_efectiva,				   
		   _n_cobertura,
			_descr_cia	,
			_no_unidad,
			_n_parentesco,
			_n_grupo,
			_n_estatus
	  from tmp_pro1106
	 order by no_documento,no_unidad,tipo_aseg desc,n_contratante,cedula	 	

	return	_no_documento,
	       _n_contratante,
		   _n_asegurado,
		   _cedula,
		   _fecha_nac,				   
		   _tipo_aseg, 
		   _fecha_efectiva,				   
		   _n_cobertura,
			_descr_cia,	
            _no_unidad,
			_n_parentesco,
			_n_grupo,
			_n_estatus,
			_n_proveedor
	  with resume;			  
end foreach

drop table tmp_pro1106;
drop table temp_perfil;
drop table tmp_codigos;
END
END PROCEDURE;