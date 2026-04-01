-- POLIZAS VIGENTES POR RAMO  *** HGIRON 24/05/2017
-- SIS v.2.0 - DEIVID, S.A.
-- EXECUTE PROCEDURE sp_pro4961('001','001','30/05/2017','*')

   DROP procedure sp_pro4961;
   CREATE procedure "informix".sp_pro4961(a_cia CHAR(03),a_agencia CHAR(3),a_fecha DATE, a_codramo char(255) default "*")
   RETURNING CHAR(20),
             CHAR(10),
			 CHAR(45),
			 CHAR(1),
             DECIMAL(16,2),
			 CHAR(255); 
			 
    DEFINE v_contratante                    	 CHAR(10);    	
	DEFINE v_prima_suscrita,v_suma_asegurada   	 DECIMAL(16,2);
    DEFINE v_asegurado                			 CHAR(45);
	DEFINE no_documento               			 CHAR(20);	
	DEFINE v_descr_cia                           CHAR(50);
	DEFINE v_filtros          					 CHAR(255);
	DEFINE _cod_categoria                        CHAR(1);
	DEFINE _tipo_persona                         CHAR(1);	
	define v_cod_tipoprod		                 char(3);
	define _tipo_produccion		                 Smallint;
	
    LET v_descr_cia      = NULL;
	LET no_documento     = NULL;
	LET v_contratante    = NULL;
	LET v_prima_suscrita = 0.00;
	LET _cod_categoria   = '';
	LET v_filtros        = '';	
	LET _tipo_persona    = '';	
	let v_cod_tipoprod   = null;
	
	    CREATE TEMP TABLE tmp_clivip(
              cod_cliente      CHAR(10),
			  tipo_persona     CHAR(1),
			  no_documento     CHAR(20),
			  prima_suscrita   DECIMAL(16,2),
			  tipo_produccion smallint)
              WITH NO LOG;
	--CREATE INDEX i_tmp_clivip_1 ON tmp_clivip(cod_cliente,no_documento);

    SET ISOLATION TO DIRTY READ;

    LET v_descr_cia = sp_sis01(a_cia);
    CALL sp_pro03(a_cia,a_agencia,a_fecha,a_codramo) RETURNING v_filtros;

    FOREACH
       SELECT y.no_documento,
              y.cod_contratante,
              y.prima_suscrita,
			  Y.cod_tipoprod
         INTO no_documento,
              v_contratante,
              v_prima_suscrita,
			  v_cod_tipoprod
         FROM temp_perfil y
        WHERE y.seleccionado = 1
     ORDER BY y.no_documento
	 
		select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = v_cod_tipoprod;	 

       SELECT nombre,tipo_persona
         INTO v_asegurado, _tipo_persona
         FROM cliclien
        WHERE cod_cliente = v_contratante;					  
		
		if _tipo_persona in ('N','J') then 			  
			insert into tmp_clivip(
			cod_cliente,
			tipo_persona,
			no_documento,
			prima_suscrita,
			tipo_produccion)
			values(v_contratante,
			_tipo_persona,
			no_documento,
			v_prima_suscrita,
			_tipo_produccion);
		end if
		 
       RETURN no_documento,
	          v_contratante,
              v_asegurado,
			  _tipo_persona,
              v_prima_suscrita,
			  v_filtros
              WITH RESUME;

    END FOREACH
	
--  Persona Natural
--  Categoría Silver $5,000.00 hasta $15,000.00- Actualmente contamos con 65 clientes
--  Categoría Gold $15,000.00 en adelante- Actualmente contamos con 25 clientes

--  Persona Jurídica
--  Categoría Silver $10,000.00 hasta $45,000.00- Actualmente contamos con 240 clientes
--  Categoría Gold $45,000.00 en adelante- Actualmente contamos con 248 clientes
	-- no tomar en cuenta tipo_produccion : 2 ni 3
 FOREACH
       SELECT cod_cliente,
				tipo_persona,
				sum(prima_suscrita)
         INTO v_contratante,
				_tipo_persona,
				v_prima_suscrita
         FROM tmp_clivip
		 where tipo_produccion <> 3
     group by cod_cliente,
			  tipo_persona
			  
		let _cod_categoria = " ";   
	
		if _tipo_persona = 'N' and v_prima_suscrita >= 15000 then 
			let _cod_categoria = "G"; 
		elif _tipo_persona = 'N' and v_prima_suscrita < 15000 and v_prima_suscrita >= 5000 then 
			let _cod_categoria = "S"; 
		elif _tipo_persona = 'J' and v_prima_suscrita >= 45000 then 
			let _cod_categoria = "G";	
		elif _tipo_persona = 'J' and v_prima_suscrita < 45000 and v_prima_suscrita >= 10000 then  
			let _cod_categoria = "S";     			
	   end if 
		
		if _cod_categoria in ('G','S') then  
		
	   {foreach 
		select distinct tipo_produccion 
		  into _tipo_produccion
		  from tmp_clivip 
		 where cod_cliente = v_contratante
		   and tipo_persona = _tipo_persona
		  exit foreach;
	       end foreach}
		 
		 {if _tipo_produccion = 2 then -- Coaseguro Mayoritario		 
		elif _tipo_produccion = 3 then -- Coaseguro Minoritario
		elif _tipo_produccion = 1 then -- Sin Coaseguro		 
		end if}
	
			insert into clivip(
				cod_cliente,
				cod_categoria,
				cod_usuario,
				user_added,
				date_added)
			values(v_contratante,
				_cod_categoria,
				'DEIVID',
				'DEIVID',
				current);
				
		end if

    END FOREACH	

--DROP TABLE temp_perfil;
--DROP TABLE tmp_clivip;

END PROCEDURE;
