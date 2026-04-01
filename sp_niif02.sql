-- Deterioro de Cartera NIIF
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

--drop procedure sp_niif02;
create procedure "informix".sp_niif02(a_periodo2 char(7))
returning   char(20),
            varchar(50),
			char(2),
			char(2),
			char(1),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2);

define _error_desc		char(100);
define _periodo			char(7);
define _saldo			dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _dias_30_neto	dec(16,2);
define _dias_60_neto	dec(16,2);
define _dias_90120150	dec(16,2);
define _dias_180_neto	dec(16,2);
define _no_documento    char(20);
define _renglon         smallint;
define _cnt             smallint;
define _porc_coaseguro  decimal(7,4); 
define _mes             char(2);
define _mes_ini         integer;
define _mes_ini_char    char(7);
define a_periodo1       char(7);
define _no_poliza       char(10);
define _cod_tipoprod    char(3);
define _estatus_poliza  smallint;
define _cod_ramo        char(3);
define _n_ramo          varchar(50);
define _tiene_imp_ch    char(2);
define _estatus_char    char(1);
define _estado			char(2);
define _cod_grupo       char(5);
define _tiene_imp       smallint;

begin

{on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,'','','';
end exception}

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;

{ CREATE TEMP TABLE tmp_cobmo
           (no_documento     CHAR(20),
			saldo_neto	     DEC(16,2) default 0,
			por_vencer_neto	 DEC(16,2) default 0,
			corriente_neto	 DEC(16,2) default 0,
			dias_30_neto	 DEC(16,2) default 0,
			dias_60_neto	 DEC(16,2) default 0,
			dias_90120150_n	 DEC(16,2) default 0,
			dias_180_neto	 DEC(16,2) default 0,
			PRIMARY KEY(no_documento)) WITH NO LOG;}


let _saldo	       = 0;
let _por_vencer	   = 0;	
let _corriente	   = 0;	
let _dias_30_neto  = 0;	
let _dias_60_neto  = 0;	
let _dias_90120150 = 0;
let _dias_180_neto = 0;
let _renglon       = 0;
let _cnt           = 0;
let _porc_coaseguro = 0;


foreach

	select no_documento,
		   saldo_neto,
		   por_vencer_neto,
		   corriente_neto,
		   dias_30_neto,
		   dias_60_neto,
		   dias_90120150_n,
		   dias_180_neto,
		   aplica_imp,
		   n_ramo,
		   estatus,
		   estado
	  into _no_documento,
		   _saldo,
		   _por_vencer,
		   _corriente,
		   _dias_30_neto,
		   _dias_60_neto,
		   _dias_90120150,
		   _dias_180_neto,
		   _tiene_imp_ch,
		   _n_ramo,
		   _estatus_char,
		   _estado
	  from tmp_cobmo

   foreach
	select distinct no_documento,no_poliza
	  into _no_documento,_no_poliza
      from deivid_cob:cobmoros2
	 where no_documento = _no_documento

	exit foreach;
   end foreach

	select cod_grupo
	  into _cod_grupo
	  from deivid:emipomae
	 where no_poliza = _no_poliza;

    if _cod_grupo = '1000' then  --Grupo del estado

        update tmp_cobmo
		   set estado = 'SI'
		 where no_documento = _no_documento;

	end if


	return _no_documento,
	       _n_ramo,
	       _tiene_imp_ch,
	       _estado,
	       _estatus_char,
	       _saldo,
	       _por_vencer,
	       _corriente,
	       _dias_30_neto,
	       _dias_60_neto,
	       _dias_90120150,
	       _dias_180_neto with resume;

end foreach

end
end procedure