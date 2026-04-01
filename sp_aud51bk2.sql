-- Procedure para sacar informacion de cglresumen / cglresumen1 para TTCORP
-- Creado    :04/04/2014 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_aud51bk2;
create procedure "informix".sp_aud51bk2()
 returning integer,  varchar(100); 

define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;
define _transaccion			char(50);

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, trim(_error_desc) || " " || _transaccion;
end exception

--SET DEBUG FILE TO "sp_aud51.trc";
--trace on;

delete from deivid_ttcorp:tmp_cglresumen;
delete from deivid_ttcorp:tmp_cglresumen1;

let _transaccion = "";
select *
  from cglresumen
where res_fechatrx >= '01/10/2016'
   and res_fechatrx <= '31/10/2016'
   and res_tipcomp <> '016'
   and res_notrx >= '776384'
  into temp prueba;

insert into deivid_ttcorp:tmp_cglresumen
select * from prueba;

drop table prueba;

select t.*
  from cglresumen1 t
 where res1_noregistro in(4190579,4190580,4190581,4190582,4199922,4199923,4199924,4199925,4208023,4208024,4208025,4208026,4208027,4208028,4208029)
  into temp prueba;

insert into deivid_ttcorp:tmp_cglresumen1
select * from prueba;

drop table prueba;

---******Carga de comprobantes de cobasien

--call sp_sac152a(a_fecha_desde, a_fecha_hasta) returning _error_cod,_error_desc;

return 0,  "Exitoso";

end

end procedure








