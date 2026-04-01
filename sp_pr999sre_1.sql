--------------------------------------------
--      TOTALES DE PRODUCCION POR         --
--         CONTRATO DE REASEGURO          --
---  Yinia M. Zamora - octubre 2000       -- YMZM
---  Ref. Power Builder - reemplaza sp_pro308
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--- Modificado por Henry 10/9/2009 filtros requeridos por Sr. Omar Wong
--- Quitar el filtro de rangos.
--------------------------------------------
DROP PROCEDURE sp_pr999sre_1;
CREATE PROCEDURE sp_pr999sre_1(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*"	)
RETURNING	char(20),		-- 01
			date,			-- 02
			date,			-- 03
			dec(16,2),		-- 04
			CHAR(3),		-- 05
			CHAR(50),		-- 06
			SMALLINT,		-- 07
			DEC(16,2),		-- 08
			DEC(16,2),		-- 09
			DEC(16,2),		-- 10
			DEC(16,2),		-- 11
			DEC(16,2),		-- 12
			CHAR(255),		-- 13
			CHAR(50),		-- 14
			DEC(16,2),		-- 15
			CHAR(10),		-- 16
			CHAR(15),		-- 17
			varchar(50);	-- 18
							
   BEGIN					
      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
      DEFINE v_desc_cobertura	             CHAR(100);
      DEFINE v_filtros,v_filtros1,v_filtros2 CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima                		 DEC(16,2);
      DEFINE v_prima1                		 DEC(16,2);
      DEFINE v_tipo_contrato                 SMALLINT;

	  define _porc_impuesto					 dec(16,2);
	  define _porc_comision					 dec(16,2);
	  define _cuenta						 char(25);
	  define _serie 						 smallint;
	  define _impuesto						 dec(16,2);
	  define _comision						 dec(16,2);
	  define _por_pagar						 dec(16,2);

	  DEFINE _cod_traspaso	 				 CHAR(5);
	  define _traspaso		 				 smallint;
	  define _tiene_comis_rea				 smallint;
	  define _cantidad						 smallint;
	  define _tipo_cont                      smallint;
	  	
	  define _porc_cont_partic 				 dec(5,2);
	  DEFINE _porc_comis_ase   				 DECIMAL(5,2);
	  define _monto_reas					 dec(16,2);
	  define v_prima_suscrita				 dec(16,2);
	  define _cod_coasegur	 				 char(3);
	  define _nombre_coas					 char(50);
	  define _nombre_cob					 char(50);
	  define _nombre_con					 char(50);
	  define _cod_subramo					 char(3);
	  define _cod_origen					 char(3);
	  define _prima_tot_ret                  dec(16,2);
	  define _prima_sus_tot					 dec(16,2);
	  define _prima_tot_ret_sum              dec(16,2);
	  define _prima_tot_sus_sum              dec(16,2);
	  define _no_cambio						 smallint;
	  define _no_unidad						 char(5);
      define v_prima_cobrada           		 DEC(16,2);
	  define _porc_partic_coas				 dec(7,4);
	  define _fecha						     date;
	  define _vigencia_ini					 date;
	  define _vigencia_fin					 date;
	  define _porc_partic_prima				 dec(9,6);
	  define _p_sus_tot						 DEC(16,2);
	  define _p_sus_tot_sum					 DEC(16,2);
	  define v_prima_tipo					 DEC(16,2);
	  define v_prima_1 						 DEC(16,2);
	  define v_prima_3 						 DEC(16,2);
	  define v_prima_bq						 DEC(16,2);
	  define v_prima_Ot						 DEC(16,2);
	  define _bouquet						 smallint;
	  DEFINE v_rango_inicial	             DEC(16,2);
	  DEFINE v_rango_final	                 DEC(16,2);
	  DEFINE v_suma_asegurada 				 DECIMAL(16,2);
	  DEFINE v_cod_tipo						 CHAR(3);
	  DEFINE v_porcentaje					 smallint;
	  DEFINE _t_ramo						 CHAR(1);
	  DEFINE _flag , _cnt					 smallint;
	  define _sum_fac_car 				     dec(16,2);
	  define _no_documento					 char(20);
      DEFINE v_no_recibo                     CHAR(10);
	  define _no_registro					 char(10);
	  define _sac_notrx                      integer;
	  define _res_comprobante				 char(15);
	  define _n_contrato                      varchar(50);
	  	  	  	
     SET ISOLATION TO DIRTY READ;

     LET v_descr_cia  = sp_sis01(a_compania);
	 let v_filtros  = "";


FOREACH
	 SELECT no_documento,
			vigencia_ini,
			vigencia_fin,
			suma_asegurada,
	 		cod_ramo,		
			desc_ramo,		
			cant_polizas, 
			p_cobrada,    
			p_retenida,   
			p_bouquet,    
			p_facultativo,
			p_otros,
			p_fac_car, 
			no_recibo, 
			res_comprobante, 
			n_contrato 
  	   INTO _no_documento,
			_vigencia_ini,
			_vigencia_fin,
			v_suma_asegurada,
  	   		v_cod_ramo, 
			v_desc_ramo, 
			_cantidad, 
			v_prima, 
			v_prima_1, 
			v_prima_bq, 
			v_prima_3, 
			v_prima_Ot,
			_sum_fac_car,
			v_no_recibo,
			_res_comprobante,
			v_desc_contrato				 
	   FROM tmp_tabla 
	  ORDER BY cod_ramo

     RETURN _no_documento,
			_vigencia_ini,
			_vigencia_fin,
			v_suma_asegurada,
     		v_cod_ramo,  
			v_desc_ramo,   
     		_cantidad,  
     		v_prima,  
     		v_prima_1,  
     		v_prima_bq,  
     		v_prima_3,  
     		v_prima_Ot, 
     		v_filtros, 
     		v_descr_cia,
     		_sum_fac_car,
     		v_no_recibo,
			_res_comprobante,
     		v_desc_contrato      		 	          
       WITH RESUME;

END FOREACH

END

END PROCEDURE


		  