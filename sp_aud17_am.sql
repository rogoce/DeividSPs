-- *********************************
-- Creado : Henry Giron Fecha : 16/09/2010
-- CGLRESUME - GLRESUMEN1
-- *********************************
DROP PROCEDURE sp_aud17_am;
CREATE PROCEDURE sp_aud17_am(a_db CHAR(18), a_fecha1 date, a_fecha2 date ) 
RETURNING integer,char(50);

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
define s_nauxiliar		char(35);
define _tiene_aux       integer;
define s_res_origen     char(3);
define _cod_tercero     char(5);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);
define _ind_tran    char(3);

define _cant        smallint;
define _cuenta      varchar(12);

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
LET _cuenta = "";

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
LET s_nauxiliar = "";

if a_db = "sac" then

	FOREACH
		select cod_tercero
		  into _cod_tercero
		  from deivid_tmp:data_aux_ter
		 where procesado = 0
		 
		select min(res_fechatrx)
		  into a_fecha1
		  from cglresumen
		 where res_noregistro in(
		select res1_noregistro
		  from sac:cglresumen1
		 where res1_cuenta = '26410'
		   and res1_auxiliar = _cod_tercero);
 
		FOREACH
			select a.res_cuenta,
				   a.res_comprobante,
				   a.res_tipcomp, 
				   year(a.res_fechatrx),
				   month(a.res_fechatrx),
				   a.res_fechacap,
				   a.res_fechatrx,
				   --a.res_debito,
				   --a.res_credito, 
				   a.res_notrx,
				   a.res_descripcion,
				   a.res_usuariocap,
				   a.res_usuarioact,
				   a.res_noregistro,
				   a.res_origen,
				   c.res1_debito,
                   c.res1_credito,
				   c.res1_auxiliar
			  into s_cuenta,
				   s_comprobante,
				   s_tipcomp, 
				   s_year,
				   s_month,
				   s_fechacap,
				   s_fechatrx,
				   --s_debito,
				   --s_credito, 
				   s_notrx,
				   s_descripcion,
				   s_usuariocap,
				   s_usuarioact,
				   s_noreg,
				   s_res_origen,
				   s_debito,
				   s_credito,
				   s_auxiliar
			  from sac:cglresumen a, sac:cglresumen1 c
			 where a.res_noregistro = c.res1_noregistro
			   and a.res_fechatrx  >= a_fecha1
			   and a.res_fechatrx  <= a_fecha2
			   and a.res_cuenta    = '26410'
			   and c.res1_cuenta   = '26410'
			   and c.res1_auxiliar = _cod_tercero
			 order by a.res_noregistro

			let s_comprobante = trim(s_comprobante);
			if s_comprobante = 'CIERRE'	then
				continue foreach;
			end if	

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
			LET s_nauxiliar = "";
			LET _tiene_aux = 0;
			
			if s_res_origen = 'CGL' then  --es manual
				let _ind_tran = 'MAN';
			else
				let _ind_tran = 'AUT';
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
				 WHERE res1_noregistro = s_noreg
				   AND res1_cuenta = s_cuenta;

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

					SELECT trim(ter_descripcion) 
					  INTO s_nauxiliar
					  FROM sac:cglterceros
					 WHERE ter_codigo  = s_auxiliar;	
				
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
					user_act,
					nauxiliar,
					ind_tran
					)
					VALUES(
					_cia_comp,
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
					s_usuarioact,
					s_nauxiliar,
					_ind_tran);  
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
				user_act,
				nauxiliar,
				ind_tran
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
				s_usuarioact,
				s_nauxiliar,
				_ind_tran);  
			end if
		END FOREACH
		update deivid_tmp:data_aux_ter
		   set procesado = 1
		  where cod_tercero = _cod_tercero;
		  
		exit foreach;  
	end FOREACH
end if
end 
return 0, "Actualizacion Exitosa";
end procedure 