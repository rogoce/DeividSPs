-- **********************************
-- Creado : Henry Giron Fecha : 16/09/2010
-- execute procedure sp_aud18("*","01/01/2010","31/03/2010")
-- *********************************
DROP PROCEDURE sp_compro;
CREATE PROCEDURE sp_compro(a_db char(18), a_fecha1 date, a_fecha2 date) 
RETURNING   CHAR(3)		as cod_compania,	--cia_comp,
			char(50)	as nom_compania,	--cia_nom,
			CHAR(12)	as cuenta,			--cuenta,
			char(50)	as nom_cuenta,		--nombrecta,
			CHAR(15)	as comprobante,		--comprobante,
			CHAR(3)		as tipo_comp,		--tipcomp,    
			CHAR(5)		as auxiliar,		--auxiliar,
			CHAR(7)		as periodo,			--periodo,
			DATE		as fecha_trx,		--fechatrx,
			DATE		as fecha_cap,		--fechacap,
			DEC(15,2)	as db,				--debito,
			DEC(15,2)	as cr,				--credito,
			INTEGER		as notrx,			--notrx,
			CHAR(50)	as descripcion,		--descripcion,
			CHAR(15)	as usuario_cap,		--usuariocap,
			CHAR(15)	as usuario_act,		--usuarioact
			CHAR(3)		as tipo_tran,
			CHAR(10)    as no_requis,
			CHAR(5)     as cod_agente,
			DEC(15,2)	as db_rq,				--debito,
			DEC(15,2)	as cr_rq,				--credito,
			CHAR(12)	as cuenta_2,   
			DEC(15,2)	as db_rq2,				--debito,
			DEC(15,2)	as cr_rq2;				--credito,
			

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
define _error			integer;
define _error_desc		char(50);
define s_sep            char(1);
define a_db_1           char(18);
define s_desc_concepto  char(30);
define s_n_tipo			char(50);
define s_n_aux			char(50);
define s_nauxiliar      char(35);
define _ind_tran        char(3);
define _no_requis       char(10);
define _cod_agente      char(5);
define _debito          dec(15,2);
define _credito         dec(15,2);
define _cod_cuenta      char(12);
define _debito2          dec(15,2);
define _credito2        dec(15,2);

CREATE TEMP TABLE tmp_aud(
	    cia             char(3),
		ncia            char(50),
		cta             CHAR(12),
		ncta            char(50),
		comp            CHAR(15),
		tipo            CHAR(3),
		ntipo           CHAR(30),
		aux				CHAR(5),
		anio_mes 		CHAR(7),
		fechatrx		DATE,
		fechaval		DATE,
		debito          DEC(16,2)	default 0,
		credito        	DEC(16,2)	default 0,
		notrx           INTEGER,
		descripcion     CHAR(50),
		user_cap  		CHAR(15),
		user_act  		CHAR(15),
		nauxiliar       CHAR(35),
		ind_tran        CHAR(3)
		) WITH NO LOG; 	
 
SET ISOLATION TO DIRTY READ;

IF a_db = "*" THEN
   foreach 
	select trim(cia_bda_codigo)
	  into a_db_1
	  from sigman02
	 where cia_bda_codigo <> "000"

		call ap_comprobantes(a_db_1, a_fecha1, a_fecha2 ) returning _error, _error_desc;

	end foreach
ELSE
	call ap_comprobantes(a_db, a_fecha1, a_fecha2 ) returning _error, _error_desc;
END IF

FOREACH	
 select cia,             
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
   into	_cia_comp,
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
		_ind_tran
   from tmp_aud

		let s_n_tipo = trim(s_desc_concepto)||" - "||trim(s_tipcomp);
		let s_n_aux  = trim(s_nauxiliar)||" - "||trim(s_auxiliar);
		
	let _no_requis = null;
	let _cod_agente = null;
	let _debito = null;
	let _credito = null;
	let _cod_cuenta = null;
	let _debito2 = null;
	let _credito2 = null;
		
 { select a.no_requis,
         a.cod_agente,
		 sum(c.debito),
		 sum(c.credito)
	into _no_requis,
	     _cod_agente,
		 _debito,
		 _credito
	from chqchmae a, chqchcta b, chqctaux c
   where a.no_requis = b.no_requis
     and b.no_requis = c.no_requis
	 and b.renglon = c.renglon
	 and b.sac_notrx = s_notrx
	 and c.cuenta = s_cuenta
	 and c.cod_auxiliar = s_auxiliar
	 and a.no_requis in (
	 '906835',
     '906835',
	'906837',
	'906837',
	'908203',
	'908203',
	'909426',
	'909426',
	'909861',
	'909961',
	'911516',
	'911517',
	'913040',
	'923895',
	'924284',
	'925735',
	'924050',
	'924274',
	'924359',
	'925675',
	'925755',
	'926994',
	'924047',
	'924114',
	'923823',
	'924326',
	'923810',
	'924276',
	'925458',
	'926829',
	'923625',
	'923756',
	'924248',
	'926829',
	'924000',
	'924259',
	'926966',
	'923778',
	'923823',
	'928220',
	'928293',
	'928293',
	'923756',
	'923829',
	'924325',
	'924326',
	'926994',
	'924000',
	'924356',
	'925425',
	'933778',
	'929064',
	'932426',
	'929261',
	'931336',
	'932476',
	'931510',
	'934122',
	'932391',
	'936741') group by a.no_requis, a.cod_agente;
 }
 
   select a.no_requis,
         a.cod_agente,
		 sum(c.debito),
		 sum(c.credito)
	into _no_requis,
	     _cod_agente,
		 _debito,
		 _credito
	from chqchmae a, chqchcta b, chqctaux c
   where a.no_requis = b.no_requis
     and b.no_requis = c.no_requis
	 and b.renglon = c.renglon
	 and b.sac_notrx = s_notrx
	 and c.cuenta = s_cuenta
	 and c.cod_auxiliar = s_auxiliar
 group by a.no_requis, a.cod_agente;
 
 if _no_requis is not null then 
  select b.cuenta,
		 sum(b.debito),
		 sum(b.credito)
	into _cod_cuenta,
		 _debito2,
		 _credito2
	from chqchmae a, chqchcta b
   where a.no_requis = b.no_requis
 	 and b.sac_notrx = s_notrx
	 and a.no_requis = _no_requis 
	 and b.cuenta <> '26410'
	 group by b.cuenta;
	
end if
	

  RETURN _cia_comp,
		 _cia_nom,
		 s_cuenta,
		 s_nombrecta,
		 s_comprobante,
		 s_tipcomp,         
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
		 _ind_tran,
         _no_requis,
	     _cod_agente,
		 _debito,
		 _credito,
		 _cod_cuenta,
		 _debito2,
		 _credito2
    	 WITH RESUME;

END FOREACH;

drop table  tmp_aud; 

END PROCEDURE
  


	  