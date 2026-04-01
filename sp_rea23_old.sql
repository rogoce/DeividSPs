--      TOTALES DE PRODUCCION PERFIL COMBINADO        -- terremoto
----   Copia del sp_pr999 Federico Coronado
DROP PROCEDURE sp_rea23;
CREATE PROCEDURE sp_rea23(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_reaseguro CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*"		)

RETURNING CHAR(3),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2), DEC(16,2), SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2), DEC(16,2), SMALLINT, DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2), CHAR(100), char(255),dec(16,2);  
   BEGIN
	  DEFINE v_cod_ramo,v_cobertura          CHAR(03);  
	  DEFINE v_desc_ramo                     CHAR(50); 
	  DEFINE v_rango_inicial	             DEC(16,2);
	  DEFINE v_rango_final	                 DEC(16,2);
	  
	  define _cantidad						 smallint;
	  DEFINE v_cobrada                		 DEC(16,2);
      DEFINE v_retenida                		 DEC(16,2);
	  define v_bouquet 						 DEC(16,2);
	  define v_facultativo					 DEC(16,2);
	  define v_otros	                     DEC(16,2);
      DEFINE v_fac_car                       DEC(16,2);
      DEFINE v_acumulada               		 DEC(16,2);
	  
	  define _cantidad1						 smallint;
	  DEFINE v_cobrada1                		 DEC(16,2);
      DEFINE v_retenida1                	 DEC(16,2);
	  define v_bouquet1 					 DEC(16,2);
	  define v_facultativo1					 DEC(16,2);
	  define v_otros1	                     DEC(16,2);
      DEFINE v_fac_car1                      DEC(16,2);
      DEFINE v_acumulada1               	 DEC(16,2);
	  
	  define _cantidad2						 smallint;
	  DEFINE v_cobrada2                		 DEC(16,2);
      DEFINE v_retenida2                	 DEC(16,2);
	  define v_bouquet2 					 DEC(16,2);
	  define v_facultativo2					 DEC(16,2);
	  define v_otros2	                     DEC(16,2);
      DEFINE v_fac_car2                      DEC(16,2);
      DEFINE v_acumulada2               	 DEC(16,2);
	  
	  DEFINE v_descr_cia                     CHAR(50);
	  DEFINE v_return22a              		 smallint;
	  DEFINE v_return22b              		 smallint;	
	  DEFINE v_return22c              		 smallint;
	  define v_filtro                        char(255);
	  define v_suma_asegurada                dec(16,2);
		--SET DEBUG FILE TO "sp_rea22.trc"; 
		--trace on;
  	  	
     SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_tabla_rea(
		cod_ramo		 CHAR(3),
		desc_ramo		 CHAR(50),
        rango_inicial    DECIMAL(16,2),
        rango_final      DECIMAL(16,2),
        cant_polizas     SMALLINT,
        p_cobrada        DEC(16,2),
        p_retenida       DEC(16,2),
		p_bouquet        DEC(16,2),
		p_facultativo    DEC(16,2),
		p_otros		     DEC(16,2),
		p_fac_car	     DEC(16,2),
		p_acumulada      DEC(16,2),
		cant_polizas1    SMALLINT,
        p_cobrada1       DEC(16,2),
        p_retenida1      DEC(16,2),
		p_bouquet1       DEC(16,2),
		p_facultativo1   DEC(16,2),
		p_otros1		 DEC(16,2),
		p_fac_car1	     DEC(16,2),
		p_acumulada1     DEC(16,2),
		cant_polizas2    SMALLINT,
        p_cobrada2       DEC(16,2),
        p_retenida2      DEC(16,2),
		p_bouquet2       DEC(16,2),
		p_facultativo2   DEC(16,2),
		p_otros2		 DEC(16,2),
		p_fac_car2	     DEC(16,2),
		p_acumulada2     DEC(16,2),
		p_filtro         char(255),
		p_suma_asegurada dec(16,2),
        PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG;
call sp_rea23a(a_compania,a_agencia, a_periodo1, a_periodo2, a_codsucursal, a_codgrupo, a_codagente, a_codusuario, a_codramo, a_reaseguro, a_contrato, a_serie, a_subramo) returning v_return22a; 
               --('001','001','2011-03','2011-03','*','*','*','*','001;','*','*','*','*')
--call sp_rea22b(a_compania, a_agencia, a_periodo1, a_periodo2, a_codsucursal, a_contrato, a_codramo, a_serie, a_subramo) returning v_return22b; 

--call sp_rea22c(a_compania, a_agencia, a_periodo1, a_periodo2, a_codsucursal, a_contrato, a_codramo, a_serie, a_subramo) returning v_return22c;

LET v_descr_cia  = sp_sis01(a_compania);
--let v_filtros = "aaaa";
FOREACH
	 SELECT cod_ramo, 
			desc_ramo, 
			rango_inicial, 
			rango_final, 
			cant_polizas, 
			p_cobrada, 
			p_retenida, 
			p_bouquet, 
			p_facultativo, 
			p_otros,
			p_fac_car, 
			p_acumulada, 
			cant_polizas1, 
			p_cobrada1, 
			p_retenida1, 
			p_bouquet1, 
			p_facultativo1, 
			p_otros1, 
			p_fac_car1, 
			p_acumulada1,
			cant_polizas2, 
			p_cobrada2, 
			p_retenida2, 
			p_bouquet2, 
			p_facultativo2, 
			p_otros2, 
			p_fac_car2, 
			p_acumulada2,
			p_filtro,
			p_suma_asegurada
  	   INTO v_cod_ramo, 
			v_desc_ramo, 
			v_rango_inicial,
			v_rango_final, 
			_cantidad, 
			v_cobrada, 
			v_retenida, 
			v_bouquet, 
			v_facultativo, 
			v_otros,
			v_fac_car,
		    v_acumulada,
			_cantidad1, 
			v_cobrada1, 
			v_retenida1, 
			v_bouquet1, 
			v_facultativo1, 
			v_otros1,
			v_fac_car1,
		    v_acumulada1,
			_cantidad2, 
			v_cobrada2, 
			v_retenida2, 
			v_bouquet2, 
			v_facultativo2, 
			v_otros2,
			v_fac_car2,
		    v_acumulada2,
			v_filtro,
			v_suma_asegurada
	   FROM tmp_tabla_rea 
	  ORDER BY cod_ramo,rango_inicial
	  
let v_desc_ramo = 'TERREMOTO';

     RETURN v_cod_ramo, 
			v_desc_ramo, 
			v_rango_inicial,
			v_rango_final, 
			_cantidad, 
			v_cobrada, 
			v_retenida, 
			v_bouquet, 
			v_facultativo, 
			v_otros,
			v_fac_car,
		    v_acumulada,
			_cantidad1, 
			v_cobrada1, 
			v_retenida1, 
			v_bouquet1, 
			v_facultativo1, 
			v_otros1,
			v_fac_car1,
		    v_acumulada1,
			_cantidad2, 
			v_cobrada2, 
			v_retenida2, 
			v_bouquet2, 
			v_facultativo2, 
			v_otros2,
			v_fac_car2,
		    v_acumulada2, 
     		v_descr_cia,
			v_filtro,
			v_suma_asegurada
       WITH RESUME;
END FOREACH
{DROP TABLE tmp_tabla_rea;
DROP TABLE temp_det;
DROP TABLE tmp_ramos;
DROP TABLE temp_produccion;
DROP TABLE temp_fact;}
--DROP TABLE tmp_sinis;
--DROP TABLE temp_ramos_rea;
--DROP TABLE tmp_ramos_rea;
--DROP TABLE tmp_contrato1;
--DROP TABLE tmp_sinis_rea;
--DROP TABLE tmp_contrato_rea;
END

END PROCEDURE