-- *********************************
-- Procedimiento que genera el reporte de Auditoria	 - SOLO AUXILIAR
-- Creado : Henry Giron Fecha : 03/03/2010
-- d_sac_sp_sac208_dw1
-- *********************************
DROP PROCEDURE sp_sac210;
CREATE PROCEDURE sp_sac210(a_db CHAR(18), a_fecha1 date, a_fecha2 date, a_auxiliar CHAR(5) ) 
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

if a_db = "sac" then
	 
	FOREACH 
	  select a.res_cuenta,
	         a.res_comprobante,
	         a.res_tipcomp, 
	         b.res1_auxiliar,
	         year(a.res_fechatrx),
	         month(a.res_fechatrx),
	         a.res_fechacap,
	         a.res_fechatrx,
	         b.res1_debito,
	         b.res1_credito, 
	         a.res_notrx,
	         a.res_descripcion,
	         a.res_usuariocap,
	         a.res_usuarioact
	    into s_cuenta,
	         s_comprobante,
	         s_tipcomp, 
	         s_auxiliar,
	         s_year,
	         s_month,
	         s_fechacap,
	         s_fechatrx,
	         s_debito,
	         s_credito, 
	         s_notrx,
	         s_descripcion,
	         s_usuariocap,
	         s_usuarioact
	    from sac:cglresumen  a ,sac:cglresumen1 b
	   where a.res_fechatrx >= a_fecha1
	     and a.res_fechatrx <= a_fecha2
		 and b.res1_auxiliar = a_auxiliar
		 and a.res_noregistro = b.res1_noregistro
	order by a.res_noregistro    	

			if s_month < 10 then
				let _mes_char = "0"||s_month;
			else
				let _mes_char = s_month;
			end if

			let _ano_char = s_year;
			let _periodo  = _ano_char || "-" || _mes_char;

			select cta_nombre
			  into s_nombrecta
			  from sac:cglcuentas
			 where cta_cuenta = s_cuenta;

		    SELECT con_descrip 
		      INTO s_desc_concepto
		      FROM sac:cglconcepto
		     WHERE con_codigo  = s_tipcomp;

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

end if


end 

return 0, "Actualizacion Exitosa";

end procedure 