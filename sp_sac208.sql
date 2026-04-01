-- *********************************
-- Procedimiento que genera el reporte de Comprobantes actualizados
-- Creado : Henry Giron Fecha : 28/03/2013
-- d_sac_sp_sac145_dw1
-- *********************************
DROP PROCEDURE sp_sac208;
CREATE PROCEDURE sp_sac208(a_db CHAR(18), a_fecha1 date, a_fecha2 date, a_auxiliar CHAR(5) ) -- a_notrx integer, a_comp char(8) ) 
RETURNING integer,
            char(50);

define _error		      integer;
define _error_isam	      integer;
define _error_desc	      char(50);

define _res_notrx		  integer;	
define _res_cuenta        char(12);
define _res_tipo_resumen  char(2);	
define _res_comprobante	  char(15);	
define _res_fechatrx	  date;
define _res_tipcomp		  char(3);	
define _res_ccosto		  char(3);	
define _res_descripcion	  char(50);
define _res_debito		  dec(15,2);
define _res_moneda		  char(2);
define _res_credito		  dec(15,2);
define _res_status		  char(1);
define _res_origen		  char(3);
define _res_usuariocap	  char(15);
define _res_noregistro	  integer;
define _res_usuarioact	  char(15);
define _res1_notrx		  integer;	
define _res1_linea	      integer;		 	  
define _res1_cuenta       char(12);	 		  
define _res1_auxiliar     char(5);	 		  
define _res1_debito       decimal(15,2);	  
define _res1_credito      decimal(15,2);	  
define _res1_noregistro   integer; 	  
define _res1_comprobante  char(15);	  
define f_res_notrx		  integer;	
define f_res_noregistro   integer; 	  

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

CREATE TEMP TABLE tmp_cglresumen(
res_notrx		  integer,		
res_cuenta        char(12),	
res_tipo_resumen  char(2),		
res_comprobante	  char(15),		
res_fechatrx	  date,		
res_tipcomp		  char(3),		
res_ccosto		  char(3),		
res_descripcion	  char(50),	
res_moneda		  char(2),
res_debito		  dec(15,2),
res_credito		  dec(15,2),
res_status		  char(1),
res_origen		  char(3),
res_usuariocap	  char(15),
res_noregistro	  integer,
res_usuarioact    char(15),
PRIMARY KEY(res_notrx,res_cuenta,res_noregistro)) WITH NO LOG;
CREATE INDEX idx1_tmp_cglresumen ON tmp_cglresumen(res_notrx);
CREATE INDEX idx2_tmp_cglresumen ON tmp_cglresumen(res_cuenta);
CREATE INDEX idx3_tmp_cglresumen ON tmp_cglresumen(res_noregistro);

CREATE TEMP TABLE tmp_cglresumen1(
res1_notrx		  integer,	
res1_linea	      integer,		  
res1_cuenta      char(12),	 	
res1_auxiliar    char(5),	 		
res1_debito      decimal(15,2),	
res1_credito     decimal(15,2),	
res1_noregistro  integer, 
res1_comprobante char(15),
PRIMARY KEY(res1_notrx,res1_noregistro,res1_linea,res1_auxiliar)) WITH NO LOG;
CREATE INDEX idx1_tmp_cglresumen1 ON tmp_cglresumen1(res1_notrx);
CREATE INDEX idx2_tmp_cglresumen1 ON tmp_cglresumen1(res1_noregistro);
CREATE INDEX idx3_tmp_cglresumen1 ON tmp_cglresumen1(res1_linea);
CREATE INDEX idx4_tmp_cglresumen1 ON tmp_cglresumen1(res1_auxiliar);

if a_db = "sac" then

	FOREACH 
	  select distinct a.res_notrx --,a.res_noregistro
	    into f_res_notrx --,f_res_noregistro
	    from sac:cglresumen  a ,sac:cglresumen1 b
	   where a.res_fechatrx  >= a_fecha1
--	     and a.res_fechatrx  <= a_fecha2
		 and b.res1_auxiliar  = a_auxiliar
--		 and b.res1_auxiliar  in ("BQ050", "BQ076")
--		 and a.res_comprobante[8,9] in ('1 ','2 ','3 ','4 ','5 ')   -- solo comp de cobros y reclamos: Demetrio
		 and a.res_comprobante[1,3] =  "REA"  -- Reaseguro
		 and a.res_comprobante[8,9] in ('10','11','12','13','14')   -- solo comp de prod: Demetrio
--		 and a.res_notrx      = "186587"
		 and a.res_noregistro = b.res1_noregistro
--	order by a.res_noregistro  

	 	FOREACH 
		  select a.res_notrx,		
		         a.res_cuenta,      
		         a.res_tipo_resumen,
		         a.res_comprobante,	
		         a.res_fechatrx,	
		         a.res_tipcomp,		
		         a.res_ccosto,		
		         a.res_descripcion,		
		         a.res_moneda,		
		         a.res_debito,		
		         a.res_credito,		
		         a.res_status,		
		         a.res_origen,		
				 a.res_usuariocap,	
				 a.res_noregistro,
				 a.res_usuarioact
		    into _res_notrx,		
				 _res_cuenta,      
				 _res_tipo_resumen,
				 _res_comprobante,	
				 _res_fechatrx,	
				 _res_tipcomp,		
				 _res_ccosto,		
				 _res_descripcion,			
				 _res_moneda,		
				 _res_debito,		
				 _res_credito,		
				 _res_status,		
				 _res_origen,		
				 _res_usuariocap,	
				 _res_noregistro,
				 _res_usuarioact 
		    from sac:cglresumen  a 
		   WHERE a.res_notrx  = f_res_notrx	  	

		 		INSERT INTO tmp_cglresumen(
				res_notrx,		
				res_cuenta,      
				res_tipo_resumen,
				res_comprobante,	
				res_fechatrx,	
				res_tipcomp,		
				res_ccosto,		
				res_descripcion,		
				res_moneda,		
				res_debito,		
				res_credito,		
				res_status,		
				res_origen,		
				res_usuariocap,	
				res_noregistro,
				res_usuarioact) 
				VALUES(	_res_notrx,		
				_res_cuenta,      
				_res_tipo_resumen,
				_res_comprobante,	
				_res_fechatrx,	
				_res_tipcomp,		
				_res_ccosto,		
				_res_descripcion,			
				_res_moneda,		
				_res_debito,		
				_res_credito,		
				_res_status,		
				_res_origen,		
				_res_usuariocap,	
				_res_noregistro,
				_res_usuarioact );  


		END FOREACH	

	   	FOREACH 
		  select b.res1_linea,	  
		         b.res1_cuenta, 
		         b.res1_auxiliar,   
		         b.res1_debito,     
		         b.res1_credito,    
		         b.res1_noregistro, 
		         b.res1_comprobante         	         			 			 			 
		    into _res1_linea,	  
				 _res1_cuenta, 
				 _res1_auxiliar,   
				 _res1_debito,     
				 _res1_credito,    
				 _res1_noregistro, 
				 _res1_comprobante 
		    from sac:cglresumen1 b
		   WHERE b.res1_noregistro in
		         (	select res_noregistro
		             from sac:cglresumen 
		            WHERE res_notrx  = f_res_notrx
           		 )	

				INSERT INTO tmp_cglresumen1(
				res1_notrx,
				res1_linea,	    
				res1_cuenta,    
				res1_auxiliar,   
				res1_debito,     
				res1_credito,    
				res1_noregistro, 
				res1_comprobante)																	
				VALUES(	
				f_res_notrx,		
				_res1_linea,	     
				_res1_cuenta, 
				_res1_auxiliar,   	
				_res1_debito,     
				_res1_credito,    
				_res1_noregistro, 
				_res1_comprobante );  

		END FOREACH	


END FOREACH


	select *
	  from sac:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac:cglterceros
	  into temp tmp_cglterceros;


end if

end 

return 0, "Actualizacion Exitosa";

end procedure 