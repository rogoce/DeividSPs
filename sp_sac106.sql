-- Consulta de comprobante cglresumen
-- Creado : 18/05/2009 - Autor : Henry Giron.
DROP PROCEDURE sp_sac106;

CREATE PROCEDURE "informix".sp_sac106(a_notrx integer,a_comp char(15))
returning char(2),
		  integer,
		  char(15),
		  date,
		  char(3),
		  char(3),
		  char(50),
		  char(2),
		  char(15),
		  char(15),
		  date,
		  date,
		  char(3),
		  char(1),
		  char(18),
		  decimal(15,2),
		  decimal(15,2);

define _res_tipo_resumen	char(2);   
define _res_notrx			integer;   
define _res_comprobante     char(15);   
define _res_fechatrx		date;
define _res_tipcomp			char(3);   
define _res_ccosto			char(3);   
define _res_descripcion		char(50);  
define _res_moneda			char(2);   
define _res_usuariocap		char(15);
define _res_usuarioact		char(15);   
define _res_fechacap		date;   
define _res_fechaact		date;
define _res_origen			char(3);  
define _res_status			char(1);   
define _res_tabla			char(18);   
define _debito				decimal(15,2);  
define _credito				decimal(15,2);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE T_cglresumen(
		 res_tipo_resumen 	char(2),   
         res_notrx			integer,   
         res_comprobante	char(15),   
         res_tipcomp		char(3),   
         res_ccosto			char(3),   
         res_descripcion	char(50),   
         res_moneda			char(2),   
         res_usuariocap		char(15),   
         res_usuarioact		char(15),   
         res_origen			char(3),   
         res_status			char(1),   
         res_tabla			char(18),   
         res_debito			decimal(15,2),  
         res_credito		decimal(15,2)
         ) WITH NO LOG;


IF (a_comp IS NULL or a_comp = "") THEN
   LET a_comp = '%';
END IF

if a_notrx is null then
	let a_notrx = 0;
end if

let _res_ccosto = '001';

if a_notrx = 0 then
	foreach
	  SELECT cglresumen.res_tipo_resumen,   
	         cglresumen.res_notrx,   
	         cglresumen.res_comprobante,   
	         cglresumen.res_tipcomp,   
--	         cglresumen.res_ccosto,   
	         cglresumen.res_descripcion,   
	         cglresumen.res_moneda,   
	         cglresumen.res_usuariocap,   
	         cglresumen.res_usuarioact,   
	         cglresumen.res_origen,   
	         cglresumen.res_status,   
	         cglresumen.res_tabla,   
	         sum(res_debito),  
	         sum(res_credito)
		 INTO _res_tipo_resumen,   
	         _res_notrx,   
	         _res_comprobante,     
	         _res_tipcomp,   
--	         _res_ccosto,   
	         _res_descripcion,   
	         _res_moneda,   
	         _res_usuariocap,   
	         _res_usuarioact,   
	         _res_origen,   
	         _res_status,   
	         _res_tabla,   
	         _debito,  
	         _credito
	    FROM cglresumen  
	   WHERE ( cglresumen.res_comprobante = a_comp )   
	GROUP BY cglresumen.res_tipo_resumen,   
	         cglresumen.res_notrx,   
	         cglresumen.res_comprobante,    
	         cglresumen.res_tipcomp,   
--	         cglresumen.res_ccosto,   
	         cglresumen.res_descripcion,   
	         cglresumen.res_moneda,   
	         cglresumen.res_usuariocap,   
	         cglresumen.res_usuarioact,     
	         cglresumen.res_origen,   
	         cglresumen.res_status,   
	         cglresumen.res_tabla   

			INSERT INTO T_cglresumen(
			res_tipo_resumen,   
			res_notrx,   
			res_comprobante,   
			res_tipcomp,   
			res_ccosto,   
			res_descripcion,   
			res_moneda,   
			res_usuariocap,   
			res_usuarioact,   
			res_origen,   
			res_status,   
			res_tabla,   
			res_debito,  
			res_credito)
			VALUES(
			_res_tipo_resumen,   
			_res_notrx,   
			_res_comprobante,     
			_res_tipcomp,   
			_res_ccosto,   
			_res_descripcion,   
			_res_moneda,   
			_res_usuariocap,   
			_res_usuarioact,   
			_res_origen,   
			_res_status,   
			_res_tabla,   
			_debito,  
			_credito);

	end foreach
else
	foreach
	  SELECT cglresumen.res_tipo_resumen,   
	         cglresumen.res_notrx,   
	         cglresumen.res_comprobante,   
	         cglresumen.res_tipcomp,   
--	         cglresumen.res_ccosto,   
	         cglresumen.res_descripcion,   
	         cglresumen.res_moneda,   
	         cglresumen.res_usuariocap,   
	         cglresumen.res_usuarioact,   
	         cglresumen.res_origen,   
	         cglresumen.res_status,   
	         cglresumen.res_tabla,   
	         sum(res_debito),  
	         sum(res_credito)
		 INTO _res_tipo_resumen,   
	         _res_notrx,   
	         _res_comprobante,     
	         _res_tipcomp,   
--	         _res_ccosto,   
	         _res_descripcion,   
	         _res_moneda,   
	         _res_usuariocap,   
	         _res_usuarioact,   
	         _res_origen,   
	         _res_status,   
	         _res_tabla,   
	         _debito,  
	         _credito
	    FROM cglresumen  
	   WHERE ( cglresumen.res_notrx = a_notrx )   
	     AND ( cglresumen.res_comprobante like a_comp )   
	GROUP BY cglresumen.res_tipo_resumen,   
	         cglresumen.res_notrx,   
	         cglresumen.res_comprobante,    
	         cglresumen.res_tipcomp,   
--	         cglresumen.res_ccosto,   
	         cglresumen.res_descripcion,   
	         cglresumen.res_moneda,   
	         cglresumen.res_usuariocap,   
	         cglresumen.res_usuarioact,     
	         cglresumen.res_origen,   
	         cglresumen.res_status,   
	         cglresumen.res_tabla   

			INSERT INTO T_cglresumen(
			res_tipo_resumen,   
			res_notrx,   
			res_comprobante,   
			res_tipcomp,   
			res_ccosto,   
			res_descripcion,   
			res_moneda,   
			res_usuariocap,   
			res_usuarioact,   
			res_origen,   
			res_status,   
			res_tabla,   
			res_debito,  
			res_credito)
			VALUES(
			_res_tipo_resumen,   
			_res_notrx,   
			_res_comprobante,     
			_res_tipcomp,   
			_res_ccosto,   
			_res_descripcion,   
			_res_moneda,   
			_res_usuariocap,   
			_res_usuarioact,   
			_res_origen,   
			_res_status,   
			_res_tabla,   
			_debito,  
			_credito);

	end foreach
end if

foreach
  SELECT T_cglresumen.res_tipo_resumen,   
         T_cglresumen.res_notrx,   
         T_cglresumen.res_comprobante,   
         T_cglresumen.res_tipcomp,   
         T_cglresumen.res_ccosto,   
         T_cglresumen.res_descripcion,   
         T_cglresumen.res_moneda,   
         T_cglresumen.res_usuariocap,   
         T_cglresumen.res_usuarioact,   
         T_cglresumen.res_origen,   
         T_cglresumen.res_status,   
         T_cglresumen.res_tabla,   
         sum(T_cglresumen.res_debito),  
         sum(T_cglresumen.res_credito)
	 INTO _res_tipo_resumen,   
         _res_notrx,   
         _res_comprobante,     
         _res_tipcomp,   
         _res_ccosto,   
         _res_descripcion,   
         _res_moneda,   
         _res_usuariocap,   
         _res_usuarioact,   
         _res_origen,   
         _res_status,   
         _res_tabla,   
         _debito,  
         _credito
    FROM T_cglresumen  
--   WHERE ( cglresumen.res_notrx = a_notrx )   
--     AND ( cglresumen.res_comprobante like a_comp )   
GROUP BY T_cglresumen.res_tipo_resumen,   
         T_cglresumen.res_notrx,   
         T_cglresumen.res_comprobante,    
         T_cglresumen.res_tipcomp,   
         T_cglresumen.res_ccosto,   
         T_cglresumen.res_descripcion,   
         T_cglresumen.res_moneda,   
         T_cglresumen.res_usuariocap,   
         T_cglresumen.res_usuarioact,     
         T_cglresumen.res_origen,   
         T_cglresumen.res_status,   
         T_cglresumen.res_tabla  


  SELECT DISTINCT date(cglresumen.res_fechatrx),
  		 date(cglresumen.res_fechacap), 
         date(cglresumen.res_fechaact)
	INTO _res_fechatrx, 
		 _res_fechacap,   
         _res_fechaact
    FROM cglresumen  
   WHERE ( cglresumen.res_notrx =  _res_notrx )   
     AND ( cglresumen.res_comprobante = _res_comprobante )
     AND ( cglresumen.res_tipcomp = _res_tipcomp ) 
     AND ( cglresumen.res_origen = _res_origen ) ;  

   return _res_tipo_resumen,   
         _res_notrx,   
         _res_comprobante,   
         _res_fechatrx,   
         _res_tipcomp,   
         _res_ccosto,   
         _res_descripcion,   
         _res_moneda,   
         _res_usuariocap,   
         _res_usuarioact,   
         _res_fechacap,   
         _res_fechaact,   
         _res_origen,   
         _res_status,   
         _res_tabla,   
         _debito,  
         _credito
		  with resume;
end foreach

DROP TABLE  T_cglresumen;
END PROCEDURE  