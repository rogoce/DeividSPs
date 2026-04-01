-- Prosedimiento para ingresar presupuesto inicial 
-- Creado    : 26/01/2009 - Autor: Henry Girón 
-- SIS v.2.0 - DEIVID, S.A. 

DROP PROCEDURE pres;

CREATE PROCEDURE pres(a_anio char(4)) 
RETURNING	SMALLINT,CHAR(100); --mess

DEFINE v_monto           DEC(15,2);
DEFINE v_monto_acum      DEC(15,2);
DEFINE v_mess			 CHAR(100);
DEFINE v_fecha			 DATE;
DEFINE v_usuario		 CHAR(8);
DEFINE v_total           DEC(17,2);
DEFINE _error   	     SMALLINT;
DEFINE i         	     SMALLINT;


DEFINE vp_sucursal		CHAR(3);
DEFINE vp_cuenta		CHAR(12);
DEFINE vp_descripcio    CHAR(100);
DEFINE vp_r_ene			DEC(15,2);  
DEFINE vp_r_feb			DEC(15,2);  
DEFINE vp_r_mar			DEC(15,2);     
DEFINE vp_r_abr			DEC(15,2);     
DEFINE vp_r_may			DEC(15,2);     
DEFINE vp_r_jun			DEC(15,2);     
DEFINE vp_r_jul			DEC(15,2);     
DEFINE vp_r_ago			DEC(15,2);     
DEFINE vp_r_sep			DEC(15,2);     
DEFINE vp_r_oct			DEC(15,2);     
DEFINE vp_r_nov			DEC(15,2);     
DEFINE vp_r_dic			DEC(15,2);     
DEFINE vp_total			DEC(15,2);  


--begin work;

--BEGIN
--ON EXCEPTION SET _error 
--	rollback work;
-- 	RETURN  _error,"Error al Pase de datos";         
--END EXCEPTION 

SET ISOLATION TO DIRTY READ;

DELETE  from cglpre02 where pre2_ano = a_anio;
DELETE  from cglpre01 where pre1_ano = a_anio;

LET v_monto = 0;
LET v_mess = 'Pase de Informacion Exitosa.';
LET v_usuario = 'DEIVID';
LET v_fecha = TODAY;

FOREACH
    SELECT presupue.sucursal,   
         presupue.cuenta,   
         presupue.descripcio,   
         trunc(presupue.r_ene,2),   
         trunc(presupue.r_feb,2),  
         trunc(presupue.r_mar,2),
         trunc(presupue.r_abr,2), 
         trunc(presupue.r_may,2),
         trunc(presupue.r_jun,2),
         trunc(presupue.r_jul,2),
         trunc(presupue.r_ago,2), 
         trunc(presupue.r_sep,2),
         trunc(presupue.r_oct,2),
         trunc(presupue.r_nov,2),
         trunc(presupue.r_dic,2),
         trunc(presupue.r_total,2) 
		 INTO vp_sucursal,   
         vp_cuenta,   
         vp_descripcio,   
         vp_r_ene,   
         vp_r_feb,   
         vp_r_mar,   
         vp_r_abr,   
         vp_r_may,   
         vp_r_jun,   
         vp_r_jul,   
         vp_r_ago,   
         vp_r_sep,   
         vp_r_oct,   
         vp_r_nov,   
         vp_r_dic,   
         vp_total  
    FROM presupue  
   --where presupue.cuenta in ('6000192')
	--where presupue.cuenta not in ('600023208','6000160')

	LET v_monto_acum = 0;
	LET v_total = vp_r_ene + vp_r_feb + vp_r_mar + vp_r_abr +vp_r_may + vp_r_jun + vp_r_jul + vp_r_ago + vp_r_sep + vp_r_oct + vp_r_nov + vp_r_dic	;


  INSERT INTO cglpre01  
         ( pre1_ano,   
           pre1_cuenta,   
           pre1_ccosto,   
           pre1_fecha,   
           pre1_monto,   
           pre1_usuario )  
  VALUES ( a_anio,   
           vp_cuenta,   
           vp_sucursal,   
           v_fecha,
           v_total,   
           v_usuario ) ;

	FOR i = 1 to 12
	  	IF i = 1 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_ene  ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_ene,   
	    	       v_monto_acum )  ;
	  	ELIF i = 2 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_feb ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_feb,   
	    	       v_monto_acum )  ;
	  	ELIF i = 3 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_mar  ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_mar,   
	    	       v_monto_acum )  ;

	 	ELIF i = 4 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_abr ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_abr,   
	    	       v_monto_acum )  ;
  		ELIF i = 5 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_may ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_may,   
	    	       v_monto_acum )  ;
  		ELIF i = 6 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_jun ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_jun,   
	    	       v_monto_acum )  ;
  		ELIF i = 7 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_jul ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_jul,   
	    	       v_monto_acum )  ;
  		ELIF i = 8 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_ago ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_ago,   
	    	       v_monto_acum )  ;
  		ELIF i = 9 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_sep ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_sep,   
	    	       v_monto_acum )  ;
  		ELIF i = 10 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_oct ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_oct,   
	    	       v_monto_acum )  ;
  		ELIF i = 11 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_nov ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_nov,   
	    	       v_monto_acum )  ;
  		ELIF i = 12 THEN
		  LET v_monto_acum = v_monto_acum + vp_r_dic ;

		  INSERT INTO cglpre02  
    		     ( pre2_ano,   
        		   pre2_cuenta,   
	    	       pre2_ccosto,   
	        	   pre2_periodo,   
    	    	   pre2_montomes,   
	           	   pre2_montoacu )  
		  VALUES ( a_anio,   
	        	   vp_cuenta,   
    		       vp_sucursal,  
	        	   i,
    		       vp_r_dic,   
	    	       v_monto_acum )  ;
  		END IF
	END FOR
END FOREACH;
--end work 
--commit work;			   
return 1,v_mess;

END PROCEDURE	