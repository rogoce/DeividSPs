--**********************************
-- Creado : Henry Giron Fecha : 16/09/2010
-- execute procedure sp_aud18("*","01/01/2010","31/03/2010")
-- Totales de control
-- *********************************
DROP PROCEDURE sp_aud19a;
CREATE PROCEDURE sp_aud19a(a_db char(18), a_fecha1 date, a_fecha2 date,a_tipo smallint) 
RETURNING   CHAR(3),	--cia_comp,
			char(50),	--cia_nom,
			DEC(15,2),	--debito,
			DEC(15,2);	--credito,

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
 
SET ISOLATION TO DIRTY READ;

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
		ind_tran        CHAR(3)   -- faltaba esta columna
		) WITH NO LOG; 	
 
SET ISOLATION TO DIRTY READ;

IF a_db = "*" THEN
   foreach 
	select trim(cia_bda_codigo)
	  into a_db_1
	  from sigman02
	 where cia_bda_codigo <> "000"

		call sp_aud17(a_db_1, a_fecha1, a_fecha2 ) returning _error, _error_desc;

	end foreach
ELSE
	call sp_aud17(a_db, a_fecha1, a_fecha2 ) returning _error, _error_desc;
END IF 



if a_tipo = 1 then

	FOREACH	
	 select cia,             
			ncia,            
			sum(debito),          
			sum(credito)
	   into	_cia_comp,
			_cia_nom,
		    s_debito,
			s_credito
	   from tmp_aud
	   group by 1,2


	  RETURN _cia_comp,
			 _cia_nom,
			 s_debito,
			 s_credito
	    	 WITH RESUME;

	END FOREACH;

else

FOREACH	
 select cia,             
		ncia,            
		cta,             
		ncta,            
		sum(debito),          
		sum(credito)
   into	_cia_comp,
		_cia_nom,
		s_cuenta,
		s_nombrecta,
		s_debito,
		s_credito
   from tmp_aud
  group by 1,2,3,4


  RETURN _cia_comp,
		 _cia_nom,
		 s_debito,
		 s_credito
    	 WITH RESUME;

END FOREACH;

end if

drop table  tmp_aud; 


END PROCEDURE