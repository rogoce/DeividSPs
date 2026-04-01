-- Deterioro de Cartera NIIF
--
-- creado    : 27/02/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_niif05;
create procedure "informix".sp_niif05(a_periodo1 char(7), a_periodo2 char(7))
returning smallint;

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

begin

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;




insert into deivid:cobmoros2
select * 
  from deivid_cob:cobmoros2
 where periodo >= a_periodo1
   and periodo <= a_periodo2;



end
end procedure