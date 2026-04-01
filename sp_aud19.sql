--**********************************
-- Creado : Henry Giron Fecha : 16/09/2010
-- execute procedure sp_aud18("*","01/01/2010","31/03/2010")
-- Totales de control
-- *********************************
drop procedure sp_aud19;
create procedure sp_aud19(a_db char(18), a_fecha1 date, a_fecha2 date,a_tipo smallint) 
returning   char(3) as cod_compania,	--cia_comp,
			char(50)as cia_nombre,	--cia_nom,
			char(12)as cuenta,	--cuenta,
			char(50)as nombre_cuenta,	--nombrecta,
			dec(15,2)as db,	--debito,
			dec(15,2)as cr;	--credito,

define s_descripcion	char(50);
define s_nombrecta		char(50);
define _error_desc		char(50);
define _cia_nom			char(50);
define s_n_tipo			char(50);
define s_n_aux			char(50);
define s_nauxiliar		char(35);
define s_desc_concepto	char(30);
define a_db_1			char(18);
define s_cuenta			char(12);
define s_comprobante	char(15);
define s_usuariocap		char(15);
define s_usuarioact		char(15);
define _periodo			char(7);
define s_auxiliar		char(5);
define _ano_char		char(4);
define s_tipcomp		char(3);
define _mes_char		char(2);
define s_sep			char(1);
define _cia_comp		char(3);
define s_debito			dec(15,2);
define s_credito		dec(15,2); 
define s_notrx			integer;
define s_month			integer;
define _error			integer;
define s_year			integer;
define s_fechacap		date;
define s_fechatrx		date;

create temp table tmp_aud(
cia             char(3),
ncia            char(50),
cta             char(12),
ncta            char(50),
comp            char(15),
tipo            char(3),
ntipo           char(30),
aux				char(5),
anio_mes 		char(7),
fechatrx		date,
fechaval		date,
debito          dec(16,2)	default 0,
credito        	dec(16,2)	default 0,
notrx           integer,
descripcion     char(50),
user_cap  		char(15),
user_act  		char(15),
nauxiliar       char(35),
ind_tran        char(3)) with no log; 	
 
set isolation to dirty read;

if a_db = "*" then
	foreach 
		select trim(cia_bda_codigo)
		  into a_db_1
		  from sigman02
		 where cia_bda_codigo <> "000"

		call sp_aud17(a_db_1, a_fecha1, a_fecha2 ) returning _error, _error_desc;
	end foreach
else
	call sp_aud17(a_db, a_fecha1, a_fecha2 ) returning _error, _error_desc;
end if 

if a_tipo = 1 then
	foreach
		select cia,             
			   ncia,
			   sum(debito),
			   sum(credito)
		  into _cia_comp,
			   _cia_nom,
			   s_debito,
			   s_credito
		  from tmp_aud
		 group by 1,2

		return	_cia_comp,
				_cia_nom,
				"",
				"",
				s_debito,
				s_credito with resume;
	end foreach;
else
	foreach	
		select cia,
			   ncia,
			   cta,
			   ncta,
			   sum(debito),
			   sum(credito)
		  into _cia_comp,
			   _cia_nom,
			   s_cuenta,
			   s_nombrecta,
			   s_debito,
			   s_credito
		  from tmp_aud
		 group by 1,2,3,4

		return	_cia_comp,
				_cia_nom,
				s_cuenta,
				s_nombrecta,
				s_debito,
				s_credito with resume;
	end foreach;
end if
drop table  if exists tmp_aud; 
end procedure;  