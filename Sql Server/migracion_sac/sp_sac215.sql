-- *********************************
-- Procedimiento que genera el reporte de Comprobantes actualizados
-- Creado : Henry Giron Fecha : 28/03/2013
-- d_sac_sp_sac215_dw1
-- *********************************
DROP PROCEDURE sp_sac215;
CREATE PROCEDURE sp_sac215(a_db CHAR(18), a_fecha1 date, a_fecha2 date, a_auxiliar CHAR(5) ) -- a_notrx integer, a_comp char(8) ) 
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
define _no_documento      char(20);
define _no_poliza		  char(10);
define _no_endoso		  char(5);
define d_poliza			  char(10);
define d_endoso			  char(5);
define d_debito			  dec(15,2);
define d_credito		  dec(15,2);
define d_res_noregistro   integer; 
define d_res1_linea       integer; 
	  

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
res_no_documento  char(20),
PRIMARY KEY(res_notrx,res_no_documento,res_cuenta,res_noregistro)) WITH NO LOG;
CREATE INDEX idx1_tmp_cglresumen ON tmp_cglresumen(res_notrx);
CREATE INDEX idx2_tmp_cglresumen ON tmp_cglresumen(res_no_documento);
CREATE INDEX idx3_tmp_cglresumen ON tmp_cglresumen(res_cuenta);
CREATE INDEX idx4_tmp_cglresumen ON tmp_cglresumen(res_noregistro);

CREATE TEMP TABLE tmp_cglresumen1(
res1_notrx		  integer,	
res1_linea	      integer,		  
res1_cuenta       char(12),	 	
res1_auxiliar     char(5),	 		
res1_debito       decimal(15,2),	
res1_credito      decimal(15,2),	
res1_noregistro   integer, 
res1_comprobante  char(15),
res1_no_documento char(20),
PRIMARY KEY(res1_notrx,res1_no_documento,res1_noregistro,res1_linea,res1_cuenta,res1_auxiliar)) WITH NO LOG;
CREATE INDEX idx1_tmp_cglresumen1 ON tmp_cglresumen1(res1_notrx);
CREATE INDEX idx2_tmp_cglresumen1 ON tmp_cglresumen1(res1_no_documento);
CREATE INDEX idx3_tmp_cglresumen1 ON tmp_cglresumen1(res1_noregistro);
CREATE INDEX idx4_tmp_cglresumen1 ON tmp_cglresumen1(res1_linea);
CREATE INDEX idx5_tmp_cglresumen1 ON tmp_cglresumen1(res1_auxiliar);

let d_poliza		 = "";	
let d_endoso		 = "";	
let d_debito		 = 0;	
let d_credito		 = 0;
let d_res_noregistro = 0;

--set debug file to "sp_sac215.trc";	
--trace on;

if a_db = "sac" then

	FOREACH 
	  select distinct a.res_notrx --,a.res_noregistro
	    into f_res_notrx --,f_res_noregistro
	    from sac:cglresumen  a ,sac:cglresumen1 b
	   where a.res_fechatrx  >= a_fecha1
	     and a.res_fechatrx  <= a_fecha2
--		 and b.res1_auxiliar  = a_auxiliar
		 and b.res1_auxiliar  in ("BQ050", "BQ076")
		 and a.res_comprobante[8,9] in ('1 ','2 ','3 ','4 ','5 ')   -- solo comp de cobros y reclamos: Demetrio
		 and a.res_comprobante[1,3] =  "REA"  -- Reaseguro
--		 and a.res_comprobante[8,9] in ('10','11','12','13','14')   -- solo comp de prod: Demetrio
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

			FOREACH
				select c.no_registro,c.no_documento,b.debito,b.credito
				  into _res_noregistro,_no_documento,d_debito,d_credito
				  from sac999:reacompasie b, sac999:reacomp c
				 where b.no_registro = c.no_registro
				   and b.sac_notrx = _res_notrx
				   and cuenta = _res_cuenta

					if d_debito is null then
						let d_debito = 0; 
					end if

					if d_credito is null then
						let d_credito = 0; 
					end if

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
					res_usuarioact,
					res_no_documento) 
					VALUES(	_res_notrx,		
					_res_cuenta,      
					_res_tipo_resumen,
					_res_comprobante,	
					_res_fechatrx,	
					_res_tipcomp,		
					_res_ccosto,		
					_res_descripcion,			
					_res_moneda,		
					d_debito, --_res_debito,		
					d_credito, --_res_credito,		
					_res_status,		
					_res_origen,		
					_res_usuariocap,	
					_res_noregistro,
					_res_usuarioact,
					_no_documento );

					let d_res1_linea = 0; 

					foreach
						select c.renglon,d.cod_auxiliar,d.debito,d.credito
							into _res1_linea,_res1_auxiliar	, d_debito,  d_credito
							from sac999:reacompasie b, sac999:reacomp c, sac999:reacompasiau d
							where b.no_registro = c.no_registro
							and b.no_registro = d.no_registro
					  		and b.cuenta = d.cuenta
							and b.sac_notrx = _res_notrx
					        and b.cuenta = _res_cuenta
							and c.no_registro = _res_noregistro
							and c.no_documento = _no_documento

							if d_debito is null then
								let d_debito = 0; 
							end if

							if d_credito is null then
								let d_credito = 0; 
							end if

							if _res1_linea is null then
								let d_res1_linea = d_res1_linea + 1;
								let _res1_linea	=  d_res1_linea;
							end if

							INSERT INTO tmp_cglresumen1(
							res1_notrx,
							res1_linea,	    
							res1_cuenta,    
							res1_auxiliar,   
							res1_debito,     
							res1_credito,    
							res1_noregistro, 
							res1_comprobante,
							res1_no_documento) 																									
							VALUES(	
							_res_notrx,		
							_res1_linea,	     
							_res_cuenta, 
							_res1_auxiliar,   	
							d_debito,  -- _res1_debito,     
							d_credito, -- _res1_credito,    
							_res_noregistro, 
							_res_comprobante,
							_no_documento );  

					END FOREACH	

			END FOREACH	

		END FOREACH	

	END FOREACH	

end if

end 

return 0, "Actualizacion Exitosa";

end procedure 