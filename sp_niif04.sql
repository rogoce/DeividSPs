-- Deterioro de Cartera NIIF con cliente
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_niif04;
create procedure "informix".sp_niif04()
returning   char(20),
            char(10),
            varchar(50),
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
			dec(16,2),
			dec(16,2);

define _error_desc		char(100);
define _periodo			char(7);
define _saldo			dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _dias_30_neto	dec(16,2);
define _dias_60_neto	dec(16,2);
define _dias_90_neto	dec(16,2);
define _dias_120_neto	dec(16,2);
define _150180_neto		dec(16,2);
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
define _vig_fin         date;
define _cod_contratante  char(10);
define _n_cliente        varchar(50);


begin

{on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,'','','';
end exception}

set isolation to dirty read;

let _saldo	        = 0;
let _por_vencer	    = 0;	
let _corriente	    = 0;	
let _dias_30_neto   = 0;	
let _dias_60_neto   = 0;	
let _dias_90_neto   = 0;
let _dias_120_neto  = 0;
let _150180_neto    = 0;
let _renglon        = 0;
let _cnt            = 0;
let _porc_coaseguro = 0;
let _n_cliente      = "";
let _cod_contratante = null;


foreach

	select no_documento,
		   saldo_neto,
		   por_vencer_neto,
		   corriente_neto,
		   dias_30_neto,
		   dias_60_neto,
		   dias_90_neto,
		   dias_120_neto,
		   masde120_neto,
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
		   _dias_90_neto,
		   _dias_120_neto,
		   _150180_neto,
		   _tiene_imp_ch,
		   _n_ramo,
		   _estatus_char,
		   _estado
	  from tmp_cobmo

   foreach
	select cod_contratante
	  into _cod_contratante
	  from deivid:emipomae
	 where no_documento = _no_documento
	  
	exit foreach;
   end foreach

   select nombre
     into _n_cliente
	 from deivid:cliclien
	where cod_cliente = _cod_contratante;

	return _no_documento,
	       _cod_contratante,
		   _n_cliente,
	       _n_ramo,
	       _tiene_imp_ch,
	       _estado,
	       _estatus_char,
	       _saldo,
	       _por_vencer,
	       _corriente,
	       _dias_30_neto,
	       _dias_60_neto,
		   _dias_90_neto,
		   _dias_120_neto,
		   _150180_neto with resume;

end foreach

end
end procedure