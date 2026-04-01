-- SD#3394:JEPEREZ- REPORTE PROVEEDOR SIGMA
-- Creado     : 16/05/2022 - Autor: Henry Giron.
-- SD#3394:JEPEREZ- REPORTE PROVEEDOR SIGMA
-- Creado     : 16/05/2022 - Autor: Henry Giron.
DROP procedure sp_pro1117;
CREATE PROCEDURE sp_pro1117()
RETURNING CHAR(10) 	as NEMP, 
          DATE 		as FLOTE,
		  CHAR(1) 	as CLOTE,
		  CHAR(1)	as NLOTE_ANEXO,
		  SMALLINT  as NREG,
		  VARCHAR(100)  as CPLAN,
		  CHAR(10)	as UVERSION,
		  CHAR(1)	as CPRODUCTO,
		  CHAR(6)	as CRAMO,
		  CHAR(20)	as CCEDASEGURADO,
		  CHAR(1)	as INACASEG,
		  CHAR(1)	as ITIPOASEG,
		  CHAR(20)	as CCEDTITULAR,
		  CHAR(1)	as INACTIT,
		  CHAR(30)	as XNOMBRE,
		  CHAR(30)	as XAPELLIDO,
		  CHAR(60)	as XNOMAPE,
		  DATE 		as FNACIMIENTO,
		  CHAR(30)	as CNPOLIZA,
		  DATE 		as FDESDE_POL,
		  DATE 		as FHASTA_POL,
		  DATE 		as FDESDE_REC,
		  DATE 		as FHASTA_REC,
		  DATE 		as FDESDE_SIGMA,
		  DATE 		as FHASTA_SIGMA,
		  CHAR(1)	as ITIPOPOL,
		  CHAR(20)	as CCOLECTIVO,
		  VARCHAR(100)	as XNOMCOLECTIVO,
		  CHAR(1)	as SEXO,
		  CHAR(1)	as FORMAPAGO;

 BEGIN

    DEFINE _no_documento        CHAR(20);
    DEFINE _no_poliza           CHAR(10);    
	DEFINE _contratante         CHAR(10);    
	DEFINE _cod_asegurado       CHAR(10);    
	DEFINE _cod_cobertura       CHAR(5);    
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
	DEFINE _n_asegurado         VARCHAR(60);
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
	define _consecutivo         INTEGER;
	define _ced_contratante     char(30);	 
	define _cnt_unidades        INTEGER;
	define _itipopol            CHAR(1);
	define _sexo                CHAR(1);
	define _forma_pago			CHAR(1);
	define _cod_perpago      	CHAR(3);
	define _nombre_aseg         VARCHAR(30);
	define _apellido_aseg		VARCHAR(30);
	define _vigencia_final      DATE;
    define _aseg_primer_nom     VARCHAR(15);
    define _aseg_segundo_nom    VARCHAR(15); 
    define _aseg_primer_ape     VARCHAR(15);
    define _aseg_segundo_ape    VARCHAR(15);
	define _nom_cob             VARCHAR(100);
	define _cramo               VARCHAR(6);
    	
	let _consecutivo = 0;
	
	drop table if exists tmp_pro1106;
	drop table if exists temp_perfil;
	drop table if exists tmp_codigos;
	
	create temp table tmp_pro1106(
			consecutivo 	integer,
			cedula_aseg  	char(30),
			tipo_aseg 		char(1),
			ced_contratante char(30),
			nombre_aseg  	char(30),
			apellido_aseg 	char(30),
			n_asegurado  	char(60),
			fecha_nac 		date,
			no_documento 	char(30),
			vigencia_inic   date,
			vigencia_final  date,
			itipopol        char(1),
			n_grupo			varchar(100),
			sexo            char(1),
			forma_pago      char(1),
			nom_cob         varchar(100), 
			cramo           varchar(6), primary key (no_documento, n_asegurado, tipo_aseg, nom_cob)
			) with no log;
	--CREATE INDEX idx1_tmp_pro1106 ON tmp_pro1106(no_documento,n_asegurado,tipo_aseg);
	
	--if a_fecha is null then
	--	LET a_fecha = TODAY;  
	--end if
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
	
	--CALL sp_pro03h('001','001',_fecha_hoy,"018,004,016;")  RETURNING _filtros;  -- Salud -Vencidas   12/07/2022
	CALL sp_sis04('01822,01823,01824,01825,01826,01827,01828,01829,01830,01831,01840,01853,01857,01863,01867,01868,01899,01862;') returning _filtros;	
	 
	LET _cod_grupo   = NULL;
	LET _n_proveedor = 'SIGMA';
    
    --set debug file to "sp_pro1117.trc";trace on;
    	
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
--          AND no_documento = '1822-00381-01'   		   
	   
		select estatus_poliza,
		       cod_perpago
		  into _estatus_poliza,
		       _cod_perpago
		  from emipomae
		 where no_poliza = _no_poliza;	

		let _forma_pago = '';

        if _cod_perpago = '002' then
			let _forma_pago = 'M';
		elif _cod_perpago = '004' then
			let _forma_pago = 'T';
		elif _cod_perpago = '008' then
			let _forma_pago = 'A';
		end if		
		 
		if _estatus_poliza not in (1) then	 --Solo Vigente 
			continue foreach;
		end if			 

		if _estatus_poliza = 1 then
			let _n_estatus = "Vigente";	
		elif _estatus_poliza = 3 then
			let _n_estatus = "Vencida";	
		end if	

        select count(*) 
          into _cnt_unidades
          from emipouni
         where no_poliza = _no_poliza
           and activo = 1;		 

		let _n_grupo = '';
		let _itipopol = 'C';
		
		if _cnt_unidades = 1 then
			select trim(nombre)||' - '||trim(_cod_grupo)
			  into _n_grupo
			  from cligrupo
			 where cod_grupo = _cod_grupo;	
			 
			let _itipopol = 'I'; 
        end if			 
		
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
			SELECT nombre,
			       cedula
			  INTO _n_contratante,
			       _ced_contratante
			  FROM cliclien
			 WHERE cod_cliente = _contratante;	   
            
			IF _cnt_unidades = 1 THEN
				LET _n_contratante = _n_grupo;
			END IF

			FOREACH
				SELECT x.no_unidad,
				       x.cod_asegurado, 
					   y.cod_cobertura, 
					   x.vigencia_inic,
					   x.vigencia_final
				  INTO _no_unidad,
				       _cod_asegurado, 
					   _cod_cobertura, 
					   _fecha_efectiva,
                       _vigencia_final					   
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
				   
				FOREACH
					SELECT nombre
					  INTO _nom_cob
					  FROM prdcober
					 WHERE cod_cobertura = _cod_cobertura
					 
					EXIT FOREACH;  
				END FOREACH
				
				LET _cramo = NULL;
				
				IF _cod_cobertura = '01840' THEN 
					LET _cramo = 'OD';
				ELIF _cod_cobertura = '01853' THEN 
					LET _cramo = 'VA';
				ELIF _cod_cobertura = '01899' THEN 
					LET _cramo = 'TELGEN';
				ELIF _cod_cobertura = '01831' THEN 
					LET _cramo = 'PSICO';
				ELIF _cod_cobertura = '01824' THEN 
					LET _cramo = 'OD';
				ELIF _cod_cobertura = '01863' THEN 
					LET _cramo = 'NUT';
				ELIF _cod_cobertura = '01822' THEN 
					LET _cramo = 'OD';
				ELIF _cod_cobertura = '01829' THEN 
					LET _cramo = 'OD';
				ELIF _cod_cobertura = '01857' THEN 
					LET _cramo = 'NUT';
				ELIF _cod_cobertura = '01827' THEN 
					LET _cramo = 'OD';
				ELIF _cod_cobertura = '01826' THEN 
					LET _cramo = 'OD';
				ELIF _cod_cobertura = '01825' THEN 
					LET _cramo = 'OD';
				ELIF _cod_cobertura = '01862' THEN 
					LET _cramo = 'TELGEN';
				END IF	
				 
				SELECT nombre, 
					   trim(aseg_primer_nom),
                       trim(aseg_segundo_nom), 
					   trim(aseg_primer_ape),
                       trim(aseg_segundo_ape), 
				       fecha_aniversario,
					   cedula,
					   sexo
				  INTO _n_asegurado,
                       _aseg_primer_nom,
                       _aseg_segundo_nom,
                       _aseg_primer_ape,
                       _aseg_segundo_ape,
				       _fecha_nac,
					   _cedula,
					   _sexo
				  FROM cliclien
				 WHERE cod_cliente = _cod_asegurado;
				 
				let _ced_contratante = _cedula; 
                
                if _aseg_primer_nom is null then
                    let _aseg_primer_nom = "";
                end if 
                if _aseg_segundo_nom is null then
                    let _aseg_segundo_nom = "";
                end if 
                if _aseg_primer_ape is null then
                    let _aseg_primer_ape = "";
                end if 
                if _aseg_segundo_ape is null then
                    let _aseg_segundo_ape = "";
                end if 
                 
				let _nombre_aseg = trim(_aseg_primer_nom) || " " || trim(_aseg_segundo_nom);
				let _apellido_aseg = trim(_aseg_primer_ape) || " " || trim(_aseg_segundo_ape);                
			 				
				let _consecutivo = 0;
				
				select max(consecutivo)
				  into _consecutivo
				  from tmp_pro1106;
				
				if _consecutivo is null then
					let _consecutivo = 0;
				end if
				
				let _consecutivo = _consecutivo + 1;
  				   
				begin 
					on exception in(-239, -268)
					end exception
						let _tipo_aseg   = 'T';

					insert into tmp_pro1106(
							consecutivo,
							cedula_aseg,
							tipo_aseg,
							ced_contratante,
							nombre_aseg,
							apellido_aseg,
							n_asegurado,
							fecha_nac,
							no_documento,
							vigencia_inic,
							vigencia_final,
							itipopol,
							n_grupo,
							sexo,
							forma_pago,
                            nom_cob,
							cramo
							)
							Values(
							_consecutivo,
							_cedula,
							_tipo_aseg,
							_ced_contratante,
							_nombre_aseg,
							_apellido_aseg,
							_n_asegurado,
							_fecha_nac,
							_no_documento,
							_fecha_efectiva,
							_vigencia_final,
							_itipopol,
							_n_contratante,
							_sexo,
							_forma_pago,
							_cod_cobertura ||"-" || TRIM(_nom_cob),
							_cramo
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

							let _consecutivo = _consecutivo + 1;

							SELECT nombre, 
            					   trim(aseg_primer_nom),
                                   trim(aseg_segundo_nom), 
            					   trim(aseg_primer_ape),
                                   trim(aseg_segundo_ape), 
								   fecha_aniversario,
								   cedula,
								   sexo
							  INTO _n_asegurado, 
                                   _aseg_primer_nom,
                                   _aseg_segundo_nom,
                                   _aseg_primer_ape,
                                   _aseg_segundo_ape,
								   _fecha_nac,
								   _cedula,
								   _sexo
							  FROM cliclien
							 WHERE cod_cliente = _cod_cltdepe;

                            if _aseg_primer_nom is null then
                                let _aseg_primer_nom = "";
                            end if 
                            if _aseg_segundo_nom is null then
                                let _aseg_segundo_nom = "";
                            end if 
                            if _aseg_primer_ape is null then
                                let _aseg_primer_ape = "";
                            end if 
                            if _aseg_segundo_ape is null then
                                let _aseg_segundo_ape = "";
                            end if 
                             
            				let _nombre_aseg = trim(_aseg_primer_nom) || " " || trim(_aseg_segundo_nom);
            				let _apellido_aseg = trim(_aseg_primer_ape) || " " || trim(_aseg_segundo_ape);                
                             								
							if _cedula is null then
								let _cedula = _cod_cltdepe;
							end if
							
							select max(consecutivo)
							  into _consecutivo
							  from tmp_pro1106;
							  
							let _consecutivo = _consecutivo + 1;  
													     
							begin
								on exception in(-239, -268)
								end exception
								let _tipo_aseg   = 'B';	

							insert into tmp_pro1106(
									consecutivo,
									cedula_aseg,
									tipo_aseg,
									ced_contratante,
									nombre_aseg,
									apellido_aseg,
									n_asegurado,
									fecha_nac,
									no_documento,
									vigencia_inic,
									vigencia_final,
									itipopol,
									n_grupo,
									sexo,
									forma_pago,
									nom_cob,
									cramo
									)
									Values(
									_consecutivo,
									_cedula,
									_tipo_aseg,
									_ced_contratante,
									_nombre_aseg,
									_apellido_aseg,
									_n_asegurado,
									_fecha_nac,
									_no_documento,
									_fecha_efectiva,
									_vigencia_final,
									_itipopol,
									_n_contratante,
									_sexo,
									_forma_pago,
									_cod_cobertura ||"-" || TRIM(_nom_cob),
									_cramo
									);
							end									 
						end foreach
					end if	
				end if			
			end foreach			
		end if						
	END FOREACH

	
	let _n_contratante = '';
foreach
	 select consecutivo,
			cedula_aseg,
			tipo_aseg,
			ced_contratante,
			nombre_aseg,
			apellido_aseg,
			n_asegurado,
			fecha_nac,
			no_documento,
			vigencia_inic,
			vigencia_final,
			itipopol,
			n_grupo,
			sexo,
			forma_pago,
            nom_cob,
			cramo
	  into 	_consecutivo,
			_cedula,
			_tipo_aseg,
			_ced_contratante,
			_nombre_aseg,
			_apellido_aseg,
			_n_asegurado,
			_fecha_nac,
			_no_documento,
			_fecha_efectiva,
			_vigencia_final,
			_itipopol,
			_n_contratante,
			_sexo,
			_forma_pago,
			_nom_cob,
			_cramo
	 from tmp_pro1106
	 order by consecutivo	 	

	return null,	
	       current,
		   "C",
		   "0",
		   _consecutivo,
		   _nom_cob,
		   null,
		   1,
		   _cramo,
		   REPLACE(_cedula,"-",""),
		   "E",
		   _tipo_aseg,
		   REPLACE(_ced_contratante,"-",""),
		   "E",
		   TRIM(_nombre_aseg),
		   TRIM(_apellido_aseg),
		   TRIM(_n_asegurado),
		   _fecha_nac,
		   _no_documento,
		   _fecha_efectiva,
		   _vigencia_final,
		   null,
		   null,
		   null,
		   null,
		   _itipopol,
		   null,
		   _n_contratante,
		   _sexo,
		   _forma_pago WITH RESUME;
end foreach

drop table tmp_pro1106;
drop table temp_perfil;
drop table tmp_codigos;
END
END PROCEDURE;
