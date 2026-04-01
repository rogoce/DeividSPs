-- *********************************
-- Procedimiento que genera el reporte de Auditoria
-- Creado : Henry Giron Fecha : 03/03/2010
-- d_sac_sp_sac177_dw1
-- *********************************
DROP PROCEDURE sp_sac178;

CREATE PROCEDURE sp_sac178(a_db CHAR(18), a_fecha1 date, a_fecha2 date ) 
RETURNING integer,
            char(50);

define s_cuenta			char(12);
define s_comprobante    char(15);
define s_tipcomp		char(3) ;
define s_auxiliar       Char(5);
define s_year			integer;
define s_month			integer;
define s_fechacap		date;
define s_fechatrx		date;
define s_debito			dec(15,2);
define s_credito	    dec(15,2); 
define v_db  			dec(15,2);
define v_cr 		    dec(15,2); 
define s_notrx		    integer;
define s_descripcion    char(50);
define s_usuariocap     char(15);
define s_usuarioact	    char(15);
define s_nombrecta  	char(50);
define _ano_char 		char(4);
define _mes_char		char(2);
define _periodo			char(7);
define _cia_nom	    	char(50);
define _cia_comp        char(3);
define s_sep            char(1);
define s_desc_concepto  char(30);
define v_auxiliar,v_dif char(1);
define s_noreg          integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select cia_nom,cia_comp
  into _cia_nom,_cia_comp
  from sigman02
 where cia_bda_codigo = a_db;

LET s_cuenta = "";
LET s_comprobante = "";
LET s_tipcomp = ""; 
LET s_tipcomp = ""; 

LET s_auxiliar = "";
LET s_year = 0;
LET s_month = 0;
LET s_fechacap = null;
LET s_fechatrx = null;
LET s_debito= 0;
LET s_credito= 0; 

LET s_notrx= 0;
LET s_descripcion = "";
LET s_usuariocap = "";
LET s_usuarioact = "";
LET s_desc_concepto = "";
LET v_dif = "N";


if a_db = "sac" then
	 
	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta ;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					INTO s_auxiliar,
					     s_debito,
					     s_credito
				    FROM sac:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea
				
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

elif a_db = "sac001" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac001:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac001:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac001:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac001:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac001:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

elif a_db = "sac002" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac002:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac002:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac002:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac002:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac002:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

elif a_db = "sac003" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac003:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac003:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac003:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac003:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac003:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH


elif a_db = "sac004" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac004:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac004:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac004:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac004:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac004:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

elif a_db = "sac005" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac005:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac005:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac005:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac005:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac005:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

elif a_db = "sac006" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac006:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac006:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac006:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac006:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac006:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

elif a_db = "sac007" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac007:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac007:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac007:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac007:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac007:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

elif a_db = "sac008" then

	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         a.res_debito,
	         a.res_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact,
			 a.res_noregistro
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact,
			 s_noreg
	    from sac008:cglresumen  a
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
	order by a.res_noregistro    				

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre,cta_auxiliar
			  into s_nombrecta,v_auxiliar
			  from sac008:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac008:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

			if v_auxiliar is null then
				let v_auxiliar = "N";
			end if

			if v_auxiliar = "S" then

				LET v_db = 0;
				LET v_cr = 0; 
				LET v_dif = "N";

	           SELECT SUM(res1_debito), 
                	  SUM(res1_credito) 
        	     INTO v_db, 
                  	  v_cr
	             FROM sac008:cglresumen1
			    WHERE res1_noregistro = s_noreg  AND		 
					  res1_cuenta = s_cuenta;

				IF v_db IS NULL THEN
					LET v_db = 0;
				END IF

				IF v_cr IS NULL THEN
					LET v_cr = 0;
				END IF

				IF s_debito <> v_db THEN
					LET  v_dif = "S";
		       	END IF
				       	
				IF s_credito <> v_cr THEN
					LET  v_dif = "S";
				END IF

				FOREACH 
				  SELECT res1_auxiliar,
				         res1_debito,
				         res1_credito
					   INTO s_auxiliar,
					        s_debito,
					        s_credito
				    FROM sac008:cglresumen1
				   WHERE res1_noregistro = s_noreg 
					 AND res1_cuenta = s_cuenta
				order by res1_linea

						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
				END FOREACH     
			else
						let s_auxiliar = "";
						INSERT INTO tmp_aud(
						cia,             
						ncia,            
						cta,             
						ncta,            
						comp,            
						tipo,            
						ntipo,
						aux,			   
						anio_mes, 		
						fechatrx,		
						fechaval,
						debito,          
						credito, 
						notrx,           
						descripcion, 
						user_cap,  	  
						user_act 
						)
						VALUES(	_cia_comp,
						_cia_nom,
						s_cuenta,
						s_nombrecta,
						s_comprobante,
						s_tipcomp,
						s_desc_concepto, 
						s_auxiliar,
						_periodo,
						s_fechatrx,
						s_fechacap,
						s_debito,
						s_credito, 
						s_notrx,
						s_descripcion,
						s_usuariocap,
						s_usuarioact
						);  
			end if

	END FOREACH

end if


end 

return 0, "Actualizacion Exitosa";

end procedure 