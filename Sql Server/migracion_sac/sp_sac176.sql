--**********************************
-- Procedimiento que genera el reporte de auditoria
-- Creado : Henry Giron Fecha : 02/03/2010
-- execute procedure sp_sac176("*","01/01/2010","31/01/2010")
-- d_sac_sp_sac176_dw1
-- *********************************
DROP PROCEDURE sp_sac176;

CREATE PROCEDURE sp_sac176(a_db char(18), a_fecha1 date, a_fecha2 date) 
RETURNING   CHAR(3),
			char(50),
			CHAR(12),
			char(50),
			CHAR(15),
			CHAR(3),
			CHAR(30),
			CHAR(5),
			CHAR(7),
			DATE,
			DATE,
			DEC(15,2),
			DEC(15,2),
			INTEGER,
			CHAR(50),
			CHAR(15),
			CHAR(15);

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
		debito          DEC(15,2)	default 0,
		credito        	DEC(15,2)	default 0,
		notrx           INTEGER,
		descripcion     CHAR(50),
		user_cap  		CHAR(15),
		user_act  		CHAR(15)
		) WITH NO LOG; 	

{1.	Número de Cuenta
2.	Nombre de la cuenta
3.	Número de comprobante
4.	Tipo de Transacción
5.	Código Auxiliar
6.	Año Mes
7.	Fecha de la transacción
8.	Fecha de valor de la transacción
9.	Débito
10.	Crédito
11.	Número de la Transacción
12.	Descripción
13.	Usuario que ingresa la transacción
14.	Usuario que autoriza la transacción}

 
SET ISOLATION TO DIRTY READ;

IF a_db = "*" THEN
   foreach 
	select trim(cia_bda_codigo)
	  into a_db_1
	  from sigman02
	 where cia_bda_codigo <> "000"

		call sp_sac178(a_db_1, a_fecha1, a_fecha2 ) returning _error, _error_desc;

	end foreach
ELSE
	call sp_sac178(a_db, a_fecha1, a_fecha2 ) returning _error, _error_desc;
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
		user_act 
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
		s_usuarioact   
   from tmp_aud

  RETURN _cia_comp,
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
    	 WITH RESUME;

END FOREACH;

drop table  tmp_aud; 

END PROCEDURE
  