-- Procedure para sacar informacion de cglresumen / cglresumen1 para TTCORP
-- 
-- Creado    :04/04/2014 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud51bk3;
create procedure "informix".sp_aud51bk3(a_fecha_desde date, a_fecha_hasta date)
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


select *
  from cglresumen
 where res_fechatrx >= a_fecha_desde
   and res_fechatrx <= a_fecha_hasta
   and res_tipcomp <> '016'
  into temp prueba;

insert into deivid_ttcorp:tmp_cglresumen
select * from prueba;

drop table prueba;

select t.*
  from cglresumen c, cglresumen1 t
 where c.res_noregistro = t.res1_noregistro
   and c.res_fechatrx >= a_fecha_desde
   and c.res_fechatrx <= a_fecha_hasta
   and c.res_tipcomp <> '016'
  into temp prueba;

insert into deivid_ttcorp:tmp_cglresumen1
select * from prueba;

drop table prueba;

---******Carga de comprobantes de cobasien
--call sp_sac152a(a_fecha_desde, a_fecha_hasta) returning _error_cod,_error_desc;

return 0,  "Exitoso";

end

end procedure








