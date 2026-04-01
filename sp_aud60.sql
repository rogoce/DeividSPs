-- ******************************************
-- Creado : Armando Moreno Fecha :25/06/2024
-- ******************************************
--DROP PROCEDURE sp_aud60;
CREATE PROCEDURE sp_aud60(a_db char(18), a_fecha1 date, a_fecha2 date) 
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
			CHAR(3)		as tipo_tran;

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


SET ISOLATION TO DIRTY READ;

--generando archivo transaccional************************
call sp_aud18(a_db, a_fecha1, a_fecha2 ) returning _cia_comp,_cia_nom,s_cuenta,s_nombrecta,s_comprobante,s_tipcomp,s_auxiliar,_periodo,s_fechatrx,s_fechacap,
                                                   s_debito,s_credito,s_notrx,s_descripcion,s_usuariocap,s_usuarioact,_ind_tran;


END FOREACH;
drop table  tmp_aud; 
END PROCEDURE
  


	  