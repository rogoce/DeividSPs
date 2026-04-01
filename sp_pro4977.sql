--  Polizas Vigentes- Proceso de Validación de Edad de Terminación de Cobertura para Asegurados
--  Creado : 08/02/2024   - Autor: Henry Giron
--  SIS v.2.0 - DEIVID, S.A.     

DROP procedure sp_pro4977;
CREATE PROCEDURE sp_pro4977(a_cia CHAR(3),a_agencia CHAR(3),a_codsucursal CHAR(255) DEFAULT "*",a_corredor char(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*",a_periodo1 DATE, a_cod_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*", a_estado smallint DEFAULT 0) 
RETURNING   CHAR(20) as Poliza,
			CHAR(10) as Contratante,
			VARCHAR(100) as Nombre_Contratante,			
			CHAR(10) as Asegurado,			
			VARCHAR(100) as Nombre_Asegurado,
			CHAR(5) as No_Unidad,
			DATE as Fecha_Nacimiento,
			INTEGER as Edad,
			VARCHAR(100) as Nombre_Producto,
			VARCHAR(50) as Ramo,
			VARCHAR(50) as SubRamo,
			INTEGER as Edad_grupo,
			VARCHAR(100) as Parentesco;

 BEGIN

    DEFINE v_nopoliza,v_contratante,_cod_asegurado,_no_poliza2 ,_cod_cliente_dep  CHAR(10);
    DEFINE v_documento                      CHAR(20);
    DEFINE v_codramo,v_codsubramo           CHAR(3);
    DEFINE v_fecha_suscripc,v_vigencia_inic,v_vigencia_final,_fecha_aniversario,_fecha_hoy,_fecha_aniversario_dp DATE;
    DEFINE v_prima_suscrita                 DECIMAL(16,2);
    DEFINE v_codagente, _no_endoso          CHAR(5);
    DEFINE v_desc_cliente                   CHAR(45);
    DEFINE v_filtros                        CHAR(255);
    DEFINE _tipo                            CHAR(01);
    DEFINE v_desc_ramo,v_desc_subr,v_desc_agente,v_descr_cia  CHAR(50);
	DEFINE _dependientes,_edad INTEGER;
	DEFINE _cant_ase integer;
	DEFINE v_desc_contratante,v_desc_asegurado  VARCHAR(100);
	DEFINE _edadcal,_est_pol                INTEGER;
	DEFINE _edadcal_tot                     INTEGER;
	DEFINE _estatus_char					char(7);
	DEFINE _estatus_poliza                  smallint;	
    DEFINE _no_unidad			    char(5);
    DEFINE _no_cambio			    smallint;
    DEFINE _cod_producto	        char(5);
	DEFINE _n_producto              VARCHAR(100);
	DEFINE _codigo_sbr, _codigo_rm   char(3);   
	DEFINE _edadcal_dp,_est_pol_dp               SMALLINT;
	DEFINE _edadcal_tot_dp                     INTEGER;	
	define _no_factura			char(10);
	DEFINE _desc_ramo,_desc_subramo  VARCHAR(50);
	DEFINE _tipo_persona    char(1);
	DEFINE _cod_parentesco  char(3);   
	DEFINE _n_parentesco    VARCHAR(100);	   
	
	LET _fecha_hoy = TODAY;
    LET v_prima_suscrita = 0;
    LET _dependientes    = 0;
    LET _edad		     = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_agente    = NULL;
    LET v_desc_subr      = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;
	let _n_parentesco    = '';
	
let _no_unidad = null;
let _no_cambio = null;
let _n_producto = '';
let _desc_ramo = '';
let _desc_subramo = '';
let _tipo_persona = '';

drop table if exists temp_perfil;
drop table if exists tmp_perfil2;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_periodo1,"004,016,018;") RETURNING v_filtros;
    CALL sp_pro03h(a_cia,a_agencia,a_periodo1,"018;") RETURNING v_filtros;

--set debug file to "sp_pro4977.trc"; 
--trace on;	
	-- Filtro de Sucursal
      IF a_codsucursal <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsucursal);
         LET _tipo = sp_sis04(a_codsucursal); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
	  
    -- Filtro de Subramo
      IF a_subramo <> "*" THEN  --   "001,006,008,012;"
         LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_subramo);
         LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros
            foreach 
			   SELECT trim(codigo )
			     into _codigo_sbr
			   FROM tmp_codigos
			   
			    if _codigo_sbr = '001' then
			       let _codigo_rm = '004';
			   end if
			    if _codigo_sbr = '006' then
			       let _codigo_rm = '016';
			   end if
			    if _codigo_sbr = '008' then
			       let _codigo_rm = '004';
			   end if
			    if _codigo_sbr = '012' then
			       let _codigo_rm = '018';
			   end if
			   
			if _codigo_rm <> '004' then
				UPDATE temp_perfil
					   SET seleccionado = 0
					 WHERE seleccionado = 1
					   AND cod_ramo in (_codigo_rm)
					   AND cod_subramo NOT IN(_codigo_sbr);
			else
				UPDATE temp_perfil
					   SET seleccionado = 0
					 WHERE seleccionado = 1
					   AND cod_ramo in (_codigo_rm)
					   AND cod_subramo NOT IN('001','008');		
			end if					   
				   
			end foreach
			
         ELSE
            foreach 
			   SELECT trim(codigo )
			     into _codigo_sbr
			   FROM tmp_codigos
			   
			    if _codigo_sbr = '001' then
			       let _codigo_rm = '004';
			   end if
			    if _codigo_sbr = '006' then
			       let _codigo_rm = '016';
			   end if
			    if _codigo_sbr = '008' then
			       let _codigo_rm = '004';
			   end if
			    if _codigo_sbr = '012' then
			       let _codigo_rm = '018';
			   end if	
			if _codigo_rm <> '004' then
				UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
				   AND cod_ramo in (_codigo_rm)
                   AND cod_subramo IN(_codigo_sbr);
			else
				UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
				   AND cod_ramo in (_codigo_rm)
				   AND cod_subramo IN('001','008');		
			end if	
			
			   

			end foreach
			
         END IF
         DROP TABLE tmp_codigos;
		 
		 SELECT temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
		   FROM temp_perfil temp_perfil
		  INNER JOIN emipomae pol ON temp_perfil.no_poliza = pol.no_poliza and pol.cod_ramo = '018' and pol.estatus_poliza = 3
		  WHERE pol.cod_no_renov not in ( '027' )   --   Pólizas con Estatus Vencidas que tengan Motivo de No Renovación: 027 - Saldo Pendientes y Facturacion Atrasada
			AND temp_perfil.seleccionado = 1   
		   INTO temp tmp_perfil2;				 
		 
		 foreach
		 SELECT distinct trim(no_factura)  --temp_perfil.no_poliza,temp_perfil.no_documento,temp_perfil.no_factura,temp_perfil.cod_ramo,temp_perfil.cod_subramo,temp_perfil.cod_sucursal,temp_perfil.cod_grupo,temp_perfil.cod_tipoprod,temp_perfil.cod_contratante,temp_perfil.cod_agente,temp_perfil.prima_suscrita,temp_perfil.prima_retenida,temp_perfil.vigencia_inic,temp_perfil.vigencia_final,temp_perfil.fecha_suscripcion,temp_perfil.usuario,temp_perfil.suma_asegurada,temp_perfil.prima_bruta,temp_perfil.seleccionado
		   into _no_factura
		   FROM tmp_perfil2
		  WHERE cod_ramo = '018' 
			and cod_subramo = '012' 
			and seleccionado = 1   
		
         UPDATE temp_perfil
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo in ('018' )
		   AND cod_subramo IN ('012' )
		   and trim(no_factura) = _no_factura;		
		   
		   end foreach
		 
		drop table if exists tmp_perfil2; 
      END IF
	  
      IF a_corredor <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_corredor);
         LET _tipo = sp_sis04(a_corredor); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_agente IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

      IF a_cod_cliente <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Corredor"||TRIM(a_cod_cliente);
         LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de poliza
   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF


    SET ISOLATION TO DIRTY READ;
	
{
    -- Filtro de Subramo
      IF a_subramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Subramo "||TRIM(a_subramo);
         LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF
}
      
	if a_estado = 1 then
		   let v_filtros = TRIM(v_filtros) ||" ESTATUS: VIGENTES; ";
	elif a_estado = 3 then
 		   let v_filtros = TRIM(v_filtros) ||"  ESTATUS: VENCIDA; ";
	else
		  let v_filtros = TRIM(v_filtros) ||"  ESTATUS: VIGENTE o VENCIDA; ";
	end if

    FOREACH
       SELECT distinct y.no_poliza,
       		  y.no_documento,
       		  y.cod_ramo,
       		  y.cod_subramo,
              y.cod_contratante,
              y.fecha_suscripcion,
              y.vigencia_inic,
              y.vigencia_final,
              y.prima_suscrita	 --,y.cod_agente
         INTO v_nopoliza,
         	  v_documento,
         	  v_codramo,
         	  v_codsubramo,
              v_contratante,
              v_fecha_suscripc,
              v_vigencia_inic,
              v_vigencia_final,
              v_prima_suscrita    --,v_codagente
         FROM temp_perfil y
        WHERE seleccionado = 1
           
       SELECT nombre
         INTO v_desc_subr
         FROM prdsubra
        WHERE cod_ramo    = v_codramo
          AND cod_subramo = v_codsubramo;

       let _cant_ase = 1;

       SELECT count(*)
         INTO _cant_ase
         FROM emipouni
        WHERE no_poliza     = v_nopoliza
          AND vigencia_inic <= a_periodo1
          AND activo        = 1;
		  
		  if _cant_ase is null then
			let _cant_ase = 0;
		  end if

       if _cant_ase = 0 then
			let _cant_ase = 1;
	   end if
          LET _dependientes    = 0;
		  
	   SELECT COUNT(*)
         INTO _dependientes
         FROM emidepen
        WHERE no_poliza = v_nopoliza
          AND activo = 1
		  and cod_parentesco in ('001','007')
          AND fecha_efectiva <= a_periodo1;

	   {SELECT nombre, fecha_aniversario,tipo_persona
	     INTO v_desc_contratante, _fecha_aniversario,_tipo_persona}
		 
	   SELECT nombre, fecha_aniversario
	     INTO v_desc_contratante, _fecha_aniversario
		 FROM cliclien
		WHERE cod_cliente = v_contratante;
		
		{if _tipo_persona <> 'N' then 
		   continue foreach;
		end if }
		
	   SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE prdramo.cod_ramo = v_codramo;			

	   IF _dependientes IS NULL THEN
			LET _dependientes = 0;
	   END IF

       let _edadcal_tot = 0;

       FOREACH
		SELECT cod_asegurado, cod_producto, no_unidad
		  INTO _cod_asegurado, _cod_producto, _no_unidad
          FROM emipouni
         WHERE no_poliza     = v_nopoliza
           AND vigencia_inic <= a_periodo1
           AND activo        = 1

        SELECT fecha_aniversario,tipo_persona
		  INTO _fecha_aniversario,_tipo_persona
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;
		 
		if _tipo_persona <> 'N' then 
		   continue foreach;
		end if 		 
		 
           let _edadcal_tot = 0;
		   
	   SELECT nombre
	     INTO v_desc_asegurado
		 FROM cliclien
		WHERE cod_cliente = _cod_asegurado;		   
		  
         let _edadcal = sp_sis78(_fecha_aniversario);
        -- let _edadcal_tot  = _edadcal_tot + _edadcal;
		 
		if ((   v_codramo = '018' or   v_codramo = '004' or  v_codramo = '016' )   and (_edadcal >= 60 and  _edadcal <=64)) then
		let _edadcal_tot  =  60 ;  
		end if
		if ((   v_codramo = '018' or   v_codramo = '004' or  v_codramo = '016' )   and (_edadcal >= 65 and  _edadcal <=69)) then
		let _edadcal_tot  =  65 ;  
		end if
		if ((   v_codramo = '018' or   v_codramo = '004' or  v_codramo = '016' )   and (_edadcal >= 70 and  _edadcal <=74)) then
		let _edadcal_tot  =  70 ;  
		end if
		if ((   v_codramo = '018' or   v_codramo = '004' or  v_codramo = '016' )   and (_edadcal >= 75 and  _edadcal <=79)) then
		let _edadcal_tot  =  75 ;  
		end if
		if ((   v_codramo = '018' or   v_codramo = '004' or  v_codramo = '016' )   and (_edadcal >= 80 and  _edadcal <=99)) then
		let _edadcal_tot  =  80 ;  
		end if


	select nombre
	  into _n_producto
	  from prdprod
	 where cod_producto = _cod_producto;

	   select estatus_poliza into _estatus_poliza from emipomae where no_poliza = v_nopoliza;	   

	   let _estatus_char = null;

       if _estatus_poliza = 1 then
		  let _estatus_char = 'VIGENTE';
	   elif _estatus_poliza = 3 then
 		  let _estatus_char = 'VENCIDA';
	   end if 	   
	   if a_estado <> 0 then
			if a_estado <> _estatus_poliza then 
			  continue foreach;
			end if			
      end if
	  
		if _edadcal_tot in (60,65,70,75,80)  then				

			
				let _desc_ramo = trim(v_desc_ramo)||' - '||trim(v_codramo);
				let _desc_subramo = trim(v_codsubramo)||' - '||trim(v_desc_subr);		
                let _n_parentesco    = '';  
		  RETURN    v_documento,	
					v_contratante, 	
					v_desc_contratante, 
					_cod_asegurado,
					v_desc_asegurado,					
					_no_unidad	,
					_fecha_aniversario,	
					_edadcal,  --_edadcal_tot,	_edadcal_tot,  --
					_n_producto,
                    _desc_ramo,
                    _desc_subramo,
                    _edadcal_tot,
                    _n_parentesco WITH RESUME;	
	   end if	 
	  if _edadcal_tot is null then
		let _edadcal_tot = 0;
	  end if
		if _edadcal_tot < 60 then
			--continue foreach;
		end if			   
	  

		let _no_poliza2 = sp_sis21(v_documento);
		select estatus_poliza into _est_pol from emipomae
		where no_poliza = _no_poliza2;
		if _est_pol = 2 then
			continue foreach;
		end if	  
		 let _edadcal_tot_dp = 0;
			if  _dependientes > 0  and  v_codramo = '018'  and  v_codsubramo = '012' then
			        let _n_parentesco    = '';  
			       foreach
				   SELECT cod_cliente, cod_parentesco
					 INTO _cod_cliente_dep, _cod_parentesco
					 FROM emidepen
					WHERE no_poliza = v_nopoliza
					  AND activo = 1
					  and cod_parentesco in ('002','007','001','015','036' )  
					  AND fecha_efectiva <= a_periodo1
					  and no_unidad = _no_unidad
					  
					select nombre
					  into _n_parentesco
					  from emiparen
					 where cod_parentesco = _cod_parentesco;					  
					  
					SELECT fecha_aniversario
					  INTO _fecha_aniversario_dp
					  FROM cliclien
					 WHERE cod_cliente = _cod_cliente_dep;
                     let _edadcal_tot_dp = 0;
					 let _edadcal_dp = sp_sis78(_fecha_aniversario_dp);
					-- let _edadcal_tot_dp  = _edadcal_tot_dp + _edadcal_dp;				  
					  
					  if _edadcal_dp < 25 then
						 continue foreach;
					  end if
					  
					  		if ((    v_codramo = '018'  and v_codsubramo= '012'  )   and (_edadcal_dp >= 25 and  _edadcal_dp <=99)) then
							   -- let _edadcal_tot_dp  =  25 ;
							   
								if ((   v_codramo = '018'  and v_codsubramo= '012'  )   and (_edadcal_dp >= 60 and  _edadcal_dp <=64)) then
									let _edadcal_tot_dp  =  60 ;  
								end if
								if ((   v_codramo = '018'  and v_codsubramo= '012'  )   and (_edadcal_dp >= 65 and  _edadcal_dp <=69)) then
									let _edadcal_tot_dp  =  65 ;  
								end if
								if ((   v_codramo = '018'  and v_codsubramo= '012'  )   and (_edadcal_dp >= 70 and  _edadcal_dp <=74)) then
									let _edadcal_tot_dp  =  70 ;  
								end if
								if ((   v_codramo = '018'  and v_codsubramo= '012'  )   and (_edadcal_dp >= 75 and  _edadcal_dp <=79)) then
									let _edadcal_tot_dp   =  75 ;  
								end if
								if ((   v_codramo = '018'  and v_codsubramo= '012'  )    and (_edadcal_dp >= 80 and  _edadcal_dp <=99)) then
									let _edadcal_tot_dp  =  80 ;  
								end if
								if ((    v_codramo = '018'  and v_codsubramo= '012'  )   and (_edadcal_dp >= 25 and  _edadcal_dp <=59)) then
										let _edadcal_tot_dp  =  25 ;  
										if _cod_parentesco in ('001','015','036') then 
										    continue foreach;
										end if
								end if	
                                let _edadcal_tot = _edadcal_tot_dp ;								
                                let _fecha_aniversario = _fecha_aniversario_dp;
								let _edadcal  = _edadcal_dp;
							   SELECT nombre
								 INTO v_desc_asegurado
								 FROM cliclien
								WHERE cod_cliente = _cod_cliente_dep;						
							end if	 
							
						if _edadcal_tot_dp in (25,60,65,70,75,80)  then	 			
						
							let _desc_ramo = trim(v_desc_ramo)||' - '||trim(v_codramo);
							let _desc_subramo = trim(v_codsubramo)||' - '||trim(v_desc_subr);		

					  RETURN    v_documento,	
								v_contratante, 	
								v_desc_contratante, 
								_cod_asegurado,
								v_desc_asegurado,					
								_no_unidad	,
								_fecha_aniversario,	
								_edadcal,  --_edadcal_tot,	_edadcal_tot,  --
								_n_producto,
								_desc_ramo,
								_desc_subramo,
								_edadcal_tot,
                                _n_parentesco WITH RESUME;	
								
							let _n_parentesco    = '';  
				   end if						
							
					  end foreach;					  
			  
			end if											


			
		



    END FOREACH
 END FOREACH
   -- DROP TABLE temp_perfil;  
END 
END PROCEDURE;
